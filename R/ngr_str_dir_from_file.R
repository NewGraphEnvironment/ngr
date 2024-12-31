#' Detect the Presence of a Specific File in a Directory
#'
#' This function checks if a specific file exists in a given directory and optionally its subdirectories.
#'
#' @param path_dir [character] A single string representing the directory path to search.
#' @param file_name [character] A string specifying the name of the file to detect.
#' @param recurse [logical] Whether to search recursively in subdirectories. Default is `FALSE`.
#' @param ... Additional arguments passed to [fs::dir_ls()].
#' @family string
#'
#' @return [character] The directory path if the file is found; otherwise, a warning is issued.
#'
#' @importFrom fs dir_ls
#' @importFrom cli cli_alert_warning
ngr_str_dir_from_file <- function(path_dir, file_name, recurse = FALSE, ...) {
  # Use dir_ls with glob to directly find matching files
  matched_files <- fs::dir_ls(path_dir, glob = paste0("**/", file_name), recurse = recurse, ...)

  # Return the directory path if a match is found
  if (length(matched_files) > 0) {
    return(path_dir)
  } else {
    cli::cli_alert_warning("No file matching '{file_name}' was found in '{path_dir}'.")
    return(NULL)
  }
}
