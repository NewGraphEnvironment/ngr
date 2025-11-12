# Cast Character to PostgreSQL ltree

Constructs a PostgreSQL ltree literal from a character string. This is
useful for composing queries that rely on ltree path syntax.

## Usage

``` r
ngr_dbqs_ltree(x)
```

## Arguments

- x:

  [character](https://rdrr.io/r/base/character.html) A single string or
  character vector to be cast to `ltree`.

## Value

[character](https://rdrr.io/r/base/character.html) A string or character
vector of PostgreSQL ltree-compatible text. Each element is wrapped in
single quotes and cast with `::ltree`.

## Details

This function is typically used to help construct PostgreSQL queries
that operate on `ltree` data types. It simply formats each input string
into the PostgreSQL `ltree` cast syntax.

## Examples

``` r
ngr_dbqs_ltree("400.431358.623573")
#> [1] "'400.431358.623573'::ltree"
```
