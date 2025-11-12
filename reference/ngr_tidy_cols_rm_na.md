# Remove Columns with All NA Values

`ngr_tidy_cols_rm_na` removes all columns from a
[data.frame](https://rdrr.io/r/base/data.frame.html) where every value
is `NA`. This can be particularly helper when attempting to join
data.frames due to type conflicts that occur due to columns with only
`NA` values.

## Usage

``` r
ngr_tidy_cols_rm_na(df)
```

## Arguments

- df:

  A [data.frame](https://rdrr.io/r/base/data.frame.html). The input data
  frame to be cleaned.

## Value

A [data.frame](https://rdrr.io/r/base/data.frame.html) with columns
containing only `NA` values removed.

## See also

Other tidy:
[`ngr_tidy_cols_type_compare()`](https://newgraphenvironment.github.io/ngr/reference/ngr_tidy_cols_type_compare.md),
[`ngr_tidy_type()`](https://newgraphenvironment.github.io/ngr/reference/ngr_tidy_type.md)

## Examples

``` r
# Example data frame
df <- data.frame(
  A = c(NA, NA, NA),
  B = c(1, 2, NA),
  C = c(NA, NA, NA),
  D = c("x", "y", NA)
)

# Apply the function
tidy_df <- ngr_tidy_cols_rm_na(df)

# Result
print(tidy_df)
#>    B    D
#> 1  1    x
#> 2  2    y
#> 3 NA <NA>
```
