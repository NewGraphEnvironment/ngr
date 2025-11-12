# Detect the Presence of a Specific File in a Directory

This function checks if a specific file exists in a given directory and
optionally its subdirectories.

## Usage

``` r
ngr_str_dir_from_file(path_dir, file_name, recurse = FALSE, ...)
```

## Arguments

- path_dir:

  [character](https://rdrr.io/r/base/character.html) A single string
  representing the directory path to search.

- file_name:

  [character](https://rdrr.io/r/base/character.html) A string specifying
  the name of the file to detect.

- recurse:

  [logical](https://rdrr.io/r/base/logical.html) Whether to search
  recursively in subdirectories. Default is `FALSE`.

- ...:

  Additional arguments passed to
  [`fs::dir_ls()`](https://fs.r-lib.org/reference/dir_ls.html).

## Value

[character](https://rdrr.io/r/base/character.html) The directory path if
the file is found; otherwise, a warning is issued.
