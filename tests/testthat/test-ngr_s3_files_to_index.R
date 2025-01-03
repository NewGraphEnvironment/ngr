test_that("index.html is created in temp directory", {
  # Create temporary directory
  temp_dir <- tempdir()

  # Test file names with s3:// prefix
  files <- c("s3://bucket1/file1.txt", "s3://bucket1/file2.txt", "s3://bucket1/folder1/", "s3://bucket1/folder2/")

  # Run the function
  output_path <- ngr_s3_files_to_index(files, dir_output = temp_dir, filename_output = "index.html", ask = FALSE)

  # Assert the output file exists
  expect_true(file.exists(output_path), info = "index.html should exist in the specified directory.")

  # Clean up
  unlink(output_path)
})


test_that("index.html contains expected HTML structure and links", {
  # Create temporary directory
  temp_dir <- tempdir()

  # Test file names with s3:// paths
  files <- c("s3://bucket1/file1.txt", "s3://bucket1/file2.txt", "s3://bucket1/folder1/", "s3://bucket1/folder2/")

  # Run the function
  output_path <- ngr_s3_files_to_index(files, dir_output = temp_dir, filename_output = "index.html", ask = FALSE)

  # Read the file content
  html_content <- readLines(output_path)

  # Assert basic HTML structure
  expect_true(any(grepl("<!DOCTYPE html>", html_content)), "HTML should contain <!DOCTYPE html>")
  expect_true(any(grepl("<title>S3 Bucket Index</title>", html_content)), "HTML should contain the correct title")

  # Assert HTTPS links are present (assuming ngr_s3_path_to_https converts paths to HTTPS links)
  expect_true(any(grepl("https://", html_content)), "HTML should contain HTTPS links.")

  # Assert specific file and directory links
  expect_true(any(grepl("file1.txt", html_content)), "HTML should contain a link to file1.txt")
  expect_true(any(grepl("folder1", html_content)), "HTML should contain a link to folder1")

  # Clean up
  unlink(output_path)
})



# path_bucket <- s3fs::s3_path("23cog")
# ls_files <- s3fs::s3_dir_ls(path_bucket, glob = "*.tif")
# ngr_s3_files_to_index(ls_files)
#
# s3fs::s3_file_copy(
#   path = "index.html",
#   path_bucket,
#   ContentType = "text/html",
#   overwrite = TRUE
# )
#
# ngr_s3_path_to_https("s3://23cog/index.html")
#
# s3fs::s3_file_info("s3://23cog/index.html")
#
# ls_files |>
#   purrr::map(
#     ~ngr_s3_path_to_https(.x)
#   )

