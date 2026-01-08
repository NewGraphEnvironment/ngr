# Check for Complete Date Sequences

Checks whether a vector of dates forms a complete, uninterrupted
sequence between its minimum and maximum values. If missing dates are
detected, they are printed using
[`dput()`](https://rdrr.io/r/base/dput.html) for easy reuse and the
function returns `FALSE` invisibly.

## Usage

``` r
ngr_chk_dt_complete(
  x,
  units = "days",
  dates_print = TRUE,
  dates_capture = FALSE
)
```

## Arguments

- x:

  [Date](https://rdrr.io/r/base/Dates.html) A vector of dates to check
  for completeness.

- units:

  [character](https://rdrr.io/r/base/character.html) Optional. A single
  string giving the time unit for the sequence passed to
  [`base::seq.Date()`](https://rdrr.io/r/base/seq.Date.html). Default is
  `"days"`.

- dates_print:

  [logical](https://rdrr.io/r/base/logical.html) Optional. Whether to
  print missing dates to the console using
  [`dput()`](https://rdrr.io/r/base/dput.html) when gaps are detected.
  Default is `TRUE`.

- dates_capture:

  [logical](https://rdrr.io/r/base/logical.html) Optional. Whether to
  capture and return the missing dates as an object when gaps are
  detected. Default is `FALSE`.

## Value

If `dates_capture = FALSE` (default), returns `TRUE` invisibly if no
dates are missing and `FALSE` invisibly if one or more dates are
missing.

If `dates_capture = TRUE`, returns the missing dates as a
[Date](https://rdrr.io/r/base/Dates.html) vector (invisibly) when gaps
are detected, and `TRUE` invisibly when no dates are missing.

## Details

The function computes a full date sequence using
[`base::seq.Date()`](https://rdrr.io/r/base/seq.Date.html) from `min(x)`
to `max(x)` and compares it to the unique values of `x` using
[`base::setdiff()`](https://rdrr.io/r/base/sets.html). Missing dates, if
any, are printed with [`dput()`](https://rdrr.io/r/base/dput.html) so
they can be copied directly into code or tests.

## See also

Other chk:
[`ngr_chk_coerce_date()`](https://newgraphenvironment.github.io/ngr/reference/ngr_chk_coerce_date.md)

## Examples

``` r
dates_ok <- as.Date("2024-01-01") + 0:4
ngr_chk_dt_complete(dates_ok)

dates_bad <- as.Date(c("2024-01-01", "2024-01-02", "2024-01-04"))
ngr_chk_dt_complete(dates_bad)
#> ! There are missing dates:
#> "2024-01-03"
```
