#' Remove Columns with All NA Values
#'
#' `ngr_tidy_cols_rm_na` removes all columns from a [data.frame] where every value is `NA`.
#'
#' @param df A [data.frame]. The input data frame to be cleaned.
#' @return A [data.frame] with columns containing only `NA` values removed.
#' @importFrom chk chk_data
#' @export
#' @family tidy
#' @examples
#' # Example data frame
#' df <- data.frame(
#'   A = c(NA, NA, NA),
#'   B = c(1, 2, NA),
#'   C = c(NA, NA, NA),
#'   D = c("x", "y", NA)
#' )
#'
#' # Apply the function
#' tidy_df <- ngr_tidy_cols_rm_na(df)
#'
#' # Result
#' print(tidy_df)
ngr_tidy_cols_rm_na <- function(df) {
  # Check that the input is a data frame
  chk::chk_data(df)

  # Remove columns where all values are NA
  df <- df[, colSums(!is.na(df)) > 0]

  # Return the cleaned data frame
  return(df)
}
