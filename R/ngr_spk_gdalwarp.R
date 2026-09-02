#' Generate GDALWarp Command Arguments
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Moved to [spacehakr::spk_gdalwarp()]. This wrapper forwards its arguments
#' unchanged and will be removed in a future release — call
#' `spacehakr::spk_gdalwarp()` directly.
#'
#' **Behaviour change.** `spacehakr::spk_gdalwarp()` places `params_add` *before* the input and output paths; this version appended them after. GDAL tolerates flags in either position, so most `params_add` values behave identically. The case that differs is a `params_add` ending in a bare non-option token: appended last it is taken as the destination, and the intended output path is demoted to a source.
#'
#' @param ... Passed unchanged to [spacehakr::spk_gdalwarp()], which owns the
#'   argument list and its defaults.
#'
#' @return The value of [spacehakr::spk_gdalwarp()].
#' @family spacehakr
#' @seealso [spacehakr::spk_gdalwarp()]
#' @export
ngr_spk_gdalwarp <- function(...) {
  lifecycle::deprecate_warn(
    when = "0.0.2",
    what = "ngr_spk_gdalwarp()",
    with = "spacehakr::spk_gdalwarp()"
  )
  spacehakr::spk_gdalwarp(...)
}

