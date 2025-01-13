path <- system.file("extdata", "pscis_phase1.xlsm", package = "ngr")
result <- ngr_xl_map_formulas(path, sheet = "PSCIS Assessment Worksheet", rowid_colnames = 4, rowid_formulas = c(5, 6))

test_that("ngr_xl_map_formulas produces a dataframe with 8 rows and 7 columns", {
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 8)
  expect_equal(ncol(result), 7)
})

test_that("ngr_xl_map_formulas produces correct formula_with_col_names in the first row", {
  first_row_value <- result$formula_with_col_names[1]
  expected_value <- "IF(ISBLANK(downstream_channel_width_meters), 0, IF(ISBLANK(diameter_or_span_meters) < 0, 0,downstream_channel_width_meters / diameter_or_span_meters))"
  expect_equal(first_row_value, expected_value)
})

test_that("ngr_xl_map_formulas produces correct formula_with_col_names in the 5th row", {
  first_row_value <- result$formula_with_col_names[5]
  expected_value <- "IF(culvert_slope_percent<1,0,IF(AND(culvert_slope_percent>=1,culvert_slope_percent<3),5,IF(culvert_slope_percent>=3,10,0)))"
  expect_equal(first_row_value, expected_value)
})
