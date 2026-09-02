# Code check — round 2

Branch `7-deprecate-ngr-spk-and-point-to-spacehakr`, staged diff (48 files).
Round 1's six findings were verified fixed (evidence below) before looking for new ones.

The R code in this diff is clean. All three new findings are **publication-side**: what the
deleted vignettes and the newly-ignored `CLAUDE.md` do to the *published pkgdown site*, which
`.Rbuildignore` does not reach.

---

## Findings

- **[fragile]** `.github/workflows/pkgdown.yaml:56` (`clean: false`) — **deleting the two STAC
  vignettes will not unpublish them.** `JamesIves/github-pages-deploy-action` with `clean: false`
  never deletes from `gh-pages`; it only adds and overwrites. Both pages are live right now:

  ```
  https://newgraphenvironment.github.io/ngr/articles/stac-spectral-indices.html          200
  https://newgraphenvironment.github.io/ngr/articles/stac-sentinel2-ortho-timelapse.html 200
  ```

  After this merge the ngr docs site keeps serving two article pages built around
  `ngr_spk_stac_calc()` — a function that, as of this diff, warns as deprecated and delegates —
  while `README.md:57` tells the reader the vignettes moved to spacehakr. The articles *index*
  will drop them, so the only way in is a direct link or a search-engine hit, which is exactly
  the audience least equipped to notice the page is stale.

  This is the failure the repo's own convention documents (`CLAUDE.md`, "pkgdown Publishing" →
  "Deploy with `clean: true`"). Pre-flight for the flip is clean — I checked `gh-pages` root:
  **no `CNAME`, no `dev/`**, and no hand-added assets (`docs` is gitignored, so everything on the
  branch is build output):

  ```
  .nojekyll  404.*  CLAUDE.*  LICENSE*.  articles/  authors.*  deps/  index.*
  katex-auto.js  lightswitch.js  link.svg  llms.txt  logo.png  news/  pkgdown.*
  reference/  search.json  sitemap.xml
  ```

  So `clean: true` is safe here. Without it, the two article pages need an explicit purge from
  `gh-pages` — the diff on its own cannot remove them.

- **[fragile]** `.Rbuildignore:14` (`^CLAUDE\.md$`) — **fixes the tarball, not the site, and reads
  as if it fixed both.** Verified live:

  ```
  https://newgraphenvironment.github.io/ngr/CLAUDE.html  200
  https://newgraphenvironment.github.io/ngr/CLAUDE.md    200
  search.json                                            contains "CLAUDE"
  ```

  `pkgdown:::package_mds()` renders every root-level `.md` outside a hardcoded allowlist, and
  `build_site_github_pages()` runs against the CI **checkout**, which `.Rbuildignore` does not
  filter. So the new line changes the built package and changes nothing about the published page.

  ngr is public (`gh repo view` → `PUBLIC`), so this is **not** a secrets exposure — the file is
  already readable in the repo. The cost is a nobody-intended page plus three copies to reap
  (`CLAUDE.html`, a verbatim `CLAUDE.md`, and the `search.json` entry). The reason to raise it
  now is the false-signal risk: the round-1 fix put `CLAUDE.md` in the one file where handling it
  looks complete. The convention's remedy is a pre-build `rm -f CLAUDE.md` step plus the
  allowlist gate on the built site; both are absent from `pkgdown.yaml`.

  Note the ordering: with `clean: false` the two published copies survive the fix, so this wants
  the finding above resolved first (or a manual purge).

- **[fragile]** `README.html` at repo root — untracked, and in **neither** `.gitignore` nor
  `.Rbuildignore`. Confirmed: `git check-ignore -v README.html` → no match. It is the leftover of
  the round-1 `knitr::knit()` run whose damage to `README.md` was fixed. `git add -A` before the
  commit sweeps it in, and once tracked nothing stops it shipping in the tarball (`.Rbuildignore`
  anchors `^README\.Rmd$` only). Delete it, or add it to `.gitignore`.

---

## Round-1 fixes: verified, not assumed

**1. File-level `skip_if_not_installed("sf")` — effective.** The obvious way this fix fails is
silently: a skip signalled outside `test_that()` doing nothing and the rest of the file running
anyway. sf is installed here, so the real file cannot reach that failure mode. Probed against a
package that cannot exist, with a positive control (testthat 3.3.2):

```
a-control:  .          <- control ran
b-skipped:  S          <- skip registered
c-installed:.          <- top-level code after a *satisfied* skip still runs
Skipped: (code run outside of `test_that()`) ('test-b-skipped.R:1:1')
```

The `stop("TOP-LEVEL CODE AFTER SKIP RAN")` on line 2 of the skipped file never fired. `skip()`
aborts via `stop()`, testthat catches it and records a skip. The fix works.

**2. NEWS native-pipe claim — accurate, and the two behaviour claims check out too.**
`R/ngr_s3_dl.R:54` has a real `|>` in code; the `ngr_xl_map_formulas.R:58` occurrence is inside a
comment, correctly no longer claimed. Both "Behaviour changes" bullets verified against spacehakr
source rather than taken on trust:

