

# Test suite for ngr_tidy_cols_rm_na
test_that("ngr_tidy_cols_rm_na works as expected", {
  # Test: Removes columns with all NA values
  df <- data.frame(
    A = c(NA, NA, NA),
    B = c(1, 2, NA),
    C = c(NA, NA, NA),
    D = c("x", "y", NA)
  )
  result <- ngr_tidy_cols_rm_na(df)
  expect_equal(names(result), c("B", "D")) # Only B and D should remain
  expect_equal(nrow(result), nrow(df))    # Number of rows should remain unchanged


  # Test: Handles empty data.frame
  empty_df <- data.frame()
  result_empty <- ngr_tidy_cols_rm_na(empty_df)
  expect_equal(ncol(result_empty), 0) # Should return an empty data frame

  # Test: Handles data.frame with no NA columns
  df_no_na <- data.frame(
    A = c(1, 2, 3),
    B = c("x", "y", "z")
  )
  result_no_na <- ngr_tidy_cols_rm_na(df_no_na)
  expect_equal(result_no_na, df_no_na) # Should return the same data frame

  # Test: Works with mixed NA and non-NA values
  df_mixed <- data.frame(
    A = c(NA, NA, NA),
    B = c(1, 2, 3),
    C = c(NA, 2, 3),
    D = c("x", "y", NA)
  )
  result_mixed <- ngr_tidy_cols_rm_na(df_mixed)
  expect_equal(names(result_mixed), c("B", "C", "D")) # A should be removed
})

