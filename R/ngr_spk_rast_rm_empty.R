#' Remove Empty Raster Files
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Moved to [spacehakr::spk_rast_rm_empty()]. This wrapper forwards its arguments
#' unchanged and will be removed in a future release — call
#' `spacehakr::spk_rast_rm_empty()` directly.
#'
#' @param ... Passed unchanged to [spacehakr::spk_rast_rm_empty()], which owns the
#'   argument list and its defaults.
#'
#' @return The value of [spacehakr::spk_rast_rm_empty()].
#' @family spacehakr
#' @seealso [spacehakr::spk_rast_rm_empty()]
#' @export
ngr_spk_rast_rm_empty <- function(...) {
  lifecycle::deprecate_warn(
    when = "0.0.2",
    what = "ngr_spk_rast_rm_empty()",
    with = "spacehakr::spk_rast_rm_empty()"
  )
  spacehakr::spk_rast_rm_empty(...)
}

