#' Retrieve GitHub Issues
#'
#' Queries issues from a specified repository using the GitHub REST API and
#' returns a tibble with selected fields. Includes issues that were open at the
#' specified date or created after it.
#'
#' @param owner [character]  GitHub user or organization name (e.g., "NewGraphEnvironment").
#' @param repo [character]  Repository name (e.g., "ngr").
#' @param date_since [character]  (ISO 8601 datetime or date). Issues must have been open on or created after this date.
#' @param token [character]  GitHub personal access token. Defaults to Sys.getenv("GITHUB_PAT"). Required to access private repositories.
#' @param fields_return [character]  vector of fields to return. Supports nested fields using "$" notation (e.g., "milestone$title").
#'
#' @return A tibble with columns specified in `fields_return`.
#'
#' @export
#' @importFrom gh gh
#' @importFrom purrr keep map_dfc
#' @importFrom tibble tibble
#' @seealso https://docs.github.com/en/rest/using-the-rest-api/issue-event-types
#' @examples
#' ngr_git_issue(
#'   owner = "NewGraphEnvironment",
#'   repo = "ngr",
#'   date_since = "2024-01-01",
#'   token = NULL
#' )
ngr_git_issue <- function(owner, repo, date_since, token = Sys.getenv("GITHUB_PAT"),
                          fields_return = c("url", "title", "body", "comments_url",
                                            "created_at", "closed_at", "milestone$title")) {
  items <- gh::gh(
    "/repos/{owner}/{repo}/issues",
    owner = owner,
    repo = repo,
    state = "all",
    .token = token,
    since = date_since,
    .limit = Inf
  )

  if (!is.null(date_since)) {
    items <- purrr::keep(items, function(x) {
      created_after <- x$created_at >= date_since
      was_open_then <- x$created_at <= date_since && (is.null(x$closed_at) || x$closed_at >= date_since)
      created_after || was_open_then
    })
  }

  # Helper: safely extract nested fields
  fields_extract <- function(x, field) {
    parts <- strsplit(field, "\\$")[[1]]
    for (p in parts) {
      if (!is.list(x) || is.null(x[[p]])) return(NA_character_)
      x <- x[[p]]
    }
    x
  }

  # Build tibble by extracting each requested field
  out <- purrr::map_dfc(fields_return, function(f) {
    vals <- vapply(items, fields_extract, character(1), field = f)
    tibble::tibble(!!make.names(f) := vals)
  })

  return(out)
}
