#' Compute Combined Extent (Bounding Box) from Multiple Raster Files
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Moved to [spacehakr::spk_rast_ext()]. This wrapper forwards its arguments
#' unchanged and will be removed in a future release — call
#' `spacehakr::spk_rast_ext()` directly.
#'
#' @param ... Passed unchanged to [spacehakr::spk_rast_ext()], which owns the
#'   argument list and its defaults.
#'
#' @return The value of [spacehakr::spk_rast_ext()].
#' @family spacehakr
#' @seealso [spacehakr::spk_rast_ext()]
#' @export
ngr_spk_rast_ext <- function(...) {
  lifecycle::deprecate_warn(
    when = "0.0.2",
    what = "ngr_spk_rast_ext()",
    with = "spacehakr::spk_rast_ext()"
  )
  spacehakr::spk_rast_ext(...)
}

