# # create 5 points
# points <- data.frame(
#   id = 1:5,
#   col2 = 5:9,
#   lon = c(0, 1, 2, 3, 10),
#   lat = c(0, 1, 2, 3, 10)
# ) |>
#   sf::st_as_sf(coords = c("lon", "lat"), crs = 4326)
#
#
# # create 5 polygons with overlap conditions
# poly <- list(
#   sf::st_polygon(list(matrix(c(-0.5, -0.5,  0.5, -0.5,  0.5,  0.5, -0.5,  0.5, -0.5, -0.5), ncol = 2, byrow = TRUE))),
#   sf::st_polygon(list(matrix(c(-1, -1,  1, -1,  1,  1, -1,  1, -1, -1), ncol = 2, byrow = TRUE))),
#   sf::st_polygon(list(matrix(c(0.5, 0.5, 1.5, 0.5, 1.5, 1.5, 0.5, 1.5, 0.5, 0.5), ncol = 2, byrow = TRUE))),
#   sf::st_polygon(list(matrix(c(1.5, 1.5, 2.5, 1.5, 2.5, 2.5, 1.5, 2.5, 1.5, 1.5), ncol = 2, byrow = TRUE))),
#   sf::st_polygon(list(matrix(c(2.5, 2.5, 3.5, 2.5, 3.5, 3.5, 2.5, 3.5, 2.5, 2.5), ncol = 2, byrow = TRUE)))
# ) |>
#   sf::st_sf(
#     attribute_string = letters[1:5],
#     attribute_numeric = 1:5,
#     attribute_numeric2 = 1:5,
#     crs = 4326
#   )
#
# # mapview::mapview(poly, zcol = "attribute_string") +
# #   mapview::mapview(points, col.regions = "black")
#
# # write to GPKG
# sf::st_write(points, "inst/extdata/points.gpkg", layer = "points", delete_layer = TRUE)
# sf::st_write(poly, "inst/extdata/poly.gpkg", layer = "poly", delete_layer = TRUE)

path_poly <- system.file("extdata/poly.gpkg", package = "ngr")
path_points <- system.file("extdata/points.gpkg", package = "ngr")

points <- sf::st_read(path_points, quiet = TRUE)

testthat::test_that("ngr_spk_join returns 5 rows and 3 columns when collapsing", {
  res <- ngr_spk_join(
    target_tbl = points,
    mask_tbl = "poly",
    mask_col_return = "attribute_string",
    path_gpkg = path_poly,
    collapse = TRUE,
    target_col_collapse = "id"
  )

  expect_equal(dim(res), c(5, 3))
})

testthat::test_that("ngr_spk_join returns multiple rows when not collapsing", {
  res <- ngr_spk_join(
    target_tbl = points,
    mask_tbl = "poly",
    mask_col_return = c("attribute_numeric","attribute_numeric2", "attribute_string"),
    path_gpkg = path_poly
  )

  expect_equal(dim(res), c(7, 6))
})

res <- ngr_spk_join(
  target_tbl = points,
  mask_tbl = "poly",
  mask_col_return = c("attribute_numeric","attribute_numeric2", "attribute_string"),
  path_gpkg = path_poly
)

test_that("ngr_spk_join warns on type change after collapsing and accepts list of cols target_col_collapse", {

  expect_warning(
    ngr_spk_join(
      target_tbl = points,
      mask_tbl = "poly",
      mask_col_return = c("attribute_numeric", "attribute_numeric2", "attribute_string"),
      path_gpkg = path_poly,
      collapse = TRUE,
      target_col_collapse = c("id", "col2")
    ),
    regexp = "attribute_numeric: integer to character.*attribute_numeric2: integer to character"
  )
})


