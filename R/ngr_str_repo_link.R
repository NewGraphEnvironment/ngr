#' Create an HTML Link to Repository Resources or GitHub Pages
#'
#' This function generates an HTML `<a>` tag linking to a specified repository resource or GitHub Pages site hosted from the repository.
#' It is particularly useful for embedding links in HTML documents.
#'
#' @param repo_source [character] A single string representing the repository name to be linked.
#' @param url [character] A single string specifying the base URL for the repository host. Default is `"https://www.newgraphenvironment.com"`.
#' @param anchor_text [character] A single string specifying the text displayed for the link. Defaults to `"url_link"`.
#' @param target [character] A single string indicating the `target` attribute in the HTML link. Default is `"_blank"`. Options include:
#'   - `"_blank"`: Opens the link in a new tab or window.
#'   - `"_self"`: Opens the link in the same tab or window.
#'   - `"_parent"`: Opens the link in the parent frame, if applicable.
#'   - `"_top"`: Opens the link in the full body of the window, ignoring frames.
#'
#' @return [character] A single string containing the HTML `<a>` tag.
#'
#' @details
#' This function can create links to either:
#' - **Repository resources**: Links directly to the repository on platforms like GitHub.
#' - **GitHub Pages**: Links to websites or documentation served from the repository, using a base URL for the hosted site.
#'
#' If the provided `url` does not start with `http://` or `https://`, a warning is issued via `cli::cli_alert_warning()` to indicate potential issues with the generated links.
#'
#' @examples
#' # Example 1: Link to the repository with default anchor text
#' ngr_str_repo_link("ngr", url = "https://github.com/NewGraphEnvironment")
#'
#' # Example 2: Link to GitHub Pages with anchor text set to the repository name
#' ngr_str_repo_link("ngr", url = "https://www.newgraphenvironment.com", anchor_text = "ngr")
#'
#' @family string
#' @importFrom chk chk_string
#' @importFrom cli cli_alert_warning
#' @export
ngr_str_repo_link <- function(repo_source, url = "https://www.newgraphenvironment.com", anchor_text = "url_link", target = "_blank") {
  # Validate inputs
  chk::chk_string(repo_source)
  chk::chk_string(url)
  chk::chk_string(anchor_text)
  chk::chk_string(target)

  # Check if the URL includes the protocol
  if (!grepl("^(http|https)://", url)) {
    cli::cli_alert_warning("The provided URL does not include 'http://' or 'https://'. Links may not function correctly.")
  }

  paste0(
    '<a href="', url, '/',
    repo_source,
    '" target="', target, '">',
    anchor_text,
    '</a>'
  )
}
