# Changelog

## ngr 0.0.2

### Deprecations

All twelve `ngr_spk_*` functions are deprecated. They now warn via
[`lifecycle::deprecate_warn()`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)
and forward to
[spacehakr](https://github.com/NewGraphEnvironment/spacehakr), which is
where they are maintained. Callers should move to `spacehakr::spk_*()`:

[`ngr_spk_gdalwarp()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_gdalwarp.md),
[`ngr_spk_geoserv_dlv()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_geoserv_dlv.md),
[`ngr_spk_join()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_join.md),
[`ngr_spk_layer_info()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_layer_info.md),
[`ngr_spk_odm()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_odm.md),
[`ngr_spk_poly_to_points()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_poly_to_points.md),
[`ngr_spk_q_layer_info()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_q_layer_info.md),
[`ngr_spk_rast_ext()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_ext.md),
[`ngr_spk_rast_not_empty()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_not_empty.md),
[`ngr_spk_rast_rm_empty()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_rm_empty.md),
[`ngr_spk_res()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_res.md),
[`ngr_spk_stac_calc()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_stac_calc.md).

There was never a removal step planned for “later” — the two copies had
already drifted, so the implementations are gone from ngr now and there
is one implementation again.

### Behaviour changes in the delegated functions

Because ngr’s copies had fallen behind, delegating is **not** a no-op.
Two functions behave differently than ngr’s implementations did:

- **[`ngr_spk_geoserv_dlv()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_geoserv_dlv.md)**
  now aborts on a non-200 response, where ngr printed a message and
  returned the output path regardless — so a failed download used to
  look like a successful one. The success message also moved from
  [`cat()`](https://rdrr.io/r/base/cat.html) on stdout to
  [`cli::cli_alert_success()`](https://cli.r-lib.org/reference/cli_alert.html)
  on stderr, which changes what anything capturing stdout sees. The
  underlying HTTP stack moved from `httr` to `httr2`.
- **[`ngr_spk_gdalwarp()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_gdalwarp.md)**
  places `params_add` before the input and output paths rather than
  after. GDAL accepts flags in either position, so most values behave
  identically; the case that differs is a `params_add` ending in a bare
  non-option token, which appended last was taken as the destination and
  demoted the intended output path to a source.

### Other

- `Depends: R (>= 4.1.0)`, corrected from `R (>= 2.10)`. This is a
  correction, not a new constraint —
  [`ngr_s3_dl()`](https://newgraphenvironment.github.io/ngr/reference/ngr_s3_dl.md)
  already used the native pipe, so the declared floor had been wrong for
  some time.
- The two STAC vignettes moved to spacehakr with the functions they
  demonstrate.
- `terra` dropped from Imports; `sf` moved to Suggests; the
  vignette-only Suggests removed.
- [`ngr_s3_dl()`](https://newgraphenvironment.github.io/ngr/reference/ngr_s3_dl.md)’s
  example was not actually protected — its `\dontrun{` was commented
  out, so `R CMD check` ran it against a non-existent bucket.

## ngr 0.0.1 (2025-05-16)

- initial commit of \[ngr_git_issue_details()\] to close
  <https://github.com/NewGraphEnvironment/ngr/issues/10>
- initial commit of \[ngr_git_issue()\] to close
  <https://github.com/NewGraphEnvironment/ngr/issues/11>
- initial commit of ngr_spk_geoserv_dlv()
- initial commit of ngr_spk_layer_info()
- initial commit of ngr_spk_join()
- initial commit of \[ngr_spk_poly_to_points()\]
- initial commit of \[ngr_spk_gdalwarp ()\] to close
  <https://github.com/NewGraphEnvironment/ngr/issues/6>
- initial commit of \[ngr_spk_res()\] to close
  [\#4](https://github.com/NewGraphEnvironment/ngr/issues/4)
  <https://github.com/NewGraphEnvironment/ngr/issues/4>
- initial commit of \[ngr_spk_ext_raster()\] to close
  [\#5](https://github.com/NewGraphEnvironment/ngr/issues/5)
  <https://github.com/NewGraphEnvironment/ngr/issues/5>
- initial commit of \[ngr_odm_args()\] to close
  [\#3](https://github.com/NewGraphEnvironment/ngr/issues/3)
- initial commit of
  [`ngr_xl_read_formulas()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_read_formulas.md),
  [`ngr_xl_map_colnames()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_map_colnames.md)
  and
  [`ngr_xl_map_formulas()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_map_formulas.md)
  to close [\#1](https://github.com/NewGraphEnvironment/ngr/issues/1)
- initial commit of ngr_xfm_xl_read_formulas() to address
  [fpr](https://github.com/NewGraphEnvironment/fpr/issues/98)
  [\#98](https://github.com/NewGraphEnvironment/ngr/issues/98)
- initial commit of ngr_str_df_col_agg()
- initial commit of ngr_s3_dl()
- initial commits of ngr_dbqs_filter_predicate and ngr_dbqs_tbl_quote

## ngr 0.0.0.9002 (2025-01-03)

- initial commit of ngr_s3_files_to_index and ngr_s3_path_to_https
- change name of ngr_str_link_repo to ngr_str_link_url and make flexible
  so any url without a `repo_source` can be provided
- initial commit of development workflow function calls
- initial commit of ngr_pkg_detach
- initial commit of ngr_tidy_cols_type_compare
- change name of “ngr_str_repo_link” to “ngr_str_link_repo”
- initial commit of ngr_str_dir_from_file
- initial commit of ngr_str_df_detect_filter

## ngr 0.0.0.9001 (2024-12-27)

- initial commit of ngr_tidy_cols_rm_na
- initial commit of ngr_str_dir_from_path
- initial commit of ngr_str_repo_link
- add lifecycle badges
- add ngr_str_replace_in_files.R
