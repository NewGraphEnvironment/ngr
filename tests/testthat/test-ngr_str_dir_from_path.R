test_that("ngr_str_dir_from_path works correctly", {
  # Mock input
  input_path <- "~/Projects/repo/ngr/data-raw/extdata.R"

  # Expected output
  expected_output <- "ngr"

  # Test the function
  result <- ngr_str_dir_from_path(input_path, levels = 2)

  # Assert equality
  expect_equal(result, expected_output)
})
