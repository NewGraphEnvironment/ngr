# The twelve ngr_spk_* functions are deprecation shims over spacehakr (ngr#7).
# Their behaviour is spacehakr's to test — spacehakr carries near-identical
# copies of the six behaviour test files that used to live here. What ngr still
# owns, and what this file asserts, is the shim contract:
#
#   1. calling it emits a deprecation warning
#   2. the call reaches the spacehakr function, not a local copy
#   3. arguments arrive unchanged
#
# `lifecycle::expect_deprecated()` rather than a bare
# `expect_warning(class = "lifecycle_warning_deprecated")`: deprecate_warn()
# dedupes by message on an 8-hour window, so a raw expectation passes on a cold
# run and fails on a warm one. expect_deprecated() sets
# lifecycle_verbosity = "warning" for its scope, which defeats the throttle.

shims <- c(
  ngr_spk_gdalwarp       = "spk_gdalwarp",
  ngr_spk_geoserv_dlv    = "spk_geoserv_dlv",
  ngr_spk_join           = "spk_join",
  ngr_spk_layer_info     = "spk_layer_info",
  ngr_spk_odm            = "spk_odm",
  ngr_spk_poly_to_points = "spk_poly_to_points",
  ngr_spk_q_layer_info   = "spk_q_layer_info",
  ngr_spk_rast_ext       = "spk_rast_ext",
  ngr_spk_rast_not_empty = "spk_rast_not_empty",
  ngr_spk_rast_rm_empty  = "spk_rast_rm_empty",
  ngr_spk_res            = "spk_res",
  ngr_spk_stac_calc      = "spk_stac_calc"
)

test_that("the shim set covers every exported ngr_spk_* function", {
  # Premise, not decoration: if a thirteenth shim is added and not listed above,
  # every per-shim test below still passes while the new one goes unchecked.
  exported <- grep("^ngr_spk_", getNamespaceExports("ngr"), value = TRUE)
  expect_setequal(names(shims), exported)
  expect_equal(length(shims), 12L)
})

test_that("every shim names a function spacehakr actually exports", {
  skip_if_not_installed("spacehakr")
  # mockery::stub() replaces the call without ever resolving the real symbol, so
  # a typo'd delegation target passes every test below and fails at a user's
  # first call. This is the only assertion that touches the real spacehakr.
  targets <- unlist(lapply(
    list.files("../../R", pattern = "^ngr_spk_.*\\.R$", full.names = TRUE),
    function(f) {
      l <- readLines(f, warn = FALSE)
      unique(regmatches(l, regexpr("spacehakr::spk_[A-Za-z0-9_]+", l)))
    }
  ))
  targets <- unique(sub("spacehakr::", "", targets))

  expect_equal(length(targets), 12L)          # premise: the scan actually found them
  expect_setequal(targets, unname(shims))     # and they are the twelve we mock
  expect_setequal(setdiff(targets, getNamespaceExports("spacehakr")), character(0))
})

for (ngr_fn in names(shims)) {
  spk_fn <- shims[[ngr_fn]]

  test_that(paste0(ngr_fn, "() warns as deprecated and delegates to spacehakr::", spk_fn, "()"), {
    skip_if_not_installed("mockery")

    f <- get(ngr_fn, envir = asNamespace("ngr"))
    seen <- NULL
    mockery::stub(
      f,
      paste0("spacehakr::", spk_fn),
      function(...) {
        seen <<- list(...)
        "SENTINEL"
      }
    )

    lifecycle::expect_deprecated(out <- f("arg_one", key = "arg_two"))

    # Reached spacehakr, not a surviving local implementation.
    expect_identical(out, "SENTINEL")
    # Arguments forwarded unchanged, positional and named alike.
    expect_identical(seen[[1]], "arg_one")
    expect_identical(seen$key, "arg_two")
  })
}
