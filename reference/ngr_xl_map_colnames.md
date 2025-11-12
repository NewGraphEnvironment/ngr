# Extract Formulas from an Excel Worksheet

This function reads rownames from a specific sheet and row of an Excel
file, maps them to the excel column id (address).

## Usage

``` r
ngr_xl_map_colnames(path, sheet, row_id)
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
  filter names by. Must be specified.

## Value

A data frame of column names, column names cleaned (lower snakecase)
their associated excel column id (address), excel address without a row
number (for tying to formulas).

## Details

It uses
[`tidyxl::xlsx_cells()`](https://nacnudus.github.io/tidyxl/reference/xlsx_cells.html)
to parse the Excel file and filters cells based on the provided sheet
name and row ID. Removes row ids from excel addresses and tidies column
names using
[`janitor::make_clean_names()`](https://sfirke.github.io/janitor/reference/make_clean_names.html)

This function reads the Excel file and filters cells to extract only
those with formulas from the specified sheet and row. The output
includes all unique formulas from the target row.

## See also

Other excel:
[`ngr_xl_map_formulas()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_map_formulas.md),
[`ngr_xl_read_formulas()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_read_formulas.md)

## Examples

``` r
path <- system.file("extdata", "pscis_phase1.xlsm", package = "ngr")
ngr_xl_map_colnames(path, sheet = "PSCIS Assessment Worksheet", row_id = 4)
#> # A tibble: 42 × 4
#>    address character                       address_rowless names_clean          
#>    <chr>   <chr>                           <chr>           <chr>                
#>  1 A4      Date of Assessment (YYYY-MM-DD) A               date_of_assessment_y…
#>  2 B4      PSCIS Crossing ID               B               pscis_crossing_id    
#>  3 C4      My Crossing Reference           C               my_crossing_reference
#>  4 D4      Crew Members                    D               crew_members         
#>  5 E4      UTM Zone                        E               utm_zone             
#>  6 F4      Easting                         F               easting              
#>  7 G4      Northing                        G               northing             
#>  8 H4      Stream Name                     H               stream_name          
#>  9 I4      Road Name                       I               road_name            
#> 10 J4      Road KM Mark                    J               road_km_mark         
#> # ℹ 32 more rows
```
