library(testthat)
library(Rcereal)

test.repo_path <- tempfile()
dir.create(test.repo_path)
test.repo <- git2r::clone("https://github.com/USCiLab/cereal.git", test.repo_path)

test_package("Rcereal")