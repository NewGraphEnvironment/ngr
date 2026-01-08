# Filter Rows Based on String Detection in a Column Detected with a partial String Match

This function filters rows in a data frame where a specified column's
name matches a pattern and the values of that column contain a specified
string.

## Usage

``` r
ngr_str_df_detect_filter(x, col_filter, str_filter)
```

## Arguments

- x:

  [data.frame](https://rdrr.io/r/base/data.frame.html) The input data
  frame to filter.

- col_filter:

  [character](https://rdrr.io/r/base/character.html) A single string
  representing the pattern to match column names.

- str_filter:

  [character](https://rdrr.io/r/base/character.html) A single string to
  match within the values of the filtered column.

## Value

A filtered data frame if matching rows are found; otherwise, the
original data frame is returned.

## See also

Other string dataframe:
[`ngr_str_df_col_agg()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_df_col_agg.md),
[`ngr_str_df_extract()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_df_extract.md)
