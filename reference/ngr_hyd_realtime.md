# Retrieve Realtime HYDAT Data for a Station

Convenience function to fetch primary and secondary water survey
parameters for a given HYDAT station over a specified number of days.
Wraps
[`tidyhydat::realtime_ws()`](https://docs.ropensci.org/tidyhydat/reference/realtime_ws.html)
with main advantage that it relies on the availability of temperature
data (or some other `param_primary` to be present before it will attempt
to obtain secondary data.

## Usage

``` r
ngr_hyd_realtime(
  id_station = NULL,
  param_primary = c(5),
  param_secondary = c(1, 18, 19, 41, 46, 6, 7, 8, 10, 40, 47),
  days_back = 581
)
```

## Arguments

- id_station:

  [character](https://rdrr.io/r/base/character.html) A single station
  identifier string.

- param_primary:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector of
  primary HYDAT parameter codes.

- param_secondary:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector of
  secondary HYDAT parameter codes. This data is only retrieved if there
  is primary data available. See the available options with
  [tidyhydat::param_id](https://docs.ropensci.org/tidyhydat/reference/param_id.html)

- days_back:

  [numeric](https://rdrr.io/r/base/numeric.html) A single integer
  specifying how many days back to fetch data. Defaults to 581 which
  seems to be the maximum amount retrievable

## Value

A list with two elements: `primary_data` and `secondary_data`, each a
data frame of results. Returns `NULL` on failure and prints a CLI alert.

## See also

[`tidyhydat::realtime_ws()`](https://docs.ropensci.org/tidyhydat/reference/realtime_ws.html)
