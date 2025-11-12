# Replace text in files using sed run in bash.

**\[superseded\]**

This function is superseded by
[`ngr_str_replace_in_files()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_replace_in_files.md).
Please use
[`ngr_str_replace_in_files()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_replace_in_files.md)
for future implementations since it is safer and allows user to review
replacements before performing them.

This function performs a bulk find-and-replace operation on a given set
of files. It replaces occurrences of `text_current` with `text_replace`
using `sed`, while handling word boundaries and trailing punctuation.

## Usage

``` r
ngr_sed_replace_in_files(text_current, text_replace, files)
```

## Arguments

- text_current:

  A character string representing the text to be replaced.

- text_replace:

  A character string representing the replacement text.

- files:

  A character vector of file paths where the replacement should be
  applied.

## Value

Invisibly returns the result of the
[`processx::run`](http://processx.r-lib.org/reference/run.md) command.

## Note

Running this example will result in modifications to the specified
files. Ensure you are working with test files or have backups before
running the function.

## See also

[`processx::run()`](http://processx.r-lib.org/reference/run.md) for
running system commands.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example usage:
# Define the strings to replace and their replacements
keys_matched <- data.frame(
  key_missing = c("exampleOldText", "anotherOldValue"),
  key_missing_guess_match = c("exampleNewText", "anotherNewValue"),
  stringsAsFactors = FALSE
)

# Example files (replace these paths with your own test files)
file_list <- c("test_file1.txt", "test_file2.txt")

# Run the replacements (note: this will modify the specified files!)
purrr::map2(
  .x = keys_matched$key_missing,
  .y = keys_matched$key_missing_guess_match,
  ~ ngr_sed_replace_in_files(text_current = .x, text_replace = .y, files = file_list)
)
} # }
```
