#' Extract Directory Name from File or Directory Path Based on Levels
#'
#' This function retrieves the directory name at a specified level(s) above the given file path.
#' It wraps [fs::path_dir()] to navigate up directory levels and [basename()] to extract the final directory name.
#' Particularly useful for retrieving repo name so it can be converted to url and or html link by [ngr_str_repo_link()].
#'
#' @param path [character] A single string. The file path.
#' @param levels [integer] A single integer. The number of levels up to traverse from the file path to extract the directory name. Default is `1`.
#'
#' @return [character] A single string representing the directory name at the specified level.
#'
#' @importFrom fs path_dir
#' @importFrom chk chk_character chk_scalar chk_numeric vld_integer
#'
#' @export
#' @family string
#'
#' @examples
#' ngr_str_dir_from_path("~/Projects/repo/ngr/data-raw/extdata.R", levels = 2)
#' # Returns "ngr"
ngr_str_dir_from_path <- function(path, levels = 1) {
  # Validate inputs
  chk::chk_character(path)

  # Validate and coerce `levels` to integer if necessary
  if (!chk::vld_integer(levels)) {
    chk::chk_numeric(levels)
    if (levels != as.integer(levels)) {
      warning("`levels` is not an integer; truncating to ", as.integer(levels), ".")
    }
    levels <- as.integer(levels)
  }

  chk::chk_scalar(levels)
  chk::chk_gte(levels, 1)

  # Traverse up the directory levels
  for (i in seq_len(levels)) {
    path <- fs::path_dir(path)
  }
  basename(path)
}
