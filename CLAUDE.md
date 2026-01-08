# ngr - New Graph Reporting

R package with utility functions for dynamic reporting, spatial
analysis, hydrology, and data wrangling.

## Build & Test Commands

``` r
devtools::document()
devtools::test()
devtools::check()
devtools::install()
```

Build documentation and run checks before committing.

## Commit Style (fledge)

This repo uses [fledge](https://github.com/cynkra/fledge) for changelog
management.

**NEWS-worthy commits** start with `-` (bullet point):

    - initial commit of [ngr_function_name()] to close [#1](https://github.com/NewGraphEnvironment/ngr/issues/1)

**Function references** use square brackets for pkgdown auto-links: -
`[function_name()]` - creates link to function docs in pkgdown site

**Issue references** use full markdown links: -
`[#19](https://github.com/NewGraphEnvironment/ngr/issues/19)`

**Non-NEWS commits** (docs, chores) don’t start with `-`:

    rebuild documentation and update build config

## Function Naming Conventions

All exported functions use prefix `ngr_` followed by category:

| Prefix      | Category                   | Example                                                                                                           |
|-------------|----------------------------|-------------------------------------------------------------------------------------------------------------------|
| `ngr_str_`  | String manipulation        | [`ngr_str_extract_between()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_extract_between.md)     |
| `ngr_spk_`  | Spatial/raster (spacehakr) | [`ngr_spk_stac_calc()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_stac_calc.md)                 |
| `ngr_hyd_`  | Hydrology                  | [`ngr_hyd_q_daily()`](https://newgraphenvironment.github.io/ngr/reference/ngr_hyd_q_daily.md)                     |
| `ngr_dbqs_` | Database/SQL queries       | [`ngr_dbqs_filter_predicate()`](https://newgraphenvironment.github.io/ngr/reference/ngr_dbqs_filter_predicate.md) |
| `ngr_tidy_` | Data frame tidying         | [`ngr_tidy_cols_rm_na()`](https://newgraphenvironment.github.io/ngr/reference/ngr_tidy_cols_rm_na.md)             |
| `ngr_xl_`   | Excel operations           | [`ngr_xl_read_formulas()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_read_formulas.md)           |
| `ngr_fs_`   | File system                | [`ngr_fs_copy_if_missing()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_copy_if_missing.md)       |
| `ngr_s3_`   | S3/cloud storage           | [`ngr_s3_dl()`](https://newgraphenvironment.github.io/ngr/reference/ngr_s3_dl.md)                                 |
| `ngr_git_`  | Git/GitHub                 | [`ngr_git_issue()`](https://newgraphenvironment.github.io/ngr/reference/ngr_git_issue.md)                         |
| `ngr_chk_`  | Validation/checking        | [`ngr_chk_dt_complete()`](https://newgraphenvironment.github.io/ngr/reference/ngr_chk_dt_complete.md)             |
| `ngr_pkg_`  | Package utilities          | [`ngr_pkg_detach()`](https://newgraphenvironment.github.io/ngr/reference/ngr_pkg_detach.md)                       |

## Documentation Style

- Use roxygen2 with markdown enabled
- Add `@family` tags to group related functions (e.g.,
  `@family spacehakr`, `@family string`)
- Use `@importFrom` for all external functions
- Include `@examples` (use `\dontrun{}` for slow/network examples)
- Reference related functions with `@seealso`

## Key Dependencies

- **chk** - Argument validation
- **cli** - User messaging
- **sf/terra** - Spatial operations
- **tidyhydat** - Hydrometric data
- **dplyr/purrr/stringr** - Data wrangling
- **glue** - String interpolation

## DESCRIPTION Management

- Keep Imports alphabetized
- Don’t duplicate packages in both Imports and Suggests
- Add vignette-only packages to Suggests (e.g., mapview, rstac)
