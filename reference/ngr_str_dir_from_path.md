# Extract Directory Name from File or Directory Path Based on Levels

This function retrieves the directory name at a specified level(s) above
the given file path. It wraps
[`fs::path_dir()`](https://fs.r-lib.org/reference/path_file.html) to
navigate up directory levels and
[`basename()`](https://rdrr.io/r/base/basename.html) to extract the
final directory name. Particularly useful for retrieving repo name so it
can be converted to url and or html link by
[`ngr_str_link_url()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_link_url.md).

## Usage

``` r
ngr_str_dir_from_path(path, levels = 1)
```

## Arguments

- path:

  [character](https://rdrr.io/r/base/character.html) A single string.
  The file path.

- levels:

  [integer](https://rdrr.io/r/base/integer.html) A single integer. The
  number of levels up to traverse from the file path to extract the
  directory name. Default is `1`.

## Value

[character](https://rdrr.io/r/base/character.html) A single string
representing the directory name at the specified level.

## See also

Other string:
[`ngr_str_extract_between()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_extract_between.md),
[`ngr_str_link_url()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_link_url.md)

## Examples

``` r
ngr_str_dir_from_path("~/Projects/repo/ngr/data-raw/extdata.R", levels = 2)
#> [1] "ngr"
# Returns "ngr"
```
