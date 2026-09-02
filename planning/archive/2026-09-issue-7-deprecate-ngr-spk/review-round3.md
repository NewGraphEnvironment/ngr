# Code review — round 3 (ngr#7, deprecate `ngr_spk_*` -> spacehakr)

Scope: staged diff on `7-deprecate-ngr-spk-and-point-to-spacehakr`.
Focus: the round-2 fixes in `.github/workflows/pkgdown.yaml` (shell-in-YAML),
`clean: true`, `rm -f CLAUDE.md`, and allowlist completeness.

Rounds 1 and 2 findings were re-checked as fixed and are not repeated.
Accepted tradeoffs (spacehakr tag not yet cut, mockery-gated tests,
pre-existing `R CMD check` 1 ERROR / 5 NOTEs) were not re-litigated.

## Findings

### 1. [fragile] `pkgdown/favicon/` is uncommitted, so the docs build calls an external service — and `clean: true` now makes a transient outage a site regression

`man/figures/logo.png` exists (added on `main` in `1e5758f`) and `pkgdown/` does
**not** exist in the repo. Measured by building the site locally exactly as CI
does (`rm -f CLAUDE.md`, then `pkgdown::build_site_github_pages(new_process =
FALSE, install = FALSE)`, pkgdown 2.2.0):

```
── Building favicons ─────────────────────────────
ℹ Building favicons with <https://realfavicongenerator.net>...
✔ Added 'apple-touch-icon.png', 'favicon-96x96.png', 'favicon.ico',
  'favicon.svg', 'site.webmanifest', and 'web-app-manifest-*.png'
```

The build created `pkgdown/favicon/` as a side effect (I removed it afterwards;
tree restored). So every CI docs build reaches out to
`https://realfavicongenerator.net` at build time.

Two consequences, the second of which is **new to this PR**:

- If the service is unavailable, the "Build site" step is at risk of failing,
  and nothing deploys. That part is pre-existing.
- More importantly: the current `gh-pages` tree contains **no** favicon files
  (`git ls-tree --name-only FETCH_HEAD` on `origin/gh-pages`), even though its
  deploy provenance is `Deploying to gh-pages from @ NewGraphEnvironment/ngr@e2e2876`
  dated 2026-09-02 19:28 — i.e. a tree that already carries the logo. So CI has
  at least once produced a site *without* favicons while exiting 0, whereas a
  local build of the same tree produces seven of them. That asymmetry is the
  problem under `clean: true`: a run that generates them deploys them, and a
  later run that silently does not will **delete** them from `gh-pages`. Under
  the old `clean: false` they would have survived. A transient upstream outage
  now becomes a visible site change.

Fix (also what pkgdown itself recommends): run `pkgdown::build_favicons()` once
and commit `pkgdown/favicon/`. `.Rbuildignore` already has `^pkgdown$` and
`.gitignore` does not ignore it, so committing it needs no other change, and it
removes the network dependency from every future build.

### 2. [fragile] The allowlist gate has no positive control — its empty-glob safety is incidental, not deliberate

`.github/workflows/pkgdown.yaml`, "Fail if an unexpected page reached the site":

```bash
for f in docs/*.html; do
  b=$(basename "$f" .html)
  if ! is_allowed "$b"; then echo "unexpected published page: $b"; rc=1; fi
done
exit $rc
```

