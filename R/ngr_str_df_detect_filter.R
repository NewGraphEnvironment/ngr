#' Filter Rows Based on String Detection in a Column Detected with a partial String Match
#'
#' This function filters rows in a data frame where a specified column's name matches a pattern and the values of that column contain a specified string.
#'
#' @param x [data.frame] The input data frame to filter.
#' @param col_filter [character] A single string representing the pattern to match column names.
#' @param str_filter [character] A single string to match within the values of the filtered column.
#'
#' @return A filtered data frame if matching rows are found; otherwise, the original data frame is returned.
#'
#' @importFrom stringr str_detect
#' @importFrom cli cli_abort
#' @family string dataframe
#' @export
ngr_str_df_detect_filter <- function(x, col_filter, str_filter) {
  chk::chk_data(x)
  chk::chk_string(col_filter) # Changed to chk_string for single string validation
  chk::chk_string(str_filter) # Changed to chk_string for single string validation

  col_name <- names(x)[stringr::str_detect(names(x), col_filter)]
  if (length(col_name) > 1) {
    cli::cli_abort("Multiple columns match the col_filter: {paste(col_name, collapse = ', ')}. Please refine your filter.")
  }
  if (length(col_name) == 1) {
    col_index <- which(names(x) == col_name)
    x[which(stringr::str_detect(x[[col_index]], str_filter)), ]
  } else {
    x
  }
}
