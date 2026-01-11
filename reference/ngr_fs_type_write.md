# Write data to a flat file with type schema preservation

Writes a data frame to a flat file format (CSV by default) and stores
the column type schema in a companion parquet file. This enables
type-preserving round-trips for formats that don't natively preserve
types, while keeping data in human-readable flat files suitable for
GitHub collaboration.

## Usage

``` r
ngr_fs_type_write(x, path, format = "csv")
```

## Arguments

- x:

  A [data.frame](https://rdrr.io/r/base/data.frame.html) or
  [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
  to write.

- path:

  Character. Path to write the file to.

- format:

  Character. File extension to replace when creating the schema file.
  Default is "csv".

## Value

Invisibly returns the file path.

## See also

[`ngr_fs_type_read()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_type_read.md)
for reading files with preserved types

Other fs:
[`ngr_fs_copy_if_missing()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_copy_if_missing.md),
[`ngr_fs_id_missing()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_id_missing.md),
[`ngr_fs_type_read()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_type_read.md)

Other serialization:
[`ngr_fs_type_read()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_type_read.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Create example data with various types
df <- data.frame(
  int_col = 1:3L,
  dbl_col = c(1.1, 2.2, 3.3),
  chr_col = c("a", "b", "c"),
  date_col = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03")),
  lgl_col = c(TRUE, FALSE, TRUE)
)

# Write to temporary file
path <- tempfile(fileext = ".csv")
ngr_fs_type_write(df, path)

# Schema file is created alongside
schema_path <- sub("\\.csv$", "_schema.parquet", path)
file.exists(schema_path)

# Read back with types preserved
df2 <- ngr_fs_type_read(path)
str(df2)
} # }
```
