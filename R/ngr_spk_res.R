#' Extract Resolution from a Raster
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Moved to [spacehakr::spk_res()]. This wrapper forwards its arguments
#' unchanged and will be removed in a future release — call
#' `spacehakr::spk_res()` directly.
#'
#' @param ... Passed unchanged to [spacehakr::spk_res()], which owns the
#'   argument list and its defaults.
#'
#' @return The value of [spacehakr::spk_res()].
#' @family spacehakr
#' @seealso [spacehakr::spk_res()]
#' @export
ngr_spk_res <- function(...) {
  lifecycle::deprecate_warn(
    when = "0.0.2",
    what = "ngr_spk_res()",
    with = "spacehakr::spk_res()"
  )
  spacehakr::spk_res(...)
}

