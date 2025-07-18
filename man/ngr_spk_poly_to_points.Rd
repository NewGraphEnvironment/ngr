% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ngr_spk_poly_to_points.R
\name{ngr_spk_poly_to_points}
\alias{ngr_spk_poly_to_points}
\title{Generate Regularly Spaced Points Inside Polygons}
\usage{
ngr_spk_poly_to_points(sf_in, col_density, col_id = NULL)
}
\arguments{
\item{sf_in}{An \code{sf} object containing polygon geometries.}

\item{col_density}{\link{character} The name of the column containing point density values per polygon.}

\item{col_id}{\link{character} or \link{NULL} The name of the column to use as the ID. Defaults to "id" if NULL.}
}
\value{
An \code{sf} object containing the generated points with an ID column.
}
\description{
This function generates a regularly spaced grid of points inside each polygon
in a given \code{sf} object and assigns it an ID. The point density is determined by a specified column.
}
\examples{
poly <- sf::st_sf(
  region = c("A", "B"),
  col_density = c(1, 5),
  geometry = sf::st_sfc(
    sf::st_polygon(list(rbind(c(0, 0), c(10, 0), c(10, 10), c(0, 10), c(0, 0)))),
    sf::st_polygon(list(rbind(c(15, 15), c(20, 15), c(20, 20), c(15, 20), c(15, 15))))
  )
)

points <- ngr_spk_poly_to_points(poly, col_density = "col_density", col_id = "region")

plot(sf::st_geometry(poly))
 plot(sf::st_geometry(points), add = TRUE, col = "red", pch = 16)

}
\seealso{
Other spacehakr: 
\code{\link{ngr_spk_gdalwarp}()},
\code{\link{ngr_spk_join}()},
\code{\link{ngr_spk_layer_info}()},
\code{\link{ngr_spk_odm}()},
\code{\link{ngr_spk_rast_ext}()},
\code{\link{ngr_spk_rast_not_empty}()},
\code{\link{ngr_spk_rast_rm_empty}()},
\code{\link{ngr_spk_res}()}
}
\concept{spacehakr}
