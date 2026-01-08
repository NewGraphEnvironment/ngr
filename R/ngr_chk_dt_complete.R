#' Check for Complete Date Sequences
#'
#' Checks whether a vector of dates forms a complete, uninterrupted sequence
#' between its minimum and maximum values. If missing dates are detected,
#' they are printed using `dput()` for easy reuse and the function returns
#' `FALSE` invisibly.
#'
#' @param x [Date] A vector of dates to check for completeness.
#' @param units [character] Optional. A single string giving the time unit
#'   for the sequence passed to [base::seq.Date()]. Default is `"days"`.
#' @param dates_print [logical] Optional. Whether to print missing dates to the
#'   console using `dput()` when gaps are detected. Default is `TRUE`.
#' @param dates_capture [logical] Optional. Whether to capture and return the
#'   missing dates as an object when gaps are detected. Default is `FALSE`.
#'
#' @details
#' The function computes a full date sequence using [base::seq.Date()] from
#' `min(x)` to `max(x)` and compares it to the unique values of `x` using
#' [base::setdiff()]. Missing dates, if any, are printed with `dput()` so they
#' can be copied directly into code or tests.
#'
#' @return
#' If `dates_capture = FALSE` (default), returns `TRUE` invisibly if no dates
#' are missing and `FALSE` invisibly if one or more dates are missing.
#'
#' If `dates_capture = TRUE`, returns the missing dates as a [Date] vector
#' (invisibly) when gaps are detected, and `TRUE` invisibly when no dates
#' are missing.
#'
#' @examples
#' dates_ok <- as.Date("2024-01-01") + 0:4
#' ngr_chk_dt_complete(dates_ok)
#'
#' dates_bad <- as.Date(c("2024-01-01", "2024-01-02", "2024-01-04"))
#' ngr_chk_dt_complete(dates_bad)
#'
#' @importFrom cli cli_alert_warning cli_alert_success
#'
#' @export
#' @family chk
ngr_chk_dt_complete <- function(x, units = "days", dates_print = TRUE, dates_capture = FALSE) {
  ngr_chk_coerce_date(x)

  x <- as.Date(x)

  full_seq <- seq.Date(
    from = min(x, na.rm = TRUE),
    to   = max(x, na.rm = TRUE),
    by   = units
  )

  dates_missing <- as.Date(setdiff(full_seq, unique(x)), origin = "1970-01-01")

  if (length(dates_missing) > 0) {
    cli::cli_alert_warning("There are missing dates:")
    if (dates_print) {
      dput(as.character(dates_missing))
    }
    if (dates_capture) {
      return(invisible(dates_missing))
    }
    return(invisible(FALSE))
  }

  invisible(TRUE)
}
