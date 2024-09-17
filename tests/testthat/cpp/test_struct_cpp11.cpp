#include <sstream>

#include <cpp11/raws.hpp>

#include <cereal/archives/binary.hpp>

struct MyClass {
    int x, y, z;
    template<class Archive>
    void serialize(Archive & archive) {
        archive( x, y, z ); 
    }
};

[[cpp11::linking_to("Rcereal")]]
[[cpp11::register]]
cpp11::raws serialize_myclass(int x = 1, int y = 2, int z = 3) {

    MyClass my_instance { x, y, z };
    std::stringstream ss;
    {
        cereal::BinaryOutputArchive oarchive(ss); 
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
        cereal::BinaryInputArchive iarchive(ss);
        iarchive(my_instance);
    }

    Rprintf("%i,%i,%i\n", my_instance.x, my_instance.y, my_instance.z);

}

