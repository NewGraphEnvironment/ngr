# Extract Single Row Formulas from an Excel Worksheet

This function reads single row formulas (formulas working on columns
within the same row of the spreadsheet where the fomula is located) from
a specific sheet and row of an Excel file. It uses
[`tidyxl::xlsx_cells()`](https://nacnudus.github.io/tidyxl/reference/xlsx_cells.html)
to parse the Excel file and filters cells based on the provided sheet
name and row ID. It processes the formulas to remove row specific
addresses so that they can be abstracted to R with less friction.
Designed as a helper function to work with
[`ngr_xl_map_colnames()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_map_colnames.md).

## Usage

``` r
ngr_xl_read_formulas(path, sheet, row_id)
```

## Arguments

- path:

  [character](https://rdrr.io/r/base/character.html) A path to the Excel
  file to be read. Must be a valid file path.

- sheet:

  [character](https://rdrr.io/r/base/character.html) The name of the
  sheet from which to extract formulas. Must be specified.

- row_id:

  [numeric](https://rdrr.io/r/base/numeric.html) The row number to
  filter formulas by. Must be specified. Can be a vector of rows (ie.
  c(5,6))

## Value

A data frame of unique formulas with their associated metadata for the
specified sheet and row.

## Details

This function reads the Excel file and filters cells to extract only
those with formulas from the specified sheet and row. The output
includes all unique formulas from the target row.

## See also

Other excel:
[`ngr_xl_map_colnames()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_map_colnames.md),
[`ngr_xl_map_formulas()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_map_formulas.md)

## Examples

``` r
path <- system.file("extdata", "pscis_phase1.xlsm", package = "ngr")
res <- ngr_xl_read_formulas(path, sheet = "PSCIS Assessment Worksheet", row_id = c(5,6))
res[, "formula_rowless"]
#> # A tibble: 8 × 1
#>   formula_rowless                                                               
#>   <chr>                                                                         
#> 1 "IF(ISBLANK(Z), 0, IF(ISBLANK(N) < 0, 0,Z / N))"                              
#> 2 "IF(O<15,0,IF(AND(O>=15,O<30),3,IF(O>=30,6,0)))"                              
#> 3 "IF(P = \"No\", 10, IF(ISBLANK(N), 0, IF(ISBLANK(Q), 0, IF(OR(Q / N <= 0.2, Q…
#> 4 "IF(V<0.15,0,IF(AND(V>=0.15,V<0.3),5,IF(V>=0.3,10,0)))"                       
#> 5 "IF(Y<1,0,IF(AND(Y>=1,Y<3),5,IF(Y>=3,10,0)))"                                 
#> 6 "IF(AF<1,0,IF(AND(AF>=1,AF<1.3),3,IF(AF>=1.3,6,0)))"                          
#> 7 "AG + AH + AI + AJ + AK"                                                      
#> 8 "IF(ISBLANK(L), \"\", IF(L = \"Open Bottom Structure\", \"Passable\", IF(L = …
```
