#' List S3 Keys from a Public or Authenticated S3 Bucket
#'
#' Retrieve all object keys from an Amazon S3 bucket, optionally filtered by prefix and glob or substring pattern.
#'
#' @param url_bucket [character] A single string. The URL of the S3 bucket (e.g., "https://nrs.objectstore.gov.bc.ca/gdwuts").
#' @param prefix [character] Optional. A prefix to filter the S3 keys returned. Default is `NULL`.
#' @param pattern [character] Optional. A vector of glob or substring patterns used to filter the result. If patterns contain wildcards (`*` or `?`), they are treated as glob; otherwise as fixed substring matches.
#'
#' @returns [character] A character vector of fully qualified S3 object URLs that match the criteria. If no matches are found or the bucket fails to respond, an error is raised or an empty character vector is returned.
#'
#' @details This function paginates through the XML responses from S3 using the `marker` parameter until `IsTruncated` is `FALSE`. Keys can be filtered using both prefix and flexible glob or fixed-string matching. Final returned values are constructed by joining `url_bucket` with each key.
#'
#' @seealso [httr2::request()], [xml2::read_xml()], [utils::glob2rx()]
#'
#' @importFrom httr GET status_code content
#' @importFrom xml2 read_xml xml_find_all xml_find_first xml_text xml_ns
#' @importFrom utils glob2rx
#' @importFrom fs path
#' @export
#'
#' @examples
#' keys <- ngr_s3_keys_get(
#'   url_bucket = "https://nrs.objectstore.gov.bc.ca/gdwuts",
#'   prefix = "093/093l",
#'   pattern = c("dem", "*.tif")
#' )
#' head(keys)
ngr_s3_keys_get <- function(url_bucket, prefix = NULL, pattern = NULL) {
  # Validate inputs
  chk::chk_string(url_bucket)
  if (!is.null(prefix)) chk::chk_string(prefix)
  if (!is.null(pattern)) chk::chk_character(pattern)

  all_keys <- character()
  is_truncated <- TRUE
  marker <- NULL

  while (is_truncated) {
    # Build query
    query <- list()
    if (!is.null(prefix)) query$prefix <- prefix
    if (!is.null(marker)) query$marker <- marker

    # GET request
    res <- httr::GET(url_bucket, query = query)
    if (httr::status_code(res) != 200) {
      cli::cli_abort("Failed to fetch bucket listing: {httr::status_code(res)}")
    }

    # Parse XML
    xml <- xml2::read_xml(httr::content(res, "text"))
    ns <- xml2::xml_ns(xml)

    # Extract keys
    keys <- xml2::xml_text(xml2::xml_find_all(xml, ".//d1:Key", ns))
    all_keys <- c(all_keys, keys)

    # Check if truncated
    is_truncated <- xml2::xml_text(xml2::xml_find_first(xml, ".//d1:IsTruncated", ns)) == "true"
    if (is_truncated && length(keys)) {
      marker <- keys[length(keys)]
    }
  }

  # Improved filtering: glob + substring match
  if (!is.null(pattern)) {
    for (p in pattern) {
      if (grepl("[*?]", p)) {
        rx <- utils::glob2rx(p)
        all_keys <- all_keys[grepl(rx, all_keys)]
      } else {
        all_keys <- all_keys[grepl(p, all_keys, fixed = TRUE)]
      }
    }
  }

  fs::path(url_bucket, all_keys)
}
