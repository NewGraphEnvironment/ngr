#' Extract Single Row Formulas from an Excel Worksheet
#'
#' This function reads single row formulas (formulas working on columns within the same row of the spreadsheet where the
#' fomula is located) from a specific sheet and row of an Excel file.
#' It uses [tidyxl::xlsx_cells()] to parse the Excel file and filters cells based on the provided sheet name and row ID.
#' It processes the formulas to remove row specific addresses so that they can be abstracted to R with less friction.
#' Designed as a helper function to work with [ngr_xl_map_colnames()].
#'
#' @param path [character] A path to the Excel file to be read. Must be a valid file path.
#' @param sheet [character] The name of the sheet from which to extract formulas. Must be specified.
#' @param row_id [numeric] The row number to filter formulas by. Must be specified. Can be a vector of rows (ie. c(5,6))
#'
#' @return A data frame of unique formulas with their associated metadata for the specified sheet and row.
#'
#' @details
#' This function reads the Excel file and filters cells to extract only those with formulas
#' from the specified sheet and row. The output includes all unique formulas from the target row.
#'
#' @examples
#' path <- system.file("extdata", "pscis_phase1.xlsm", package = "ngr")
#' res <- ngr_xl_read_formulas(path, sheet = "PSCIS Assessment Worksheet", row_id = c(5,6))
#' res[, "formula_rowless"]
#'
#' @importFrom tidyxl xlsx_cells
#' @export
#' @family excel
ngr_xl_read_formulas <- function(path, sheet, row_id) {
  # Validate inputs
  chk::chk_file(path)
  chk::chk_string(sheet)
  lapply(row_id, chk_numeric)

  # Read the Excel file
  x <- tidyxl::xlsx_cells(path)

  # Filter for the specified sheet and row with formulas
  x_filtered <- x[x$sheet == sheet & !is.na(x$formula) & x$row %in% row_id, ]
  x_filtered$formula_rowless <- gsub("([A-Z]+)\\d+", "\\1", x_filtered$formula, perl = TRUE)
  x_filtered$address_rowless <- gsub("(?<=[A-Z])\\d+", "", x_filtered$address, perl = TRUE)
  # Remove duplicate formulas
  x_unique <- x_filtered[!duplicated(x_filtered$formula_rowless), ]

  x_select <- x_unique[, c("address", "row", "address_rowless", "formula", "formula_rowless")]

  return(x_select)
}
