test_that("ngr_str_replace_filenames renames and skips correctly", {
  # Mock inputs
  path <- tempfile()  # Temporary directory for testing
  dir.create(path)

  # Create mock files
  files <- c(
    "tests/testthat/ngr_sed_replace_in_files1.txt",
    "tests/testthat/ngr_sed_replace_in_files2.txt",
    "tests/testthat/ngr_sed_replace1.txt",
    "ngr_sed_replace.txt"
  )
  file_paths <- file.path(path, files)
  fs::dir_create(unique(dirname(file_paths)))  # Ensure directories exist
  for (file in file_paths) file.create(file)  # Create empty files

  text_current <- "ngr_sed_replace"
  text_replace <- "ngr_sed_replace_in_files"

  # Call the function
  ngr_str_replace_filenames(
    path = path,
    text_current = text_current,
    text_replace = text_replace,
    ask = FALSE
  )

  # Expected results
  expected_renamed <- c(
    "ngr_sed_replace_in_files1.txt",
    "ngr_sed_replace_in_files.txt"
  ) |>
    fs::path_file()

  expected_skipped <- c(
    "tests/testthat/ngr_sed_replace_in_files1.txt",
    "tests/testthat/ngr_sed_replace_in_files2.txt"
  ) |>
    fs::path_file()

  # Check the renamed files
  renamed_files <- fs::path_file(
    fs::dir_ls(path, recurse = TRUE, type = "file")
  )

  # Assertions
  expect_true(all(expected_renamed %in% renamed_files))  # Ensure renamed files are correct
  expect_true(all(expected_skipped %in% renamed_files))  # Ensure skipped files are still present

  # Cleanup
  unlink(path, recursive = TRUE)
})



