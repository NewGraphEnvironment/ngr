# Helper function to remove trailing slashes from URLs
rtrim_slash <- function(x) {
  sub("/+$", "", x)
}


#' Download Files from a Directory
#'
#' This function downloads files matching a specified pattern from a directory URL to a local folder.
#'
#' @param url [character] The URL of the directory containing files to download. This can be an FTP, HTTP, or S3 directory.
#' @param path [character] The local path where the files should be downloaded.
#' @param glob [character] A regular expression pattern to match file types. Default is `""` for downloading all files.
#' Can use options such as `"\\.tif$"` to download all `tif` files or `"11\\.tif$"` to download all tiff files with filenames
#' that end in 11.
#' @param timeout_limit [numeric] The timeout limit for file downloads in seconds. Default is `18000` (30 minutes).
#' @param ... Empty. For passing arguments to [curl::multi_download()]/
#' @return A A tibble from [curl::multi_download()] indicating the completion of the download process and the path to the downloaded files.
#' @details
#' The function parses the HTML page at the provided URL, identifies links matching the specified pattern, and downloads each file to the specified local directory. Note that this will only work for S3 buckets exposed as static websites (e.g., `http://example-bucket.s3-website-region.amazonaws.com`).
#'
#' @importFrom fs path path_wd dir_create
#' @importFrom rvest read_html html_nodes html_attr
#' @importFrom chk chk_string chk_number
#' @importFrom curl multi_download
#' @importFrom cli cli_progress_bar cli_progress_update cli_progress_done cli_alert_info cli_alert_success cli_alert_warning
#' @export
#'
#' @examples
#' # \dontrun{
#' # Download all .tiff and .pdf files from the main directory of a static S3 bucket
#' url <- "http://example-bucket.s3-website-region.amazonaws.com"
#' path <- "./downloaded_files"
#' glob <- "\\.(tiff|pdf)$"
#' ngr_s3_dl(url, path, glob)
#' # }
ngr_s3_dl <- function(url, path, glob = "\\.tif$", timeout_limit = 18000, ...) {
  # Validate inputs
  chk::chk_string(url)
  chk::chk_string(path)
  chk::chk_string(glob)
  chk::chk_number(timeout_limit)

  # Set timeout for large file downloads
  options(timeout = timeout_limit)

  # Create the download directory if it doesn't exist
  fs::dir_create(path)

  # Fetch and parse the HTML page
  html_page <- rvest::read_html(url)

  # Extract file links matching the pattern
  links <- rvest::html_nodes(html_page, "a") |>
    rvest::html_attr("href")
  filenames <- grep(glob, links, value = TRUE)

  # Construct full URLs and destination paths
  urls <- paste0(rtrim_slash(url), "/", basename(filenames))
  dest_files <- fs::path(path, basename(filenames))

  curl::multi_download(
    urls = urls,
    destfiles = dest_files,
    ...
  )

}
