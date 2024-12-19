#' Rename Files and Directories Containing Specific Text
#'
#' This function renames files and directories by replacing occurrences of a specified text with a new text.
#' It allows exclusions and inclusions using glob patterns and provides an option to confirm changes before applying them.
#'
#' @param path [character] A vector of one or more paths. The root directory to start searching for files and directories.
#' @param text_current [character] A string representing the text to be replaced in filenames.
#' @param text_replace [character] A string representing the new text to replace the current text in filenames.
#' @param glob_exclude [character] A glob pattern to exclude specific paths from renaming. Default is ".git".
#' @param glob_include [character] or [NULL] A glob pattern to include specific files or directories. Default is `NULL`.
#' @param ask [logical] Whether to prompt the user for confirmation before renaming. Default is `TRUE`.
#'
#' @details
#' The function uses `stringr::str_detect()` to find filenames containing the specified `text_current` and excludes those where `text_replace` is already present. It then renames files and directories accordingly using `fs::file_move()`.
#'
#' @return `NULL` invisibly after completing the renaming operation.
#'
#' @importFrom fs dir_ls file_move
#' @importFrom stringr str_detect str_replace
#' @importFrom cli cli_alert_info cli_alert_warning cli_alert_success cli_h2 cli_ul
#'
#' @export
#' @family replace
ngr_str_replace_filenames <- function(path = ".", text_current, text_replace, glob_exclude = ".git", glob_include = NULL, ask = TRUE) {
  # Validate inputs
  chk::chk_character(path)
  chk::chk_character(text_current)
  chk::chk_character(text_replace)
  if (!is.null(glob_exclude)) chk::chk_character(glob_exclude)
  if (!is.null(glob_include)) chk::chk_character(glob_include)

  # Get all files and directories
  entries <- fs::dir_ls(path, recurse = TRUE, all = TRUE)

  # Exclude specified glob pattern if provided
  if (!is.null(glob_exclude)) {
    entries <- entries[!stringr::str_detect(entries, glob_exclude)]
  }

  # Include only specified glob pattern if provided
  if (!is.null(glob_include)) {
    entries <- entries[stringr::str_detect(entries, glob_include)]
  }

  # Filter entries containing the target text
  entries_to_rename <- entries[stringr::str_detect(entries, paste0("(^|[^a-zA-Z0-9_])", text_current, "(?=[^a-zA-Z_]|$)")) &
                                 !stringr::str_detect(entries, paste0("(^|[^a-zA-Z0-9_])", text_replace, "($|[^a-zA-Z0-9_])"))]

  new_names <- stringr::str_replace(
    entries_to_rename,
    paste0("(^|[^a-zA-Z0-9_])(", text_current, ")(?=[^a-zA-Z_]|$)"),
    paste0("\\1", text_replace)
  )

  # Skip entries where the new name matches the original name
  to_rename <- which(entries_to_rename != new_names)
  entries_to_rename <- entries_to_rename[to_rename]
  new_names <- new_names[to_rename]

  # If no entries to rename, exit early
  if (length(entries_to_rename) == 0) {
    cli::cli_alert_info("No files or directories to rename.")
    return(invisible(NULL))
  }

  # Show changes and ask for confirmation if ask = TRUE
  if (ask) {
    cli::cli_h2("Files to be renamed:")
    changes <- paste0(entries_to_rename, " -> ", new_names)
    cli::cli_ul(changes)
    proceed <- readline("Proceed with renaming? (y/n): ")
    if (tolower(proceed) != "y") {
      cli::cli_alert_warning("Operation canceled.")
      return(invisible(NULL))
    }
  }

  # Rename files and directories
  for (i in seq_along(entries_to_rename)) {
    fs::file_move(entries_to_rename[i], new_names[i])
  }

  cli::cli_alert_success("Renaming completed.")
  invisible(NULL)
}
