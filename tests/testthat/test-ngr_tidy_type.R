test_that("ngr_tidy_type coerces types correctly and preserves non-overlapping columns", {
  dat_w_types <- data.frame(
    test = as.numeric(1:3),             # numeric
    this = as.character(letters[1:3])   # character
  )

  dat_to_type <- data.frame(
    test = as.character(c("1", "2", "3")),  # character, should be coerced to numeric
    this = factor(c("a", "b", "c")),        # factor, should be coerced to character
    action = letters[1:3]                     # not in reference, should remain untouched
  )

  result <- ngr_tidy_type(dat_w_types, dat_to_type)

  expect_equal(class(result$test), "numeric")
  expect_equal(class(result$this), "character")
  expect_equal(class(result$action), "character")  # should remain as-is
  expect_equal(result$test, 1:3)
})

test_that("ngr_tidy_type throws a warning with informative message on failed coercion", {
  dat_w_types <- data.frame(a = as.numeric(1:3))
  dat_to_type <- data.frame(a = c("1", "2", "not_a_number", "also_not_a_number"))

  expect_warning(
    ngr_tidy_type(dat_w_types, dat_to_type),
    "Coercion of column a to numeric introduced NAs."
  )
})

test_that("full informative error is shown on failed coercion", {
  dat_w_types <- data.frame(a = as.numeric(1:4))
  dat_to_type <- data.frame(a = c("bad", "worse", "worst", "trash"))

  expect_snapshot(error = TRUE, {
    ngr_tidy_type(dat_w_types, dat_to_type)
  })
})

