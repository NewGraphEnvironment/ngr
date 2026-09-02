#' Spatial Join with Optional Mask Filtering and Column Selection
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Moved to [spacehakr::spk_join()]. This wrapper forwards its arguments
#' unchanged and will be removed in a future release — call
#' `spacehakr::spk_join()` directly.
#'
#' @param ... Passed unchanged to [spacehakr::spk_join()], which owns the
#'   argument list and its defaults.
#'
#' @return The value of [spacehakr::spk_join()].
#' @family spacehakr
#' @seealso [spacehakr::spk_join()]
#' @export
ngr_spk_join <- function(...) {
  lifecycle::deprecate_warn(
    when = "0.0.2",
    what = "ngr_spk_join()",
    with = "spacehakr::spk_join()"
  )
  spacehakr::spk_join(...)
}

