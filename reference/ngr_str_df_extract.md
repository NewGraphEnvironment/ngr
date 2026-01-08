# Extract segments of text from a data-frame column

Pull substrings **between** regex start/end delimiters from a string
column. Each element of `segment_pairs` is a length-2 character vector:
`c(start_regex, end_regex)`. The **list name** becomes the output column
name.

## Usage

``` r
ngr_str_df_extract(data, col, segment_pairs)
```

## Arguments

- data:

  [data.frame](https://rdrr.io/r/base/data.frame.html) or
  [tibble::tbl_df](https://tibble.tidyverse.org/reference/tbl_df-class.html)
  A table containing the source text column.

- col:

  [character](https://rdrr.io/r/base/character.html) A single string:
  the **name of the text column** (e.g., "details").

- segment_pairs:

  [list](https://rdrr.io/r/base/list.html) A **named** list where each
  element is a length-2
  [character](https://rdrr.io/r/base/character.html) vector
  `c(start_regex, end_regex)`. List names become output column names.
  Names must be non-empty and unique.

## Value

[data.frame](https://rdrr.io/r/base/data.frame.html) The input `data`
with one new column per named segment. Values are `NA` where no match is
found. An error is raised if `col` is missing from `data`, if
`segment_pairs` is not a properly named list, or if any element is not a
length-2 [character](https://rdrr.io/r/base/character.html) vector.

## See also

[`ngr_str_extract_between()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_extract_between.md)
to extract a single pair from a character vector.

Other string dataframe:
[`ngr_str_df_col_agg()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_df_col_agg.md),
[`ngr_str_df_detect_filter()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_df_detect_filter.md)

## Examples

``` r
df <- tibble::tibble(details = c(
"Grant Amount: $400,000 Intake Year: 2025 Region: Fraser Basin Project Theme: Restoration",
"Grant Amount: $150,500 Intake Year: 2024 Region: Columbia Basin Project Theme: Food Systems"
))

segs <- list(
amount = c("Grant\\\\s*Amount", "Intake\\\\s*Year|Region|Project\\\\s*Theme|$"),
year = c("Intake\\\\s*Year", "Region|Project\\\\s*Theme|$"),
region = c("Region", "Project\\\\s*Theme|$"),
theme = c("Project\\\\s*Theme", "$")
)

out <- ngr_str_df_extract(df, "details", segs)
out
#> # A tibble: 2 × 5
#>   details                                              amount year  region theme
#>   <chr>                                                <chr>  <chr> <chr>  <chr>
#> 1 Grant Amount: $400,000 Intake Year: 2025 Region: Fr… NA     NA    : Fra… NA   
#> 2 Grant Amount: $150,500 Intake Year: 2024 Region: Co… NA     NA    : Col… NA   
```
