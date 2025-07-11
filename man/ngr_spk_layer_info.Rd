% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ngr_spk_layer_info.R
\name{ngr_spk_layer_info}
\alias{ngr_spk_layer_info}
\title{Summarise Layers and Geometry Types in a Spatial Data Source}
\usage{
ngr_spk_layer_info(path)
}
\arguments{
\item{path}{\link{character} A single string. Path to the vector spatial data source (e.g., a GeoPackage or shapefile).}
}
\value{
\link{data.frame} A data frame of available layers and their geometry types.
If a layer contains no geometry, or an error occurs during reading, the \code{geomtype} will be \code{NA}.
}
\description{
Extracts and summarises information about layers within a spatial vector data source.
Attempts to determine the geometry type of each layer by querying a sample feature.
}
\details{
Uses \code{\link[sf:st_layers]{sf::st_layers()}} to list available layers in the data source.
For each layer, attempts to read a single feature using an SQL query and determines the geometry type using \code{\link[sf:st_geometry_type]{sf::st_geometry_type()}}.
Layers with no geometry or errors in reading are safely assigned \code{NA}.
The \code{driver} column is removed from the output as it may contain invalid entries for further data frame operations.
}
\seealso{
\code{\link[sf:st_layers]{sf::st_layers()}}, \code{\link[sf:st_read]{sf::st_read()}}, \code{\link[sf:st_geometry_type]{sf::st_geometry_type()}}

Other spacehakr: 
\code{\link{ngr_spk_gdalwarp}()},
\code{\link{ngr_spk_join}()},
\code{\link{ngr_spk_odm}()},
\code{\link{ngr_spk_poly_to_points}()},
\code{\link{ngr_spk_rast_ext}()},
\code{\link{ngr_spk_rast_not_empty}()},
\code{\link{ngr_spk_rast_rm_empty}()},
\code{\link{ngr_spk_res}()}
}
\concept{spacehakr}
