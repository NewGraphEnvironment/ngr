# Read data from a flat file with type schema preservation

Reads a data frame from a flat file format (CSV by default) using a
companion parquet schema file to restore column types. This enables
type-preserving round-trips for formats that don't natively preserve
types.

## Usage

``` r
ngr_fs_type_read(path, format = "csv", schema_suffix = "schema")
```

## Arguments

- path:

  Character. Path to the file to read. A companion schema file must
  exist.

- format:

  Character. File extension to replace when finding the schema file.
  Default is "csv".

- schema_suffix:

  Character. Suffix appended to base filename for the schema file.
  Default is "schema" (e.g., `data.csv` -\> `data_schema.parquet`). Use
  `""` for no suffix (e.g., `data.csv` -\> `data.parquet`).

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with column types restored from the schema file.

## See also

[`ngr_fs_type_write()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_type_write.md)
for writing files with type preservation

Other fs:
[`ngr_fs_copy_if_missing()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_copy_if_missing.md),
[`ngr_fs_id_missing()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_id_missing.md),
[`ngr_fs_type_write()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_type_write.md)

Other serialization:
[`ngr_fs_type_write()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_type_write.md)

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

# Read back with types preserved
df2 <- ngr_fs_type_read(path)
str(df2)

# Compare types
sapply(df, class)
sapply(df2, class)
} # }
```
