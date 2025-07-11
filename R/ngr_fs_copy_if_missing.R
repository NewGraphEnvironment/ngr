#' Copy files from one directory to another only if they don't already exist
#'
#' Recursively lists files in `dir_in` and copies them to the same relative
#' path under `dir_out`, skipping any files that already exist.
#'
#' @param dir_in Character. Path to the input directory.
#' @param dir_out Character. Path to the output directory.
#'
#' @return Invisibly returns `NULL`. Used for side effects (file copying).
#' @family fs
#' @export
#' @importFrom fs dir_create dir_ls path_rel path file_exists path_dir file_copy
#' @importFrom chk chk_string chk_dir
#'
#' @examples
#' dir_in <- fs::dir_create(fs::path(tempfile(), "a"))
#' dir_out <- fs::dir_create(fs::path(tempfile(), "b"))
#' fs::file_create(fs::path(dir_in, "test.txt"))
#' ngr_fs_copy_if_missing(fs::path_dir(dir_in), fs::path_dir(dir_out))
#' fs::file_exists(fs::path(dir_out, "a", "test.txt"))
ngr_fs_copy_if_missing <- function(dir_in, dir_out) {
  chk::chk_string(dir_in)
  chk::chk_string(dir_out)
  chk::chk_dir(dir_in)
  chk::chk_dir(dir_out)

  paths_in <- ngr_fs_id_missing(dir_in, dir_out)

  if (length(paths_in) == 0) return(invisible(NULL))

  paths_rel <- fs::path_rel(paths_in, start = dir_in)
  paths_out <- fs::path(dir_out, paths_rel)

  files_copy_idx <- which(!fs::file_exists(paths_out))

  if (length(files_copy_idx) == 0) return(invisible(NULL))

  fs::dir_create(fs::path_dir(paths_out[files_copy_idx]))
  fs::file_copy(paths_in[files_copy_idx], paths_out[files_copy_idx])

  invisible(NULL)
}
