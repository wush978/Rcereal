# Rcereal: cereal headers for R and C++ serialization

This package provides R with access to [__cereal__][cereal_gh] header files.
__cereal__ is a header-only C++11 serialization library. __cereal__ takes
arbitrary data types and reversibly turns them into different representations,
such as compact binary encodings, XML, or JSON.

For more information, please visit the official website of the __cereal__
project: <https://uscilab.github.io/cereal/>.

[cereal_gh]: https://uscilab.github.io/cereal/

The headers in this package can be used via:

-   the `LinkingTo:` field in the DESCRIPTION of an R package;
-   the `[[cpp11::linking_to("Rcereal")]]` attribute and `cpp11::source` from
    the [cpp11][cpp11_url] package, or;
-   the `[[Rcpp::depends(Rcereal)]]` [Rcpp attribute][rcpp_attributes_vignette].

[cpp11_url]: https://cpp11.r-lib.org
[rcpp_attributes_vignette]: https://cran.r-project.org/package=Rcpp/vignettes/Rcpp-attributes.pdf


## Installation

### Latest release

The latest release can be installed from [CRAN][rcereal_cran] via:

```r
install.packages('Rcereal')
```

[rcereal_cran]: https://CRAN.R-project.org/package=Rcereal


### Development version

Use `remotes::install_github` to install the latest version of __Rcereal__.
Optionally: use `Rcereal::update_version` to over-write the header files in the
R library with a version from <https://github.com/USCiLab/cereal>.

```r
remotes::install_github("wush978/Rcereal")
Rcereal::update_version() # optional
```


## Usage

See the official __cereal__ [Quick Start][cereal_quick_start_doc] guide for
further details about using __cereal__ in C++11.

[cereal_quick_start_doc]: https://uscilab.github.io/cereal/quickstart.html


### Using cpp11

The following example shows how to use __Rcereal__ alongside [cpp11][cpp11_url]
to serialize and deserialize a user-defined `struct` using raw vectors:

```cpp
// path/to/example.cpp
#include <sstream>

#include <cpp11/raws.hpp>

#include <cereal/archives/binary.hpp>

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

[[cpp11::linking_to("Rcereal")]]
[[cpp11::register]]
cpp11::raws serialize_myclass(int x = 1, int y = 2, int z = 3) {
    MyClass my_instance { x, y, z };
    std::stringstream ss;
    {
        cereal::BinaryOutputArchive oarchive(ss); // Create an output archive
        oarchive(my_instance);
    }
    ss.seekg(0, ss.end);
    cpp11::writable::raws result(ss.tellg());
    ss.seekg(0, ss.beg);
    std::copy(std::istreambuf_iterator<char>{ss},
              std::istreambuf_iterator<char>(),
              result.begin());
    return result;
}

[[cpp11::register]]
void deserialize_myclass(cpp11::raws src) {
    std::stringstream ss;
    std::copy(src.cbegin(), src.cend(), std::ostream_iterator<char>(ss));
    MyClass my_instance;
    {
        cereal::BinaryInputArchive iarchive(ss); // Read from input archive
        iarchive(my_instance);
    }
    Rprintf("%i,%i,%i\n", my_instance.x, my_instance.y, my_instance.z);
}
```

Then, provided C++11 is enabled by default (see [this tidyverse
post 03/2023][tidyverse_post_03_2023]), in R:

```r
cpp11::cpp_source(file='path/to/example.cpp')
raw_vector <- serialize_myclass(1, 2, 4)
deserialize_myclass(raw_vector)
```

[tidyverse_post_03_2023]: https://www.tidyverse.org/blog/2023/03/cran-checks-compiled-code/


### Using Rcpp

The following example shows how to use __Rcereal__ alongside [Rcpp][rcpp_cran]
to serialize and deserialize a user-defined `struct` using raw vectors:

```cpp
// path/to/example.cpp

//[[Rcpp::depends(Rcereal)]]
#include <sstream>

#include <cereal/archives/binary.hpp>

#include <Rcpp.h>
using namespace Rcpp;

struct MyClass
{
    /* same as cpp11 example above */
};

//[[Rcpp::export]]
Rcpp::RawVector serialize_myclass(int x = 1, int y = 2, int z = 3) {
    MyClass my_instance { x, y, z };
    std::stringstream ss;
    {
        cereal::BinaryOutputArchive oarchive(ss); // Create an output archive
        oarchive(my_instance);
    }
    ss.seekg(0, ss.end);
    Rcpp::RawVector result(ss.tellg());
    ss.seekg(0, ss.beg);
    ss.read(reinterpret_cast<char*>(&result[0]), result.size());
    return result;
}

//[[Rcpp::export]]
void deserialize_myclass(Rcpp::RawVector src) {
    std::stringstream ss;
    ss.write(reinterpret_cast<char*>(&src[0]), src.size());
    ss.seekg(0, ss.beg);
    MyClass my_instance;
    {
        cereal::BinaryInputArchive iarchive(ss);
        iarchive(my_instance);
    }
    Rcpp::Rcout << my_instance.x << "," << my_instance.y << "," <<
        my_instance.z << std::endl;
}
```

Then in R, provided C++ is enabled by default:

```r
Rcpp::sourceCpp("path/to/example.cpp")
raw_vector <- serialize_myclass(1, 2, 4)
deserialize_myclass(raw_vector)
```

[rcpp_cran]: https://cran.r-project.org/package=Rcpp


## Troubleshooting

C++11 may not be enabled by default for some compilers, if not; ensure that
`PKG_CXXFLAGS` contains `-std=c++11`, e.g. if you use `pkgbuild::compile_dll()`
to build a package (similarly for `devtools::build`):

```r
withr::with_makevars(c("PKG_CXXFLAGS"="std=c++11"),
                     pkgbuild::compile_dll(),
                     assignment="+=")
```

If the compiler reports missing header files, try `Rcereal::update_version()` to
update the content of __cereal__ from GitHub. Check that a directory named
`cereal` is in the folder  `system.file("include", package = "Rcereal")`.
