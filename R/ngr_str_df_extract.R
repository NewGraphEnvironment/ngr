#' Extract segments of text from a data-frame column
#'
#' Pull substrings **between** regex start/end delimiters from a string column.
#' Each element of `segment_pairs` is a length-2 character vector:
#' `c(start_regex, end_regex)`. The **list name** becomes the output column name.
#'
#' @param data [data.frame] or [tibble::tbl_df] A table containing the source text column.
#' @param col [character] A single string: the **name of the text column** (e.g., "details").
#' @param segment_pairs [list] A **named** list where each element is a length-2
#' [character] vector `c(start_regex, end_regex)`. List names become output
#' column names. Names must be non-empty and unique.
#'
#' @returns [data.frame] The input `data` with one new column per named segment.
#' Values are `NA` where no match is found. An error is raised if `col` is
#' missing from `data`, if `segment_pairs` is not a properly named list, or if
#' any element is not a length-2 [character] vector.
#'
#' @seealso [ngr_str_extract_between()] to extract a single pair from a character vector.
#'
#' @family string dataframe
#' @export
#'
#' @importFrom cli cli_abort
#'
#' @examples
#' df <- tibble::tibble(details = c(
#' "Grant Amount: $400,000 Intake Year: 2025 Region: Fraser Basin Project Theme: Restoration",
#' "Grant Amount: $150,500 Intake Year: 2024 Region: Columbia Basin Project Theme: Food Systems"
#' ))
#'
#' segs <- list(
#' amount = c("Grant\\\\s*Amount", "Intake\\\\s*Year|Region|Project\\\\s*Theme|$"),
#' year = c("Intake\\\\s*Year", "Region|Project\\\\s*Theme|$"),
#' region = c("Region", "Project\\\\s*Theme|$"),
#' theme = c("Project\\\\s*Theme", "$")
#' )
#'
#' out <- ngr_str_df_extract(df, "details", segs)
#' out
ngr_str_df_extract <- function(data, col, segment_pairs) {
  # sanity checks
  chk::chk_data(data)
  chk::chk_string(col)
  if (!col %in% names(data)) {
    cli::cli_abort("ngr_str_df_extract: column '{col}' not found in `data`.")
  }
  if (!is.list(segment_pairs)) {
    cli::cli_abort("ngr_str_df_extract: `segment_pairs` must be a named list of length-2 character vectors.")
  }
  if (is.null(names(segment_pairs))) {
    cli::cli_abort("ngr_str_df_extract: `segment_pairs` must have names; names become output columns.")
  }
  nms <- names(segment_pairs)
  if (any(nms == "")) cli::cli_abort("ngr_str_df_extract: all `segment_pairs` names must be non-empty.")
  if (any(duplicated(nms))) cli::cli_abort("ngr_str_df_extract: names in `segment_pairs` must be unique.")
  bad <- !vapply(segment_pairs, function(p) is.character(p) && length(p) == 2L, logical(1))
  if (any(bad)) cli::cli_abort("ngr_str_df_extract: each element must be `c(start_regex, end_regex)`.")


  # extraction
  for (nm in names(segment_pairs)) {
    p <- segment_pairs[[nm]]
    data[[nm]] <- ngr_str_extract_between(data[[col]], p[1], p[2])
  }


  data
}
