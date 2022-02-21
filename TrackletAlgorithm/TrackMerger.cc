#include "TrackMerger.h"
#include "TrackHandler.cc"
#include <bitset>

void ComparisonModule::inputTrack(const TrackHandler track){ 
  #pragma HLS inline
  // put tracks into buffer
  if(track.getTrackWord() == 0){
    endOfStream = 1;
   //std::cout << "endOfStream: " << endOfStream << std::endl;
  } else {
    endOfStream = 0;
    assert(writeIndex < bufferSize);
    inputBuffer[writeIndex] = track;
    if (writeIndex == 0){
      masterTrack = track;
      #ifndef _SYNTHESIS_
      // std::cout << "Module#: " << myIndex << " InputTrack#: " << writeIndex << " " << " masterTrack: " << masterTrack.getTrackWord() << " track: " << track.getTrackWord() << "\n";
      #endif
    }
    writeIndex++;
  }

}
void ComparisonModule::processTrack(){
  #pragma HLS inline
  #pragma HLS pipeline
  if(endOfStream == 0){
    if (myIndex == 0){
      masterTrack.setDebugFlag(1);
    } else {
      masterTrack.setDebugFlag(0);
    }
    if(masterTrack.getTrackWord() != track.getTrackWord()){
      masterTrack.CompareTrack(track);
      // masterTrack.MergeTrack(track, matchFound, mergeCondition);
    }
    tracksProcessed++;
  }
}

void ComparisonModule::getTrack(){
  #pragma HLS inline
  track = inputBuffer[readIndex];
  readIndex++;
}

void ComparisonModule::endEvent(TrackHandler outputBuffer[16], unsigned int outputWriteIndex){
  #pragma HLS inline
  if(endOfStream == 1 && tracksProcessed == writeIndex){
    endOfModule = 1;
    #ifndef _SYNTHESIS_
    // std::cout << "endOfStream: " << endOfStream << " tracksProcessed: " << tracksProcessed << " writeIndex: " << writeIndex << " endEvent track: " << masterTrack.getTrackWord() << std::endl;
    #endif
    outputBuffer[outputWriteIndex] = masterTrack;
    #ifndef _SYNTHESIS_
    // std::cout << "masterTrack to output: " << outputBuffer[outputWriteIndex].getTrackWord() << std::endl;
    #endif
    writeIndex = 0;
    readIndex = 0;
  }
}

