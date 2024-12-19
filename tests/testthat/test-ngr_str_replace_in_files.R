test_that("ngr_str_replace_in_files handles @citation keys and avoids duplicate replacements", {
  # Create temporary files
  temp_file1 <- tempfile(fileext = ".txt")
  temp_file2 <- tempfile(fileext = ".txt")

  # Write initial content to the files
  writeLines(c(
    "This is a reference to @citation_key1 in text.",
    "Another @citation_key1 example in this file.",
    "A different key like @citation_key2 appears here."
  ), temp_file1)

  writeLines(c(
    "@citation_key1 already replaced here.",
    "Unrelated text without citations.",
    "Another instance of @citation_key2 in this file."
  ), temp_file2)

  # Define files and replacements
  files <- c(temp_file1, temp_file2)
  keys_matched <- data.frame(
    key_missing = c("citation_key1", "citation_key2"),
    key_missing_guess_match = c("CitationKeyOne", "CitationKeyTwo"),
    stringsAsFactors = FALSE
  )

  # Apply replacements using the function
  for (i in seq_len(nrow(keys_matched))) {
    ngr_str_replace_in_files(
      text_current = keys_matched$key_missing[i],
      text_replace = keys_matched$key_missing_guess_match[i],
      files = files,
      ask = FALSE # Disable ask for testing
    )
  }

  # Read back the modified files
  output1 <- readLines(temp_file1)
  output2 <- readLines(temp_file2)

  # Test expectations
  # Ensure all occurrences of the original keys are gone
  expect_false(any(grepl("citation_key1", c(output1, output2))))
  expect_false(any(grepl("citation_key2", c(output1, output2))))

  # Ensure replacements are present and correct
  expect_true(any(grepl("@CitationKeyOne", output1)))
  expect_true(any(grepl("@CitationKeyTwo", output1)))
  expect_true(any(grepl("@CitationKeyTwo", output2)))

  # Ensure no duplicate replacements or broken lines
  expect_true(all(!grepl("CitationKeyOneCitationKeyOne", c(output1, output2))))
  expect_true(all(!grepl("CitationKeyTwoCitationKeyTwo", c(output1, output2))))

  # Clean up
  file.remove(temp_file1, temp_file2)
})


test_that("ngr_str_replace_in_files asks for user confirmation when ask = TRUE", {
  # Skip test if mockery is not installed
  if (!requireNamespace("mockery", quietly = TRUE)) {
    skip("mockery package not installed")
  }

  # Create temporary files with test content
  temp_file <- tempfile(fileext = ".txt")
  temp_file2 <- tempfile(fileext = ".txt")
  writeLines(c(
    "This is a reference to @citation_key1 in text.",
    "Another @citation_key1 example in this file.",
    "A different key like @citation_key2 appears here."
  ), temp_file)
  writeLines(c(
    "This is a reference to @citation_key1 in text.",
    "Another @citation_key1 example in this file.",
    "A different key like @citation_key2 appears here."
  ), temp_file2)

  # Use mockery to stub readline
  readline_mock <- mockery::mock("y", cycle = TRUE) # Simulate "y" input for readline

  # Stub readline to use the mock
  mockery::stub(ngr_str_replace_in_files, "readline", readline_mock)

  # Capture CLI messages
  messages <- testthat::capture_messages(
    ngr_str_replace_in_files(
      text_current = "citation_key1",
      text_replace = "CitationKeyOne",
      files = c(temp_file, temp_file2),
      ask = TRUE
    )
  )

  # Assertions
  expect_true(any(grepl("Line 1: This is a reference to @citation_key1 in text.", messages)))
  expect_true(any(grepl("Line 2: Another @citation_key1 example in this file.", messages)))
  mockery::expect_called(readline_mock, 2)

  # Clean up
  file.remove(temp_file, temp_file2)
})



test_that("ngr_str_replace_in_files replaces colors correctly in multiple files", {
  # Define the content for the first test file
  content1 <- c(
    "This line is red and green.",
    "This line is blue, and over here it is green.",
    "Another line with red, green, and violet."
  )

  # Define the content for the second test file with a different row order
  content2 <- c(
    "Green and yellow are here.",
    "Violet is here, and blue is here too.",
    "Red, green, and orange are everywhere!"
  )

  # Create temporary files and write the content
  temp_file1 <- tempfile(fileext = ".txt")
  temp_file2 <- tempfile(fileext = ".txt")
  writeLines(content1, temp_file1)
  writeLines(content2, temp_file2)

  # Define test parameters
  text_current <- "green"
  text_replace <- "black"

  # Run the function on both files
  ngr_str_replace_in_files(
    text_current = text_current,
    text_replace = text_replace,
    files = c(temp_file1, temp_file2),
    ask = FALSE # Disable user confirmation for testing
  )

  # Read the updated content of both files
  updated_content1 <- readLines(temp_file1)
  updated_content2 <- readLines(temp_file2)

  # Assert that replacements occurred correctly in both files
  expect_false(any(grepl("green", updated_content1))) # "green" should not exist in file1
  expect_true(any(grepl("black", updated_content1)))  # "black" should exist in file1

  expect_false(any(grepl("green", updated_content2))) # "green" should not exist in file2
  expect_true(any(grepl("black", updated_content2)))  # "black" should exist in file2

  # Clean up temporary files
  file.remove(temp_file1, temp_file2)
})

test_that("ngr_str_replace_in_files aborts if .git files are in the input list", {
  # Create temporary files to simulate valid files and a .git file
  temp_file1 <- tempfile(fileext = ".txt")
  temp_file2 <- tempfile(fileext = ".txt")
  temp_git_file <- tempfile(tmpdir = ".git", fileext = ".txt") # Simulate a .git file

  # Write content to temporary files
  writeLines("This is a test file.", temp_file1)
  writeLines("This is another test file.", temp_file2)

  # Ensure the .git directory exists before creating the test file
  if (!dir.exists(".git")) {
    dir.create(".git", recursive = TRUE)
  }
  writeLines("This is a .git file.", temp_git_file)

  # Combine files into a list
  files <- c(temp_file1, temp_file2, temp_git_file)

  # Define test parameters
  text_current <- "test"
  text_replace <- "example"

  # Expect the function to abort with an error containing ".git directories are not allowed"
  expect_error(
    ngr_str_replace_in_files(
      text_current = text_current,
      text_replace = text_replace,
      files = files,
      ask = FALSE
    ),
    regexp = "\\.git directories are not allowed"
  )

  # Clean up temporary files and directories
  file.remove(temp_file1, temp_file2, temp_git_file)
  unlink(".git", recursive = TRUE)
})



