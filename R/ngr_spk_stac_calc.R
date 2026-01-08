#' Spectral index calculation from a STAC item
#'
#' Compute a spectral index for a single STAC item. By default, the function reads
#' red and near-infrared (NIR) assets to compute NDVI, but this is only the
#' default configuration. The function is designed to read any two or three
#' assets and apply different spectral index calculations as they are added in
#' the future.
#'
#' The default asset names (`"red"` and `"nir08"`) align with common conventions
#' in Landsat Collection 2 Level-2 STAC items (e.g. the `landsat-c2-l2` collection
#' on Planetary Computer), but are fully parameterized to support other
#' collections with different band naming schemes.
#'
#' @param feature [list] A single STAC Item (one element from an `items$features`
#' list).
#' @param aoi [sf] or [NULL] Optional. An AOI object used to restrict reads (by
#' bbox) and to crop and mask the output. If `NULL`, the full assets are read and
#' no crop/mask is applied. Default is `NULL`.
#' @param asset_a [character] Optional. A single string giving the asset name for
#' the first input band. For NDVI this corresponds to the red band. Default is
#' `"red"`.
#' @param asset_b [character] Optional. A single string giving the asset name for
#' the second input band. For NDVI this corresponds to the NIR band. Default is
#' `"nir08"`.
#' @param asset_c [character] or [NULL] Optional. A single string giving the asset
#' name for an optional third input band, used by some calculations. Default is
#' `NULL`.
#' @param vsi_prefix [character] Optional. A single string giving the GDAL VSI
#' prefix used by [terra::rast()] to enable streaming, windowed reads over HTTP.
#' Exposed to allow alternative VSI backends (e.g. `/vsis3/`). Default is
#' `"/vsicurl/"`.
#' @param quiet [logical] Optional. If `TRUE`, suppress CLI messages. Default is
#' `FALSE`.
#' @param timing [logical] Optional. If `TRUE`, emit simple elapsed-time messages
#' for reads. Default is `FALSE`.
#'
#' @details
#' This function expects `feature` to provide the required `assets` referenced by
#' `asset_a`, `asset_b`, and (if used) `asset_c`. When `aoi` is not `NULL`,
#' `feature` must also have `properties$"proj:epsg"` so the AOI can be transformed
#' for windowed reads.
#'
#' The calculation performed is controlled by `calc`. By default, `calc = "ndvi"`
#' computes the Normalized Difference Vegetation Index using `(b - a) / (b + a)`.
#' This structure allows additional spectral indices (e.g. NDWI, EVI) to be added
#' in the future without changing the data access or cropping logic.
#'
#' When `aoi` is provided, reading is limited to the AOI bounding box in the
#' feature's projected CRS, and then cropped/masked to the AOI. When `aoi = NULL`,
#' the full assets are read and the calculated raster is returned for the full
#' raster extent.
#'
#' @return A [terra::SpatRaster] with calculated index values.
#'
#' @section Production-ready alternative:
#' This function is a proof of concept demonstrating how to perform raster
#' calculations on STAC items using `terra`. For production workflows involving
#' time series reductions, multi-image composites, or data cubes with varying
#' pixel sizes and coordinate reference systems, consider the
#' [gdalcubes](https://github.com/appelmar/gdalcubes) package. Key functions
#' include:
#' \itemize{
#'   \item `stac_image_collection()`: Create an image collection directly from
#'     STAC query results with automatic band detection and VSI prefix handling.
#'   \item `cube_view()`: Define spatiotemporal extent, resolution, aggregation,
#'     and resampling method in a single specification.
#'   \item `raster_cube()`: Build a data cube from an image collection,
#'     automatically reprojecting and resampling images to a common grid.
#'   \item `apply_pixel()`: Apply arithmetic expressions (e.g.,
#'     `"(nir - red) / (nir + red)"`) across all pixels.
#'   \item `reduce_time()`: Temporal reductions (mean, median, max, etc.) to
#'     composite multi-date imagery.
#' }
#'
#' @seealso [terra::rast()], [terra::crop()], [terra::mask()], [sf::st_transform()]
#'
#' @importFrom chk chk_flag chk_string
#' @importFrom cli cli_abort cli_alert_info
#' @importFrom sf st_crs st_transform
#' @importFrom terra crop ext mask rast vect
#'
#' @family spacehakr
#' @export
#' @examples
#' \dontrun{
#' # STAC query against Planetary Computer (Landsat C2 L2)
#' stac_url <- "https://planetarycomputer.microsoft.com/api/stac/v1"
#' y <- 2000
#' date_time <- paste0(y, "-05-01/", y, "-07-30")
#'
#' # Define an AOI from a bounding box (WGS84)
#' bbox <- c(
#'   xmin = -126.55350240037997,
#'   ymin =  54.4430453753869,
#'   xmax = -126.52422763064457,
#'   ymax =  54.46001902038006
#' )
#'
#' aoi <- sf::st_as_sfc(sf::st_bbox(bbox, crs = 4326)) |>
#'   sf::st_as_sf()
#'
#' stac_query <- rstac::stac(stac_url) |>
#'   rstac::stac_search(
#'     collections = "landsat-c2-l2",
#'     datetime = date_time,
#'     intersects = sf::st_geometry(aoi)[[1]],
#'     limit = 200
#'   ) |>
#'   rstac::ext_filter(`eo:cloud_cover` <= 10)
#'
#' items <- stac_query |>
#'   rstac::post_request() |>
#'   rstac::items_fetch() |>
#'   rstac::items_sign_planetary_computer()
#'
#' ndvi_list <- items$features |>
#'   purrr::map(ngr_spk_stac_calc, aoi = aoi)
#'
#' ndvi_list <- ndvi_list |>
#'   purrr::set_names(purrr::map_chr(items$features, "id"))
#' }

