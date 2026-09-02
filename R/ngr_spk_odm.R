#' Construct Docker Command Arguments for ODM
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Moved to [spacehakr::spk_odm()]. This wrapper forwards its arguments
#' unchanged and will be removed in a future release — call
#' `spacehakr::spk_odm()` directly.
#'
#' @param ... Passed unchanged to [spacehakr::spk_odm()], which owns the
#'   argument list and its defaults.
#'
#' @return The value of [spacehakr::spk_odm()].
#' @family spacehakr
#' @seealso [spacehakr::spk_odm()]
#' @export
ngr_spk_odm <- function(...) {
  lifecycle::deprecate_warn(
    when = "0.0.2",
    what = "ngr_spk_odm()",
    with = "spacehakr::spk_odm()"
  )
  spacehakr::spk_odm(...)
}

