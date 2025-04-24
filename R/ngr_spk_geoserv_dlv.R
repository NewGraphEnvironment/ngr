#' Download a Vector Layer from a GeoServer WFS
#'
#' This function downloads a single vector layer from a WFS (Web Feature Service)
#' endpoint and saves it locally in GeoJSON or another supported format.
#'
#' By default, the `layer_name_out` is inferred from `layer_name_raw` by removing
#' a namespace prefix (e.g., `geonode:`), which is common in GeoServer layers.
#'
#' @param url_geoserver [character] A single URL string to the GeoServer WFS endpoint.
#' @param dir_out [character] A directory path where the output file will be saved. Must exist or be creatable.
#' @param layer_name_raw [character] A WFS layer name, usually including a namespace (e.g., `geonode:LayerName`).
#' @param layer_name_out [character] Optional. Output file name without extension. Defaults to the name extracted from `layer_name_raw`.
#' @param crs [integer] EPSG code for the coordinate reference system to request from the server. Default is 3005.
#' @param bbox [bbox] or [numeric] Optional. A bounding box to filter features spatially. Must be in the same CRS or coercible.
#' @param format_out [character] WFS output format. Common values: "json", "GML2", "shape-zip". Default is "json" and function will need to be modified in the future to accomodate other formats.
#'
#' @return Invisibly returns the output file path on success. Prints status messages to console.
#'
#' @details
#' If a bounding box is passed as a `sf::st_bbox()` object and it has a different CRS
#' than the target CRS, it will be transformed using `sf::st_transform()`.
#'
#' @seealso [fs::dir_create()], [fs::path()], [sf::st_bbox()], [sf::st_transform()]
#'
#' @examples
#' \dontrun{
#' dir_out <- "data"
#' layer_name_raw <- "geonode:UBulkley_wshed"
#' ngr_spk_geoserv_dlv(
#'   dir_out = dir_out,
#'   layer_name_raw = layer_name_raw
#' )
#' }
#'
#' @export
#' @importFrom chk chk_string chk_dir chk_not_null
#' @importFrom fs dir_create path path_abs
#' @importFrom stringr str_extract
#' @importFrom httr GET write_disk status_code
#' @importFrom sf st_crs st_transform st_bbox st_as_sfc
ngr_spk_geoserv_dlv <- function(
    url_geoserver = "https://maps.skeenasalmon.info/geoserver/ows",
    dir_out = NULL,
    layer_name_raw = NULL,
    layer_name_out = stringr::str_extract(layer_name_raw, "(?<=:).*"),
    crs = 3005,
    bbox = NULL,
    format_out = "json"
){
  chk::chk_string(url_geoserver)
  chk::chk_string(layer_name_raw)
  chk::chk_string(layer_name_out)
  chk::chk_dir(dir_out)
  chk::chk_not_null(crs)

  # create directory with fs
  fs::dir_create(dir_out)

  # Construct the WFS GetFeature request URL
  query_params <- list(
    service = "WFS",
    version = "1.0.0",
    request = "GetFeature",
    typename = layer_name_raw,
    outputFormat = format_out,
    srsName = paste0("EPSG:", crs)
  )

  if (!is.null(bbox)) {
    if (inherits(bbox, "bbox")) {
      bbox_crs <- sf::st_crs(bbox)
      target_crs <- sf::st_crs(crs)
      if (!is.na(bbox_crs) && bbox_crs != target_crs) {
        bbox <- sf::st_bbox(sf::st_transform(sf::st_as_sfc(bbox), target_crs))
      }
    }
    bbox_str <- paste(c(bbox, paste0("EPSG:", crs)), collapse = ",")
    query_params$bbox <- bbox_str
  }

  # Send request and save response to a GeoJSON file
  file_out <- fs::path(dir_out, layer_name_out, ext = "geojson")
  response <- httr::GET(url = url_geoserver, query = query_params, httr::write_disk(file_out, overwrite = TRUE))

  if (httr::status_code(response) == 200) {
    cat("GeoJSON saved to:", fs::path_abs(file_out), "\n")
  } else {
    cat("Error: Failed to download layer. HTTP Status:", httr::status_code(response), "\n")
  }

  invisible(file_out)
}