// overall module only reads in a track and pass it to the comparison module
void TrackMerger(const BXType bx,
  const TrackFit::TrackWord trackWord [kMaxProc],
  const TrackFit::BarrelStubWord barrelStubWords[4][kMaxProc],
  const TrackFit::DiskStubWord diskStubWords[4][kMaxProc],
  BXType &bx_o, 
  TrackFit::TrackWord trackWord_o[kMaxProc],
  TrackFit::BarrelStubWord barrelStubWords_o[4][kMaxProc],
  TrackFit::DiskStubWord diskStubWords_o[4][kMaxProc],
  int &outputNumber
  ){
    #pragma HLS array_partition variable=barrelStubWords complete dim=1
    #pragma HLS array_partition variable=diskStubWords complete dim=1
    #pragma HLS array_partition variable=barrelStubWords_o complete dim=1
    #pragma HLS array_partition variable=diskStubWords_o complete dim=1

    ComparisonModule comparisonModule[kNComparisonModules];
    unsigned int outputIndex{0};
    unsigned int unmergedOutputIndex{0};
    LOOP_ModuleIndex:
    for(unsigned int nModule = 0; nModule < kNComparisonModules; nModule++)
    {
      #pragma HLS unroll
      comparisonModule[nModule].myIndex=nModule;
    }
    TrackHandler outputBuffer[kNComparisonModules];
    unsigned int nActiveModules = 1;
    unsigned int modulesToRun[kNComparisonModules];
    modulesToRun[0] = 1;
    TrackFit::TrackWord unmergedTracks[kMaxProc];
    TrackFit::BarrelStubWord unmergedBarrelStubs[4][kMaxProc];
    TrackFit::DiskStubWord unmergedDiskStubs[4][kMaxProc];
    
    LOOP_InputProc:
    for (int i = 0; i < kMaxProc; i++){ 
      #ifndef _SYNTHESIS_
      // std::cout << "Step#: " << i << " masterTrackWord: " << trackWord[i] << " brl1: "<< barrelStubWords[0][i] << " brl2: " << barrelStubWords[1][i] << " brl3: " << barrelStubWords[2][i] << " brl4: " << barrelStubWords[3][i] << std::endl;
      #endif
      unsigned int moduleEnd{0};
      LOOP_ModuleEndFlag:
      for (unsigned int activeModule = 0; activeModule < kNComparisonModules; activeModule++){
        #pragma HLS unroll
        if(comparisonModule[activeModule].getEndOfModule() == 1){
          moduleEnd++;
        }
      } 
      if(moduleEnd == kNComparisonModules){continue;}

      TrackFit::BarrelStubWord barrelStubWordsArray[4];
      TrackFit::DiskStubWord diskStubWordsArray[4];
      for(unsigned int layerIndex = 0; layerIndex < 4; layerIndex++){
        #pragma HLS unroll
        barrelStubWordsArray[layerIndex] = barrelStubWords[layerIndex][i];
        diskStubWordsArray[layerIndex] = diskStubWords[layerIndex][i];
      }

      // TrackFit::BarrelStubWord barrelStubWordsArray[4] = {barrelStubWords[0][i], barrelStubWords[1][i], barrelStubWords[2][i], barrelStubWords[3][i]};
      // TrackFit::DiskStubWord diskStubWordsArray[4] = {diskStubWords[0][i], diskStubWords[1][i], diskStubWords[2][i], diskStubWords[3][i]};
      TrackHandler track(trackWord[i], barrelStubWordsArray, diskStubWordsArray);

      // run active modules 
      // local array to keep track of which modules have been activated
      unsigned int activeModules[kNComparisonModules];
      LOOP_ActiveModule:
      for(unsigned int activeModule = 0; activeModule < kNComparisonModules; activeModule++) //might not be able to unroll as processing 
      { 
        // if module has yet to be activated, carry on 
        if(modulesToRun[activeModule] == 0){ 
          continue;
        }
        activeModules[activeModule] = 1;
        // if it is active,  process this track 
        comparisonModule[activeModule].inputTrack(track);
        comparisonModule[activeModule].getTrack();
        comparisonModule[activeModule].processTrack();
        comparisonModule[activeModule].endEvent(outputBuffer, activeModule);

        // if it's the last Comparison Module 
        // nothing to pass an unmatched track to
        if(activeModule == kNComparisonModules-1) continue;
        // if the next Comparison Module is inactive 
        // and a mismatch has been found 
        // next comparison module also processes this track
        if(modulesToRun[activeModule+1] == 0 && comparisonModule[activeModule].getMatchFound() == 0 && comparisonModule[activeModule].getNProcessed() >1) //might not be able to unroll
        { 
          #ifndef _SYNTHESIS_
          // std::cout << "Activating Module# " << activeModule+1 << " trackWord: " << trackWord[i] << std::endl;
          #endif

          comparisonModule[activeModule+1].inputTrack(track);
          comparisonModule[activeModule+1].getTrack();
          comparisonModule[activeModule+1].processTrack();
          comparisonModule[activeModule+1].endEvent(outputBuffer, activeModule);
          activeModules[activeModule+1] = 1;
        }
      }
      
      // update global array that keeps track of which modules have been activated 
      LOOP_ModulesToRun:
      for(unsigned int activeModule = 0; activeModule < kNComparisonModules; activeModule++)
      {
        #pragma HLS unroll
        modulesToRun[activeModule] = activeModules[activeModule];
      }

      //output the master track from each comparison module as the output array
      //also outputs any unmerged tracks from the last comparison module 
      LOOP_LastCMOut:
      for(unsigned int activeModule = 0; activeModule < kNComparisonModules; activeModule++){
        #pragma HLS unroll
        if(activeModules[activeModule] == 0){continue;}
        // if am not the last comparison module - when finished processing, output the master track
        if(comparisonModule[activeModule].getEndOfModule() == 1){
          trackWord_o[outputIndex] = comparisonModule[activeModule].getMasterTrackWord();
          LOOP_OutputStubWords:
          for (unsigned int layerIndex = 0; layerIndex < 4; layerIndex++){
            #pragma HLS unroll
            barrelStubWords_o[layerIndex][outputIndex] = comparisonModule[activeModule].getMasterTrackBarrelStubs(0, layerIndex);
            diskStubWords_o[layerIndex][outputIndex] = comparisonModule[activeModule].getMasterTrackDiskStubs(0, layerIndex);
          }  
          outputIndex++;
        }
        
        //if this is the last comparison module 
        //if it has found no duplicates - output this track (to keep track of unmerged tracks)
        //or if the module has finished processing tracks, output the master
        if(activeModule == kNComparisonModules-1 && comparisonModule[activeModule].getMatchFound() == 0 && comparisonModule[activeModule].getNProcessed() >1){
        // fill the outputs with the trackWord, barrel and disk stubs
          unmergedTracks[unmergedOutputIndex] = trackWord[i];
          LOOP_UnmergedStubs:
          for (unsigned int arrayIndex = 0; arrayIndex < 4; arrayIndex++){
            #pragma HLS unroll
            unmergedBarrelStubs[arrayIndex][unmergedOutputIndex] = barrelStubWords[arrayIndex][i];
            unmergedDiskStubs[arrayIndex][unmergedOutputIndex] = diskStubWords[arrayIndex][i];
            #ifndef _SYNTHESIS_
            // std::cout << "UnmergedbrlStubs: " << barrelStubWords[arrayIndex][i] << " UnmergeddiskStubs: " << diskStubWords[arrayIndex][i] << std::endl;
            #endif
          }
          unmergedOutputIndex++;
        }
        
      }
    }
    #ifndef _SYNTHESIS_
    //  std::cout << "outputBuffer: " << outputBuffer[0].getTrackWord() << " firstTrackWord: " << trackWord[0] << "\n";
    #endif
    for(unsigned int activeModule = 0; activeModule < kNComparisonModules; activeModule++)
    {
      #ifndef _SYNTHESIS_
        // std::cout << "\t\tModule#" << activeModule << " active " << modulesToRun[activeModule] << std::endl;
      #endif
    }
    bx_o = bx;
    outputNumber = outputIndex + unmergedOutputIndex;
    LOOP_OutputUnmergedTrackWord:
    for (unsigned int i = 0; i < kMaxProc; i++){
      #pragma HLS unroll
      if(i >= unmergedOutputIndex) continue;
      trackWord_o[outputIndex+i] = unmergedTracks[i];
      LOOP_OutputUnmergedStubWords:
      for (unsigned int j = 0; j < 4; j++){
        #pragma HLS unroll
        barrelStubWords_o[j][outputIndex+i] = unmergedBarrelStubs[j][i];
        diskStubWords_o[j][outputIndex+i] = unmergedDiskStubs[j][i];
        #ifndef _SYNTHESIS_
        // std::cout << "j: " << j << " UnmergedBrlStubs: " << unmergedBarrelStubs[j][i] << std::endl;
        // std::cout << "j: " << j << " UnmergedDiskStubs: " << unmergedDiskStubs[j][i] << std::endl;
        #endif
      }
    }
    #ifndef _SYNTHESIS_
    // std::cout << "outputNumber: " << outputNumber << std::endl;
    // std::cout << "no. trackWords: " << outputIndex << std::endl;
    // for (unsigned int trackNumber = 0; trackNumber < outputIndex; trackNumber++){
    //   std::cout << "trackWord: " << trackWord[trackNumber] << " trackNumber: " << trackNumber << std::endl;
    // }
    #endif
}