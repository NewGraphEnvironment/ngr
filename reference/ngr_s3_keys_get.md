# List S3 Keys from a Public or Authenticated S3 Bucket

Retrieve all object keys from an Amazon S3 bucket, optionally filtered
by prefix and glob or substring pattern.

## Usage

``` r
ngr_s3_keys_get(url_bucket, prefix = NULL, pattern = NULL)
```

## Arguments

- url_bucket:

  [character](https://rdrr.io/r/base/character.html) A single string.
  The URL of the S3 bucket (e.g.,
  "https://nrs.objectstore.gov.bc.ca/gdwuts").

- prefix:

  [character](https://rdrr.io/r/base/character.html) Optional. A prefix
  to filter the S3 keys returned. Default is `NULL`.

- pattern:

  [character](https://rdrr.io/r/base/character.html) Optional. A vector
  of glob or substring patterns used to filter the result. If patterns
  contain wildcards (`*` or `?`), they are treated as glob; otherwise as
  fixed substring matches.

## Value

[character](https://rdrr.io/r/base/character.html) A character vector of
fully qualified S3 object URLs that match the criteria. If no matches
are found or the bucket fails to respond, an error is raised or an empty
character vector is returned.

## Details

This function paginates through the XML responses from S3 using the
`marker` parameter until `IsTruncated` is `FALSE`. Keys can be filtered
using both prefix and flexible glob or fixed-string matching. Final
returned values are constructed by joining `url_bucket` with each key.

## See also

[`httr2::request()`](https://httr2.r-lib.org/reference/request.html),
[`xml2::read_xml()`](http://xml2.r-lib.org/reference/read_xml.md),
[`utils::glob2rx()`](https://rdrr.io/r/utils/glob2rx.html)

## Examples

``` r
keys <- ngr_s3_keys_get(
  url_bucket = "https://nrs.objectstore.gov.bc.ca/gdwuts",
  prefix = "093/093l",
  pattern = c("dem", "*.tif")
)
#> No encoding supplied: defaulting to UTF-8.
#> No encoding supplied: defaulting to UTF-8.
#> No encoding supplied: defaulting to UTF-8.
head(keys)
#> https:/nrs.objectstore.gov.bc.ca/gdwuts/093/093l/2016/dem/bc_093l031242_xl2m_utm9_20160922_dem.tif
#> https:/nrs.objectstore.gov.bc.ca/gdwuts/093/093l/2016/dem/bc_093l031244_xl2m_utm9_20160922_dem.tif
#> https:/nrs.objectstore.gov.bc.ca/gdwuts/093/093l/2016/dem/bc_093l031343_xl2m_utm9_20160922_dem.tif
#> https:/nrs.objectstore.gov.bc.ca/gdwuts/093/093l/2016/dem/bc_093l031344_xl2m_utm9_20160922_dem.tif
#> https:/nrs.objectstore.gov.bc.ca/gdwuts/093/093l/2016/dem/bc_093l031421_xl2m_utm9_20160922_dem.tif
#> https:/nrs.objectstore.gov.bc.ca/gdwuts/093/093l/2016/dem/bc_093l031422_xl2m_utm9_20160922_dem.tif
```
