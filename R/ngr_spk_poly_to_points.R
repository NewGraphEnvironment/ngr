ngr_spk_poly_to_points <- function(sf_in, col_density) {
  # Validate input
  chk::chk_is(sf_in, "sf")
  chk::chk_string(col_density)
  chk::chk_subset(col_density, names(sf_in))
  # chk::chk_gt(points_density, 0)  # Ensure density is > 0

  # Generate points within each polygon using st_sample
  point_list <- mapply(function(poly, density) {
    sf::st_sample(poly, size = as.integer(density * sf::st_area(poly)), type = "regular")
  }, sf::st_geometry(sf_in), sf_in[[col_density]], SIMPLIFY = FALSE)

  # Convert list to sf object
  points <- do.call(c, point_list)
  sf_points <- sf::st_sf(geometry = points)

  return(sf_points)
}
