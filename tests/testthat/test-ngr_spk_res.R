path <- system.file("extdata", "test.tif", package = "ngr")
crs_out <- "EPSG:32609"
result <- ngr_spk_res(path, crs_out)

test_that("ngr_spk_res gives result of 3m x 3m", {
  expect_equal(result, c(3, 3))
})
