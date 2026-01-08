# Test input validation --------------------------------------------------------

testthat::test_that("ngr_spk_stac_calc errors when feature is not a list with assets", {

  testthat::expect_error(
    ngr::ngr_spk_stac_calc(feature = "not_a_list"),
    "must be a single STAC item"
  )

  testthat::expect_error(
    ngr::ngr_spk_stac_calc(feature = list(no_assets = TRUE)),
    "must be a single STAC item"
  )

  testthat::expect_error(
    ngr::ngr_spk_stac_calc(feature = list(assets = "not_a_list")),
    "must be a single STAC item"
  )
})

testthat::test_that("ngr_spk_stac_calc errors when aoi is not sf or NULL", {
  mock_feature <- list(
    id = "test_item",
    assets = list(
      red = list(href = "https://example.com/red.tif"),
      nir08 = list(href = "https://example.com/nir.tif")
    )
  )

  testthat::expect_error(
    ngr::ngr_spk_stac_calc(feature = mock_feature, aoi = "not_sf"),
    "must be an sf object"
  )

  testthat::expect_error(
    ngr::ngr_spk_stac_calc(feature = mock_feature, aoi = data.frame(x = 1)),
    "must be an sf object"
  )
})

testthat::test_that("ngr_spk_stac_calc errors when required assets are missing", {
  mock_feature <- list(
    id = "test_item",
    assets = list(
      blue = list(href = "https://example.com/blue.tif")
    )
  )

  testthat::expect_error(
    ngr::ngr_spk_stac_calc(feature = mock_feature, quiet = TRUE),
    "Missing asset href.*asset_a.*red"
  )

  mock_feature2 <- list(
    id = "test_item",
    assets = list(
      red = list(href = "https://example.com/red.tif")
    )
  )

  testthat::expect_error(
    ngr::ngr_spk_stac_calc(feature = mock_feature2, quiet = TRUE),
    "Missing asset href.*asset_b.*nir08"
  )
})

testthat::test_that("ngr_spk_stac_calc errors when asset href is empty", {
  mock_feature <- list(
    id = "test_item",
    assets = list(
      red = list(href = ""),
      nir08 = list(href = "https://example.com/nir.tif")
    )
  )

  testthat::expect_error(
    ngr::ngr_spk_stac_calc(feature = mock_feature, quiet = TRUE),
    "Missing asset href.*asset_a.*red"
  )
})

testthat::test_that("ngr_spk_stac_calc errors when aoi provided but proj:epsg missing", {
  mock_feature <- list(
    id = "test_item",
    properties = list(),
    assets = list(
      red = list(href = "https://example.com/red.tif"),
      nir08 = list(href = "https://example.com/nir.tif")
    )
  )

  aoi <- sf::st_as_sfc(sf::st_bbox(c(xmin = 0, ymin = 0, xmax = 1, ymax = 1), crs = 4326)) |>
    sf::st_as_sf()

  testthat::expect_error(
    ngr::ngr_spk_stac_calc(feature = mock_feature, aoi = aoi, quiet = TRUE),
    "Missing.*proj:epsg"
  )
})

# Test parameter validation ----------------------------------------------------

testthat::test_that("ngr_spk_stac_calc validates string parameters", {
  mock_feature <- list(
    id = "test_item",
    assets = list(
      red = list(href = "https://example.com/red.tif"),
      nir08 = list(href = "https://example.com/nir.tif")
    )
  )

  testthat::expect_error(ngr::ngr_spk_stac_calc(feature = mock_feature, asset_a = 123))
  testthat::expect_error(ngr::ngr_spk_stac_calc(feature = mock_feature, asset_b = 123))
  testthat::expect_error(ngr::ngr_spk_stac_calc(feature = mock_feature, calc = 123))
  testthat::expect_error(ngr::ngr_spk_stac_calc(feature = mock_feature, vsi_prefix = 123))
})

testthat::test_that("ngr_spk_stac_calc validates flag parameters", {
  mock_feature <- list(
    id = "test_item",
    assets = list(
      red = list(href = "https://example.com/red.tif"),
      nir08 = list(href = "https://example.com/nir.tif")
    )
  )

  testthat::expect_error(ngr::ngr_spk_stac_calc(feature = mock_feature, quiet = "yes"))
  testthat::expect_error(ngr::ngr_spk_stac_calc(feature = mock_feature, timing = "yes"))
})

# Test internal .ngr_spk_calc helper -------------------------------------------

testthat::test_that(".ngr_spk_calc computes NDVI correctly", {
  testthat::skip_if_not_installed("terra")

  # Create synthetic rasters with known values
  a <- terra::rast(nrows = 2, ncols = 2, vals = c(100, 200, 150, 50))
  b <- terra::rast(nrows = 2, ncols = 2, vals = c(300, 400, 150, 250))

  # Calculate expected NDVI: (nir - red) / (nir + red)
  red_vals <- c(100, 200, 150, 50)
  nir_vals <- c(300, 400, 150, 250)
  expected <- (nir_vals - red_vals) / (nir_vals + red_vals)

  result <- ngr:::.ngr_spk_calc("ndvi", a = a, b = b)
  result_vals <- as.vector(terra::values(result))

  testthat::expect_equal(result_vals, expected, tolerance = 1e-10)
})

testthat::test_that(".ngr_spk_calc returns values in expected NDVI range", {
  testthat::skip_if_not_installed("terra")

  # NDVI should be between -1 and 1 for valid reflectance values
  set.seed(42)
  a <- terra::rast(matrix(stats::runif(100, 0, 1000), nrow = 10))
  b <- terra::rast(matrix(stats::runif(100, 0, 1000), nrow = 10))

  result <- ngr:::.ngr_spk_calc("ndvi", a = a, b = b)
  result_vals <- terra::values(result)

  testthat::expect_true(all(result_vals >= -1 & result_vals <= 1, na.rm = TRUE))
})

testthat::test_that(".ngr_spk_calc errors on unknown calc type", {
  testthat::skip_if_not_installed("terra")

  a <- terra::rast(matrix(1:4, nrow = 2))
  b <- terra::rast(matrix(5:8, nrow = 2))

  testthat::expect_error(
    ngr:::.ngr_spk_calc("unknown_index", a = a, b = b),
    "Unknown calc"
  )
})

# Test null coalescing helper --------------------------------------------------

testthat::test_that("%||% returns first value when not NULL", {
  testthat::expect_equal(ngr:::`%||%`("value", "default"), "value")
  testthat::expect_equal(ngr:::`%||%`(0, "default"), 0)
  testthat::expect_equal(ngr:::`%||%`(FALSE, TRUE), FALSE)
})

testthat::test_that("%||% returns second value when first is NULL", {
  testthat::expect_equal(ngr:::`%||%`(NULL, "default"), "default")
  testthat::expect_equal(ngr:::`%||%`(NULL, 42), 42)
})
