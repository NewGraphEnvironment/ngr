#' Create an HTML Link to Repository Resources or GitHub Pages
#'
#' This function generates an HTML `<a>` tag linking to a url or a url related to specified repository resource or
#' GitHub Pages site hosted from the repository. It is particularly useful for embedding links in html tables such as DT tables.
#'
#' @param url_base [character] A character vector specifying either the URL(s) to link to or (if `url_resource` is provided)
#' the base URL(s) for the repository host. Default is New Graph
#' gitpages at \url{https://www.newgraphenvironment.com}. \url{https://github.com/NewGraphEnvironment} gets you to the
#' repository itself.
#' @param url_resource [character] A character vector representing the repository name(s) to be linked. Optional. Default is `NULL`.
#' @param url_resource_path [logical] A logical value indicating whether to include a `/` between `url_base` and `url_resource`.
#' Defaults to `TRUE`. When set to `FALSE`, it facilitates constructing file paths from `url_base` and `url_resource` without `/` in between,
#' which is useful for API calls such as those to tile servers.
#' @param anchor_text [character] A character vector specifying the text displayed for the link. Defaults to `"url_link"`.
#' @param target [character] A single string indicating the `target` attribute in the HTML link. Default is `"_blank"`. Options include:
#'   - `"_blank"`: Opens the link in a new tab or window.
#'   - `"_self"`: Opens the link in the same tab or window.
#'   - `"_parent"`: Opens the link in the parent frame, if applicable.
#'   - `"_top"`: Opens the link in the full body of the window, ignoring frames.
#'
#' @return [character] A character vector containing the HTML `<a>` tags.
#'
#' @examples
#' # Example 1: Link to the repository with default anchor text
#' ngr_str_link_url("ngr", url_base = "https://github.com/NewGraphEnvironment")
#'
#' # Example 2: Link to GitHub Pages with anchor text set to the repository name
#' ngr_str_link_url(url_resource = "ngr", anchor_text = "ngr")
#'
#' # Example 3: Link with no url_resource
#' ngr_str_link_url(url_base = "https://www.newgraphenvironment.com", anchor_text = "Visit New Graph")
#'
#' # Example 4: Use in a dplyr::mutate()
#' library(dplyr)
#' df <- data.frame(
#'   url_resource = c("ngr", "fpr"),
#'   url_base = c("https://github.com/NewGraphEnvironment", "https://www.newgraphenvironment.com")
#' )
#' df <- df %>%
#'   mutate(
#'     link = ngr_str_link_url(url_resource = url_resource, url_base = url_base, anchor_text = url_resource)
#'   )
#' print(df$link)
#'
#' @family string
#' @importFrom chk chk_string chk_character
#' @importFrom cli cli_alert_warning cli_abort
#' @export
ngr_str_link_url <- function(url_base = "https://www.newgraphenvironment.com", url_resource = NULL, url_resource_path = TRUE, anchor_text = "url_link", target = "_blank") {
  # Validate inputs
  if (!is.null(url_resource)) {
    chk::chk_character(url_resource)
    if (length(url_base) != 1 && length(url_base) != length(url_resource)) {
      cli::cli_abort("`url_base` must be either of length 1 or the same length as `url_resource`.")
    }
  }
  chk::chk_character(url_base)
  chk::chk_character(anchor_text)
  chk::chk_string(target)
  chk::chk_flag(url_resource_path)

  # Recycle `url_base` if necessary
  if (!is.null(url_resource) && length(url_base) == 1) {
    url_base <- rep(url_base, length(url_resource))
  }

  # Check if the URL includes the protocol
  if (!all(grepl("^(http|https)://", url_base))) {
    cli::cli_alert_warning("Some URLs do not include 'http://' or 'https://'. Links may not function correctly.")
  }

  # Construct the href
  href <- if (!is.null(url_resource)) {
    if (url_resource_path) {
      paste0(url_base, '/', url_resource)
    } else {
      paste0(url_base, url_resource)
    }
  } else {
    url_base
  }

  # Vectorized output
  paste0(
    '<a href="', href, '" target="', target, '">',
    anchor_text,
    '</a>'
  )
}
