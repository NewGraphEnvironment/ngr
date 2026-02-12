#' Generate an HTML iframe for the COG Viewer
#'
#' Creates an HTML `<iframe>` tag that embeds the COG viewer at `viewer.a11s.one` with a cache-busting version
#' parameter. Bump `v` when the viewer has breaking changes to invalidate stale browser caches across all reports.
#'
#' @param url [character] A single string specifying the full URL of the COG file (e.g., an S3 HTTPS URL).
#' @param v [integer] Cache-busting version parameter appended to the viewer URL. Default is `2L`. Bump this in the
#'   package when `viewer.html` has breaking changes (e.g., TiTiler path updates) to force browsers to fetch the
#'   latest viewer for all reports on rebuild.
#' @param viewer_base [character] A single string specifying the base URL of the viewer. Default is
#'   `"https://viewer.a11s.one/"`.
#' @param width [character] A single string specifying the iframe width. Default is `"100%"`.
#' @param height [character] A single string specifying the iframe height in pixels. Default is `"600"`.
#'
#' @return [character] A single string containing the HTML `<iframe>` tag. Pass to [knitr::asis_output()] for
#'   rendering in report chunks.
#'
#' @details
#' The viewer URL is constructed as `<viewer_base>?v=<v>&cog=<url>`. The `v` parameter is ignored by the viewer
#' JavaScript but changes the URL enough to bypass stale browser caches.
#'
#' @examples
#' ngr_str_viewer_cog("https://stac-dem-bc.s3.us-west-2.amazonaws.com/dem_pouce_coupe_2023.tif")
#'
#' # In a report chunk:
#' # knitr::asis_output(ngr_str_viewer_cog("https://bucket.s3.amazonaws.com/ortho.tif"))
#'
#' @family string
#' @importFrom chk chk_string chk_whole_number
#' @export
ngr_str_viewer_cog <- function(url,
                               v = 2L,
                               viewer_base = "https://viewer.a11s.one/",
                               width = "100%",
                               height = "600") {
  chk::chk_string(url)
  chk::chk_whole_number(v)
  chk::chk_string(viewer_base)
  chk::chk_string(width)
  chk::chk_string(height)

  src <- paste0(viewer_base, "?v=", v, "&cog=", url)

  paste0(
    '<iframe src="', src, '" ',
    'scrolling="no" ',
    'title="COG Viewer" ',
    'width="', width, '" ',
    'height="', height, '" ',
    'frameBorder="0">',
    '</iframe>'
  )
}
