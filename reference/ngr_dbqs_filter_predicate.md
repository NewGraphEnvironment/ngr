# Construct a SQL Query Using Spatial Predicates

This function generates a SQL query to filter and join tables based on
spatial predicates. Should work on any SQL database that supports
spatial functions.

## Usage

``` r
ngr_dbqs_filter_predicate(
  target_tbl,
  mask_tbl,
  target_col_return = "*",
  mask_col_return = NULL,
  mask_col_filter = NULL,
  mask_col_filter_values = NULL,
  mask_col_filter_values_negate = FALSE,
  function_spatial = "ST_Intersects",
  quote_tbl = FALSE,
  ...
)
```

## Arguments

- target_tbl:

  [character](https://rdrr.io/r/base/character.html) The name of the
  target table. Required.

- mask_tbl:

  [character](https://rdrr.io/r/base/character.html) The name of the
  mask table. Required.

- target_col_return:

  [character](https://rdrr.io/r/base/character.html) Columns to return
  from the target table. Default is '\*', meaning all columns.

- mask_col_return:

  [character](https://rdrr.io/r/base/character.html) Columns to return
  from the mask table. Default is `NULL`, meaning no columns are
  returned.

- mask_col_filter:

  [character](https://rdrr.io/r/base/character.html) The column from the
  mask table used for filtering. Default is `NULL`.

- mask_col_filter_values:

  [character](https://rdrr.io/r/base/character.html) Values to filter
  the mask column by. Default is `NULL`.

- mask_col_filter_values_negate:

  [logical](https://rdrr.io/r/base/logical.html) Whether to negate the
  filter condition for the mask column. Default is `FALSE`.

- function_spatial:

  [character](https://rdrr.io/r/base/character.html) The spatial
  function to use for filtering, e.g., "ST_Intersects". Default is
  "ST_Intersects". Valid options are:

  - `ST_Intersects`

  - `ST_Contains`

  - `ST_Within`

  - `ST_Overlaps`

  - `ST_Crosses`

  - `ST_Touches`

  For more details on spatial functions, see [PostGIS Query
  Functions](https://postgis.net/docs/using_postgis_query.html#:~:text=To%20make%20it%20easy%20to,%2C%20ST_Overlaps%2C%20ST_Touches%2C%20ST_Within.).

- quote_tbl:

  [logical](https://rdrr.io/r/base/logical.html) Whether to quote table
  names to handle special characters. Default is `FALSE`. Allows quoting
  to be adjusted so can be used in geopackage when table names have
  periods in them. Uses
  [`ngr_dbqs_tbl_quote()`](https://newgraphenvironment.github.io/ngr/reference/ngr_dbqs_tbl_quote.md)
  to quote table names.

- ...:

  Additional arguments passed to `ngr::ngr_fdb_tbl_quote()` if
  `quote_tbl` is `TRUE`.

## Value

[character](https://rdrr.io/r/base/character.html) A SQL query string.

## Details

To enable geopackage support:

1.  Install spatialite-tools on cmd line with

    `brew install spatialite-tools`

2.  Find your installation on cmd line with

    `find /opt/homebrew -name mod_spatialite.dylib`

3.  Then Connect to GeoPackage in R with

    `con <- DBI::dbConnect(RSQLite::SQLite(), path_to_gpkg)`

4.  Load SpatiaLite

    `dbExecute(con, "SELECT load_extension('/opt/homebrew/lib/mod_spatialite.dylib');")`

5.  Run queries with

    `DBI::dbGetQuery(con, query = ngr_dbqs_filter_predicate(blah, blah, blah, quote_tbl = TRUE))`

## Examples

``` r
ngr_dbqs_filter_predicate(
  target_tbl = "target_table",
  mask_tbl = "mask_table",
  target_col_return = c("col1", "col2"),
  mask_col_return = c("filter_col"),
  mask_col_filter = "filter_col",
  mask_col_filter_values = c("value1", "value2"),
  function_spatial = "ST_Intersects"
)
#> SELECT target.col1, target.col2, mask.filter_col FROM target_table AS target JOIN mask_table AS mask ON ST_Intersects(target.geom, mask.geom) AND mask.filter_col IN ('value1', 'value2');
```
