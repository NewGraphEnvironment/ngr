#' Extract text between two regex delimiters
#'
#' Pull a substring found **between** a start and end regular-expression pattern
#' from each element of a character vector. Matching is case-insensitive and
#' dot-all by default, and an optional colon after the start pattern is ignored
#' (e.g., `"Label:"`). You may optionally normalize internal whitespace.
#'
#' @param x [character] A character vector to search.
#' @param reg_start [character] A single string: the **start** regex pattern.
#' Optional trailing colon and whitespace in the source text are ignored.
#' @param reg_end [character] A single string: the **end** regex pattern used
#' in a lookahead; the matched text will end **before** this pattern.
#' @param squish [logical] Optional. If `TRUE`, collapse and trim whitespace in
#' the extracted text via [stringr::str_squish()]. Default is `FALSE`.
#'
#' @returns [character] A character vector the same length as `x`, with the
#' extracted substrings. Elements are `NA` when no match is found. Errors may
#' be thrown by the underlying regex engine if `reg_start` or `reg_end`
#' contain invalid regular expressions.
#'
#' @section Matching details:
#' * Flags used: `(?i)` case-insensitive, `(?s)` dot matches newline.
#' * Pattern built: non-capturing `(?:reg_start)` then optional `:\s*`, then
#' the first **non-greedy** capture `(.*?)`, ending **just before**
#' `(?:reg_end)` via a lookahead. If `squish = TRUE`, surrounding and internal
#' whitespace is normalized.
#'
#' @seealso [ngr_str_df_extract()] for applying multiple start/end pairs to a
#' data-frame column.
#'
#' @family string
#'
#' @export
#'
#' @importFrom stringr regex str_match str_squish
#' @importFrom chk chk_character chk_string chk_flag
#'
#' @examples
#' x <- c(
#' "Grant Amount: $400,000 Intake Year: 2025",
#' "Grant Amount: $150,500 Intake Year: 2024"
#' )
#' ngr_str_extract_between(x,
#' reg_start = "Grant\\\\s*Amount",
#' reg_end = "Intake\\\\s*Year|$"
#' )
#'
#' # With whitespace normalization
#' ngr_str_extract_between(
#' x = "Region : Fraser Basin Project Theme: Something",
#' reg_start = "Region",
#' reg_end = "Project\\\\s*Theme|$",
#' squish = TRUE
#' )
ngr_str_extract_between <- function(x, reg_start, reg_end, squish = FALSE) {
  chk::chk_character(x)
  chk::chk_string(reg_start)
  chk::chk_string(reg_end)
  chk::chk_flag(squish)


  pat <- stringr::regex(
    paste0("(?is)(?:", reg_start, ")\\s*(.*?)\\s*(?=(?:", reg_end, "))")
  )
    out <- stringr::str_match(x, pat)[, 2]
  if (squish) out <- stringr::str_squish(out)
  ifelse(is.na(out), NA_character_, out)
}
