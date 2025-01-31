path <- system.file("extdata", "test1.tif", package = "ngr")
crs_out <- "EPSG:32609"
result <- ngr_spk_res(path, crs_out)

test_that("ngr_spk_res gives expected result", {
  expect_equal(result, c(20, 20))
})
