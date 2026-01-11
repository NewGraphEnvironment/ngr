#' Write data to a flat file with type schema preservation
#'
#' Writes a data frame to a flat file format (CSV by default) and stores the
#' column type schema in a companion parquet file. This enables type-preserving
#' round-trips for formats that don't natively preserve types, while keeping
#' data in human-readable flat files suitable for GitHub collaboration.
#'
#' @param x A [data.frame] or [tibble] to write.
#' @param path Character. Path to write the file to.
#' @param format Character. File extension to replace when creating the schema file.
#'   Default is "csv".
#'
#' @return Invisibly returns the file path.
#' @family fs
#' @family serialization
#' @seealso [ngr_fs_type_read()] for reading files with preserved types
#' @export
#' @importFrom arrow write_csv_arrow write_parquet
#' @importFrom chk chk_data chk_string
#' @importFrom fs dir_create path_dir
#'
#' @examples
#' \dontrun{
#' # Create example data with various types
#' df <- data.frame(
#'   int_col = 1:3L,
#'   dbl_col = c(1.1, 2.2, 3.3),
#'   chr_col = c("a", "b", "c"),
#'   date_col = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03")),
#'   lgl_col = c(TRUE, FALSE, TRUE)
#' )
#'
#' # Write to temporary file
#' path <- tempfile(fileext = ".csv")
#' ngr_fs_type_write(df, path)
#'
#' # Schema file is created alongside
#' schema_path <- sub("\\.csv$", "_schema.parquet", path)
#' file.exists(schema_path)
#'
#' # Read back with types preserved
#' df2 <- ngr_fs_type_read(path)
#' str(df2)
#' }
ngr_fs_type_write <- function(x, path, format = "csv") {
  chk::chk_data(x)
  chk::chk_string(path)
  chk::chk_string(format)

  pattern <- paste0("\\.", format, "$")
  schema_path <- sub(pattern, "_schema.parquet", path, ignore.case = TRUE)

  fs::dir_create(fs::path_dir(path))
  arrow::write_csv_arrow(x, path)
  arrow::write_parquet(x[0, , drop = FALSE], schema_path)

  invisible(path)
}
