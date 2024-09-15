test_that("serialize and deserialize with cpp11", {
    cpp11::cpp_source(file="cpp/test_struct_cpp11.cpp")
    x <- sample.int(1000, 3)
    .raw <- serialize_myclass(x[1], x[2], x[3])
    result <- capture.output(deserialize_myclass(.raw))
    expect_equal(result, paste(x, collapse = ","))
})

test_that("serialize and deserialize with Rcpp", {
    Rcpp::sourceCpp(file="cpp/test_struct_Rcpp.cpp")
    x <- sample.int(1000, 3)
    .raw <- serialize_myclass(x[1], x[2], x[3])
    result <- capture.output(deserialize_myclass(.raw))
    expect_equal(result, paste(x, collapse = ","))
})
