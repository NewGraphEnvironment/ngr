# Aggregate Numeric Columns by Row

This function aggregates numeric columns in a data frame or `sf` object
by rows based on a specified aggregation function (e.g.,
[`mean()`](https://rdrr.io/r/base/mean.html),
[`sum()`](https://rdrr.io/r/base/sum.html),
[`median()`](https://rdrr.io/r/stats/median.html)). It allows column
inclusion/exclusion using string matching and supports rational
rounding.

## Usage

``` r
ngr_str_df_col_agg(
  dat,
  col_str_match,
  col_result,
  fun = "mean",
  col_str_negate = NULL,
  decimal_places = 1
)
```

## Arguments

- dat:

  [data.frame](https://rdrr.io/r/base/data.frame.html) or
  [sf::sf](https://r-spatial.github.io/sf/reference/sf.html) object. The
  input data.

- col_str_match:

  [character](https://rdrr.io/r/base/character.html) A string to match
  column names for aggregation.

- col_result:

  [character](https://rdrr.io/r/base/character.html) The name of the
  resulting column with aggregated values.

- fun:

  [character](https://rdrr.io/r/base/character.html) The aggregation
  function to use. Options are "mean", "sum", "median", "min", or "max".
  Default is "mean".

- col_str_negate:

  [character](https://rdrr.io/r/base/character.html) (Optional) A string
  to exclude matching columns from aggregation. Default is `NULL`.

- decimal_places:

  [numeric](https://rdrr.io/r/base/numeric.html) Number of decimal
  places for rounding. Default is 1.

## Value

The input `dat` with a new column named `col_result` containing
aggregated values.

## Details

This function identifies columns matching `col_str_match` while
excluding those matching `col_str_negate`, applies the specified
aggregation function row-wise. It attaches the result as a new column in
the input data. If the result column exists within the dataframe it is
updated with the aggregated values.

Rounding is performed using rational rounding (e.g., 1.55 rounds to
1.6).

## See also

[`mean()`](https://rdrr.io/r/base/mean.html),
[`sum()`](https://rdrr.io/r/base/sum.html),
[`median()`](https://rdrr.io/r/stats/median.html),
[`min()`](https://rdrr.io/r/base/Extremes.html),
[`max()`](https://rdrr.io/r/base/Extremes.html)

Other string dataframe:
[`ngr_str_df_detect_filter()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_df_detect_filter.md),
[`ngr_str_df_extract()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_df_extract.md)

## Examples

``` r
# Load example data

dat_raw <- data.frame(
  channel_width_m_1 = c(5.0, 4.2, 6.3, NA, 5.5),
  channel_width_m_2 = c(5.5, 4.0, 6.1, NA, 5.8),
  wetted_width_m_1 = c(3.0, 2.8, 3.5, NA, 3.3),
  wetted_width_m_2 = c(3.2, 2.9, 3.4, NA, 3.6),
  residual_pool_m_1 = c(0.8, 0.7, 0.9, NA, 0.85),
  residual_pool_m_2 = c(0.75, 0.65, 0.92, NA, 0.88),
  gradient_percent_1 = c(2.5, 2.0, 3.0, NA, 2.7),
  gradient_percent_2 = c(2.6, 2.1, 3.1, NA, 2.8),
  bankfull_depth_m_1 = c(1.2, 1.1, 1.3, NA, 1.25),
  bankfull_depth_m_2 = c(1.15, 1.05, 1.35, NA, 1.3),
  wetted_width_m_2.channel_width_m_2_time = c("2023-12-01", "2023-12-02", "2023-12-03", NA, "2023-12-05"),
  method_for_wetted_width = c("manual", "manual", "manual", NA, "manual"),
  method_for_channel_width = c("automatic", "automatic", "automatic", NA, "automatic"),
  avg_channel_width_m = NA_real_,
  avg_wetted_width_m = NA_real_,
  average_residual_pool_depth_m = NA_real_,
  average_gradient_percent = NA_real_,
  average_bankfull_depth_m = NA_real_
)

col_str_negate = "time|method|avg|average"
col_str_to_agg <- c("channel_width", "wetted_width", "residual_pool", "gradient", "bankfull_depth")
columns_result <- c("avg_channel_width_m", "avg_wetted_width_m", "average_residual_pool_depth_m", "average_gradient_percent", "average_bankfull_depth_m")

# Initialize dat as a copy of dat_raw to preserve the original and allow cumulative updates
dat <- dat_raw

# Use mapply with cumulative updates
# Suppress mapply output by assigning it to invisible
invisible(mapply(
  FUN = function(col_str_match, col_result) {
    # Update dat cumulatively using double assignment operator to update each already updated version of the dataframe
    dat <<- ngr_str_df_col_agg(
      dat = dat,  # Use the updated dat for each iteration
      col_str_match = col_str_match,
      col_result = col_result,
      col_str_negate = col_str_negate,
      decimal_places = 1
    )
  },
  col_str_match = col_str_to_agg,
  col_result = columns_result
))

# Print the first few rows of the resulting data after subsetting for clarity
dat_subset <- dat[1:5, grep("average|avg", names(dat))]
head(dat_subset)
#>   avg_channel_width_m avg_wetted_width_m average_residual_pool_depth_m
#> 1                 5.3                3.1                           0.8
#> 2                 4.1                2.8                           0.7
#> 3                 6.2                3.5                           0.9
#> 4                  NA                 NA                            NA
#> 5                 5.7                3.5                           0.9
#>   average_gradient_percent average_bankfull_depth_m
#> 1                      2.6                      1.2
#> 2                      2.1                      1.1
#> 3                      3.1                      1.3
#> 4                       NA                       NA
#> 5                      2.8                      1.3
if (FALSE) { # \dontrun{
#'Load the geopackage shipped with the package
path <- system.file("extdata", "form_fiss_site_2024.gpkg", package = "ngr")

dat_raw <- sf::st_read(path)

# Use purrr::reduce with cumulative updates
dat <- purrr::reduce(
  .x = seq_along(col_str_to_agg),
  .f = function(acc_df, i) {
    ngr_str_df_col_agg(
      dat = acc_df,
      col_str_match = col_str_to_agg[i],
      col_result = columns_result[i],
      col_str_negate = col_str_negate,
      decimal_places = 1
    )
  },
  .init = dat_raw
)

# Print the first few rows of the resulting data
# Convert to a plain data.frame
dat_subset <- dat[1:5, grep("average|avg", names(dat))]
head(dat_subset)
} # }
```
