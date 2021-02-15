// ProjectionRouter test bench
#include "MatchProcessorTopL3.h"
#include "CandidateMatchMemory.h"
#include "VMProjectionMemory.h"
#include "ProjectionRouterBuffer.h"
#include "VMStubMEMemoryCM.h"
#include "FileReadUtility.h"
#include "hls_math.h"

#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <iterator>


const int nevents = 1;  // number of events to run

using namespace std;



int main() {
  // error counter
  int err_count = 0;

  // input memories
  static TrackletProjectionMemory<BARRELPS> tprojarray[maxTrackletProjections];
  static TrackletProjectionMemory<BARRELPS> tproj1;
  static TrackletProjectionMemory<BARRELPS> tproj2;
  static TrackletProjectionMemory<BARRELPS> tproj3;
  static TrackletProjectionMemory<BARRELPS> tproj4;
  static TrackletProjectionMemory<BARRELPS> tproj5;
  static TrackletProjectionMemory<BARRELPS> tproj6;
  static TrackletProjectionMemory<BARRELPS> tproj7;
  static TrackletProjectionMemory<BARRELPS> tproj8;
  static AllStubMemory<BARRELPS>        allstub;
  static AllProjectionMemory<BARRELPS>  allproj;

  VMStubMEMemoryCM<BARRELPS,3,3> inputvmstubs1;
  VMStubMEMemoryCM<BARRELPS,3,3> inputvmstubs2;
  VMStubMEMemoryCM<BARRELPS,3,3> inputvmstubs3;
  VMStubMEMemoryCM<BARRELPS,3,3> inputvmstubs4;
  VMStubMEMemoryCM<BARRELPS,3,3> inputvmstubs5;
  VMStubMEMemoryCM<BARRELPS,3,3> inputvmstubs6;
  VMStubMEMemoryCM<BARRELPS,3,3> inputvmstubs7;
  VMStubMEMemoryCM<BARRELPS,3,3> inputvmstubs8;

  // declare output memory array to be filled by hls simulation
  static FullMatchMemory<BARREL> fullmatch[maxFullMatchCopies];

  ap_uint<8>* valid;

  // open input files
  cout << "Open files..." << endl;

  ifstream fin_tproj1;
  ifstream fin_tproj2;
  ifstream fin_tproj3;
  ifstream fin_tproj4;
  ifstream fin_tproj5;
  ifstream fin_tproj6;
  ifstream fin_tproj7;
  ifstream fin_tproj8;
  ifstream fin_as;
  ifstream fout_ap;

  if (not openDataFile(fin_tproj1, "MP/TrackletProjections_TPROJ_L1L2F_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj2, "MP/TrackletProjections_TPROJ_L1L2G_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj3, "MP/TrackletProjections_TPROJ_L1L2H_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj4, "MP/TrackletProjections_TPROJ_L1L2I_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj5, "MP/TrackletProjections_TPROJ_L1L2J_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj6, "MP/TrackletProjections_TPROJ_L5L6B_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj7, "MP/TrackletProjections_TPROJ_L5L6C_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj8, "MP/TrackletProjections_TPROJ_L5L6D_L3PHIC_04.dat")) return -1;
  /*
  if (not openDataFile(fin_tproj1, "PR/PR_L3PHIC/TrackletProjections_TPROJ_L1L2F_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj2, "PR/PR_L3PHIC/TrackletProjections_TPROJ_L1L2G_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj3, "PR/PR_L3PHIC/TrackletProjections_TPROJ_L1L2H_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj4, "PR/PR_L3PHIC/TrackletProjections_TPROJ_L1L2I_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj5, "PR/PR_L3PHIC/TrackletProjections_TPROJ_L1L2J_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj6, "PR/PR_L3PHIC/TrackletProjections_TPROJ_L5L6B_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj7, "PR/PR_L3PHIC/TrackletProjections_TPROJ_L5L6C_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fin_tproj8, "PR/PR_L3PHIC/TrackletProjections_TPROJ_L5L6D_L3PHIC_04.dat")) return -1;
  */

  ifstream fin_vmstub1, fin_vmstub2, fin_vmstub3, fin_vmstub4, fin_vmstub5, fin_vmstub6, fin_vmstub7, fin_vmstub8;
  /*
  bool validvmstub1 = openDataFile(fin_vmstub1,"MP/MP_L3PHIC17/VMStubs_VMSME_L3PHIC17n1_04.dat");
  bool validvmstub2 = openDataFile(fin_vmstub2,"MP/MP_L3PHIC18/VMStubs_VMSME_L3PHIC18n1_04.dat");
  bool validvmstub3 = openDataFile(fin_vmstub3,"MP/MP_L3PHIC19/VMStubs_VMSME_L3PHIC19n1_04.dat");
  bool validvmstub4 = openDataFile(fin_vmstub4,"MP/MP_L3PHIC20/VMStubs_VMSME_L3PHIC20n1_04.dat");
  bool validvmstub5 = openDataFile(fin_vmstub5,"MP/MP_L3PHIC21/VMStubs_VMSME_L3PHIC21n1_04.dat");
  bool validvmstub6 = openDataFile(fin_vmstub6,"MP/MP_L3PHIC22/VMStubs_VMSME_L3PHIC22n1_04.dat");
  bool validvmstub7 = openDataFile(fin_vmstub7,"MP/MP_L3PHIC23/VMStubs_VMSME_L3PHIC23n1_04.dat");
  bool validvmstub8 = openDataFile(fin_vmstub8,"MP/MP_L3PHIC24/VMStubs_VMSME_L3PHIC24n1_04.dat");
  */
  bool validvmstub1 = openDataFile(fin_vmstub1,"MP/VMStubs_VMSME_L3PHICn1_04.dat");
  bool validvmstub2 = openDataFile(fin_vmstub2,"MP/VMStubs_VMSME_L3PHICn1_04.dat");
  bool validvmstub3 = openDataFile(fin_vmstub3,"MP/VMStubs_VMSME_L3PHICn1_04.dat");
  bool validvmstub4 = openDataFile(fin_vmstub4,"MP/VMStubs_VMSME_L3PHICn1_04.dat");
  bool validvmstub5 = openDataFile(fin_vmstub5,"MP/VMStubs_VMSME_L3PHICn1_04.dat");
  bool validvmstub6 = openDataFile(fin_vmstub6,"MP/VMStubs_VMSME_L3PHICn1_04.dat");
  bool validvmstub7 = openDataFile(fin_vmstub7,"MP/VMStubs_VMSME_L3PHICn1_04.dat");
  bool validvmstub8 = openDataFile(fin_vmstub8,"MP/VMStubs_VMSME_L3PHICn1_04.dat");
  if (not validvmstub1) return -1;
  if (not validvmstub2) return -1;
  if (not validvmstub3) return -1;
  if (not validvmstub4) return -1;
  if (not validvmstub5) return -1;
  if (not validvmstub6) return -1;
  if (not validvmstub7) return -1;
  if (not validvmstub8) return -1;

  /*
  if (not openDataFile(fin_as,"MC/MC_L3PHIC/AllStubs_AS_L3PHICn6_04.dat")) return -1;
  if (not openDataFile(fout_ap,"MC/MC_L3PHIC/AllProj_AP_L3PHIC_04.dat")) return -1;
  */
  if (not openDataFile(fin_as,"MP/AllStubs_AS_L3PHICn1_04.dat")) return -1;
  if (not openDataFile(fout_ap,"MC/MC_L3PHIC/AllProj_AP_L3PHIC_04.dat")) return -1;

  // open file(s) with reference results
  ifstream fout_fm1;
  ifstream fout_fm2;
  ifstream fout_fm3;
  ifstream fout_fm4;
  ifstream fout_fm5;
  ifstream fout_fm6;
  ifstream fout_fm7;

  //if (not openDataFile(fout_fm1,"MC/MC_L3PHIC/FullMatches_FM_L1L2_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fout_fm1,"MP/FullMatches_FM_L1L2_L3PHIC_04.dat")) return -1;
  //if (not openDataFile(fout_fm2,"MC/MC_L1PHIC/FullMatches_FM_L3L4_L1PHIC_04.dat")) return -1;
  //if (not openDataFile(fout_fm3,"MC/MC_L3PHIC/FullMatches_FM_L5L6_L3PHIC_04.dat")) return -1;
  if (not openDataFile(fout_fm3,"MP/FullMatches_FM_L5L6_L3PHIC_04.dat")) return -1;
  //if (not openDataFile(fout_fm4,"MC/MC_L1PHIC/FullMatches_FM_D1D2_L1PHIC_04.dat")) return -1;
  //if (not openDataFile(fout_fm5,"MC/MC_L1PHIC/FullMatches_FM_D3D4_L1PHIC_04.dat")) return -1;
  //if (not openDataFile(fout_fm6,"")) return -1;
  //if (not openDataFile(fout_fm7,"MC/MC_L1PHIC/FullMatches_FM_L2D1_L1PHIC_04.dat")) return -1;

  // loop over events
  for (int ievt = 0; ievt < nevents; ++ievt) {
    cout << "Event: " << dec << ievt << endl;

    allproj.clear();
    fullmatch[0].clear();
//    fullmatch[1].clear();
//    fullmatch[2].clear();
    fullmatch[3].clear();
//    fullmatch[4].clear();
//    fullmatch[5].clear();
//    fullmatch[6].clear();
//    fullmatch[7].clear();

    // read event and write to memories
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tproj1, fin_tproj1, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tproj2, fin_tproj2, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tproj3, fin_tproj3, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tproj4, fin_tproj4, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tproj5, fin_tproj5, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tproj6, fin_tproj6, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tproj7, fin_tproj7, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tproj8, fin_tproj8, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tprojarray[0], fin_tproj1, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tprojarray[1], fin_tproj2, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tprojarray[2], fin_tproj3, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tprojarray[3], fin_tproj4, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tprojarray[4], fin_tproj5, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tprojarray[5], fin_tproj6, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tprojarray[6], fin_tproj7, ievt);
    writeMemFromFile<TrackletProjectionMemory<BARRELPS> >(tprojarray[7], fin_tproj8, ievt);
    writeMemFromFile<AllStubMemory<BARRELPS> >(allstub, fin_as, ievt);
    //writeMemFromFile<AllProjectionMemory<BARRELPS> >(allproj, fin_ap, ievt);

    writeMemFromFile<VMStubMEMemoryCM<BARRELPS,3,3> >(inputvmstubs1, fin_vmstub1, ievt);
    writeMemFromFile<VMStubMEMemoryCM<BARRELPS,3,3> >(inputvmstubs2, fin_vmstub2, ievt);
    writeMemFromFile<VMStubMEMemoryCM<BARRELPS,3,3> >(inputvmstubs3, fin_vmstub3, ievt);
    writeMemFromFile<VMStubMEMemoryCM<BARRELPS,3,3> >(inputvmstubs4, fin_vmstub4, ievt);
    writeMemFromFile<VMStubMEMemoryCM<BARRELPS,3,3> >(inputvmstubs5, fin_vmstub5, ievt);
    writeMemFromFile<VMStubMEMemoryCM<BARRELPS,3,3> >(inputvmstubs6, fin_vmstub6, ievt);
    writeMemFromFile<VMStubMEMemoryCM<BARRELPS,3,3> >(inputvmstubs7, fin_vmstub7, ievt);
    writeMemFromFile<VMStubMEMemoryCM<BARRELPS,3,3> >(inputvmstubs8, fin_vmstub8, ievt);
    /* FIXME
    writeMemFromFile<VMStubMEMemory<BARRELPS,3> >(inputvmstubs[0], fin_vmstub1, ievt);
    writeMemFromFile<VMStubMEMemory<BARRELPS,3> >(inputvmstubs[1], fin_vmstub2, ievt);
    writeMemFromFile<VMStubMEMemory<BARRELPS,3> >(inputvmstubs[2], fin_vmstub3, ievt);
    writeMemFromFile<VMStubMEMemory<BARRELPS,3> >(inputvmstubs[3], fin_vmstub4, ievt);
    writeMemFromFile<VMStubMEMemory<BARRELPS,3> >(inputvmstubs[4], fin_vmstub5, ievt);
    writeMemFromFile<VMStubMEMemory<BARRELPS,3> >(inputvmstubs[5], fin_vmstub6, ievt);
    writeMemFromFile<VMStubMEMemory<BARRELPS,3> >(inputvmstubs[6], fin_vmstub7, ievt);
    writeMemFromFile<VMStubMEMemory<BARRELPS,3> >(inputvmstubs[7], fin_vmstub8, ievt);
    */
    VMStubMEMemoryCM<BARRELPS,3,3> inputvmstubs[maxInCopies] = {inputvmstubs1, inputvmstubs2, inputvmstubs3, inputvmstubs4, inputvmstubs5, inputvmstubs6, inputvmstubs7, inputvmstubs8};

    //set bunch crossing
    BXType bx=ievt;
    BXType bx_out;

    int noutcandmatch = 0;

    // Unit Under Test
    MatchProcessorTopL3(bx,
                        tprojarray,
                        &tproj1, &tproj2, &tproj3, &tproj4,
                        &tproj5, &tproj6, &tproj7, &tproj8,
                        inputvmstubs,
                        &allstub, &allproj,
                        bx_out,
                        fullmatch);

    // compare the computed outputs with the expected ones for the candidate 
    // matches
    bool truncation = true;

    // compare the computed outputs with the expected ones 
    //compareMemWithFile<AllProjectionMemory<BARRELPS> >(allproj, fout_ap, ievt, "AllProjections", truncation);
    //std::cout << "FM: L1L2 seeding" << std::endl;
    compareMemWithFile<FullMatchMemory<BARREL> >(fullmatch[0], fout_fm1, ievt, "FullMatch", truncation);
    //err_count += compareMemWithFile<FullMatchMemory<BARREL> >(fullmatch[0], fout_fm1, ievt, "FullMatch", truncation);
    //std::cout << "FM: L3L4 seeding" << std::endl;
    //err_count += compareMemWithFile<FullMatchMemory<BARREL> >(fullmatch2, fout_fm2, ievt, "FullMatch", truncation);
    //std::cout << "FM: L5L6 seeding" << std::endl;
    compareMemWithFile<FullMatchMemory<BARREL> >(fullmatch[3], fout_fm3, ievt, "FullMatch", truncation);
    //err_count += compareMemWithFile<FullMatchMemory<BARREL> >(fullmatch[2], fout_fm3, ievt, "FullMatch", truncation);
    //std::cout << "FM: D1D2 seeding" << std::endl;
    //err_count += compareMemWithFile<FullMatchMemory<BARREL> >(fullmatch4, fout_fm4, ievt, "FullMatch", truncation);
    //std::cout << "FM: D3D4 seeding" << std::endl;
    //err_count += compareMemWithFile<FullMatchMemory<BARREL> >(fullmatch5, fout_fm5, ievt, "FullMatch", truncation);
    //std::cout << "FM: L1D1 seeding" << std::endl;
    //err_count += compareMemWithFile<FullMatchMemory<BARREL> >(fullmatch6, fout_fm6, ievt, "FullMatch", truncation);
    //std::cout << "FM: L2D1 seeding" << std::endl;
    //err_count += compareMemWithFile<FullMatchMemory<BARREL> >(fullmatch7, fout_fm7, ievt, "FullMatch", truncation);
    

  }  // end of event loop
  
  // close files
  fin_tproj1.close();
  fin_tproj2.close();
  fin_tproj3.close();
  fin_tproj4.close();
  fin_tproj5.close();
  fin_tproj6.close();
  fin_tproj7.close();
  fin_tproj8.close();
  fin_vmstub1.close();
  fin_vmstub2.close();
  fin_vmstub3.close();
  fin_vmstub4.close();
  fin_vmstub5.close();
  fin_vmstub6.close();
  fin_vmstub7.close();
  fin_vmstub8.close();

  fout_fm1.close();
  fout_fm2.close();
  fout_fm3.close();
  fout_fm4.close();
  fout_fm5.close();
  fout_fm6.close();
  fout_fm7.close();

  return err_count;

}