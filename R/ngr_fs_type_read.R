#' Read data from a flat file with type schema preservation
#'
#' Reads a data frame from a flat file format (CSV by default) using a companion
#' parquet schema file to restore column types. This enables type-preserving
#' round-trips for formats that don't natively preserve types.
#'
#' @param path Character. Path to the file to read.
#'   A companion schema file with suffix `_schema.parquet` must exist.
#' @param format Character. File extension to replace when finding the schema file.
#'   Default is "csv".
#'
#' @return A [tibble] with column types restored from the schema file.
#' @family fs
#' @family serialization
#' @seealso [ngr_fs_type_write()] for writing files with type preservation
#' @export
#' @importFrom arrow read_csv_arrow read_parquet schema
#' @importFrom chk chk_file chk_string
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
#' # Read back with types preserved
#' df2 <- ngr_fs_type_read(path)
#' str(df2)
#'
#' # Compare types
#' sapply(df, class)
#' sapply(df2, class)
#' }
ngr_fs_type_read <- function(path, format = "csv") {
  chk::chk_string(path)
  chk::chk_file(path)
  chk::chk_string(format)

  pattern <- paste0("\\.", format, "$")
  schema_path <- sub(pattern, "_schema.parquet", path, ignore.case = TRUE)
  chk::chk_file(schema_path)

  schema <- arrow::schema(arrow::read_parquet(schema_path))
  arrow::read_csv_arrow(path, schema = schema, skip = 1)
}
