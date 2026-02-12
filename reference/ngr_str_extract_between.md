# Extract text between two regex delimiters

Pull a substring found **between** a start and end regular-expression
pattern from each element of a character vector. Matching is
case-insensitive and dot-all by default, and an optional colon after the
start pattern is ignored (e.g., `"Label:"`). You may optionally
normalize internal whitespace.

## Usage

``` r
ngr_str_extract_between(x, reg_start, reg_end, squish = FALSE)
```

## Arguments

- x:

  [character](https://rdrr.io/r/base/character.html) A character vector
  to search.

- reg_start:

  [character](https://rdrr.io/r/base/character.html) A single string:
  the **start** regex pattern. Optional trailing colon and whitespace in
  the source text are ignored.

- reg_end:

  [character](https://rdrr.io/r/base/character.html) A single string:
  the **end** regex pattern used in a lookahead; the matched text will
  end **before** this pattern.

- squish:

  [logical](https://rdrr.io/r/base/logical.html) Optional. If `TRUE`,
  collapse and trim whitespace in the extracted text via
  [`stringr::str_squish()`](https://stringr.tidyverse.org/reference/str_trim.html).
  Default is `FALSE`.

## Value

[character](https://rdrr.io/r/base/character.html) A character vector
the same length as `x`, with the extracted substrings. Elements are `NA`
when no match is found. Errors may be thrown by the underlying regex
engine if `reg_start` or `reg_end` contain invalid regular expressions.

## Matching details

- Flags used: `(?i)` case-insensitive, `(?s)` dot matches newline.

- Pattern built: non-capturing `(?:reg_start)` then optional `:\s*`,
  then the first **non-greedy** capture `(.*?)`, ending **just before**
  `(?:reg_end)` via a lookahead. If `squish = TRUE`, surrounding and
  internal whitespace is normalized.

## See also

[`ngr_str_df_extract()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_df_extract.md)
for applying multiple start/end pairs to a data-frame column.

Other string:
[`ngr_str_dir_from_path()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_dir_from_path.md),
[`ngr_str_link_url()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_link_url.md),
[`ngr_str_viewer_cog()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_viewer_cog.md)

## Examples

``` r
x <- c(
"Grant Amount: $400,000 Intake Year: 2025",
"Grant Amount: $150,500 Intake Year: 2024"
)
ngr_str_extract_between(x,
reg_start = "Grant\\\\s*Amount",
reg_end = "Intake\\\\s*Year|$"
)
#> [1] NA NA

# With whitespace normalization
ngr_str_extract_between(
x = "Region : Fraser Basin Project Theme: Something",
reg_start = "Region",
reg_end = "Project\\\\s*Theme|$",
squish = TRUE
)
#> [1] ": Fraser Basin Project Theme: Something"
```
