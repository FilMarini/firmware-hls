#ifndef TrackletAlgorithm_StubPairMemory_h
#define TrackletAlgorithm_StubPairMemory_h

#include "Constants.h"
#include "MemoryTemplate.h"

// Data object definition
template<bool isDiskSeed> class StubPair {};

template<>
class StubPair<false>
{
public:
  enum BitWidths {
    // Bit size for full StubPairMemory
    kStubPairSize = 2*kNBits_MemAddr
  };
  enum BitLocations {
    // The location of the least significant bit (LSB) and most significant bit (MSB) in the StubPairMemory word for different fields
    kSPOuterIndexLSB = 0,
    kSPOuterIndexMSB = kSPOuterIndexLSB + kNBits_MemAddr - 1,
    kSPInnerIndexLSB = kSPOuterIndexMSB + 1,
    kSPInnerIndexMSB = kSPInnerIndexLSB + kNBits_MemAddr - 1
  };
    
  typedef ap_uint<kNBits_MemAddr> SPInnerIndex;
  typedef ap_uint<kNBits_MemAddr> SPOuterIndex;

  typedef ap_uint<kStubPairSize> StubPairData;

  // Constructors
  StubPair(const StubPairData& newdata):
    data_(newdata)
  {}

  StubPair(const SPInnerIndex innerindex, const SPOuterIndex outerindex):
    data_( (innerindex,outerindex) )
  {}
  
  StubPair()
  {}

  #ifndef __SYNTHESIS__
  StubPair(const char* datastr, int base=16)
  {
    StubPairData newdata(datastr, base);
    data_ = newdata;
  }
  #endif

  // Getter
  static constexpr int getWidth() {return kStubPairSize;}

  StubPairData raw() const {return data_;}
  
  SPInnerIndex getInnerIndex() const {
    return data_.range(kSPInnerIndexMSB,kSPInnerIndexLSB);
  }

  SPOuterIndex getOuterIndex() const {
    return data_.range(kSPOuterIndexMSB,kSPOuterIndexLSB);
  }

  bool getNegZ() const {
    return 0;
  }


  // Setter
  void setInnerIndex(const SPInnerIndex id) {
    data_.range(kSPInnerIndexMSB,kSPInnerIndexLSB) = id;
  }

  void setOuterIndex(const SPOuterIndex id) {
    data_.range(kSPOuterIndexMSB,kSPOuterIndexLSB) = id;
  }

private:
  
  StubPairData data_;
  
};

template<>
class StubPair<true>
{
public:
  enum BitWidths {
    // Bit size for full StubPairMemory
    kStubPairSize = 2*kNBits_MemAddr,
    negZSize = 1
  };
  enum BitLocations {
    // The location of the least significant bit (LSB) and most significant bit (MSB) in the StubPairMemory word for different fields
    kSPOuterIndexLSB = 0,
    kSPOuterIndexMSB = kSPOuterIndexLSB + kNBits_MemAddr - 1,
    kSPInnerIndexLSB = kSPOuterIndexMSB + 1,
    kSPInnerIndexMSB = kSPInnerIndexLSB + kNBits_MemAddr - 1,
    kSPNegZLSB = kSPInnerIndexMSB + 1,
    kSPNegZMSB = kSPNegZLSB
  };
    
  typedef ap_uint<kNBits_MemAddr> SPInnerIndex;
  typedef ap_uint<kNBits_MemAddr> SPOuterIndex;

  typedef ap_uint<kStubPairSize> StubPairData;

  // Constructors
  StubPair(const StubPairData& newdata):
    data_(newdata)
  {}

  StubPair(const SPInnerIndex innerindex, const SPOuterIndex outerindex):
    data_( (innerindex,outerindex) )
  {}

  StubPair()
  {}

  #ifndef __SYNTHESIS__
  StubPair(const char* datastr, int base=16)
  {
    StubPairData newdata(datastr, base);
    data_ = newdata;
  }
  #endif

  // Getter
  static constexpr int getWidth() {return kStubPairSize + 1;}

  StubPairData raw() const {return data_;}
  
  SPInnerIndex getInnerIndex() const {
    return data_.range(kSPInnerIndexMSB,kSPInnerIndexLSB);
  }

  SPOuterIndex getOuterIndex() const {
    return data_.range(kSPOuterIndexMSB,kSPOuterIndexLSB);
  }

  SPOuterIndex getNegZ() const {
    return data_.range(kSPNegZMSB,kSPNegZLSB);
  }


  // Setter
  void setInnerIndex(const SPInnerIndex id) {
    data_.range(kSPInnerIndexMSB,kSPInnerIndexLSB) = id;
  }

  void setOuterIndex(const SPOuterIndex id) {
    data_.range(kSPOuterIndexMSB,kSPOuterIndexLSB) = id;
  }

  void setOuterIndex(const bool negZ) {
    data_.range(kSPNegZMSB,kSPNegZLSB) = negZ;
  }
private:
  
  StubPairData data_;
  
};

// Memory definition
template<bool isDiskSeed> using StubPairMemory =  MemoryTemplate<StubPair<isDiskSeed>, 1, kNBits_MemAddr>;

#endif
