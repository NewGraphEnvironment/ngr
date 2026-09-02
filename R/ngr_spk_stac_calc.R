#' Retrieve and optionally calculate spectral indices from a STAC item
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Moved to [spacehakr::spk_stac_calc()]. This wrapper forwards its arguments
#' unchanged and will be removed in a future release — call
#' `spacehakr::spk_stac_calc()` directly.
#'
#' @param ... Passed unchanged to [spacehakr::spk_stac_calc()], which owns the
#'   argument list and its defaults.
#'
#' @return The value of [spacehakr::spk_stac_calc()].
#' @family spacehakr
#' @seealso [spacehakr::spk_stac_calc()]
#' @export
ngr_spk_stac_calc <- function(...) {
  lifecycle::deprecate_warn(
    when = "0.0.2",
    what = "ngr_spk_stac_calc()",
    with = "spacehakr::spk_stac_calc()"
  )
  spacehakr::spk_stac_calc(...)
}

