if (Sys.getenv("RCEREAL_TEST_GITHUB") == "TRUE") {
  context("Test the instruction of installation via github_install")

  test_that("Install the package via github_install", {
    devtools::install_github("wush978/Rcereal@master")
    update_version("1.2.1")
    expect_true("include" %in% dir(system.file("", package = "Rcereal")))
  })
}
