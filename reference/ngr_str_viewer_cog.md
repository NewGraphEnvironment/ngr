# Generate an HTML iframe for the COG Viewer

Creates an HTML `<iframe>` tag that embeds the COG viewer at
`viewer.a11s.one` with a cache-busting version parameter. Bump `v` when
the viewer has breaking changes to invalidate stale browser caches
across all reports.

## Usage

``` r
ngr_str_viewer_cog(
  url,
  v = 2L,
  viewer_base = "https://viewer.a11s.one/",
  width = "100%",
  height = "600"
)
```

## Arguments

- url:

  [character](https://rdrr.io/r/base/character.html) A single string
  specifying the full URL of the COG file (e.g., an S3 HTTPS URL).

- v:

  [integer](https://rdrr.io/r/base/integer.html) Cache-busting version
  parameter appended to the viewer URL. Default is `2L`. Bump this in
  the package when `viewer.html` has breaking changes (e.g., TiTiler
  path updates) to force browsers to fetch the latest viewer for all
  reports on rebuild.

- viewer_base:

  [character](https://rdrr.io/r/base/character.html) A single string
  specifying the base URL of the viewer. Default is
  `"https://viewer.a11s.one/"`.

- width:

  [character](https://rdrr.io/r/base/character.html) A single string
  specifying the iframe width. Default is `"100%"`.

- height:

  [character](https://rdrr.io/r/base/character.html) A single string
  specifying the iframe height in pixels. Default is `"600"`.

## Value

[character](https://rdrr.io/r/base/character.html) A single string
containing the HTML `<iframe>` tag. Pass to
[`knitr::asis_output()`](https://rdrr.io/pkg/knitr/man/asis_output.html)
for rendering in report chunks.

## Details

The viewer URL is constructed as `<viewer_base>?v=<v>&cog=<url>`. The
`v` parameter is ignored by the viewer JavaScript but changes the URL
enough to bypass stale browser caches.

## See also

Other string:
[`ngr_str_dir_from_path()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_dir_from_path.md),
[`ngr_str_extract_between()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_extract_between.md),
[`ngr_str_link_url()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_link_url.md)

## Examples

``` r
ngr_str_viewer_cog("https://stac-dem-bc.s3.us-west-2.amazonaws.com/dem_pouce_coupe_2023.tif")
#> [1] "<iframe src=\"https://viewer.a11s.one/?v=2&cog=https://stac-dem-bc.s3.us-west-2.amazonaws.com/dem_pouce_coupe_2023.tif\" scrolling=\"no\" title=\"COG Viewer\" width=\"100%\" height=\"600\" frameBorder=\"0\"></iframe>"

# In a report chunk:
# knitr::asis_output(ngr_str_viewer_cog("https://bucket.s3.amazonaws.com/ortho.tif"))
```
