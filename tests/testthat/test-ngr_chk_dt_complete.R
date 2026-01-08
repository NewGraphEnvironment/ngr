# test data
dates_ok <- as.Date("2024-01-01") + 0:4
dates_bad <- as.Date(c("2024-01-01", "2024-01-02", "2024-01-04"))


testthat::test_that("ngr_chk_dt_complete returns nothing for complete date sequences", {
  res <- ngr_chk_dt_complete(dates_ok)
  testthat::expect_true(res)
})

testthat::test_that("ngr_chk_dt_complete returns FALSE for incomplete date sequences", {
  res <- ngr_chk_dt_complete(dates_bad)
  testthat::expect_false(res)
})

testthat::test_that("ngr_chk_dt_complete returns dates when dates_capture = TRUE", {
  res <- ngr_chk_dt_complete(dates_bad, dates_capture = TRUE)
  testthat::expect_identical(res, as.Date("2024-01-03"))

})
