#' Extract segments of text from a dataframe column
#'
#' @description
#' Pulls text **between** regex start/end delimiters from a string column.
#' Each element of `segment_pairs` is a length-2 character vector:
#' `c(reg_start, reg_end)`. The **list name** becomes the output column name.
#'
#' @param data A data.frame / tibble containing the source text column.
#' @param col Character string: the **name of the text column** (e.g., `"details"`).
#' @param segment_pairs Named list where each element is `c(start_regex, end_regex)`.
#'
#' @return The input `data` with one new column per named segment.
#' @export
#'
#' @importFrom stringr regex str_match str_squish str_extract str_remove_all
#' @importFrom tibble tibble
#' @family string dataframe
#'
#' @examples
#' df <- tibble::tibble(details = c(
#'   "Grant Amount: $400,000 Intake Year: 2025 Region: Fraser Basin Project Theme: Restoration",
#'   "Grant Amount: $150,500 Intake Year: 2024 Region: Columbia Basin Project Theme: Food Systems"
#' ))
#'
#' segs <- list(
#'   amount = c("Grant\\s*Amount",            "Intake\\s*Year|Region|Project\\s*Theme|$"),
#'   year   = c("Intake\\s*Year",             "Region|Project\\s*Theme|$"),
#'   region = c("Region",                      "Project\\s*Theme|$"),
#'   theme  = c("Project\\s*Theme",            "$")
#' )
#'
#' out <- ngr_str_df_extract(df, "details", segs)
#' out
#'
#' # Optional normalization examples (to show how you might clean the extracted text (e.g., $400,000 → 400000, "2025" → integer) after running the extraction):
#' out$amount_num <- out$amount |>
#'   stringr::str_extract("\\$?\\s*[0-9][0-9,]*") |>
#'   stringr::str_remove_all("[\\$,]") |>
#'   as.double()
#'
#' out$year_int <- out$year |>
#'   stringr::str_extract("\\b(19|20)\\d{2}\\b") |>
#'   as.integer()
#'
ngr_str_df_extract <- function(data, col, segment_pairs) {
  stopifnot(is.character(col), length(col) == 1, nzchar(col))
  if (!col %in% names(data)) stop("Column '", col, "' not found in data.", call. = FALSE)

  grab_between <- function(x, start_pat, end_pat) {
    pat <- stringr::regex(
      paste0("(?is)", start_pat, "\\s*:?\\s*(.*?)\\s*(?=", end_pat, ")")
    )
    out <- stringr::str_match(x, pat)[, 2]
    ifelse(is.na(out), NA_character_, stringr::str_squish(out))
  }

  for (nm in names(segment_pairs)) {
    p <- segment_pairs[[nm]]
    if (!is.character(p) || length(p) != 2L)
      stop("Each element of segment_pairs must be a length-2 character vector: c(start_regex, end_regex).",
           call. = FALSE)
    data[[nm]] <- grab_between(data[[col]], p[1], p[2])
  }

  data
}
