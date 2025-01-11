#' Extract Formulas from an Excel Worksheet
#'
#' This function reads formulas from a specific sheet and row of an Excel file.
#' It uses `tidyxl::xlsx_cells()` to parse the Excel file and filters cells based on the provided sheet name and row ID.
#'
#' @param path [character] A path to the Excel file to be read. Must be a valid file path.
#' @param sheet [character] The name of the sheet from which to extract formulas. Must be specified.
#' @param row_id [numeric] The row number to filter formulas by. Must be specified.
#'
#' @return A data frame of unique formulas with their associated metadata for the specified sheet and row.
#'
#' @details
#' This function reads the Excel file and filters cells to extract only those with formulas
#' from the specified sheet and row. The output includes all unique formulas from the target row.
#'
#' @examples
#' path <- system.file("extdata", "pscis_phase1.xlsm", package = "ngr")
#' ngr_xfm_xl_read_formulas(path, sheet = "PSCIS Assessment Worksheet", row_id = 5)
#'
#' @importFrom tidyxl xlsx_cells
#' @export
#' @family excel transform
ngr_xfm_xl_read_formulas <- function(path, sheet, row_id) {
  # Validate inputs
  chk::chk_file(path)
  chk::chk_string(sheet)
  chk::chk_number(row_id)

  # Read the Excel file
  x <- tidyxl::xlsx_cells(path)

  # Filter for the specified sheet and row with formulas
  x_filtered <- x[x$sheet == sheet & !is.na(x$formula) & x$row == row_id, ]

  # Remove duplicate formulas
  x_unique <- x_filtered[!duplicated(x_filtered$formula), ]

  return(x_unique)
}
