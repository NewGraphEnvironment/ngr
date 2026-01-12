test_that("ngr_fs_type_write and ngr_fs_type_read round-trip preserves basic types", {
  df <- data.frame(
    int_col = 1:3L,
    dbl_col = c(1.1, 2.2, 3.3),
    chr_col = c("a", "b", "c"),
    lgl_col = c(TRUE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )

  path <- tempfile(fileext = ".csv")
  ngr_fs_type_write(df, path)

  # Check files exist
  schema_path <- sub("\\.csv$", "_schema.parquet", path)
  expect_true(file.exists(path))
  expect_true(file.exists(schema_path))

  # Read back and compare types

  df2 <- ngr_fs_type_read(path)

  expect_type(df2$int_col, "integer")
  expect_type(df2$dbl_col, "double")
  expect_type(df2$chr_col, "character")
  expect_type(df2$lgl_col, "logical")

  # Compare values

  expect_equal(df2$int_col, df$int_col)
  expect_equal(df2$dbl_col, df$dbl_col)
  expect_equal(df2$chr_col, df$chr_col)
  expect_equal(df2$lgl_col, df$lgl_col)
})

test_that("ngr_fs_type preserves types for columns with all NA values", {
  # This is the key case - columns defined as specific types but containing only NAs
  df <- data.frame(
    int_col = c(NA_integer_, NA_integer_, NA_integer_),
    dbl_col = c(NA_real_, NA_real_, NA_real_),
    chr_col = c(NA_character_, NA_character_, NA_character_),
    lgl_col = c(NA, NA, NA),
    stringsAsFactors = FALSE
  )

  path <- tempfile(fileext = ".csv")
  ngr_fs_type_write(df, path)
  df2 <- ngr_fs_type_read(path)

  # Types should be preserved even though all values are NA
  expect_type(df2$int_col, "integer")
  expect_type(df2$dbl_col, "double")
  expect_type(df2$chr_col, "character")
  expect_type(df2$lgl_col, "logical")
})

test_that("ngr_fs_type preserves types for columns with mixed values and NAs", {
  df <- data.frame(
    int_col = c(1L, NA_integer_, 3L),
    dbl_col = c(1.1, NA_real_, 3.3),
    chr_col = c("a", NA_character_, "c"),
    lgl_col = c(TRUE, NA, FALSE),
    stringsAsFactors = FALSE
  )

  path <- tempfile(fileext = ".csv")
  ngr_fs_type_write(df, path)
  df2 <- ngr_fs_type_read(path)

  expect_type(df2$int_col, "integer")
  expect_type(df2$dbl_col, "double")
  expect_type(df2$chr_col, "character")
  expect_type(df2$lgl_col, "logical")

  # Check NA positions preserved
  expect_true(is.na(df2$int_col[2]))
  expect_true(is.na(df2$dbl_col[2]))
  expect_true(is.na(df2$chr_col[2]))
  expect_true(is.na(df2$lgl_col[2]))

  # Check non-NA values
  expect_equal(df2$int_col[c(1, 3)], c(1L, 3L))
  expect_equal(df2$dbl_col[c(1, 3)], c(1.1, 3.3))
  expect_equal(df2$chr_col[c(1, 3)], c("a", "c"))
  expect_equal(df2$lgl_col[c(1, 3)], c(TRUE, FALSE))
})

test_that("ngr_fs_type preserves Date columns", {
  df <- data.frame(
    date_col = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03")),
    stringsAsFactors = FALSE
  )

  path <- tempfile(fileext = ".csv")
  ngr_fs_type_write(df, path)
  df2 <- ngr_fs_type_read(path)

  expect_s3_class(df2$date_col, "Date")
  expect_equal(df2$date_col, df$date_col)
})

test_that("ngr_fs_type preserves Date columns with all NAs", {
  df <- data.frame(
    date_col = as.Date(c(NA, NA, NA)),
    stringsAsFactors = FALSE
  )

  path <- tempfile(fileext = ".csv")
  ngr_fs_type_write(df, path)
  df2 <- ngr_fs_type_read(path)

  expect_s3_class(df2$date_col, "Date")
  expect_true(all(is.na(df2$date_col)))
})

test_that("ngr_fs_type creates directory if it doesn't exist", {
  df <- data.frame(x = 1:3)
  path <- file.path(tempfile(), "subdir", "test.csv")

  ngr_fs_type_write(df, path)

  expect_true(file.exists(path))
  expect_true(file.exists(sub("\\.csv$", "_schema.parquet", path)))
})

test_that("ngr_fs_type_read errors when schema file missing", {
  path <- tempfile(fileext = ".csv")
  writeLines("a,b,c\n1,2,3", path)

  expect_error(ngr_fs_type_read(path))
})

test_that("ngr_fs_type works with empty schema_suffix", {
  df <- data.frame(x = 1:3L, y = c("a", "b", "c"), stringsAsFactors = FALSE)
  path <- tempfile(fileext = ".csv")

  ngr_fs_type_write(df, path, schema_suffix = "")

  # Schema file should be data.parquet (no suffix)
  schema_path <- sub("\\.csv$", ".parquet", path)
  expect_true(file.exists(schema_path))

  df2 <- ngr_fs_type_read(path, schema_suffix = "")
  expect_type(df2$x, "integer")
  expect_type(df2$y, "character")
})

test_that("ngr_fs_type works with custom schema_suffix", {
  df <- data.frame(x = 1:3L, stringsAsFactors = FALSE)
  path <- tempfile(fileext = ".csv")

  ngr_fs_type_write(df, path, schema_suffix = "types")

  # Schema file should be data_types.parquet
  schema_path <- sub("\\.csv$", "_types.parquet", path)
  expect_true(file.exists(schema_path))

  df2 <- ngr_fs_type_read(path, schema_suffix = "types")
  expect_type(df2$x, "integer")
})

test_that("ngr_fs_type_write with schema_only writes only schema file", {
  df <- data.frame(x = 1:3L, y = c("a", "b", "c"), stringsAsFactors = FALSE)
  path <- tempfile(fileext = ".csv")
  schema_path <- sub("\\.csv$", "_schema.parquet", path)

  ngr_fs_type_write(df, path, schema_only = TRUE)

  # Schema file should exist, data file should not

  expect_true(file.exists(schema_path))
  expect_false(file.exists(path))

  # Schema should have correct types
  schema <- arrow::schema(arrow::read_parquet(schema_path))
  expect_equal(length(schema), 2L)
})
