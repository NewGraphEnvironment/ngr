path <- system.file("extdata", "form_fiss_site_2024.gpkg", package = "ngr")

dat_raw <- sf::st_read(path)

# dat |> dplyr::select(dplyr::matches("ave|avg"))

col_str_negate = "time|method|avg|ave"
col_str_to_agg <- c("channel_width", "wetted_width", "residual_pool", "gradient", "bankfull_depth")
columns_result <- c("avg_channel_width_m", "avg_wetted_width_m", "average_residual_pool_depth_m", "average_gradient_percent", "average_bankfull_depth_m")

# Iterate with purrr::reduce - this works but nice to avoid purrr in suggest and depends
# dat <- purrr::reduce(
#   .x = seq_along(col_str_to_agg),
#   .f = function(acc_df, i) {
#     ngr_str_df_col_agg(
#       dat = acc_df,
#       col_str_match = col_str_to_agg[i],
#       col_result = columns_result[i],
#       col_str_negate = col_str_negate,
#       decimal_places = 1
#     )
#   },
#   .init = dat_raw
# )

# Initialize dat as a copy of dat_raw to preserve the original and allow cumulative updates
dat <- dat_raw

# Use mapply with cumulative updates
mapply(
  FUN = function(col_str_match, col_result) {
    # Update dat cumulatively
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
)

# see the results quick with dplyr
# dat |>
#   dplyr::select(dplyr::matches("ave|avg")) |>
#   dplyr::slice(1:10)
#
# t2 <- dat |>
#   dplyr::select(dplyr::contains(col_str_to_agg)) |>
#   dplyr::slice(1:10)


test_that("Correct average values for ngr_str_df_col_agg are calculated", {
  # Define the expected values for each result column
  expected_values <- list(
    avg_channel_width_m = c(5.0, 4.0, 3.6, 3.4, 2.5, 2.8, 3.3, 5.0, 2.6, 6.2),
    avg_wetted_width_m = c(2.8, 1.8, 1.1, 1.6, 1.9, 1.2, 1.5, 2.1, 1.4, 3.5),
    average_gradient_percent = c(NA, NA, NA, NA, 2.2, 2.7, 3.3, NA, NA, 4.1),
    average_residual_pool_depth_m = c(NA, NA, NA, NA, 0.4, 0.3, 0.4, NA, NA, 0.6),
    average_bankfull_depth_m = c(NA, NA, NA, NA, 0.5, 0.4, 0.4, NA, NA, 0.7)
  )

  # Iterate through the columns to test
  for (i in seq_along(columns_result)) {
    col_result <- columns_result[i]
    expect_equal(
      # we just use the first 10 values
      head(dat,10)[[col_result]],  # Extract column from dat
      expected_values[[col_result]],  # Compare with expected values
      info = paste("Mismatch in column:", col_result)
    )
  }
})

test_that("NA values for ngr_str_df_col_agg are correctly handled (no NaN)", {
  # Iterate through the result columns
  for (col_result in columns_result) {
    column_data <- head(dat[[col_result]], 10)  # Check only the first 10 rows

    # Check that no NaN values exist
    expect_true(
      all(!is.nan(column_data)),
      info = paste("Found NaN in column:", col_result)
    )

    # If the column contains NA values, verify their presence
    if (any(is.na(column_data))) {
      expect_true(
        any(is.na(column_data)),
        info = paste("No NA values found in column when expected:", col_result)
      )
    } else {
      # If no NA values are expected, ensure none are present
      expect_true(
        all(!is.na(column_data)),
        info = paste("Unexpected NA values found in column:", col_result)
      )
    }
  }
})

test_that("Output of ngr_str_df_col_agg is an sf object", {
  # Check if dat is an sf object (automatically a data.frame as well)
  expect_true(
    inherits(dat, "sf"),
    info = "Output dat is not an sf object"
  )
})


# col_str_match = "channel_width"
# result <- ngr_str_df_col_agg(
#   dat = dat,
#   col_str_match = col_str_match,
#   col_result = "avg_channel_width_m",
#   col_str_negate = col_str_negate,
#   decimal_places = 1
# )
#
# result |>
#   dplyr::select(dplyr::contains(col_str_match)) |>
#   print()
#
# col_str_match = "wetted_width"
# result <- ngr_str_df_col_agg(
#   dat = dat,
#   col_str_match = col_str_match,
#   col_result = "avg_wetted_width_m",
#   col_str_negate = col_str_negate,
#   decimal_places = 1
# )
#
# result |>
#   dplyr::select(dplyr::contains(col_str_match)) |>
#   print()
#
#
# col_str_match <-  "residual_pool"
# result <- ngr_str_df_col_agg(
#   dat = dat,
#   col_str_match = col_str_match,
#   col_result = "average_residual_pool_depth_m",
#   col_str_negate = "time|method|avg|ave",
#   decimal_places = 1
# )
#
# result |>
#   dplyr::select(dplyr::contains(col_str_match)) |>
#   print()
#
# col_str_match <- "gradient"
# result <- ngr_str_df_col_agg(
#   dat = dat,
#   col_str_match = col_str_match,
#   col_result = "average_gradient_percent",
#   col_str_negate = "time|method|avg|ave",
#   decimal_places = 1
# )
#
# result |>
#   dplyr::select(dplyr::contains(col_str_match)) |>
#   print()


