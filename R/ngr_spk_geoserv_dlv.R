#' Download a Vector Layer from a GeoServer WFS
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Moved to [spacehakr::spk_geoserv_dlv()]. This wrapper forwards its arguments
#' unchanged and will be removed in a future release — call
#' `spacehakr::spk_geoserv_dlv()` directly.
#'
#' **Behaviour change.** `spacehakr::spk_geoserv_dlv()` aborts via [cli::cli_abort()] on a non-200 response. This version printed a message and returned the output path regardless, so a failed download looked like a successful one. The success message also moves from `cat()` on stdout to [cli::cli_alert_success()] on stderr, so anything capturing stdout sees a different result.
#'
#' @param ... Passed unchanged to [spacehakr::spk_geoserv_dlv()], which owns the
#'   argument list and its defaults.
#'
#' @return The value of [spacehakr::spk_geoserv_dlv()].
#' @family spacehakr
#' @seealso [spacehakr::spk_geoserv_dlv()]
#' @export
ngr_spk_geoserv_dlv <- function(...) {
  lifecycle::deprecate_warn(
    when = "0.0.2",
    what = "ngr_spk_geoserv_dlv()",
    with = "spacehakr::spk_geoserv_dlv()"
  )
  spacehakr::spk_geoserv_dlv(...)
}

