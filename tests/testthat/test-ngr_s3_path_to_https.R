test_that("ngr_s3_path_to_https produces correct URL with default parameters", {
  s3_path <- "s3://my-bucket/my-object.txt"
  expected_url <- "https://my-bucket.s3.amazonaws.com/my-object.txt"
  result <- ngr_s3_path_to_https(s3_path)
  expect_equal(result, expected_url)
})


test_that("ngr_s3_path_to_https produces correct URL when website = TRUE", {
  s3_path <- "s3://my-bucket/my-object.txt"
  expected_url <- "http://my-bucket.s3-website-us-west-2.amazonaws.com/my-object.txt"
  result <- ngr_s3_path_to_https(s3_path, website = TRUE)
  expect_equal(result, expected_url)
})

