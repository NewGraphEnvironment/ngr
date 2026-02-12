# Create an HTML Link to Repository Resources or GitHub Pages

This function generates an HTML `<a>` tag linking to a url or a url
related to specified repository resource or GitHub Pages site hosted
from the repository. It is particularly useful for embedding links in
html tables such as DT tables.

## Usage

``` r
ngr_str_link_url(
  url_base = "https://www.newgraphenvironment.com",
  url_resource = NULL,
  url_resource_path = TRUE,
  anchor_text = "url_link",
  target = "_blank"
)
```

## Arguments

- url_base:

  [character](https://rdrr.io/r/base/character.html) A character vector
  specifying either the URL(s) to link to or (if `url_resource` is
  provided) the base URL(s) for the repository host. Default is New
  Graph gitpages at <https://www.newgraphenvironment.com>.
  <https://github.com/NewGraphEnvironment> gets you to the repository
  itself.

- url_resource:

  [character](https://rdrr.io/r/base/character.html) A character vector
  representing the repository name(s) to be linked. Optional. Default is
  `NULL`.

- url_resource_path:

  [logical](https://rdrr.io/r/base/logical.html) A logical value
  indicating whether to include a `/` between `url_base` and
  `url_resource`. Defaults to `TRUE`. When set to `FALSE`, it
  facilitates constructing file paths from `url_base` and `url_resource`
  without `/` in between, which is useful for API calls such as those to
  tile servers.

- anchor_text:

  [character](https://rdrr.io/r/base/character.html) A character vector
  specifying the text displayed for the link. Defaults to `"url_link"`.

- target:

  [character](https://rdrr.io/r/base/character.html) A single string
  indicating the `target` attribute in the HTML link. Default is
  `"_blank"`. Options include:

  - `"_blank"`: Opens the link in a new tab or window.

  - `"_self"`: Opens the link in the same tab or window.

  - `"_parent"`: Opens the link in the parent frame, if applicable.

  - `"_top"`: Opens the link in the full body of the window, ignoring
    frames.

## Value

[character](https://rdrr.io/r/base/character.html) A character vector
containing the HTML `<a>` tags.

## See also

Other string:
[`ngr_str_dir_from_path()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_dir_from_path.md),
[`ngr_str_extract_between()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_extract_between.md),
[`ngr_str_viewer_cog()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_viewer_cog.md)

## Examples

``` r
# Example 1: Link to the repository with default anchor text
ngr_str_link_url("ngr", url_base = "https://github.com/NewGraphEnvironment")
#> [1] "<a href=\"https://github.com/NewGraphEnvironment/ngr\" target=\"_blank\">url_link</a>"

# Example 2: Link to GitHub Pages with anchor text set to the repository name
ngr_str_link_url(url_resource = "ngr", anchor_text = "ngr")
#> [1] "<a href=\"https://www.newgraphenvironment.com/ngr\" target=\"_blank\">ngr</a>"

# Example 3: Link with no url_resource
ngr_str_link_url(url_base = "https://www.newgraphenvironment.com", anchor_text = "Visit New Graph")
#> [1] "<a href=\"https://www.newgraphenvironment.com\" target=\"_blank\">Visit New Graph</a>"

# Example 4: Use in a dplyr::mutate()
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
df <- data.frame(
  url_resource = c("ngr", "fpr"),
  url_base = c("https://github.com/NewGraphEnvironment", "https://www.newgraphenvironment.com")
)
df <- df %>%
  mutate(
    link = ngr_str_link_url(url_resource = url_resource, url_base = url_base, anchor_text = url_resource)
  )
print(df$link)
#> [1] "<a href=\"https://github.com/NewGraphEnvironment/ngr\" target=\"_blank\">ngr</a>"
#> [2] "<a href=\"https://www.newgraphenvironment.com/fpr\" target=\"_blank\">fpr</a>"   
```
