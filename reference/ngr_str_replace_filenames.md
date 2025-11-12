# Rename Files and Directories Containing Specific Text

This function renames files and directories by replacing occurrences of
a specified text with a new text. It allows exclusions and inclusions
using glob patterns and provides an option to confirm changes before
applying them.

## Usage

``` r
ngr_str_replace_filenames(
  path = ".",
  text_current,
  text_replace,
  glob_exclude = ".git",
  glob_include = NULL,
  ask = TRUE
)
```

## Arguments

- path:

  [character](https://rdrr.io/r/base/character.html) A vector of one or
  more paths. The root directory to start searching for files and
  directories.

- text_current:

  [character](https://rdrr.io/r/base/character.html) A string
  representing the text to be replaced in filenames.

- text_replace:

  [character](https://rdrr.io/r/base/character.html) A string
  representing the new text to replace the current text in filenames.

- glob_exclude:

  [character](https://rdrr.io/r/base/character.html) A glob pattern to
  exclude specific paths from renaming. Default is ".git".

- glob_include:

  [character](https://rdrr.io/r/base/character.html) or
  [NULL](https://rdrr.io/r/base/NULL.html) A glob pattern to include
  specific files or directories. Default is `NULL`.

- ask:

  [logical](https://rdrr.io/r/base/logical.html) Whether to prompt the
  user for confirmation before renaming. Default is `TRUE`.

## Value

`NULL` invisibly after completing the renaming operation.

## Details

The function uses
[`stringr::str_detect()`](https://stringr.tidyverse.org/reference/str_detect.html)
to find filenames containing the specified `text_current` and excludes
those where `text_replace` is already present. It then renames files and
directories accordingly using
[`fs::file_move()`](https://fs.r-lib.org/reference/file_move.html).