ngr_spk_stac_calc <- function(
    feature,
    aoi = NULL,
    asset_a = "red",
    asset_b = "nir08",
    asset_c = NULL,
    calc = "ndvi",
    vsi_prefix = "/vsicurl/",
    quiet = FALSE,
    timing = FALSE
) {
  chk::chk_string(asset_a)
  chk::chk_string(asset_b)
  if (!is.null(asset_c)) chk::chk_string(asset_c)
  chk::chk_string(calc)
  chk::chk_string(vsi_prefix)
  chk::chk_flag(quiet)
  chk::chk_flag(timing)

  if (!is.list(feature) || is.null(feature$assets) || !is.list(feature$assets)) {
    cli::cli_abort("`feature` must be a single STAC item (a list with an `assets` element).")
  }
  if (!is.null(aoi) && !inherits(aoi, "sf")) {
    cli::cli_abort("`aoi` must be an sf object or `NULL`.")
  }

  id <- feature$id %||% "<unknown>"

  if (!is.null(aoi)) {
    f_epsg <- feature[["properties"]][["proj:epsg"]]
    if (is.null(f_epsg) || is.na(f_epsg)) {
      cli::cli_abort("Missing `properties$proj:epsg` for item: {id}.")
    }
  }

  a_href <- feature$assets[[asset_a]]$href
  b_href <- feature$assets[[asset_b]]$href
  if (is.null(a_href) || !nzchar(a_href)) {
    cli::cli_abort("Missing asset href for `asset_a` `{asset_a}` in item: {id}.")
  }
  if (is.null(b_href) || !nzchar(b_href)) {
    cli::cli_abort("Missing asset href for `asset_b` `{asset_b}` in item: {id}.")
  }

  a_url <- paste0(vsi_prefix, a_href)
  b_url <- paste0(vsi_prefix, b_href)

  if (is.null(aoi)) {
    if (!quiet) cli::cli_alert_info("aoi is NULL: reading full assets: {id}")

    if (!quiet) cli::cli_alert_info("read asset_a: {id}")
    t0 <- if (timing) base::proc.time()[[3]] else NA_real_
    a <- terra::rast(a_url)
    if (timing && !quiet) cli::cli_alert_info("read asset_a elapsed (s): {format(base::proc.time()[[3]] - t0, digits = 3)}")

    if (!quiet) cli::cli_alert_info("read asset_b: {id}")
    t1 <- if (timing) base::proc.time()[[3]] else NA_real_
    b <- terra::rast(b_url)
    if (timing && !quiet) cli::cli_alert_info("read asset_b elapsed (s): {format(base::proc.time()[[3]] - t1, digits = 3)}")

    out <- .ngr_spk_calc(calc, a = a, b = b, c = NULL)
    return(out)
  }

  aoi_epsg <- sf::st_transform(aoi, f_epsg)
  win <- terra::ext(aoi_epsg)

  if (!quiet) cli::cli_alert_info("read asset_a: {id}")
  t0 <- if (timing) base::proc.time()[[3]] else NA_real_
  a <- terra::rast(a_url, win = win)
  if (timing && !quiet) cli::cli_alert_info("read asset_a elapsed (s): {format(base::proc.time()[[3]] - t0, digits = 3)}")

  if (!quiet) cli::cli_alert_info("read asset_b: {id}")
  t1 <- if (timing) base::proc.time()[[3]] else NA_real_
  b <- terra::rast(b_url, win = win)
  if (timing && !quiet) cli::cli_alert_info("read asset_b elapsed (s): {format(base::proc.time()[[3]] - t1, digits = 3)}")

  out <- .ngr_spk_calc(calc, a = a, b = b, c = NULL)

  aoi_v <- aoi |>
    sf::st_transform(sf::st_crs(out)) |>
    terra::vect()

  terra::crop(out, aoi_v) |>
    terra::mask(aoi_v)
}

# ---- helpers

#' Calculation dispatcher
#'
#' @param calc [character] Name of the calculation.
#' @param a [terra::SpatRaster] First input raster.
#' @param b [terra::SpatRaster] Second input raster.
#' @param c [terra::SpatRaster] or [NULL] Optional third input raster.
#'
#' @return A [terra::SpatRaster].
#'
#' @noRd
.ngr_spk_calc <- function(calc, a, b, c = NULL) {
  if (calc == "ndvi") {
    return((b - a) / (b + a))
  }

  cli::cli_abort("Unknown calc: {calc}.")
}


#' Null-coalescing helper
#'
#' @param x An object.
#' @param y An object to return if `x` is `NULL`.
#'
#' @return `x` if not `NULL`, otherwise `y`.
#'
#' @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
