#' Extract Formulas from an Excel Worksheet
#'
#' This function reads rownames from a specific sheet and row of an Excel file, maps them to the excel column id (address).
#'
#'
#' It uses [tidyxl::xlsx_cells()] to parse the Excel file and filters cells based on the provided sheet name and row ID.
#' Removes row ids from excel addresses and tidies column names using [janitor::make_clean_names()]
#'
#' @param path [character] A path to the Excel file to be read. Must be a valid file path.
#' @param sheet [character] The name of the sheet from which to extract formulas. Must be specified.
#' @param row_id [numeric] The row number to filter names by. Must be specified.
#'
#' @return A data frame of column names, column names cleaned (lower snakecase) their associated excel column id (address),
#' excel address without a row number
#' (for tying to formulas).
#'
#' @details
#' This function reads the Excel file and filters cells to extract only those with formulas
#' from the specified sheet and row. The output includes all unique formulas from the target row.
#'
#' @examples
#' path <- system.file("extdata", "pscis_phase1.xlsm", package = "ngr")
#' ngr_xl_map_colnames(path, sheet = "PSCIS Assessment Worksheet", row_id = 4)
#'
#' @importFrom tidyxl xlsx_cells
#' @importFrom chk chk_file chk_string chk_number
#' @importFrom janitor make_clean_names
#' @export
#' @family excel
ngr_xl_map_colnames <- function(path, sheet, row_id) {
  # Validate inputs
  chk::chk_file(path)
  chk::chk_string(sheet)
  chk::chk_number(row_id)

  # Read the Excel file
  x <- tidyxl::xlsx_cells(path)

  # Filter for the specified sheet and row with formulas
  x_filtered <- x[x$sheet == sheet & x$row == row_id, ]

  # remove the numbers from the address and make clean names
  x_xfm <- within(x_filtered, {
    address_rowless <- gsub("(?<=[A-Z])\\d+", "", address, perl = TRUE)
    names_clean <- janitor::make_clean_names(character)
  })

  x_select <- x_xfm[, c("address", "character", "address_rowless", "names_clean")]

  return(x_select)
}
