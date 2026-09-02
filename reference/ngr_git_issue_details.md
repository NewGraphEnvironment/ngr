# Get GitHub Issue Timeline or Event Details

This function retrieves the timeline or event details for a specified
GitHub issue using the GitHub API. By default, it filters for events
associated with commits only.

## Usage

``` r
ngr_git_issue_details(
  issue_url_json,
  token = gh::gh_token(),
  endpoint = "timeline",
  events_all = FALSE
)
```

## Arguments

- issue_url_json:

  [character](https://rdrr.io/r/base/character.html). The full GitHub
  API URL of the issue (e.g.,
  "https://api.github.com/repos/user/repo/issues/123").

- token:

  [character](https://rdrr.io/r/base/character.html). A GitHub personal
  access token (PAT). Default is
  [`gh::gh_token()`](https://gh.r-lib.org/reference/gh_token.html).

- endpoint:

  [character](https://rdrr.io/r/base/character.html). The API endpoint
  to use for retrieving issue events. Defaults to "timeline". to access
  administrative actions like mentioned, labeling or assigning.

- events_all:

  [logical](https://rdrr.io/r/base/logical.html). If `TRUE`, return all
  events. If `FALSE` (default), return only those associated with
  commits (i.e., with a non-null `commit_id`).

## Value

A tibble with columns: `issue_url_json`, `event`, `commit_id`,
`commit_url_json`, and `created_at`.

## References

GitHub Issue Event Types:
https://docs.github.com/en/rest/using-the-rest-api/issue-event-types

## See also

[`gh::gh()`](https://gh.r-lib.org/reference/gh.html),
[`purrr::map_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html),
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)

## Examples

``` r
ngr_git_issue_details("https://api.github.com/repos/NewGraphEnvironment/fpr/issues/13")
#> # A tibble: 0 × 0
ngr_git_issue_details("https://api.github.com/repos/NewGraphEnvironment/fpr/issues/13", events_all = TRUE)
#> # A tibble: 5 × 3
#>   issue_url_json                                                event created_at
#>   <chr>                                                         <chr> <chr>     
#> 1 https://api.github.com/repos/NewGraphEnvironment/fpr/issues/… labe… 2022-12-1…
#> 2 https://api.github.com/repos/NewGraphEnvironment/fpr/issues/… assi… 2022-12-1…
#> 3 https://api.github.com/repos/NewGraphEnvironment/fpr/issues/… clos… 2022-12-2…
#> 4 https://api.github.com/repos/NewGraphEnvironment/fpr/issues/… reop… 2022-12-2…
#> 5 https://api.github.com/repos/NewGraphEnvironment/fpr/issues/… comm… 2022-12-2…
```
