# Detach a package

This function is a convenience wrapper around `[detach()]` to unload a
package. It is designed to speed up development and testing for package
development and report writing.

## Usage

``` r
ngr_pkg_detach(pkg)
```

## Arguments

- pkg:

  [character](https://rdrr.io/r/base/character.html) A single string
  representing the name of the package to detach.

## Value

Invisibly returns NULL.

## Examples

``` r
if (FALSE) { # \dontrun{
ngr_pkg_detach("ngr")
} # }
```
