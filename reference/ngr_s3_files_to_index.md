# Generate S3 Index HTML

This function generates an `index.html` file to link to an S3 bucket's
contents. Can be loaded to bucket to provide a simple web interface for
browsing files. For now we need to be sure to run this in the cmd line
to see it though
`aws s3 website s3://{my_bucket_name}/ --index-document index.html`

## Usage

``` r
ngr_s3_files_to_index(
  files,
  dir_output = ".",
  filename_output = "index.html",
  ask = TRUE,
  header1 = "Index"
)
```

## Arguments

- files:

  [character](https://rdrr.io/r/base/character.html) A character vector
  of file and directory names (e.g., `"file1.txt"`, `"folder/"`).

- dir_output:

  [character](https://rdrr.io/r/base/character.html) A string specifying
  the output directory where the file will be created. Defaults to the
  current working directory (`"."`).

- filename_output:

  [character](https://rdrr.io/r/base/character.html) A string specifying
  the name of the output file. Defaults to `"index.html"`.

- ask:

  [logical](https://rdrr.io/r/base/logical.html) A logical value
  indicating whether to prompt the user before overwriting an existing
  file. Defaults to `TRUE`.

- header1:

  [character](https://rdrr.io/r/base/character.html) A string specifying
  the `<h1>` title for the HTML page. Defaults to `"Index"`.

## Value

[character](https://rdrr.io/r/base/character.html) Invisibly returns the
path to the generated file.

## Details

This function uses
[`ngr_s3_path_to_https()`](https://newgraphenvironment.github.io/ngr/reference/ngr_s3_path_to_https.md)
to convert file paths into HTTPS links before constructing the HTML.

## Examples

``` r
# Example input
files <- c("file1.txt", "file2.txt", "folder1/", "folder2/")

# Specify a custom output directory and filename
ngr_s3_files_to_index(files, dir_output = "output_dir", filename_output = "custom_index.html", header1 = "My Custom Index")
#> Error in FUN(X[[i]], ...): The input must start with 's3://'.
```
