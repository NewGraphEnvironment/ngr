# Check and Validate Date-Coercible Input

Checks whether an object is a [Date](https://rdrr.io/r/base/Dates.html)
or can be safely coerced to a [Date](https://rdrr.io/r/base/Dates.html)
using [`base::as.Date()`](https://rdrr.io/r/base/as.Date.html). If the
input is coercible, it is returned invisibly; otherwise, an informative
error is thrown.

## Usage

``` r
ngr_chk_coerce_date(x, x_name = NULL)
```

## Arguments

- x:

  [any](https://rdrr.io/r/base/any.html) An object expected to be a
  [Date](https://rdrr.io/r/base/Dates.html) or a string coercible to a
  [Date](https://rdrr.io/r/base/Dates.html).

- x_name:

  [character](https://rdrr.io/r/base/character.html) Optional. A single
  string giving the name of `x` used in error messages. If `NULL`, the
  name is inferred from the calling expression.

## Value

`x` invisibly if it is a [Date](https://rdrr.io/r/base/Dates.html) or
coercible to one. An error is thrown if coercion fails.

## Details

This helper is intended for lightweight validation in functions that
accept date inputs but do not need to modify them. Coercion is attempted
via [`base::as.Date()`](https://rdrr.io/r/base/as.Date.html), and
failure results in a call to
[`chk::abort_chk()`](https://poissonconsulting.github.io/chk/reference/abort_chk.html).

## See also

[`base::as.Date()`](https://rdrr.io/r/base/as.Date.html),
[`chk::abort_chk()`](https://poissonconsulting.github.io/chk/reference/abort_chk.html)

Other chk:
[`ngr_chk_dt_complete()`](https://newgraphenvironment.github.io/ngr/reference/ngr_chk_dt_complete.md)
