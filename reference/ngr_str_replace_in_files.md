# Perform Bulk Find-and-Replace on Multiple Files Using stringr

This function explicitly reads the content of files, performs
find-and-replace operations using `stringr`, and writes the updated
content back to the files. It handles word boundaries, trailing
punctuation, and allows for specific symbols like `@` to precede the
text to be replaced.

## Usage

``` r
ngr_str_replace_in_files(text_current, text_replace, files, ask = TRUE)
```

## Arguments

- text_current:

  [character](https://rdrr.io/r/base/character.html) A string
  representing the text to be replaced in filenames.

- text_replace:

  [character](https://rdrr.io/r/base/character.html) A string
  representing the new text to replace the current text in filenames.

- files:

  [character](https://rdrr.io/r/base/character.html) A vector of file
  paths to perform find-and-replace operations on.

- ask:

  [logical](https://rdrr.io/r/base/logical.html) Whether to prompt the
  user for confirmation before renaming. Default is `TRUE`.

## Value

[logical](https://rdrr.io/r/base/logical.html) Invisibly returns a
logical vector indicating success for each file.