| NEWS claim | spacehakr evidence |
|---|---|
| `spk_geoserv_dlv()` aborts on non-200 | `R/spk_geoserv_dlv.R:113` `cli::cli_abort("Failed to download layer. HTTP Status: {status}")` |
| `cat()` → `cli_alert_success()` | `:111` `cli::cli_alert_success(...)` |
| `httr` → `httr2` | `:46,92-95` `httr2::request/req_url_query/req_error/req_perform` |
| `params_add` moved before the paths | `R/spk_gdalwarp.R` `args <- c(..., if (!is.null(params_add)) params_add, path_in, path_out)` |

**3. README.Rmd ↔ README.md — consistent; a future `build_readme()` would be a no-op in
substance.** Read both in full. Same 11-row prefix table, same deprecation cell, same
"Example: GitHub issue threads" section, same Vignettes paragraph, same Roadmap with #7 marked
done. The only differences are the ones `github_document` legitimately produces (hard-wrapping,
`#` → `\#` escaping in issue links, typographic quotes, `|----|` table rule widths). No raw YAML
front matter remains.

**4. `.Rbuildignore` — no over-exclusion, tarball clean.** The specific worry, `^\.git$` catching
`.github` or `.gitignore`, does not happen: the `$` anchor makes it an exact match. Ran R's own
matcher over the pattern file, then confirmed against a real `R CMD build`:

```
.git                             -> ^\.git$
.github                          -> ^\.github$        (pre-existing rule, not the new one)
.github/workflows/pkgdown.yaml   -> no match
.gitignore                       -> no match          (excluded by R's built-in
.gitattributes                   -> no match           .hidden_file_exclusions instead)

tar tzf ngr_*.tar.gz | grep -c ...
  ngr/planning/ 0   ngr/dev/ 0   ngr/CLAUDE.md 0   ngr/.git 0
  ngr/.github 0     ngr/.gitignore 0   ngr/vignettes 0
```

**5. Dead `skip_if_not_installed("spacehakr")` — gone.** `devtools::test()` reports
`SKIP 0`, so the twelve delegation tests genuinely executed rather than skipping.

---

## Checked and clean

- **Test suite:** `[ FAIL 0 | WARN 4 | SKIP 0 | PASS 197 ]`. The 4 warnings are the pre-existing
  `ngr_sed_replace_in_files()` supersession notice, not new.
- **All twelve shim targets exist.** Every `spacehakr::spk_*` named by a shim is in spacehakr's
  `NAMESPACE` — checked one by one, 12/12. Worth doing explicitly: `mockery::stub()` replaces the
  reference, so `test-ngr_spk_deprecated.R` never resolves the real symbol and a typo'd or
  nonexistent target would pass the suite and fail only at a user's first call.
- **`man/` and `NAMESPACE` are in sync with the roxygen.** Copied the tree to scratch, ran
  `devtools::document()`, diffed back: zero changes to `man/`, `NAMESPACE` identical. The
  `man/ngr-package.Rd` logo line in the diff is a legitimate catch-up from an earlier
  `document()`, not drift.
- **Lifecycle badge SVGs are present** — `man/figures/lifecycle-deprecated.svg` exists, so the
  ten Rd files referencing it will not produce a missing-figure NOTE or a broken image on pkgdown.
- **No dangling references.** Nothing in `R/` calls `ngr_spk_*` internally (so no non-deprecated
  function emits a deprecation warning on a user's behalf); nothing in `tests/`, `inst/` or
  `_pkgdown.yml` references the removed implementations; no remaining references to the deleted
  vignette files outside the two README sentences that describe the move.
- **No dropped dependency is still used.** `terra::` and the seven removed Suggests
  (`kableExtra`, `leafem`, `leaflet`, `rmarkdown`, `mapview`, `rstac`, `stars`) appear nowhere in
  `R/`, `tests/`, `README.Rmd` or `_pkgdown.yml`. The only surviving `sf::` is a roxygen example
  comment in `R/ngr_str_df_col_agg.R:88`, and sf is a Suggest that `R CMD check` installs.
- **No orphaned internals.** `%||%` and `.ngr_spk_calc()`, both deleted with
  `ngr_spk_stac_calc.R`, have no remaining callers.
- **No circular dependency.** spacehakr's DESCRIPTION does not list ngr, and spacehakr ships its
  own `inst/extdata` copies (`points.gpkg`, `poly.gpkg`, `test1.tif`, `test2.tif`) rather than
  reaching into ngr's via `system.file(..., package = "ngr")`.
- **`Depends: R (>= 4.1.0)`** is consistent with spacehakr, which declares the same floor and uses
  both `|>` and the `\(x)` lambda.

### Note, not a finding

`inst/extdata/{points.gpkg, poly.gpkg, test1.tif, test2.tif}` (~268 KB) are now referenced by
nothing in ngr — they were fixtures for the six deleted `ngr_spk_*` test files, and spacehakr
carries its own copies. Dead weight in every tarball, not a defect. Removing them is safe from
ngr's side; it is deliberately *not* recommended here without checking anything else that may
resolve them by `system.file()`.
