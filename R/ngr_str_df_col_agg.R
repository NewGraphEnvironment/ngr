ngr_help_round <- function(x, decimal_places = 1) {
  multiplier <- 10^decimal_places
  floor(x * multiplier + 0.5) / multiplier
}

#' Aggregate Numeric Columns by Row
#'
#' This function aggregates numeric columns in a data frame or `sf` object by rows based on a specified aggregation function (e.g., [mean()], [sum()], [median()]). It allows column inclusion/exclusion using string matching and supports rational rounding.
#'
#' @param dat [data.frame] or [sf] object. The input data.
#' @param col_str_match [character] A string to match column names for aggregation.
#' @param col_result [character] The name of the resulting column with aggregated values.
#' @param fun [character] The aggregation function to use. Options are "mean", "sum", "median", "min", or "max". Default is "mean".
#' @param col_str_negate [character] (Optional) A string to exclude matching columns from aggregation. Default is `NULL`.
#' @param decimal_places [numeric] Number of decimal places for rounding. Default is 1.
#'
#' @return The input `dat` with a new column named `col_result` containing aggregated values.
#'
#' @details
#' This function identifies numeric columns matching `col_str_match` while excluding those matching `col_str_negate`, applies the specified aggregation function row-wise, and attaches the result as a new column in the input data.
#'
#' Rounding is performed using rational rounding (e.g., 1.55 rounds to 1.6).
#'
#' @seealso [mean()], [sum()], [median()], [min()], [max()]
#' @importFrom chk chk_data chk_string chk_number chk_numeric chk_integer
#' @importFrom cli cli_abort cli_warn
#' @export
#' @family string dataframe


ngr_str_df_col_agg <- function(dat, col_str_match, col_result, fun = "mean", col_str_negate = NULL, decimal_places = 1) {
  # Validate input parameters
  chk::chk_data(dat)
  chk::chk_string(col_str_match)
  chk::chk_string(col_result)
  chk::chk_string(fun)
  if (!is.null(col_str_negate)) chk::chk_string(col_str_negate)
  chk::chk_number(decimal_places)
  if (decimal_places < 0) cli::cli_abort("decimal_places must be a positive integer.")

  # Supported aggregation functions
  funs_supported <- c("mean", "sum", "median", "min", "max")
  if (!fun %in% funs_supported) {
    cli::cli_abort("Invalid aggregation function. Must be one of: {funs_supported}.")
  }

  # Identify columns matching the string
  cols_matched <- grep(col_str_match, names(dat), value = TRUE)

  # Exclude columns containing the negation string, if provided
  if (!is.null(col_str_negate)) {
    cols_matched <- setdiff(
      cols_matched,
      grep(col_str_negate, names(dat), value = TRUE)
    )
  }

  # Check if any columns remain to process
  if (length(cols_matched) == 0) {
    cli::cli_warn("No columns match the specified string: {col_str_match}, or all matching columns were excluded by col_str_negate: {col_str_negate}.")
    dat[[col_result]] <- NA
    return(dat)
  }

  # Ensure matched columns are numeric or integer
  numeric_data <- as.data.frame(dat)
  numeric_data_subset <- numeric_data[cols_matched] # Subset only numeric columns

  for (col in cols_matched) {
    tryCatch({
      chk::chk_numeric(dat[[col]])
    }, error = function(e) {
      tryCatch({
        chk::chk_integer(dat[[col]])
      }, error = function(e) {
        cli::cli_abort("Column '{col}' is not numeric or integer.")
      })
    })
  }

  # Define aggregation logic
  fun_selected <- switch(
    fun,
    "mean"   = function(x) mean(x, na.rm = TRUE),
    "sum"    = function(x) sum(x, na.rm = TRUE),
    "median" = function(x) median(x, na.rm = TRUE),
    "min"    = function(x) min(x, na.rm = TRUE),
    "max"    = function(x) max(x, na.rm = TRUE)
  )

  # Compute the result for each row
  result <- apply(
    numeric_data_subset,
    1,
    function(row) {
      numeric_values <- as.numeric(row)
      numeric_values <- numeric_values[!is.na(numeric_values) & !is.nan(numeric_values)]
      if (length(numeric_values) == 0) {
        return(NA) # Return NA if no valid data
      }
      fun_selected(numeric_values)
    }
  )

  # Attach result back to sf object
  dat[[col_result]] <- ngr_help_round(result, decimal_places = decimal_places)

  return(dat)
}

