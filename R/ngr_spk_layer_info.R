#' Summarise Layers and Geometry Types in a Spatial Data Source
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Moved to [spacehakr::spk_layer_info()]. This wrapper forwards its arguments
#' unchanged and will be removed in a future release — call
#' `spacehakr::spk_layer_info()` directly.
#'
#' @param ... Passed unchanged to [spacehakr::spk_layer_info()], which owns the
#'   argument list and its defaults.
#'
#' @return The value of [spacehakr::spk_layer_info()].
#' @family spacehakr
#' @seealso [spacehakr::spk_layer_info()]
#' @export
ngr_spk_layer_info <- function(...) {
  lifecycle::deprecate_warn(
    when = "0.0.2",
    what = "ngr_spk_layer_info()",
    with = "spacehakr::spk_layer_info()"
  )
  spacehakr::spk_layer_info(...)
}

