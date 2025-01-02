#' Create an HTML Link to Repository Resources or GitHub Pages
#'
#' This function generates an HTML `<a>` tag linking to a specified repository resource or GitHub Pages site hosted from the repository.
#' It is particularly useful for embedding links in HTML documents.
#'
#' @param url [character] A single string specifying the either the URL to link to or (if `repo_source` is provided)
#' the base URL for the repository host. Default is New Graph
#' gitpages at \url{https://www.newgraphenvironment.com"}. \url{https://github.com/NewGraphEnvironment} gets you to the
#' repository itself.
#' @param repo_source [character] A single string representing the repository name to be linked. Optional. Default is `NULL`.
#' @param anchor_text [character] A single string specifying the text displayed for the link. Defaults to `"url_link"`.
#' @param target [character] A single string indicating the `target` attribute in the HTML link. Default is `"_blank"`. Options include:
#'   - `"_blank"`: Opens the link in a new tab or window.
#'   - `"_self"`: Opens the link in the same tab or window.
#'   - `"_parent"`: Opens the link in the parent frame, if applicable.
#'   - `"_top"`: Opens the link in the full body of the window, ignoring frames.
#'
#' @return [character] A single string containing the HTML `<a>` tag.
#'
#' @examples
#' # Example 1: Link to the repository with default anchor text
#' ngr_str_link_url("ngr", url = "https://github.com/NewGraphEnvironment")
#'
#' # Example 2: Link to GitHub Pages with anchor text set to the repository name
#' ngr_str_link_url(repo_source = "ngr", anchor_text = "ngr")
#'
#' # Example 3: Link with no repo_source
#' ngr_str_link_url(url = "https://www.newgraphenvironment.com", anchor_text = "Visit New Graph")
#'
#' @family string
#' @importFrom chk chk_string chk_character
#' @importFrom cli cli_alert_warning
#' @export
ngr_str_link_url <- function(repo_source = NULL, url = "https://www.newgraphenvironment.com", anchor_text = "url_link", target = "_blank") {
  # Validate inputs
  if (!is.null(repo_source)) {
    chk::chk_character(repo_source)
  }
  chk::chk_string(url)
  chk::chk_string(anchor_text)
  chk::chk_string(target)

  # Check if the URL includes the protocol
  if (!grepl("^(http|https)://", url)) {
    cli::cli_alert_warning("The provided URL does not include 'http://' or 'https://'. Links may not function correctly.")
  }

  # Construct the href
  href <- if (!is.null(repo_source)) {
    paste0(url, '/', repo_source)
  } else {
    url
  }

  paste0(
    '<a href="', href, '" target="', target, '">',
    anchor_text,
    '</a>'
  )
}

