# Copy files from one directory to another only if they don't already exist

Recursively lists files in `dir_in` and copies them to the same relative
path under `dir_out`, skipping any files that already exist.

## Usage

``` r
ngr_fs_copy_if_missing(dir_in, dir_out)
```

## Arguments

- dir_in:

  Character. Path to the input directory.

- dir_out:

  Character. Path to the output directory.

## Value

Invisibly returns `NULL`. Used for side effects (file copying).

## See also

Other fs:
[`ngr_fs_id_missing()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_id_missing.md),
[`ngr_fs_type_read()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_type_read.md),
[`ngr_fs_type_write()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_type_write.md)

## Examples

``` r
dir_in <- fs::dir_create(fs::path(tempfile(), "a"))
dir_out <- fs::dir_create(fs::path(tempfile(), "b"))
fs::file_create(fs::path(dir_in, "test.txt"))
ngr_fs_copy_if_missing(fs::path_dir(dir_in), fs::path_dir(dir_out))
fs::file_exists(fs::path(dir_out, "a", "test.txt"))
#> /tmp/Rtmphy0Ekj/file1d9325e4b1c3/b/a/test.txt 
#>                                         FALSE 
```
