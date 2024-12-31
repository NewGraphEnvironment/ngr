test_that("ngr_str_df_detect_filter fails when multiple columns match col_filter", {
  df <- data.frame(
    project_name = c("A", "B", "C"),
    project_status = c("Active", "Inactive", "Completed"),
    value = c(1, 2, 3)
  )

  expect_error(
    ngr_str_df_detect_filter(df, "project", "Active"),
    "Multiple columns match the col_filter: project_name, project_status. Please refine your filter."
  )
})

test_that("ngr_str_df_detect_filter filters rows based on string detection", {
  df <- data.frame(
    project_name = c("A", "B", "C"),
    project_status = c("Active", "Active", "Completed"),
    value = c(1, 2, 3)
  )

  expect_equal(
    ngr_str_df_detect_filter(df, "project_status", "Active"),
    data.frame(
      project_name = c("A","B"),
      project_status = c("Active","Active"),
      value = c(1,2)
    )
  )
})

test_that("ngr_str_df_detect_filter returns the dataframe unchanged if the col_filter param is not detected in the col names", {
  df <- data.frame(
    project_name = c("A", "B", "C"),
    project_status = c("Active", "Active", "Completed"),
    value = c(1, 2, 3)
  )

  expect_equal(
    ngr_str_df_detect_filter(df, "project_type", "Active"),
    df
  )
})
