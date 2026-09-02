# ngr

> New Graph Reporting — utilities for dynamic, reproducible
> environmental data-science reporting.

A curated set of helpers that recurring tasks across spatial-data
ingest, STAC catalog browsing, BC hydrology data, GitHub-issue scraping,
S3 object handling, filesystem operations, Excel-formula introspection,
and Rmarkdown report wiring all need but no single domain package owns.
Organized by domain prefix so functions are findable by what they do,
not where they grew up.

## Installation

``` r

pak::pak("NewGraphEnvironment/ngr")
```

## Function domains

Functions are named by prefix so the API surface is browseable as a flat
list. 46 exports across 11 prefixes:

| Prefix | Domain | Sample functions |
|----|----|----|
| `ngr_spk_*` | **Deprecated** — moved to [spacehakr](https://github.com/NewGraphEnvironment/spacehakr). All 12 remain as shims that warn and delegate. | [`spacehakr::spk_gdalwarp()`](http://www.newgraphenvironment.com/spacehakr/reference/spk_gdalwarp.md), [`spacehakr::spk_stac_calc()`](http://www.newgraphenvironment.com/spacehakr/reference/spk_stac_calc.md), [`spacehakr::spk_join()`](http://www.newgraphenvironment.com/spacehakr/reference/spk_join.md) |
| `ngr_str_*` | String + path manipulation, file-content rewriting | [`ngr_str_extract_between()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_extract_between.md), [`ngr_str_replace_in_files()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_replace_in_files.md), [`ngr_str_viewer_cog()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_viewer_cog.md), [`ngr_str_link_url()`](https://newgraphenvironment.github.io/ngr/reference/ngr_str_link_url.md) |
| `ngr_fs_*` | Filesystem helpers — typed read/write, conditional copy | [`ngr_fs_type_read()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_type_read.md), [`ngr_fs_type_write()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_type_write.md), [`ngr_fs_copy_if_missing()`](https://newgraphenvironment.github.io/ngr/reference/ngr_fs_copy_if_missing.md) |
| `ngr_s3_*` | S3 object listing + download + URL transforms | [`ngr_s3_keys_get()`](https://newgraphenvironment.github.io/ngr/reference/ngr_s3_keys_get.md), [`ngr_s3_dl()`](https://newgraphenvironment.github.io/ngr/reference/ngr_s3_dl.md), [`ngr_s3_path_to_https()`](https://newgraphenvironment.github.io/ngr/reference/ngr_s3_path_to_https.md), [`ngr_s3_files_to_index()`](https://newgraphenvironment.github.io/ngr/reference/ngr_s3_files_to_index.md) |
| `ngr_git_*` | GitHub issue + comment scraping (REST API) | [`ngr_git_issue()`](https://newgraphenvironment.github.io/ngr/reference/ngr_git_issue.md), [`ngr_git_issue_details()`](https://newgraphenvironment.github.io/ngr/reference/ngr_git_issue_details.md) |
| `ngr_hyd_*` | BC hydrometric data via tidyhydat | [`ngr_hyd_q_daily()`](https://newgraphenvironment.github.io/ngr/reference/ngr_hyd_q_daily.md), [`ngr_hyd_realtime()`](https://newgraphenvironment.github.io/ngr/reference/ngr_hyd_realtime.md) |
| `ngr_xl_*` | Excel formula introspection — read formulas, map column names, rewrite | [`ngr_xl_read_formulas()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_read_formulas.md), [`ngr_xl_map_colnames()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_map_colnames.md), [`ngr_xl_map_formulas()`](https://newgraphenvironment.github.io/ngr/reference/ngr_xl_map_formulas.md) |
| `ngr_tidy_*` | tidyverse-flavored helpers — column drop / type compare / coerce | [`ngr_tidy_cols_rm_na()`](https://newgraphenvironment.github.io/ngr/reference/ngr_tidy_cols_rm_na.md), [`ngr_tidy_cols_type_compare()`](https://newgraphenvironment.github.io/ngr/reference/ngr_tidy_cols_type_compare.md), [`ngr_tidy_type()`](https://newgraphenvironment.github.io/ngr/reference/ngr_tidy_type.md) |
| `ngr_dbqs_*` | DB-query string builders — predicate filters, identifier quoting, `ltree` | [`ngr_dbqs_filter_predicate()`](https://newgraphenvironment.github.io/ngr/reference/ngr_dbqs_filter_predicate.md), [`ngr_dbqs_ltree()`](https://newgraphenvironment.github.io/ngr/reference/ngr_dbqs_ltree.md), [`ngr_dbqs_tbl_quote()`](https://newgraphenvironment.github.io/ngr/reference/ngr_dbqs_tbl_quote.md) |
| `ngr_chk_*` | Validation + coercion (chk-flavoured) | [`ngr_chk_coerce_date()`](https://newgraphenvironment.github.io/ngr/reference/ngr_chk_coerce_date.md), [`ngr_chk_dt_complete()`](https://newgraphenvironment.github.io/ngr/reference/ngr_chk_dt_complete.md) |
| `ngr_sed_*` | sed-style bulk replacement across files | [`ngr_sed_replace_in_files()`](https://newgraphenvironment.github.io/ngr/reference/ngr_sed_replace_in_files.md) |

## Example: GitHub issue threads

ngr wraps common workflows so the noisy parts (auth headers, pagination,
JSON walking) stay out of report chunks.

Grab the full thread of a GitHub issue — body plus every comment — for a
report-generating workflow:

``` r

issue <- ngr_git_issue_details("NewGraphEnvironment/ngr", 34)
issue$body
issue$comments[[1]]$body
```

## Vignettes

The two STAC vignettes moved to
[spacehakr](https://newgraphenvironment.github.io/spacehakr/) along with
the `spk_*` functions they demonstrate.

## Roadmap

ngr is a working catch-all that’s gradually being rationalized into
focused packages — when a prefix group reaches enough mass to stand on
its own, it moves. Active direction:

- **Spatial-kit extraction**
  ([\#7](https://github.com/NewGraphEnvironment/ngr/issues/7)) —
  **done.** All 12 `ngr_spk_*` functions now live in
  [spacehakr](https://github.com/NewGraphEnvironment/spacehakr) as
  `spk_*`; ngr keeps deprecated shims that warn and delegate.
- **Reproducible Posit Package Manager helpers**
  ([\#31](https://github.com/NewGraphEnvironment/ngr/issues/31)) —
  `ngr_rspm_*` family for faster GitHub Actions builds against pinned
  snapshots.
- **HTML widget head-injection**
  ([\#34](https://github.com/NewGraphEnvironment/ngr/issues/34)) —
  `ngr_html_head_inject()` for setting title + favicon + arbitrary
  `<head>` on saved widget pages.
- **Date validation + coercion**
  ([\#21](https://github.com/NewGraphEnvironment/ngr/issues/21)) — round
  out the `ngr_chk_*` family.
- **String extraction utilities**
  ([\#20](https://github.com/NewGraphEnvironment/ngr/issues/20)) —
  additional `ngr_str_*` parsing primitives for structured text.

Browse [open issues](https://github.com/NewGraphEnvironment/ngr/issues)
for the current backlog.

## License

MIT.
