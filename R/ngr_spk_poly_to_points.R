#' Generate Point Grid Within Multiple Polygons
#'
#' This function generates a regular grid of points within each polygon in an `sf` object.
#' The grid resolution is determined by the `points_density` parameter, which defines the number of points per square
#' meter.
#'
#' @param sf_in [sf] An `sf` object containing multiple polygon geometries.
#' @param points_density [numeric] The number of points per square meter. MOTE: When using hexagonal grids
#' (`square = FALSE` in `sf::st_make_grid()`), the `cellsize` defines the diameter of
#' the hexagons rather than their area, affecting the effective spacing.
#' @param col_id [character] or [NULL] The name of the column to use as the ID. Default is `NULL`, which falls back to 'id' if present,
#' otherwise assigns sequential numeric IDs.
#' @param ... Additional arguments passed to `sf::st_make_grid()`.
#'
#' @return An `sf` object containing the generated points within each polygon, with an `id` column matching the source polygon.
#'
#' @importFrom sf st_make_grid st_within st_sf st_geometry
#' @importFrom chk chk_is chk_numeric chk_gt
#' @family spachakr
#' @export
#'
#' @examples
#' # Create a simple 2-row polygon sf object
#' poly <- sf::st_sf(id = 1:2, geometry = sf::st_sfc(
#'   sf::st_polygon(list(rbind(c(0, 0), c(2, 0), c(2, 2), c(0, 2), c(0, 0)))),
#'   sf::st_polygon(list(rbind(c(3, 3), c(5, 3), c(5, 5), c(3, 5), c(3, 3))))
#' ))
#'
#' # Generate points with density of 1 point per square meter
#' points <- ngr_spk_poly_to_points(poly, points_density = 1)
#'
#' plot(sf::st_geometry(poly))
#' plot(sf::st_geometry(points), add = TRUE, col = 'red', pch = 16)
ngr_spk_poly_to_points <- function(sf_in, points_density, col_id = NULL, ...) {
  # Validate input
  chk::chk_is(sf_in, "sf")
  chk::chk_numeric(points_density)
  chk::chk_gt(points_density, 0)  # Ensure density is > 0

  # Convert density to grid cell size
  cell_size <- 1 / sqrt(points_density)  # Determines point spacing

  # Identify an ID column in the input sf object (default: 'id')
  if (is.null(col_id)) {
    col_id <- "id"
  }
  if (!col_id %in% names(sf_in)) {
    sf_in$id <- seq_len(nrow(sf_in))  # Assign default IDs if none exist
  }

  # Generate individual grids for each polygon and associate IDs
  grid_list <- mapply(function(poly, id) {
    grid <- sf::st_make_grid(poly, cellsize = cell_size, what = "centers", ...)
    points <- grid[sf::st_within(grid, poly, sparse = FALSE)]
    df <- data.frame(id = id)
    names(df)[1] <- col_id
    sf::st_sf(df, geometry = points)  # Assign ID to each point
  }, sf::st_geometry(sf_in), sf_in[[col_id]], SIMPLIFY = FALSE)

  # Combine all filtered points
  sf_points <- do.call(rbind, grid_list)

  return(sf_points)
}
