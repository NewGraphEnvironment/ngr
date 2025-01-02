test_that("ngr_tidy_cols_type_compare gives correct number of FALSE flags for inconsistent columns", {
  # Example data
  nested_list_df <- list(
    df1 = data.frame(a = 1:3, b = c("x", "y", "z"), c = as.Date("2023-01-01") + 0:2, stringsAsFactors = FALSE),
    df2 = data.frame(a = c(1.1, 2.2, 3.3), b = c("x", "y", "z"), c = c(TRUE, FALSE, TRUE), stringsAsFactors = FALSE),
    df3 = data.frame(a = c("one", "two", "three"), b = c("x", "y", "z"), c = as.Date("2023-01-01") + 0:2, stringsAsFactors = FALSE)
  )

  # Run the function
  result_df <- ngr_tidy_cols_type_compare(nested_list_df)

  # Count the number of FALSE flags
  false_count <- sum(!result_df$consistent)

  # Expected number of inconsistent columns
  expected_false_count <- 2

  # Test
  expect_equal(false_count, expected_false_count, info = "The number of inconsistent columns should be 2.")
})
