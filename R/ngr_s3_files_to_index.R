#' Generate S3 Index HTML
#'
#' This function generates an `index.html` file to link to an S3 bucket's contents. Can be loaded to bucket to provide
#' a simple web interface for browsing files. For now we need to be sure to run this in the cmd line to see it though
#' `aws s3 website s3://{my_bucket_name}/ --index-document index.html`
#'
#' This function uses [ngr_s3_path_to_https()] to convert file paths into HTTPS links before constructing the HTML.
#'
#' @param files [character] A character vector of file and directory names (e.g., `"file1.txt"`, `"folder/"`).
#' @param dir_output [character] A string specifying the output directory where the file will be created. Defaults to the current working directory (`"."`).
#' @param filename_output [character] A string specifying the name of the output file. Defaults to `"index.html"`.
#' @param ask [logical] A logical value indicating whether to prompt the user before overwriting an existing file. Defaults to `TRUE`.
#' @param header1 [character] A string specifying the `<h1>` title for the HTML page. Defaults to `"Index"`.
#'
#' @return [character] Invisibly returns the path to the generated file.
#'
#' @importFrom fs dir_create path file_exists
#' @importFrom cli cli_alert_success cli_alert_info cli_alert_warning cli_abort
#' @family S3
#' @export
#'
#' @examples
#' # Example input
#' files <- c("file1.txt", "file2.txt", "folder1/", "folder2/")
#'
#' # Specify a custom output directory and filename
#' ngr_s3_files_to_index(files, dir_output = "output_dir", filename_output = "custom_index.html", header1 = "My Custom Index")
ngr_s3_files_to_index <- function(files, dir_output = ".", filename_output = "index.html", ask = TRUE, header1 = "Index") {
  # Validate input
  chk::chk_character(files)
  chk::chk_string(dir_output)
  chk::chk_string(filename_output)
  chk::chk_flag(ask)
  chk::chk_string(header1)

  # Ensure output directory exists
  fs::dir_create(dir_output)

  # Define output file path
  output_file <- fs::path(dir_output, filename_output)

  # Check if file exists and ask for confirmation if needed
  if (fs::file_exists(output_file) && ask) {
    cli::cli_alert_warning("File already exists: {output_file}")
    overwrite <- readline(prompt = "Do you want to overwrite it? (y/n): ")
    if (tolower(overwrite) != "y") {
      return(invisible(NULL))
    }
  }

  # Convert files to HTTPS paths
  files <- vapply(
    files,
    FUN = ngr::ngr_s3_path_to_https,
    FUN.VALUE = character(1),
    USE.NAMES = FALSE
  )

  # Helper Function to Generate HTML Content
  ngr_s3_html_index <- function(file_list, header1) {

    # Separate files and directories
    directories <- file_list[grepl("/$", file_list)]
    files <- file_list[!grepl("/$", file_list)]

    # Start HTML content
    html_content <- c(
      "<!DOCTYPE html>",
      "<html lang='en'>",
      "<head>",
      "<meta charset='UTF-8'>",
      "<meta name='viewport' content='width=device-width, initial-scale=1.0'>",
      "<title>S3 Bucket Index</title>",
      "<style>",
      "body { font-family: Arial, sans-serif; line-height: 1.6; }",
      "ul { list-style-type: none; padding-left: 20px; }",
      "li { margin: 5px 0; }",
      "a { text-decoration: none; color: #0073e6; }",
      "a:hover { text-decoration: underline; }",
      "</style>",
      "</head>",
      "<body>",
      paste0("<h1>", header1, "</h1>"),
      "<ul>"
    )

    # Add directories
    for (dir in directories) {
      html_content <- c(html_content, paste0("<li><strong>", dir, "</strong></li>"))
    }

    # Add files
    for (file in files) {
      html_content <- c(html_content, paste0("<li><a href='", file, "'>", file, "</a></li>"))
    }

    # Close HTML
    html_content <- c(html_content, "</ul>", "</body>", "</html>")
    return(html_content)
  }

  # Generate HTML content
  html_content <- ngr_s3_html_index(files, header1)

  writeLines(html_content, output_file)

  cli::cli_alert_success("File created successfully at: {output_file}")

  # Return output file path invisibly
  invisible(output_file)
}
