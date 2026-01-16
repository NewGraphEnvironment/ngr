#' Perform Bulk Find-and-Replace on Multiple Files Using stringr
#'
#' This function explicitly reads the content of files, performs find-and-replace
#' operations using `stringr`, and writes the updated content back to the files.
#' It handles word boundaries, trailing punctuation, and allows for specific symbols
#' like `@` to precede the text to be replaced.
#'
#' @inheritParams ngr_str_replace_filenames
#' @param files [character] A vector of file paths to perform find-and-replace operations on.
#' @importFrom stringr str_replace_all str_detect str_which
#' @importFrom cli cli_alert_info cli_alert_warning cli_alert_success cli_abort
#' @importFrom chk chk_file chk_character
#' @return [logical] Invisibly returns a logical vector indicating success for each file.
#' @export
ngr_str_replace_in_files <- function(text_current, text_replace, files, ask = TRUE) {
  # Validate inputs
  chk::chk_character(text_current)
  chk::chk_character(text_replace)
  lapply(files, chk::chk_file) # Validate files with base R loop

  # Abort if any files are in .git directories
  if (any(grepl("\\.git/", files))) {
    cli::cli_abort("Files in .git directories are not allowed. Please remove them from the input list.")
  }

  # Process each file
  results <- logical(length(files))
  for (i in seq_along(files)) {
    # Read file content
    content <- readLines(files[i], warn = FALSE)

    # Detect lines that contain text_current but not text_replace
    lines_to_replace_indices <- which(
      stringr::str_detect(
        content,
        paste0("(^|[^a-zA-Z0-9_])", stringr::fixed(text_current), "(?=[^a-zA-Z_]|$)")
      ) & !stringr::str_detect(
        content,
        paste0("(^|[^a-zA-Z0-9_])", stringr::fixed(text_replace), "($|[^a-zA-Z0-9_])")
      )
    )

    if (length(lines_to_replace_indices) > 0) {
      # Aggregate information about replacements
      replacement_info <- paste(
        sprintf("  Line %d: %s", lines_to_replace_indices, content[lines_to_replace_indices]),
        collapse = "\n"
      )

      # Display matches to the user
      if (ask) {
        cli::cli_alert_info("In file {files[i]}:\n{replacement_info}")
        response <- readline(prompt = "Do you want to proceed with these replacements? (y/n): ")
        if (tolower(response) != "y") {
          cli::cli_alert_warning("Skipping replacements for file {files[i]}")
          next
        }
      }

      # Perform replacements only if user confirmed
      updated_content <- stringr::str_replace_all(
        content,
        paste0("(^|[^a-zA-Z0-9_])", stringr::fixed(text_current), "(?=[^a-zA-Z_]|$)"),
        paste0("\\1", text_replace)
      )

      # Write back to the file
      writeLines(updated_content, files[i])
      cli::cli_alert_success("Replacements applied to file {files[i]}")
      results[i] <- TRUE
    } else {
      cli::cli_alert_info("No replacements needed for file {files[i]}")
    }
  }

  # Return success status
  invisible(results)
}
