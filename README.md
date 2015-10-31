# Rceral - cereal, A c++11 library for serialization, for R

This package provides R with access to ceral header files. 
cereal is a header-only C++11 serialization library.
cereal takes arbitrary data types and reversibly turns them into different representations, such as compact binary encodings, XML, or JSON. 
For more information, please visit the official website of the cereal project: <http://uscilab.github.io/cereal/>

This package can be used via the `LinkingTo:` field in the DESCRIPTION field of an R package and the `Rcpp::depends` in the Rcpp-attributes. The R and Rcpp infrastructure tools will know how to set include flags properly.

## Installation

Please use the `devtools::install_github` to install the latest version of Rceral and use `Rcereal::update_version` to install the content of the header files of cereal.

```r
devtools::install_github("wush978/Rcereal")
Rcereal::upate_version()
```

## Getting Started

The following example shows how to use Rcereal in Rcpp-attributes to serialize a user defined c++ structure into raw vector and deserialize from the raw vector.

```cpp
//[[Rcpp::depends(Rcereal)]]

#include <sstream>
#include <cereal/archives/binary.hpp>
#include <Rcpp.h>

struct MyClass
{
  int x, y, z;

  // This method lets cereal know which data members to serialize
  template<class Archive>
  void serialize(Archive & archive)
  {
    archive( x, y, z ); // serialize things by passing them to the archive
  }
};

using namespace Rcpp;
//[[Rcpp::export]]
RawVector serialize_myclass(int x = 1, int y = 2, int z = 3) {
  MyClass my_instance;
  my_instance.x = x;
  my_instance.y = y;
  my_instance.z = z;
  std::stringstream ss;
  {
    cereal::BinaryOutputArchive oarchive(ss); // Create an output archive
    oarchive(my_instance);
  }
  ss.seekg(0, ss.end);
  RawVector retval(ss.tellg());
  ss.seekg(0, ss.beg);
  ss.read(reinterpret_cast<char*>(&retval[0]), retval.size());
  return retval;
}

//[[Rcpp::export]]
void deserialize_myclass(RawVector src) {
  std::stringstream ss;
  ss.write(reinterpret_cast<char*>(&src[0]), src.size());
  ss.seekg(0, ss.beg);
  MyClass my_instance;
  {
    cereal::BinaryInputArchive iarchive(ss);
    iarchive(my_instance);
  }
  Rcout << my_instance.x << "," << my_instance.y << "," << my_instance.z << std::endl;
}

/*** R
raw_vector <- serialize_myclass(1, 2, 4)
deserialize_myclass(raw_vector)
*/
```

To compile the cpp file, the user enable the support of c++11 before using `Rcpp::sourceCpp`. 

```r
Sys.setenv(PKG_CXXFLAGS="-std=c++11")
Rcpp::sourceCpp("<the path to the cpp file>")
```

## Status

OS     |  Status
-------|-------------
Linux  |[![](https://travis-ci.org/wush978/Rcereal.svg?branch=master)](https://travis-ci.org/wush978/Rcereal/branches)
os x   |[![](https://travis-ci.org/wush978/Rcereal.svg?branch=osx)](https://travis-ci.org/wush978/Rcereal/branches)
Windows|[![Build status](https://ci.appveyor.com/api/projects/status/yjmrqa3yn70qf2q0/branch/master?svg=true)](https://ci.appveyor.com/project/wush978/rcereal/branch/master)
