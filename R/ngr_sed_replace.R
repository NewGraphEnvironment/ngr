#' Perform Bulk Find-and-Replace on Multiple Files
#'
#' This function performs a bulk find-and-replace operation on a given set of files.
#' It replaces occurrences of `text_current` with `text_replace` using `sed`, while
#' handling word boundaries and trailing punctuation.
#'
#' @param text_current A character string representing the text to be replaced.
#' @param text_replace A character string representing the replacement text.
#' @param files A character vector of file paths where the replacement should be applied.
#' @return Invisibly returns the result of the `processx::run` command.
#' @importFrom purrr map2
#' @examples
#' \dontrun{
#' # Example usage:
#' # Define the strings to replace and their replacements
#' keys_matched <- data.frame(
#'   key_missing = c("exampleOldText", "anotherOldValue"),
#'   key_missing_guess_match = c("exampleNewText", "anotherNewValue"),
#'   stringsAsFactors = FALSE
#' )
#'
#' # Example files (replace these paths with your own test files)
#' file_list <- c("test_file1.txt", "test_file2.txt")
#'
#' # Run the replacements (note: this will modify the specified files!)
#' purrr::map2(
#'   .x = keys_matched$key_missing,
#'   .y = keys_matched$key_missing_guess_match,
#'   ~ ngr_sed_replace(text_current = .x, text_replace = .y, files = file_list)
#' )
#' }
#' @note Running this example will result in modifications to the specified files.
#' Ensure you are working with test files or have backups before running the function.
#'
#' @seealso [processx::run()] for running system commands.
ngr_sed_replace <- function(text_current, text_replace, files) {
  # Ensure files are properly quoted to handle spaces or special chars in filenames
  files_quoted <- shQuote(files)

  # Construct the sed command with extended regex
  cmd <- sprintf(
    "sed -E -i '' 's/(^|[^A-Za-z0-9_])%s([^A-Za-z0-9_]|$)/\\1%s\\2/g' %s",
    text_current, text_replace, paste(files_quoted, collapse = " ")
  )

  # Run the command
  res <- processx::run(
    command = "bash",
    args = c("-c", cmd),
    echo = TRUE,
    error_on_status = TRUE
  )

  return(invisible(res))
}

