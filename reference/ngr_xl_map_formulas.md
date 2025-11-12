# Read Formulas and Column Names from an Excel Worksheet and Combine to Aid in Transformation of Formulas to R

This function reads single row formulas (formulas working on columns
within the same row of the spreadsheet where the fomula is located) and
column names from a specific sheet and rows of an Excel file. It uses
[`tidyxl::xlsx_cells()`](https://nacnudus.github.io/tidyxl/reference/xlsx_cells.html)
to parse the Excel file then uses `ngr` helper functions
[`ngr_xl_read_formulas()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_read_formulas.md)
and
[`ngr_xl_map_colnames()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_map_colnames.md)
to clean up formulas and column names. Column names are subbed in the
place of excel addresses so (for now) the formulas can be passed to LLMs
to convert from excel syntax to `R`.

## Usage

``` r
ngr_xl_map_formulas(path, sheet, rowid_colnames, rowid_formulas)
```

## Arguments

- path:

  [character](https://rdrr.io/r/base/character.html) A path to the Excel
  file to be read. Must be a valid file path.

- sheet:

  [character](https://rdrr.io/r/base/character.html) The name of the
  sheet from which to extract formulas and/or row names. Must be
  specified.

- rowid_colnames:

  [numeric](https://rdrr.io/r/base/numeric.html) A single row number
  used to extract column names.

- rowid_formulas:

  [numeric](https://rdrr.io/r/base/numeric.html) A vector of row numbers
  to filter formulas by. Must be specified.

## Value

A data frame with the following columns:

- address_rowless:

  Excel address without the row ID appended.

- address:

  Raw Excel column identifier.

- row:

  Row number in the Excel spreadsheet from which the formula was
  extracted.

- formula:

  Raw formula as it appears in the Excel spreadsheet.

- formula_rowless:

  Formula with row numbers of referenced cells removed, aligned with
  `address_rowless`.

- formula_colname:

  Column name indicating where the formula is located in the Excel
  spreadsheet.

- formula_with_col_names:

  Excel formula with associated column names substituted for Excel
  addresses.

## See also

Other excel:
[`ngr_xl_map_colnames()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_map_colnames.md),
[`ngr_xl_read_formulas()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_read_formulas.md)

## Examples

``` r
path <- system.file("extdata", "pscis_phase1.xlsm", package = "ngr")
result <- ngr_xl_map_formulas(path, sheet = "PSCIS Assessment Worksheet", rowid_colnames = 4, rowid_formulas = c(5, 6))
result[, c("formula_colname", "formula_with_col_names")][7, ]
#>   formula_colname
#> 7     final_score
#>                                                                                    formula_with_col_names
#> 7 culvert_length_score + embed_score + outlet_drop_score + culvert_slope_score + stream_width_ratio_score
```
