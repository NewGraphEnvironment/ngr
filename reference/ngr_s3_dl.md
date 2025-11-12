# Download Files from a Directory

This function downloads files matching a specified pattern from a
directory URL to a local folder.

## Usage

``` r
ngr_s3_dl(url, path, glob = "\\.tif$", timeout_limit = 3600, ...)
```

## Arguments

- url:

  [character](https://rdrr.io/r/base/character.html) The URL of the
  directory containing files to download. This can be an FTP, HTTP, or
  S3 directory.

- path:

  [character](https://rdrr.io/r/base/character.html) The local path
  where the files should be downloaded.

- glob:

  [character](https://rdrr.io/r/base/character.html) A regular
  expression pattern to match file types. Default is `""` for
  downloading all files. Can use options such as `"\\.tif$"` to download
  all `tif` files or `"11\\.tif$"` to download all tiff files with
  filenames that end in 11.

- timeout_limit:

  [numeric](https://rdrr.io/r/base/numeric.html) The timeout limit for
  file downloads in seconds. Default is `3600` (60 minutes).

- ...:

  Empty. For passing arguments to
  [`curl::multi_download()`](https://jeroen.r-universe.dev/curl/reference/multi_download.html)

## Value

A tibble from
[`curl::multi_download()`](https://jeroen.r-universe.dev/curl/reference/multi_download.html)
indicating the completion of the download process and the path to the
downloaded files.

## Details

The function parses the HTML page at the provided URL, identifies links
matching the specified pattern, and downloads each file to the specified
local directory. Note that this will only work for S3 buckets exposed as
static websites (e.g.,
`http://example-bucket.s3-website-region.amazonaws.com`).

## Examples

``` r
# \dontrun{
# Download all .tiff and .pdf files from the main directory of a static S3 bucket
url <- "http://example-bucket.s3-website-region.amazonaws.com"
path <- "./downloaded_files"
glob <- "\\.(tiff|pdf)$"
ngr_s3_dl(url, path, glob)
#> Error in open.connection(x, "rb"): cannot open the connection
# }
```
