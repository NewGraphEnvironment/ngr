# this is necessary to get around R's weird rounding where 1.55 would round to 1.5 vs 1.6 as we would expect.
# TO DO: move to its own page with doucmentation so easy to find and easy to recycle to other functions
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
#' This function identifies columns matching `col_str_match` while excluding those matching `col_str_negate`,
#' applies the specified aggregation function row-wise. It attaches the result as a new column in the input data. If
#' the result column exists within the dataframe it is updated with the aggregated values.
#'
#' Rounding is performed using rational rounding (e.g., 1.55 rounds to 1.6).
#'
#' @seealso [mean()], [sum()], [median()], [min()], [max()]
#' @importFrom chk chk_data chk_string chk_number chk_numeric chk_integer
#' @importFrom cli cli_abort cli_warn
#' @export
#' @family string dataframe
#' @examples
#' # Load example data
#'
#' dat_raw <- data.frame(
#'   channel_width_m_1 = c(5.0, 4.2, 6.3, NA, 5.5),
#'   channel_width_m_2 = c(5.5, 4.0, 6.1, NA, 5.8),
#'   wetted_width_m_1 = c(3.0, 2.8, 3.5, NA, 3.3),
#'   wetted_width_m_2 = c(3.2, 2.9, 3.4, NA, 3.6),
#'   residual_pool_m_1 = c(0.8, 0.7, 0.9, NA, 0.85),
#'   residual_pool_m_2 = c(0.75, 0.65, 0.92, NA, 0.88),
#'   gradient_percent_1 = c(2.5, 2.0, 3.0, NA, 2.7),
#'   gradient_percent_2 = c(2.6, 2.1, 3.1, NA, 2.8),
#'   bankfull_depth_m_1 = c(1.2, 1.1, 1.3, NA, 1.25),
#'   bankfull_depth_m_2 = c(1.15, 1.05, 1.35, NA, 1.3),
#'   wetted_width_m_2.channel_width_m_2_time = c("2023-12-01", "2023-12-02", "2023-12-03", NA, "2023-12-05"),
#'   method_for_wetted_width = c("manual", "manual", "manual", NA, "manual"),
#'   method_for_channel_width = c("automatic", "automatic", "automatic", NA, "automatic"),
#'   avg_channel_width_m = NA_real_,
#'   avg_wetted_width_m = NA_real_,
#'   average_residual_pool_depth_m = NA_real_,
#'   average_gradient_percent = NA_real_,
#'   average_bankfull_depth_m = NA_real_
#' )
#'
#' col_str_negate = "time|method|avg|average"
#' col_str_to_agg <- c("channel_width", "wetted_width", "residual_pool", "gradient", "bankfull_depth")
#' columns_result <- c("avg_channel_width_m", "avg_wetted_width_m", "average_residual_pool_depth_m", "average_gradient_percent", "average_bankfull_depth_m")
#'
#' # Initialize dat as a copy of dat_raw to preserve the original and allow cumulative updates
#' dat <- dat_raw
#'
#' # Use mapply with cumulative updates
#' # Suppress mapply output by assigning it to invisible
#' invisible(mapply(
#'   FUN = function(col_str_match, col_result) {
#'     # Update dat cumulatively using double assignment operator to update each already updated version of the dataframe
#'     dat <<- ngr_str_df_col_agg(
#'       dat = dat,  # Use the updated dat for each iteration
#'       col_str_match = col_str_match,
#'       col_result = col_result,
#'       col_str_negate = col_str_negate,
#'       decimal_places = 1
#'     )
#'   },
#'   col_str_match = col_str_to_agg,
#'   col_result = columns_result
#' ))
#'
#' # Print the first few rows of the resulting data after subsetting for clarity
#' dat_subset <- dat[1:5, grep("average|avg", names(dat))]
#' head(dat_subset)
#' \dontrun{
#' #'Load the geopackage shipped with the package
#' path <- system.file("extdata", "form_fiss_site_2024.gpkg", package = "ngr")
#'
#' dat_raw <- sf::st_read(path)
#'
#' # Use purrr::reduce with cumulative updates
#' dat <- purrr::reduce(
#'   .x = seq_along(col_str_to_agg),
#'   .f = function(acc_df, i) {
#'     ngr_str_df_col_agg(
#'       dat = acc_df,
#'       col_str_match = col_str_to_agg[i],
#'       col_result = columns_result[i],
#'       col_str_negate = col_str_negate,
#'       decimal_places = 1
#'     )
#'   },
#'   .init = dat_raw
#' )
#'
#' # Print the first few rows of the resulting data
#' # Convert to a plain data.frame
#' dat_subset <- dat[1:5, grep("average|avg", names(dat))]
#' head(dat_subset)
#' }


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

  # Compute the result for each row but return NA vs NaN if there are no values to average
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

