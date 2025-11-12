# Convert an S3 Path to an https URL

This function converts an S3 path into its corresponding https or
website-specific http URL.

## Usage

``` r
ngr_s3_path_to_https(s3_path, website = FALSE, aws_region = "us-west-2")
```

## Arguments

- s3_path:

  [character](https://rdrr.io/r/base/character.html) A single S3 path to
  convert, starting with `"s3://"`.

- website:

  [logical](https://rdrr.io/r/base/logical.html) Whether to construct a
  static website hosting URL. Default is `FALSE`. This can be used to
  serve an index.html file via http (unsecured) like the ones created
  with
  [`ngr_s3_files_to_index()`](https://newgraphenvironment.github.io/ngr/reference/ngr_s3_files_to_index.md).

- aws_region:

  [character](https://rdrr.io/r/base/character.html) The AWS region for
  the bucket. Default is `"us-west-2"`.

## Value

[character](https://rdrr.io/r/base/character.html) The https or http URL
corresponding to the S3 path.

## Details

The function removes the `"s3://"` prefix, splits the remaining path
into the bucket name and object key, and constructs an https URL in the
format `https://<bucket>.s3.amazonaws.com/<key>`. If `website = TRUE`,
it constructs a http URL in the format
`http://<bucket>.s3-website-<region>.amazonaws.com/<key>`.

Note: HTTPS is not supported for static website URLs directly from S3;
use CloudFront for HTTPS.

## Examples

``` r
# Example usage:
ngr_s3_path_to_https("s3://my-bucket/my-object.txt")
#> [1] "https://my-bucket.s3.amazonaws.com/my-object.txt"
ngr_s3_path_to_https("s3://my-bucket/my-object.txt", website = TRUE)
#> [1] "http://my-bucket.s3-website-us-west-2.amazonaws.com/my-object.txt"
```
