# One-page bucket listing in the S3 ListBucketResult shape, so the join can be
# tested without the network.
s3_listing_mock <- function(keys) {
  xml <- paste0(
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">',
    "<IsTruncated>false</IsTruncated>",
    paste0("<Contents><Key>", keys, "</Key></Contents>", collapse = ""),
    "</ListBucketResult>"
  )
  testthat::local_mocked_bindings(
    GET = function(...) "response",
    status_code = function(...) 200L,
    content = function(...) xml,
    .package = "httr",
    .env = parent.frame()
  )
}

test_that("ngr_s3_keys_get returns URLs that keep the scheme's double slash", {
  s3_listing_mock(c("093/093l/2019/dem/a.tif", "093/093l/2019/dem/b.tif"))
  urls <- ngr_s3_keys_get("https://nrs.objectstore.gov.bc.ca/gdwuts")
  expect_equal(urls, c(
    "https://nrs.objectstore.gov.bc.ca/gdwuts/093/093l/2019/dem/a.tif",
    "https://nrs.objectstore.gov.bc.ca/gdwuts/093/093l/2019/dem/b.tif"
  ))
})

test_that("ngr_s3_keys_get does not double the separator after a trailing slash", {
  s3_listing_mock("093/093l/2019/dem/a.tif")
  urls <- ngr_s3_keys_get("https://nrs.objectstore.gov.bc.ca/gdwuts/")
  expect_equal(urls, "https://nrs.objectstore.gov.bc.ca/gdwuts/093/093l/2019/dem/a.tif")
})

test_that("ngr_s3_keys_get returns an empty character vector when nothing matches", {
  s3_listing_mock("093/093l/2019/dem/a.tif")
  urls <- ngr_s3_keys_get("https://nrs.objectstore.gov.bc.ca/gdwuts", pattern = "dsm")
  expect_identical(urls, character())
})

test_that("ngr_s3_keys_get returns https:// URLs from the live objectstore", {
  skip_on_cran()
  skip_if_offline("nrs.objectstore.gov.bc.ca")
  urls <- ngr_s3_keys_get(
    "https://nrs.objectstore.gov.bc.ca/gdwuts",
    prefix = "093/093l/2019/dem/",
    pattern = "*.tif"
  )
  expect_gt(length(urls), 0)
  expect_true(all(startsWith(urls, "https://nrs.objectstore.gov.bc.ca/gdwuts/093/093l/2019/dem/")))
})
