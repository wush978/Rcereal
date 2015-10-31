library(testthat)
library(Rcereal)

if (Sys.getenv("RCEREAL_TEST_GITHUB") == "TRUE") {
  cat("install_github will be tested\n")
}

if (Sys.getenv("RCEREAL_TEST_UPDATE") == "TRUE") {
  cat("update_version will be tested")
}

test_check("Rcereal")
