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
#> # A tibble: 30 × 7
#>    url             title body  comments_url created_at closed_at milestone.title
#>    <chr>           <chr> <chr> <chr>        <chr>      <chr>     <chr>          
#>  1 https://api.gi… Add … "## … https://api… 2026-01-1… 2026-01-… Type-preservin…
#>  2 https://api.gi… Feat…  NA   https://api… 2026-01-1… 2026-01-… NA             
#>  3 https://api.gi… Add … "Add… https://api… 2026-01-1… 2026-01-… Type-preservin…
#>  4 https://api.gi… Add … "Add… https://api… 2026-01-1… 2026-01-… Type-preservin…
#>  5 https://api.gi… 24 s…  NA   https://api… 2026-01-0… 2026-01-… NA             
#>  6 https://api.gi… Add … "Add… https://api… 2026-01-0… NA        NA             
#>  7 https://api.gi… Allo… "Mod… https://api… 2026-01-0… NA        NA             
#>  8 https://api.gi… Impr… "## … https://api… 2026-01-0… 2026-01-… NA             
#>  9 https://api.gi… Ngr … "  N… https://api… 2026-01-0… 2026-01-… NA             
#> 10 https://api.gi… Add … "## … https://api… 2026-01-0… NA        NA             
#> # ℹ 20 more rows
```
