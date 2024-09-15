//[[Rcpp::depends(Rcereal)]]
#include <sstream>

#include <cereal/archives/binary.hpp>

#include <Rcpp.h>

struct MyClass
{
    int x, y, z;
    template<class Archive>
    void serialize(Archive & archive) {
        archive( x, y, z ); 
    }
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

