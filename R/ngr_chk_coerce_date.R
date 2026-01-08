#' Check and Validate Date-Coercible Input
#'
#' Checks whether an object is a [Date] or can be safely coerced to a [Date]
#' using [base::as.Date()]. If the input is coercible, it is returned
#' invisibly; otherwise, an informative error is thrown.
#'
#' @param x [any] An object expected to be a [Date] or a string coercible to a
#'   [Date].
#' @param x_name [character] Optional. A single string giving the name of `x`
#'   used in error messages. If `NULL`, the name is inferred from the calling
#'   expression.
#'
#' @details
#' This helper is intended for lightweight validation in functions that accept
#' date inputs but do not need to modify them. Coercion is attempted via
#' [base::as.Date()], and failure results in a call to
#' [chk::abort_chk()].
#'
#' @returns
#' `x` invisibly if it is a [Date] or coercible to one. An error is thrown if
#' coercion fails.
#'
#' @seealso
#' [base::as.Date()], [chk::abort_chk()]
#'
#' @family chk
#'
#' @importFrom chk abort_chk
#'
#' @export
ngr_chk_coerce_date <- function(x, x_name = NULL) {
  if (!inherits(try(as.Date(x), silent = TRUE), "try-error")) {
    return(invisible(x))
  }
  if (is.null(x_name)) {
    x_name <- deparse(substitute(x))
  }
  chk::abort_chk(
    x_name, " must be a Date or a string coercible to Date",
    x = x
  )
}

