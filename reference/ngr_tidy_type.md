# Coerce column types in one data frame to match another

This function ensures that shared columns in `dat_to_type` are coerced
to match the data types of corresponding columns in `dat_w_types`.

## Usage

``` r
ngr_tidy_type(dat_w_types, dat_to_type)
```

## Arguments

- dat_w_types:

  [data.frame](https://rdrr.io/r/base/data.frame.html) Reference data
  frame with desired column types.

- dat_to_type:

  [data.frame](https://rdrr.io/r/base/data.frame.html) Data frame to be
  coerced to match `dat_w_types`.

## Value

[data.frame](https://rdrr.io/r/base/data.frame.html) `dat_to_type` with
shared columns coerced to the types in `dat_w_types`.

## See also

Other tidy:
[`ngr_tidy_cols_rm_na()`](https://newgraphenvironment.github.io/ngr/reference/ngr_tidy_cols_rm_na.md),
[`ngr_tidy_cols_type_compare()`](https://newgraphenvironment.github.io/ngr/reference/ngr_tidy_cols_type_compare.md)

## Examples

``` r
dat_w_types <- data.frame(a = as.numeric(1:3), b = as.character(4:6))
dat_to_type <- data.frame(a = as.character(1:3), b = 4:6)
ngr_tidy_type(dat_w_types, dat_to_type)
#> Successfully converted column a to numeric.
#> Successfully converted column b to character.
#>   a b
#> 1 1 4
#> 2 2 5
#> 3 3 6
```
