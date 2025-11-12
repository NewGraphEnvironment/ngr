# Compare Column Type Consistency Across Nested Dataframes

This function checks for column type consistency across multiple
dataframes nested in a list.

## Usage

``` r
ngr_tidy_cols_type_compare(nested_list_df)
```

## Arguments

- nested_list_df:

  [list](https://rdrr.io/r/base/list.html) A named list of dataframes,
  where each dataframe is expected to have consistent column names.

## Value

A [data.frame](https://rdrr.io/r/base/data.frame.html) with the
following columns:

- `col_name`: The name of the column.

- `types`: A comma-separated string of unique types found for the column
  across all datasets.

- `consistent`: A logical value indicating whether the column types are
  consistent across all datasets.

## Details

This function inspects the class of each column across a list of
dataframes. It aggregates the unique types for each column and
determines if the column types are consistent across all datasets in the
list.

## See also

Other tidy:
[`ngr_tidy_cols_rm_na()`](https://newgraphenvironment.github.io/ngr/reference/ngr_tidy_cols_rm_na.md),
[`ngr_tidy_type()`](https://newgraphenvironment.github.io/ngr/reference/ngr_tidy_type.md)

## Examples

``` r
nested_list_df <- list(
  df1 = data.frame(a = 1:3, b = c("x", "y", "z"), c = as.Date("2023-01-01") + 0:2, stringsAsFactors = FALSE),
  df2 = data.frame(a = c(1.1, 2.2, 3.3), b = c("x", "y", "z"), c = c(TRUE, FALSE, TRUE), stringsAsFactors = FALSE),
  df3 = data.frame(a = c("one", "two", "three"), b = c("x", "y", "z"), c = as.Date("2023-01-01") + 0:2, stringsAsFactors = FALSE)
)
ngr_tidy_cols_type_compare(nested_list_df)
#>   col_name                       types consistent
#> 1        a integer, numeric, character      FALSE
#> 2        b                   character       TRUE
#> 3        c               Date, logical      FALSE
```
