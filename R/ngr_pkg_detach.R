#' Detach a package
#'
#' This function is a convenience wrapper around `[detach()]` to unload a package.
#' It is designed to speed up development and testing for package development and report writing.
#'
#' @param pkg [character] A single string representing the name of the package to detach.
#' @family package
#' @return Invisibly returns NULL.
#' @examples
#' \dontrun{
#' ngr_pkg_detach("ngr")
#' }
#' @export
ngr_pkg_detach <- function(pkg) {
  # Validate input
  chk::chk_string(pkg)

  # Try detaching the package
  detach(paste0("package:", pkg), unload = TRUE, character.only = TRUE)

  invisible(NULL)
}
