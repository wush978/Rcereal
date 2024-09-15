# helper to check that header files inside `include` match
compare_dir <- function(path_src, path_inst) {

    files_src <- sort(dir(path_src, recursive = TRUE))
    files_inst <- sort(dir(path_inst, recursive = TRUE))

    if (!isTRUE(all.equal(files_src, files_inst))) return(FALSE)

    for(i in seq_along(files_src)) {
        chk_src <- tools::md5sum(file.path(path_src, files_src[i]))
        chk_inst <- tools::md5sum(file.path(path_inst, files_inst[i]))
        if (chk_src != chk_inst) return(FALSE)
    }

    TRUE

}

testthat::test_that("Switch to specific version", {

    testthat::skip_if(!Sys.getenv("RCEREAL_TEST_UPDATE") %in% TRUE)

    versions <- package_version("1.2.1")
    update_version(versions)
    git2r::checkout(git2r::tags(test.repo)[[sprintf("v%s", versions)]])
    testthat::expect_true(compare_dir(system.file("include", package="Rcereal"),
                          file.path(test.repo_path, "include")))

})