Tested against four inputs under `bash -e` (GitHub's default `run` shell):

| input | result |
|---|---|
| only allowed pages | `rc=0` |
| a rogue `CLAUDE.html` present | prints the page, `rc=1` |
| `docs/` exists but holds no `.html` | `rc=1` (literal `docs/*.html` -> `b=*`) |
| `docs/` missing entirely | `rc=1` |

So it does **not** currently fail toward pass, and it is placed before the
Deploy step with no `if:` override, so a failure skips the deploy. Filenames
containing spaces or glob metacharacters are handled — the glob does not word
split, `basename "$f"` and `is_allowed "$b"` are quoted, and `[ "$a" = "$1" ]`
is a literal comparison (this is the loop form, not the `case` substring form
the conventions warn about).

The residual is that rows 3 and 4 pass only because bash leaves an unmatched
glob literal by default. Set `nullglob` — a future `shell:` line, a repo default,
or a maintainer "tidying" the step — and the loop runs zero times and exits 0,
reporting a clean site for a site with no pages. That is exactly the shape
`CLAUDE.md` names under *"An empty result set is not a pass"*, and the guard has
no assertion that it looked at anything. One line pins it:

```bash
[ -f docs/index.html ] || { echo "no site was built"; exit 1; }
```

Low severity — it is correct today, and I measured it rather than assuming.

## Verified clean (evidence, so a later round need not redo it)

- **Allowlist is complete for this site.** Built locally with `CLAUDE.md`
  removed. Root `.html` produced: `404.html`, `authors.html`, `index.html`,
  `LICENSE.html`, `LICENSE-text.html` — exactly
  `allowed="404 authors index LICENSE LICENSE-text"`. Running the guard verbatim
  against that real `docs/` gave `rc=0`. `news/`, `reference/`, `articles/`,
  `tutorials/` are directories and are not root pages.
- **`clean: true` deletes nothing that should survive.** Enumerated the live
  `gh-pages` root (26 entries) against the local build output. Everything is
  reproduced by the build except `CLAUDE.html` and `CLAUDE.md`, which is the
  intent, plus the stale `articles/` pages for the two moved vignettes, also the
  intent. No `CNAME`, no `dev/`, no hand-added assets. `.nojekyll` is written by
  `build_site_github_pages()` and is present in `docs/`.
- **`rm -f CLAUDE.md` is early enough and breaks nothing.** It sits after
  dependency setup and before "Build site". I built with the file removed:
  exit 0, and `docs/` contains no `CLAUDE.html`, no `CLAUDE.md` and no CLAUDE
  text in `search.json`. `_pkgdown.yml` does not reference it. `-f` makes a
  missing file a no-op.
- **All 12 shims delegate correctly.** Each `ngr_spk_X()` calls
  `spacehakr::spk_X(...)` with matching `what`/`with`/`when = "0.0.2"`;
  spacehakr's NAMESPACE exports all 12 names. No `ngr_spk_` references remain
  elsewhere in `R/`, and no orphaned internal helpers were left in the shim files.
- **Tests pass.** `devtools::test()` -> `FAIL 0 | WARN 4 | SKIP 0 | PASS 197`.
  The 12 delegation tests ran (mockery installed). The only warnings are the
  pre-existing `ngr_sed_replace_in_files()` superseded notice.
- **`devtools::document()` produces no diff** — `man/` and `NAMESPACE` are in
  sync with `R/`.
- **NEWS claims are accurate — checked, not assumed.**
  - "`R CMD check` ran `ngr_s3_dl()`'s example": confirmed with
    `tools::Rd2ex()` on `git show HEAD:man/ngr_s3_dl.Rd` — the old Rd emits
    `ngr_s3_dl(url, path, glob)` as live code, because `# \dontrun{` is an R
    comment but not an Rd one. The new Rd emits `## Not run:` / `##D`. Fixed.
  - "`spk_gdalwarp()` places `params_add` before the paths": confirmed in
    spacehakr's source.
  - "`spk_geoserv_dlv()` aborts on non-200, `cat()` -> `cli_alert_success()`,
    httr -> httr2": confirmed. The `discard_no_features` early-return and
    `invisible(file_out)` return are unchanged from ngr's version, so nothing is
    missing from the note.
  - "**Two** functions behave differently": diffed all 12 old ngr
    implementations against spacehakr's. Ten differ textually; eight are
    whitespace/quote-style/`return()`-removal only. The single other semantic
    edit is in `spk_join()`, which appends `dplyr::all_of(attr(result,
    "sf_column"))` to the select. Measured it: for an sf object the result is
    `identical()` to the old select (sf's `select` keeps geometry anyway), and
    for a plain data.frame `attr(x, "sf_column")` is `NULL`. No-op — the "two"
    claim stands.
- **Removed Suggests are unused.** No reference to `kableExtra`, `leafem`,
  `leaflet`, `rmarkdown`, `mapview`, `rstac`, `stars` or `terra` anywhere in
  `R/`, `tests/`, `man/`, `inst/`, `data-raw/` or `README.Rmd`.
  `VignetteBuilder: knitr` was removed alongside the vignettes.
- **README counts check out** — 46 exports across 11 prefixes, matching NAMESPACE.
- The `sf::st_read()` call in `ngr_str_df_col_agg()`'s `@examples` is inside
  `\dontrun{}`, so moving `sf` to Suggests does not expose it to `R CMD check`
  or pkgdown.

## Note on method

`diff` is a shell function in this environment (`git diff --no-index
--color-words`). A first pass comparing the 12 implementations returned "0
differing lines" for every function — including the two NEWS says changed —
because `git diff --no-index` on files outside a repo produced nothing. Re-run
with `command diff`, ten of twelve differ. Recorded because `CLAUDE.md` already
carries this trap and it fired again here.

## Working-tree hygiene

The local pkgdown build created `docs/` (gitignored) and `pkgdown/favicon/`
(**not** gitignored). Both were removed; `git status --porcelain` afterwards
shows only the staged change set and no untracked files, and `CLAUDE.md` was
restored.
