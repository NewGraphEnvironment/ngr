# Construct Docker Command Arguments for ODM

Generates arguments for running the OpenDroneMap Docker container (WHICH
MUST BE RUNNING FOR THESE args to be PASSED TO IT) with a specified
project path. The function can produce either a vector of arguments for
[`processx::run`](http://processx.r-lib.org/reference/run.md) or a
complete Docker command as a string ready to copy and paste into the
terminal, depending on the `interactive` parameter. It includes
opinionated `params_default` optimized for processing high-resolution
imagery, producing outputs such as a digital surface model (DSM) and a
digital terrain model (DTM).

## Usage

``` r
ngr_spk_odm(
  path_project,
  params_default = c("--dtm", "--dsm", "--pc-quality", "low", "--dem-resolution", "10"),
  params_add = NULL,
  interactive = FALSE
)
```

## Arguments

- path_project:

  [character](https://rdrr.io/r/base/character.html) The absolute path
  to the directory where the project is held. Must be a valid directory.

- params_default:

  [character](https://rdrr.io/r/base/character.html) or
  [NULL](https://rdrr.io/r/base/NULL.html) Optional. A character vector
  of opinionated parameters to include in the arguments. Defaults to
  c("–dtm", "–dsm", "–cog", "–pc-quality", "low", "–dem-resolution",
  "10").

- params_add:

  [character](https://rdrr.io/r/base/character.html) or
  [NULL](https://rdrr.io/r/base/NULL.html) Optional. A character vector
  of additional parameters to include in the arguments.

- interactive:

  [logical](https://rdrr.io/r/base/logical.html) Whether to include the
  `-ti` flag for interactive mode. If `TRUE`, the full command including
  `docker` is returned as a single string for terminal use. Default is
  `FALSE`.

## Value

[character](https://rdrr.io/r/base/character.html) A vector of arguments
to pass to
[`processx::run`](http://processx.r-lib.org/reference/run.md), or a
single string with the full command for terminal use if
`interactive = TRUE`.

## Details

By default, this function generates both DTM and DSM outputs using the
`--dtm` and `--dsm` flags. `--cog` generation appears to be corrupted by
metadata writing so that is left for a seperate step. Additional
parameters can be passed through `params_add` as a character vector.
When `interactive = TRUE`, the full command including `docker` is
returned as a single string for terminal use. For more details on the
steps and arguments, see the OpenDroneMap documentation:
<https://docs.opendronemap.org/arguments/>

## See also

Other spacehakr:
[`ngr_spk_gdalwarp()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_gdalwarp.md),
[`ngr_spk_join()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_join.md),
[`ngr_spk_layer_info()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_layer_info.md),
[`ngr_spk_poly_to_points()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_poly_to_points.md),
[`ngr_spk_q_layer_info()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_q_layer_info.md),
[`ngr_spk_rast_ext()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_ext.md),
[`ngr_spk_rast_not_empty()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_not_empty.md),
[`ngr_spk_rast_rm_empty()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_rm_empty.md),
[`ngr_spk_res()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_res.md),
[`ngr_spk_stac_calc()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_stac_calc.md)

Other processx:
[`ngr_spk_gdalwarp()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_gdalwarp.md)

Other spacehakr:
[`ngr_spk_gdalwarp()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_gdalwarp.md),
[`ngr_spk_join()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_join.md),
[`ngr_spk_layer_info()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_layer_info.md),
[`ngr_spk_poly_to_points()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_poly_to_points.md),
[`ngr_spk_q_layer_info()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_q_layer_info.md),
[`ngr_spk_rast_ext()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_ext.md),
[`ngr_spk_rast_not_empty()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_not_empty.md),
[`ngr_spk_rast_rm_empty()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_rm_empty.md),
[`ngr_spk_res()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_res.md),
[`ngr_spk_stac_calc()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_stac_calc.md)

## Examples

``` r
if (FALSE) { # \dontrun{
path_project <- "/Volumes/backup_2022/backups/new_graph/archive/uav_imagery/fraser/nechacko/2024/199174_necr_trib_dog"
args <- ngr_spk_odm(
  path_project,
  params_add = c("--rerun-from", "odm_dem", "--orthophoto-kmz", "--copy-to", "~/Projects"),
  interactive = FALSE
)
processx::run(command = "docker", args = args, echo = TRUE)

# Generate a quick running command for interactive terminal use:
interactive_command <- ngr_spk_odm(
  path_project,
  params_default = NULL,
  params_add = c("--fast-orthophoto",
               "--pc-quality", "low",
               "--skip-report",
              "--orthophoto-resolution", "20"),
              ,
  interactive = TRUE
  )

cat(interactive_command, "\n")

#process multiple project files that contain `images` directory
paths <- c("/Volumes/backup_2022/backups/new_graph/archive/uav_imagery/skeena/bulkley/2024/8530_sandstone_test",
           "/Volumes/backup_2022/backups/new_graph/archive/uav_imagery/skeena/bulkley/2024/8530_sandstone_test2")

args2 <- lapply(paths, ngr::ngr_spk_odm)

args2 |> purrr::walk(
  ~ processx::run(
    command = "docker",
    args = .x,
    echo = TRUE
  )
)
} # }
```
