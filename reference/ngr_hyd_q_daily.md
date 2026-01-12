# Combine daily Streamflow Data from HYDAT and ECCC Realtime Sources

Retrieve and amalgamate daily streamflow data for one or more HYDAT
stations, combining historical daily flows from HYDAT with available
realtime daily flow data where supported. The function warns when
realtime data are unavailable and checks for missing dates in the
combined time series.

## Usage

``` r
ngr_hyd_q_daily(
  id_station,
  date_rt_start = Sys.Date() - 581,
  date_rt_end = Sys.Date(),
  date_hydat_start = "1980-01-01",
  ...
)
```

## Arguments

- id_station:

  [character](https://rdrr.io/r/base/character.html) A character vector
  of one or more HYDAT station IDs

- date_rt_start:

  [Date](https://rdrr.io/r/base/Dates.html) Optional. A single start
  date (or string coercible to date) for realtime data retrieval.
  Defaults to `Sys.Date() - 581` (18 months).

- date_rt_end:

  [Date](https://rdrr.io/r/base/Dates.html) Optional. A single end date
  (or string coercible to date) for realtime data retrieval. Defaults to
  [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html).

- date_hydat_start:

  [character](https://rdrr.io/r/base/character.html) Optional. A single
  date (or string coercible to date) giving the start date for
  historical HYDAT daily flows. Default is "1980-01-01".

- ...:

  Optional. Additional arguments passed to
  [`ngr_chk_dt_complete()`](https://newgraphenvironment.github.io/ngr/reference/ngr_chk_dt_complete.md)
  when checking for missing dates within each `STATION_NUMBER` time
  series (e.g., `dates_print = FALSE`).

## Value

A data frame containing daily streamflow data for the requested
stations. Warnings are emitted when realtime data are unavailable for
some stations or when missing dates are detected.

## Details

Historical daily flows are retrieved using
[`tidyhydat::hy_daily_flows()`](https://docs.ropensci.org/tidyhydat/reference/hy_daily_flows.html).
Realtime daily flows are retrieved using
[`tidyhydat::realtime_ws()`](https://docs.ropensci.org/tidyhydat/reference/realtime_ws.html)
for stations that support realtime reporting, as identified by
[`tidyhydat::realtime_stations()`](https://docs.ropensci.org/tidyhydat/reference/realtime_stations.html).
Realtime data are coerced to daily resolution and typed to match the
HYDAT data using
[`ngr_tidy_type()`](https://newgraphenvironment.github.io/ngr/reference/ngr_tidy_type.md).

Input dates are validated using
[`ngr_chk_coerce_date()`](https://newgraphenvironment.github.io/ngr/reference/ngr_chk_coerce_date.md).
Missing daily timestamps are checked per station using
[`ngr_chk_dt_complete()`](https://newgraphenvironment.github.io/ngr/reference/ngr_chk_dt_complete.md).

Duplicate station-date records are removed, keeping historical HYDAT
values where overlaps occur. The function reports stations with missing
dates using cli messages.

## Examples

``` r
ngr_hyd_q_daily(id_station = c("08NH118", "08NH126"))
#> Error in hy_src(hydat_path): No Hydat.sqlite3 found at /home/runner/.local/share/tidyhydat. Run download_hydat() to download the database.
```
