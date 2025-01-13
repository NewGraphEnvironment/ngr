#' Read Formulas and Column Names from an Excel Worksheet and Combine to Aid in Transformation of Formulas to R
#'
#' This function reads single row formulas (formulas working on columns within the same row of the spreadsheet where the
#' fomula is located) and column names from a specific sheet and rows of an Excel file.
#' It uses `tidyxl::xlsx_cells()` to parse the Excel file then uses `ngr` helper functions [ngr_xl_read_formulas()]
#' and [ngr_xl_map_colnames()] to clean up formulas and column names. Column names are subbed in the place of
#' excel addresses so (for now) the formulas can be passed to LLMs to convert from excel syntax to `R`.
#'
#' @param path [character] A path to the Excel file to be read. Must be a valid file path.
#' @param sheet [character] The name of the sheet from which to extract formulas and/or row names. Must be specified.
#' @param rowid_colnames [numeric] A single row number used to extract column names.
#' @param rowid_formulas [numeric] A vector of row numbers to filter formulas by. Must be specified.
#'
#' @return A data frame with the following columns:
#'   \describe{
#'     \item{address_rowless}{Excel address without the row ID appended.}
#'     \item{address}{Raw Excel column identifier.}
#'     \item{row}{Row number in the Excel spreadsheet from which the formula was extracted.}
#'     \item{formula}{Raw formula as it appears in the Excel spreadsheet.}
#'     \item{formula_rowless}{Formula with row numbers of referenced cells removed, aligned with \code{address_rowless}.}
#'     \item{formula_colname}{Column name indicating where the formula is located in the Excel spreadsheet.}
#'     \item{formula_with_col_names}{Excel formula with associated column names substituted for Excel addresses.}
#'   }
#'
#' @examples
#' path <- system.file("extdata", "pscis_phase1.xlsm", package = "ngr")
#' result <- ngr_xl_map_formulas(path, sheet = "PSCIS Assessment Worksheet", rowid_colnames = 4, rowid_formulas = c(5, 6))
#' result[, c("formula_colname", "formula_with_col_names")][7, ]
#'
#' @importFrom tidyxl xlsx_cells
#' @export
#' @family excel
ngr_xl_map_formulas <- function(path, sheet, rowid_colnames, rowid_formulas) {
  # Validate inputs
  chk::chk_file(path)
  chk::chk_string(sheet)
  chk::chk_number(rowid_colnames)
  lapply(rowid_formulas, chk_numeric)

  col_names_raw <- ngr::ngr_xl_map_colnames(path = path, sheet = sheet, row_id = rowid_colnames)
  col_names <- col_names_raw[, c("address_rowless", "names_clean")]
  # change the names_clean column name to formula_colname
  colnames(col_names)[colnames(col_names) == "names_clean"] <- "formula_colname"

  formulas_raw <- ngr::ngr_xl_read_formulas(path = path, sheet = sheet, row_id = rowid_formulas)

  formulas_prep <- merge(
    formulas_raw,
    col_names,
    by = "address_rowless",
    all.x = TRUE
  )

  # Create named vector for replacements
  xref_addresses_names <- setNames(col_names$formula_colname, col_names$address_rowless)

  # Perform replacements iteratively with purrr
  # formulas_prep2 <- formulas_prep |>
  #   dplyr::mutate(
  #     formula_with_col_names = purrr::reduce(
  #       .x = names(xref_addresses_names),
  #       .f = ~ stringr::str_replace_all(.x, stringr::regex(paste0("\\b", .y, "\\b")), xref_addresses_names[.y]),
  #       .init = formula_rowless
  #     )
  #   )

  # Perform replacements iteratively with mapply
  formulas_prep$formula_with_col_names <- mapply(
    function(formula, names_map) {
      result <- formula
      for (name in names(names_map)) {
        result <- gsub(paste0("\\b", name, "\\b"), names_map[[name]], result, perl = TRUE)
      }
      result
    },
    formula = formulas_prep$formula_rowless,
    MoreArgs = list(names_map = xref_addresses_names),
    SIMPLIFY = TRUE
  )

  return(formulas_prep)
}
