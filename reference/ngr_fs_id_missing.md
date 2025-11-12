# Identify files in dir_in that are missing in dir_out

Returns paths from dir_in that do not exist under the same relative path
in dir_out.

## Usage

``` r
ngr_fs_id_missing(dir_in, dir_out, type = "file", recurse = TRUE, ...)
```

## Arguments

- dir_in:

  [character](https://rdrr.io/r/base/character.html) Path to the input
  directory.

- dir_out:

  [character](https://rdrr.io/r/base/character.html) Path to the output
  directory.

- type:

  [character](https://rdrr.io/r/base/character.html)
  [fs::dir_ls](https://fs.r-lib.org/reference/dir_ls.html) type param
  input. Defaults to "file"

- recurse:

  [logical](https://rdrr.io/r/base/logical.html)
  [fs::dir_ls](https://fs.r-lib.org/reference/dir_ls.html) recurse param
  input. Defaults to TRUE

- ...:

  Not used. For passing params to
  [fs::dir_ls](https://fs.r-lib.org/reference/dir_ls.html)

## Value

A character vector of input file paths that are missing from dir_out.

## See also

Other fs:
[`ngr_fs_copy_if_missing()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_copy_if_missing.md)
