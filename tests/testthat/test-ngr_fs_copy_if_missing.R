test_that("ngr_fs_copy_if_missing copies only missing files", {
  dir_in <- fs::dir_create(fs::path(tempfile(), "in/a"))
  dir_out <- fs::dir_create(fs::path(tempfile(), "out"))

  file1 <- fs::file_create(fs::path(dir_in, "test1.txt"))
  file2 <- fs::file_create(fs::path(dir_in, "test2.txt"))

  # Copy all initially
  ngr_fs_copy_if_missing(fs::path_dir(dir_in), dir_out)

  expect_true(fs::file_exists(fs::path(dir_out, "a", "test1.txt")))
  expect_true(fs::file_exists(fs::path(dir_out, "a", "test2.txt")))

  # Overwrite prevention check
  fs::file_delete(fs::path(dir_in, "test2.txt"))
  fs::file_create(fs::path(dir_in, "test3.txt"))

  ngr_fs_copy_if_missing(fs::path_dir(dir_in), dir_out)

  expect_true(fs::file_exists(fs::path(dir_out, "a", "test1.txt")))
  expect_true(fs::file_exists(fs::path(dir_out, "a", "test2.txt"))) # still there
  expect_true(fs::file_exists(fs::path(dir_out, "a", "test3.txt"))) # newly copied
})
