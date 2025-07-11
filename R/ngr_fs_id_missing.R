#' Identify files in dir_in that are missing in dir_out
#'
#' Returns paths from dir_in that do not exist under the same relative path in dir_out.
#'
#' @param dir_in Character. Path to the input directory.
#' @param dir_out Character. Path to the output directory.
#'
#' @return A character vector of input file paths that are missing from dir_out.
#' @family fs
#' @export
#' @importFrom fs dir_ls path_rel path file_exists
#' @importFrom chk chk_string chk_dir
ngr_fs_id_missing <- function(dir_in, dir_out) {
  chk::chk_string(dir_in)
  chk::chk_string(dir_out)
  chk::chk_dir(dir_in)
  chk::chk_dir(dir_out)

  paths_in <- fs::dir_ls(dir_in, recurse = TRUE, type = "file")
  paths_rel <- fs::path_rel(paths_in, start = dir_in)
  paths_out <- fs::path(dir_out, paths_rel)

  paths_in[!fs::file_exists(paths_out)]
}
