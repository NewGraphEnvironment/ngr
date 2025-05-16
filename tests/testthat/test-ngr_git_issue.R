test_that("ngr_git_issue returns a tibble", {
  result <- ngr_git_issue(
    owner = "NewGraphEnvironment",
    repo = "ngr",
    date_since = "2024-01-01",
    token = NULL
  )

  expect_s3_class(result, "tbl_df")
})
