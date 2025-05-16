#' Get GitHub Issue Timeline or Event Details
#'
#' This function retrieves the timeline or event details for a specified GitHub issue using the GitHub API. By default, it filters for events associated with commits only.
#'
#' @param issue_url_json [character]. The full GitHub API URL of the issue (e.g., "https://api.github.com/repos/user/repo/issues/123").
#' @param token [character]. A GitHub personal access token (PAT). Default is `Sys.getenv("GITHUB_PAT")`.
#' @param endpoint [character]. The API endpoint to use for retrieving issue events. Defaults to "timeline".
#' to access administrative actions like mentioned, labeling or assigning.
#' @param events_all [logical]. If `TRUE`, return all events. If `FALSE` (default), return only those associated with commits (i.e., with a non-null `commit_id`).
#'
#' @return A tibble with columns: `issue_url_json`, `event`, `commit_id`, `commit_url_json`, and `created_at`.
#'
#' @importFrom gh gh
#' @importFrom purrr map_dfr
#' @importFrom tibble tibble
#' @importFrom chk chk_string chk_flag chk_not_null
#' @export
#'
#' @seealso [gh::gh()], [purrr::map_dfr()], [tibble::tibble()]
#'
#' @references
#' GitHub Issue Event Types: https://docs.github.com/en/rest/using-the-rest-api/issue-event-types
#'
#' @examples
#' ngr_git_issue_details("https://api.github.com/repos/NewGraphEnvironment/fpr/issues/13")
#' ngr_git_issue_details("https://api.github.com/repos/NewGraphEnvironment/fpr/issues/13", events_all = TRUE)
ngr_git_issue_details <- function(issue_url_json, token = Sys.getenv("GITHUB_PAT"), endpoint = "timeline", events_all = FALSE) {
  chk::chk_not_null(issue_url_json)
  chk::chk_string(issue_url_json)
  if (!is.null(token)) chk::chk_string(token)
  chk::chk_string(endpoint)
  chk::chk_flag(events_all)

  # Strip base API to get relative path
  issue_path <- sub("^https://api.github.com", "", issue_url_json)
  issue_response <- paste0(issue_path, "/", endpoint)

  events <- gh::gh(
    issue_response,
    .token = token,
    .send_headers = c(Accept = "application/vnd.github.mockingbird-preview+json")
  )

  purrr::map_dfr(events, function(e) {
    if (events_all || !is.null(e$commit_id)) {
      tibble::tibble(
        issue_url_json = issue_url_json,
        event = e$event,
        commit_id = e$commit_id,
        commit_url_json = e$commit_url,
        created_at = e$created_at
      )
    } else {
      NULL
    }
  })
}
