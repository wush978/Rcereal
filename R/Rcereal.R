#' List version(s) of cereal on GitHub.
#'
#' Use the GitHub API to query the versions of cereal.
#'
#' The GitHub page of cereal is <https://github.com/USCiLab/cereal>, the
#' tags are accessed via the GitHub API, from which a `package_version` object
#' is coerced.
#'
#' @return `package_version`, a vector of available versions.
#'
#' @export
#' @md
list_version <- function() {

    response <- httr::GET("https://api.github.com/repos/USCiLab/cereal/tags")
    stopifnot(httr::status_code(response) %in% 200L)

    tag <- sapply(httr::content(response), function(obj) {
        substring(obj$name, 2L, nchar(obj$name))
    })

    package_version(tag)

}

#' Return the latest version of cereal on the GitHub.
#'
#' Uses the GitHub API to find the latest version of cereal.
#'
#' Gets all the versions from GitHub via [list_version()] and selects the
#' largest version number.
#'
#' @return `package_version`
#' @export
#' @md
last_version <- function() max(list_version())


# Helper for finding location of header files
.package_file <- function(...) system.file(..., package = .packageName)


#' Update installed cereal headers
#'
#' Clone a different version of the cereal headers into R library.
#'
#' This over-writes the installed cereal headers inside an R library. The
#' default location for the files is found via [system.file()]. The library
#' location can be specified by passing an argument `lib.loc`. See
#' [system.file()] for further details.
#'
#' @param version `character` or [package_version]; the version to install, e.g.
#' '1.3.2' or `v1.3.2`.
#' @param ... additional arguments passed to [system.file()], e.g. `lib.loc` for
#' the location of the library that Rcereal is installed in.
#'
#' @export
#' @md
update_version <- function(version=last_version(), ...) {

    stopifnot(length(version) == 1L,
              is.character(version) || is.package_version(version))

    if (is.character(version)) {
        if (substring(version, 1L, 1L) == "v")
            version <- substring(version, 2L, nchar(version))
    }
    version <- package_version(version)

    .tmppath <- tempfile()
    dir.create(.tmppath)
    git2r::clone("https://github.com/USCiLab/cereal.git", .tmppath)
    .repo <- git2r::repository(.tmppath)
    .commit <- git2r::tags(.repo)[[sprintf("v%s", version)]]
    git2r::checkout(.commit)

    .dst <- file.path(.package_file("", ...), "include")
    stopifnot(
        file.rename(.dst,
                    .include <- file.path(.package_file("", ...), ".include"))
    )

    tryCatch({
        .src <- file.path(.tmppath, "include")
        file.copy(.src, .package_file("", ...), overwrite=TRUE, recursive=TRUE)
        stopifnot(dir(.dst) == "cereal")
        unlink(.include, recursive=TRUE)
    }, error = function(e) {
        file.rename(.include, .dst)
        stop(conditionMessage(e))
    })

}

