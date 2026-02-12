test_that("ngr_str_viewer_cog generates valid iframe with cache-busting parameter", {
  url <- "https://stac-dem-bc.s3.us-west-2.amazonaws.com/dem_pouce_coupe_2023.tif"
  result <- ngr_str_viewer_cog(url)

  expected <- paste0(
    '<iframe src="https://viewer.a11s.one/?v=2&cog=', url, '" ',
    'scrolling="no" ',
    'title="COG Viewer" ',
    'width="100%" ',
    'height="600" ',
    'frameBorder="0">',
    '</iframe>'
  )
  expect_equal(result, expected)
})

test_that("ngr_str_viewer_cog respects custom version parameter", {
  url <- "https://bucket.s3.amazonaws.com/ortho.tif"
  result <- ngr_str_viewer_cog(url, v = 3L)
  expect_match(result, "v=3&cog=", fixed = TRUE)
})

test_that("ngr_str_viewer_cog respects custom dimensions", {
  url <- "https://bucket.s3.amazonaws.com/ortho.tif"
  result <- ngr_str_viewer_cog(url, width = "80%", height = "400")
  expect_match(result, 'width="80%"', fixed = TRUE)
  expect_match(result, 'height="400"', fixed = TRUE)
})

test_that("ngr_str_viewer_cog validates inputs", {
  expect_error(ngr_str_viewer_cog(123))
  expect_error(ngr_str_viewer_cog("url", v = 1.5))
  expect_error(ngr_str_viewer_cog(c("url1", "url2")))
})
