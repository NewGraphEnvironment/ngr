test_that("ngr_git_issue_details returns a tibble", {
  result <- ngr_git_issue_details("https://api.github.com/repos/NewGraphEnvironment/fpr/issues/13", events_all = TRUE)

  expect_s3_class(result, "tbl_df")
})
