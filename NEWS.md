<!-- NEWS.md is maintained by https://cynkra.github.io/fledge, do not edit -->

# ngr 0.0.2

## Deprecations

All twelve `ngr_spk_*` functions are deprecated. They now warn via
`lifecycle::deprecate_warn()` and forward to
[spacehakr](https://github.com/NewGraphEnvironment/spacehakr), which is where
they are maintained. Callers should move to `spacehakr::spk_*()`:

`ngr_spk_gdalwarp()`, `ngr_spk_geoserv_dlv()`, `ngr_spk_join()`,
`ngr_spk_layer_info()`, `ngr_spk_odm()`, `ngr_spk_poly_to_points()`,
`ngr_spk_q_layer_info()`, `ngr_spk_rast_ext()`, `ngr_spk_rast_not_empty()`,
`ngr_spk_rast_rm_empty()`, `ngr_spk_res()`, `ngr_spk_stac_calc()`.

There was never a removal step planned for "later" — the two copies had already
drifted, so the implementations are gone from ngr now and there is one
implementation again.

## Behaviour changes in the delegated functions

Because ngr's copies had fallen behind, delegating is **not** a no-op. Two
functions behave differently than ngr's implementations did:

- **`ngr_spk_geoserv_dlv()`** now aborts on a non-200 response, where ngr
  printed a message and returned the output path regardless — so a failed
  download used to look like a successful one. The success message also moved
  from `cat()` on stdout to `cli::cli_alert_success()` on stderr, which changes
  what anything capturing stdout sees. The underlying HTTP stack moved from
  `httr` to `httr2`.
- **`ngr_spk_gdalwarp()`** places `params_add` before the input and output paths
  rather than after. GDAL accepts flags in either position, so most values
  behave identically; the case that differs is a `params_add` ending in a bare
  non-option token, which appended last was taken as the destination and
  demoted the intended output path to a source.

## Other

- `Depends: R (>= 4.1.0)`, corrected from `R (>= 2.10)`. This is a correction,
  not a new constraint — `ngr_s3_dl()` already used the native pipe, so the
  declared floor had been wrong for some time.
- The two STAC vignettes moved to spacehakr with the functions they demonstrate.
- `terra` dropped from Imports; `sf` moved to Suggests; the vignette-only
  Suggests removed.
- `ngr_s3_dl()`'s example was not actually protected — its `\dontrun{` was
  commented out, so `R CMD check` ran it against a non-existent bucket.

# ngr 0.0.1 (2025-05-16)

- initial commit of [ngr_git_issue_details()] to close https://github.com/NewGraphEnvironment/ngr/issues/10
- initial commit of [ngr_git_issue()] to close https://github.com/NewGraphEnvironment/ngr/issues/11
- initial commit of ngr_spk_geoserv_dlv()
- initial commit of ngr_spk_layer_info()
- initial commit of ngr_spk_join()
- initial commit of [ngr_spk_poly_to_points()]
- initial commit of [ngr_spk_gdalwarp ()] to close https://github.com/NewGraphEnvironment/ngr/issues/6
- initial commit of [ngr_spk_res()] to close #4 https://github.com/NewGraphEnvironment/ngr/issues/4
- initial commit of [ngr_spk_ext_raster()] to close #5 https://github.com/NewGraphEnvironment/ngr/issues/5
- initial commit of [ngr_odm_args()] to close [#3](https://github.com/NewGraphEnvironment/ngr/issues/3)
- initial commit of `ngr_xl_read_formulas()`, `ngr_xl_map_colnames()` and `ngr_xl_map_formulas()` to close [#1](https://github.com/NewGraphEnvironment/ngr/issues/1)
- initial commit of ngr_xfm_xl_read_formulas() to address [fpr #98](https://github.com/NewGraphEnvironment/fpr/issues/98)
- initial commit of ngr_str_df_col_agg()
- initial commit of ngr_s3_dl()
- initial commits of ngr_dbqs_filter_predicate and ngr_dbqs_tbl_quote


# ngr 0.0.0.9002 (2025-01-03)

- initial commit of ngr_s3_files_to_index and ngr_s3_path_to_https
- change name of ngr_str_link_repo to ngr_str_link_url and make flexible so any url without a `repo_source` can be provided
- initial commit of development workflow function calls
- initial commit of ngr_pkg_detach
- initial commit of ngr_tidy_cols_type_compare
- change name of "ngr_str_repo_link" to "ngr_str_link_repo"
- initial commit of ngr_str_dir_from_file
- initial commit of ngr_str_df_detect_filter


# ngr 0.0.0.9001 (2024-12-27)

- initial commit of ngr_tidy_cols_rm_na
- initial commit of ngr_str_dir_from_path
- initial commit of ngr_str_repo_link
- add lifecycle badges
- add ngr_str_replace_in_files.R


