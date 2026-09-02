#' Generate Regularly Spaced Points Inside Polygons
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Moved to [spacehakr::spk_poly_to_points()]. This wrapper forwards its arguments
#' unchanged and will be removed in a future release — call
#' `spacehakr::spk_poly_to_points()` directly.
#'
#' @param ... Passed unchanged to [spacehakr::spk_poly_to_points()], which owns the
#'   argument list and its defaults.
#'
#' @return The value of [spacehakr::spk_poly_to_points()].
#' @family spacehakr
#' @seealso [spacehakr::spk_poly_to_points()]
#' @export
ngr_spk_poly_to_points <- function(...) {
  lifecycle::deprecate_warn(
    when = "0.0.2",
    what = "ngr_spk_poly_to_points()",
    with = "spacehakr::spk_poly_to_points()"
  )
  spacehakr::spk_poly_to_points(...)
}

