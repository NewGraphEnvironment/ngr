test_that("Detects temp files in temp directories", {
  # Create a temp directory
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "testfile.txt")

  # Create a temporary file
  writeLines("Sample content", temp_file)

  # Test detection
  result <- ngr_str_dir_from_file(temp_dir, "testfile.txt")
  expect_equal(result, temp_dir)

  # Clean up
  unlink(temp_file)
})

test_that("Throws warning for partial string matches and returns NULL", {
  # Create a temp directory
  temp_dir <- tempdir()
  partial_file <- file.path(temp_dir, "testfile_partial.txt")

  # Create a file with a partial name match
  writeLines("Sample content", partial_file)

  # Test for cli warning and result
  expect_message(
    result <- ngr_str_dir_from_file(temp_dir, "testfile.txt"),
    regexp = "No file matching 'testfile.txt' was found in"
  )
  expect_null(result)

  # Clean up
  unlink(partial_file)
})

