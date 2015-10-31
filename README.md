# Rceral - cereal, A c++11 library for serialization, for R

This package provides R with access to ceral header files. 
cereal is a header-only C++11 serialization library.
cereal takes arbitrary data types and reversibly turns them into different representations, such as compact binary encodings, XML, or JSON. 
For more information, please visit the official website of the cereal project: <http://uscilab.github.io/cereal/>

This package can be used via the `LinkingTo:` field in the DESCRIPTION field of an R package and the `Rcpp::depends` in the Rcpp-attributes. The R and Rcpp infrastructure tools will know how to set include flags properly.

## Status

OS     |  Status
-------|-------------
Linux  |[![](https://travis-ci.org/wush978/Rcereal.svg?branch=master)](https://travis-ci.org/wush978/Rcereal/branches)
os x   |[![](https://travis-ci.org/wush978/Rcereal.svg?branch=osx)](https://travis-ci.org/wush978/Rcereal/branches)
Windows|[![Build status](https://ci.appveyor.com/api/projects/status/yjmrqa3yn70qf2q0/branch/master?svg=true)](https://ci.appveyor.com/project/wush978/rcereal/branch/master)
