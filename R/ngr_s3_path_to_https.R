#' Convert an S3 Path to an https URL
#'
#' This function converts an S3 path into its corresponding https or website-specific http URL.
#'
#' @param s3_path [character] A single S3 path to convert, starting with `"s3://"`.
#' @param website [logical] Whether to construct a static website hosting URL. Default is `FALSE`. This can be used to
#' serve an index.html file via http (unsecured) like the ones created with [ngr_s3_files_to_index()].
#' @param aws_region [character] The AWS region for the bucket. Default is `"us-west-2"`.
#'
#' @returns [character] The https or http URL corresponding to the S3 path.
#'
#' @details
#' The function removes the `"s3://"` prefix, splits the remaining path into the bucket name and object key, and
#' constructs an https URL in the format `https://<bucket>.s3.amazonaws.com/<key>`. If `website = TRUE`, it constructs
#' a http URL in the format `http://<bucket>.s3-website-<region>.amazonaws.com/<key>`.
#'
#' Note: HTTPS is not supported for static website URLs directly from S3; use CloudFront for HTTPS.
#'
#' @importFrom cli cli_abort
#'
#' @export
#' @family s3
#' @examples
#' # Example usage:
#' ngr_s3_path_to_https("s3://my-bucket/my-object.txt")
#' ngr_s3_path_to_https("s3://my-bucket/my-object.txt", website = TRUE)
ngr_s3_path_to_https <- function(s3_path, website = FALSE, aws_region = "us-west-2") {
  # Validate inputs
  chk::chk_string(s3_path)
  chk::chk_flag(website)
  chk::chk_string(aws_region)

  if (!grepl("^s3://", s3_path)) {
    cli::cli_abort("The input must start with 's3://'.")
  }

  # Remove the 's3://' prefix
  path_without_prefix <- sub("^s3://", "", s3_path)

  # Split the path into bucket and key
  parts <- strsplit(path_without_prefix, "/", fixed = TRUE)[[1]]
  bucket_name <- parts[1]
  object_key <- paste(parts[-1], collapse = "/")

  # Construct the URL
  if (website) {
    url <- sprintf("http://%s.s3-website-%s.amazonaws.com/%s", bucket_name, aws_region, object_key)
  } else {
    url <- sprintf("https://%s.s3.amazonaws.com/%s", bucket_name, object_key)
  }

  return(url)
}
