# Retrieve GitHub Issues

Queries issues from a specified repository using the GitHub REST API and
returns a tibble with selected fields. Includes issues that were open at
the specified date or created after it.

## Usage

``` r
ngr_git_issue(
  owner,
  repo,
  date_since,
  token = gh::gh_token(),
  fields_return = c("url", "title", "body", "comments_url", "created_at", "closed_at",
    "milestone$title")
)
```

## Arguments

- owner:

  [character](https://rdrr.io/r/base/character.html) GitHub user or
  organization name (e.g., "NewGraphEnvironment").

- repo:

  [character](https://rdrr.io/r/base/character.html) Repository name
  (e.g., "ngr").

- date_since:

  [character](https://rdrr.io/r/base/character.html) (ISO 8601 datetime
  or date). Issues must have been open on or created after this date.

- token:

  [character](https://rdrr.io/r/base/character.html) GitHub personal
  access token. Defaults to
  [`gh::gh_token()`](https://gh.r-lib.org/reference/gh_token.html).
  Required to access private repositories.

- fields_return:

  [character](https://rdrr.io/r/base/character.html) vector of fields to
  return. Supports nested fields using "\$" notation (e.g.,
  "milestone\$title").

## Value

A tibble with columns specified in `fields_return`.

## See also

https://docs.github.com/en/rest/using-the-rest-api/issue-event-types

## Examples

``` r
ngr_git_issue(
  owner = "NewGraphEnvironment",
  repo = "ngr",
  date_since = "2024-01-01",
  token = NULL
)
#> Error in validate_gh_pat(new_gh_pat(x)): Invalid GitHub PAT format
#> ℹ A GitHub PAT must have one of three forms:
#> • 40 hexadecimal digits (older PATs)
#> • A 'ghp_' prefix followed by 36 to 251 more characters (newer PATs)
#> • A 'github_pat_' prefix followed by 36 to 244 more characters (fine-grained
#>   PATs)
#> ℹ Read more at
#>   <https://gh.r-lib.org/articles/managing-personal-access-tokens.html>.
```
