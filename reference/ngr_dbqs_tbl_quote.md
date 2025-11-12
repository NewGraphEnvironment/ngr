# Quote a Table Name for SQL Queries

This function wraps a table name with the specified type of quotation
marks, ensuring compatibility with SQL queries.

## Usage

``` r
ngr_dbqs_tbl_quote(table_name, quote_type = "double")
```

## Arguments

- table_name:

  [character](https://rdrr.io/r/base/character.html) A single string
  representing the table name to be quoted.

- quote_type:

  [character](https://rdrr.io/r/base/character.html) A single string
  specifying the type of quote to use, either `'single'` or `'double'`.
  Default is `'double'`.

## Value

[character](https://rdrr.io/r/base/character.html) The table name
wrapped in the specified type of quotation marks.

## Details

The function uses
[`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) to
format the table name with either single or double quotes. If an invalid
`quote_type` is specified, an error is thrown.

## Examples

``` r
ngr_dbqs_tbl_quote("my_table")
#> "my_table"
ngr_dbqs_tbl_quote("my_table", quote_type = "single")
#> 'my_table'
```
