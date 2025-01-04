#' Quote a Table Name for SQL Queries
#'
#' This function wraps a table name with the specified type of quotation marks, ensuring compatibility with SQL queries.
#'
#' @param table_name [character] A single string representing the table name to be quoted.
#' @param quote_type [character] A single string specifying the type of quote to use, either `'single'` or `'double'`. Default is `'double'`.
#'
#' @return [character] The table name wrapped in the specified type of quotation marks.
#'
#' @details
#' The function uses `glue::glue()` to format the table name with either single or double quotes. If an invalid `quote_type` is specified, an error is thrown.
#'
#' @importFrom glue glue
#' @importFrom cli cli_abort
#'
#' @examples
#' ngr_dbqs_tbl_quote("my_table")
#' ngr_dbqs_tbl_quote("my_table", quote_type = "single")
#'
#' @export
ngr_dbqs_tbl_quote <- function(table_name, quote_type = "double") {
  # Validate inputs
  chk::chk_string(table_name)
  chk::chk_string(quote_type)

  # Ensure valid quote_type
  if (!quote_type %in% c("double", "single")) {
    cli::cli_abort("Invalid quote_type specified. Use 'single' or 'double'.")
  }

  # Quote table name based on quote_type
  table_name_quoted <- if (quote_type == "single") {
    glue::glue("'{table_name}'")
  } else {
    glue::glue('"{table_name}"')
  }

  return(table_name_quoted)
}

