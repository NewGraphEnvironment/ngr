# tests/testthat/test-ngr_str_extract_between.R

# Test data (reusable across tests)
x <- c(
  "Grant Amount: $400,000 Intake Year: 2025",
  "Grant Amount: $150,500 Intake Year: 2024"
)

# Colon required when explicitly included in start pattern
# Expect dollars without the leading colon/space

testthat::test_that("extracts after colon", {
  out <- ngr::ngr_str_extract_between(x, reg_start = "Amount:", reg_end = "Intake")
  testthat::expect_equal(out, c("$400,000", "$150,500"))
})

# When start pattern is 'Amount' (no colon), current behavior keeps the literal ': '
# before the captured value in these examples

testthat::test_that("extracts including leading colon", {
  out <- ngr::ngr_str_extract_between(x, reg_start = "Amount", reg_end = "Intake")
  testthat::expect_equal(out, c(": $400,000", ": $150,500"))
})
