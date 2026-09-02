# Review round 1 — `ngr_spk_*` deprecation to spacehakr (v0.0.2)

Reviewer: fresh-eyes code check against the staged diff (`ngr7.diff`), the current
tree at `/Users/airvine/Projects/repo/ngr`, and `/Users/airvine/Projects/repo/spacehakr`.

Every claim below was measured, not reasoned about. Commands and outputs are shown
where the finding turns on them.

---

## Findings

### 1. **[bug] `DESCRIPTION:42` — `Remotes:` names a tag that does not exist. Every fresh install fails.**

```
Remotes:
    NewGraphEnvironment/spacehakr@v0.1.0,
```

Measured, with a positive control so the result is not a broken probe:

```
$ Rscript -e 'pak::pkg_deps("NewGraphEnvironment/spacehakr@v0.1.0")'
! Can't find reference @v0.1.0 in GitHub repo NewGraphEnvironment/spacehakr.

$ Rscript -e 'pak::pkg_deps("NewGraphEnvironment/spacehakr@main")'
main resolves OK
```

`gh api repos/NewGraphEnvironment/spacehakr/tags` and `.../releases` both return
empty. The repo exists and is PUBLIC; it has **zero** tags and zero releases. The
`v0.1.0` PR is open and unmerged.

Blast radius:

- `pak::pak("NewGraphEnvironment/ngr")` — the install line in the README — fails at
  dependency resolution for every user.
- `.github/workflows/pkgdown.yaml:36` (`extra-packages: any::pkgdown, local::.`)
  resolves `DESCRIPTION` including `Remotes:`, so the docs deploy fails.

**This is masked locally.** `spacehakr` 0.1.0 is already installed in
`~/Library/R/arm64/4.5/library/spacehakr`, so `devtools::test()` and
`devtools::check()` on this machine pass without ever consulting the `Remotes:`
line. Nothing on this machine can detect it — same shape as the CLAUDE.md rule
about a guard whose comparison never reads the upstream.

Fix: land the spacehakr tag before this merges, or point at `@main` / a commit SHA
until it exists. Whichever, verify with the `pak::pkg_deps()` call above rather
than by reading the file.

---

### 2. **[bug] `DESCRIPTION:16` — `sf` moved Imports → Suggests, but a test uses it unguarded at file top level.**

`tests/testthat/test-ngr_str_df_col_agg.R:3`:

```r
path <- system.file("extdata", "form_fiss_site_2024.gpkg", package = "ngr")

dat_raw <- sf::st_read(path)      # <- line 3, no guard
```

Measured: `any(grepl("skip_if_not_installed", readLines(...)))` → **FALSE**. It is
the only unguarded `sf::` use in `tests/` (the hit in
`test-ngr_dbqs_tbl_quote.R:8` is a comment).

While `sf` was in `Imports:` this was correct. As a `Suggests:` it is the standard
R CMD check failure — on a machine or CI job without `sf`, the file errors with
`there is no package called 'sf'` and the check goes red for a reason unrelated to
any change under review.

Fix is one line at the top of that file (testthat 3e skips the remainder of a file
from a top-level `skip()`):

```r
skip_if_not_installed("sf")
```

The `R/` side of the Suggests move is **clean** — see "Verified clean" below.

---

### 3. **[bug] `NEWS.md:40-42` — a factual claim in the changelog is half wrong.**

> `ngr_s3_dl()` and `ngr_xl_map_formulas()` already used the native pipe, so the
> declared floor had been wrong for some time.

`R/ngr_xl_map_formulas.R` does not use the native pipe in live code. The only `|>`
in that file is line 58, **inside a comment**:

```
58:  # formulas_prep2 <- formulas_prep |>
59:  #   dplyr::mutate(
```

`grep -rln "|>" R/` returns exactly two files; the other, `R/ngr_s3_dl.R:54`, is a
genuine use. So the *conclusion* (`R (>= 4.1.0)`) is correct and the bump should
stay — it rests on `ngr_s3_dl()` alone. Only the cited evidence is wrong. Drop
`ngr_xl_map_formulas()` from the sentence.

---

### 4. **[bug] `README.md:1-3` — README.md is not the knitted output of README.Rmd.**

The diff adds raw Rmd YAML front matter to the *generated* file:

```
1:---
2:output: github_document
3:---
```

`devtools::build_readme()` strips that block. Three further tells that README.md
was hand-edited rather than regenerated: the prose lines are unwrapped (knitr's
`github_document` hard-wraps), the code fences changed from ` ``` r ` (knitr's
output) to ` ```r `, and an untracked `README.html` is sitting at the repo root —
i.e. README.Rmd was rendered to the wrong output format at some point.

Consequences: GitHub renders that leading `---` block at the top of the project
page, and the next legitimate `devtools::build_readme()` produces a large diff that
has nothing to do with whoever runs it. This is the CLAUDE.md
"running a generator is not committing what it generated" rule arriving from the
other side — the artifact was written by hand and the generator never ran.

Fix: `devtools::build_readme()`, commit the result, and add `^README\.html$` to
`.Rbuildignore` (or delete the file).

---

### 5. **[fragile] `tests/testthat/test-ngr_spk_deprecated.R:43-44` — the whole shim contract sits behind a Suggests-gated skip.**

The test is good (it can fail — measured, see below). This finding is only about it
silently *not running*.

Measured, by forcing the mockery skip:

```
baseline                    FAIL=0 SKIP=0  PASS=50
mockery unavailable         FAIL=0 SKIP=12 PASS=2
```

`mockery` is Suggests-only, so any check run without Suggests reports green having
verified nothing but the premise — the twelve delegation assertions, which are the
entire point of the file, never execute. Same class as CLAUDE.md's "tests that
silently do not run". Worth at minimum a comment recording that CI must install
Suggests; better, an unconditional structural assertion beside the mocked ones
(e.g. that each shim's body contains a `spacehakr::` call and a `deprecate_warn`),
so something guards the contract when the mock-based half skips.

Separately, `skip_if_not_installed("spacehakr")` on line 44 is dead code:
`spacehakr` is in `Imports:`, so `ngr` cannot load at all without it. Harmless, but
it reads as protection that cannot apply — a skip condition that cannot hold.

---

### 6. **[fragile] `.Rbuildignore` — `planning/` ships in the tarball, and this diff stages changes into it.**

```
$ for d in planning dev; do ... done
SHIPS: planning/
SHIPS: dev/
SHIPS: CLAUDE.md
```

`.Rbuildignore` has no `^planning$`, `^dev$`, `^CLAUDE\.md$`, or `^\.git$`. This is
CLAUDE.md's own rule ("`R CMD build` ships every top-level directory not in
`.Rbuildignore`"), and this diff is the moment `planning/active/task_plan.md` and
`findings.md` become part of a versioned release.

Pre-existing, not introduced here, but two parts are sharper than usual:

- `ngr` is **PUBLIC** (`gh repo view` → `"visibility":"PUBLIC"`) and
  `.github/workflows/pkgdown.yaml` has no pre-build `rm -f CLAUDE.md` step, so
  pkgdown publishes `CLAUDE.html`, a verbatim `CLAUDE.md`, and the full text inside
  `search.json`.
- `^\.git$` is missing, which per CLAUDE.md ships a developer absolute path whenever
  the package is built from a `git worktree`.

Verify any fix against the tarball, not the config:
`R CMD build . && tar tzf ngr_*.tar.gz | grep -c '^ngr/planning/'` → expect 0.

---

## Verified clean — measured, so it need not be re-litigated

**Pure `...` forwarding is safe for all twelve.** A grep over the whole of
`spacehakr/R/` for `missing(`, `match.arg`, `substitute(`, `sys.call`,
`match.call`, `deparse(`, `enquo`, `ensym`, `rlang::` returns **zero** hits. Only
`spk_join` has a `...`, and it is in last position, so partial matching of named
arguments still resolves at the `spk_*` level exactly as it did at the `ngr_spk_*`
level (R disables partial matching only for formals *after* `...`). Positional and
named forwarding both confirmed by direct probe:

```
$ f <- function(...) spacehakr::spk_res(...)
  mockery::stub(f, "spacehakr::spk_res", function(...) {seen <<- list(...); "SENTINEL"})
  f("a", key = "b")
result: SENTINEL
seen: List of 2 — $ : chr "a"   $ key: chr "b"
```

`mockery::stub()` **does** intercept a `pkg::fn` namespaced call — that was the
main vacuity risk in the test and it does not hold.

**The test can fail, measured in four directions** (defects restored by patching
the binding in `asNamespace("ngr")`, which is the right target here because the
test resolves via `get(ngr_fn, envir = asNamespace("ngr"))` rather than through the
search path):

| restored defect | result |
|---|---|
| baseline | FAIL=0 PASS=50 |
| shim stops calling `deprecate_warn()` | **FAIL=1** |
| shim keeps a local impl, does not delegate | **FAIL=3** |
| a 13th `ngr_spk_*` export unlisted in `shims` | **`expect_setequal` fails, naming `ngr_spk_thirteenth`** |

The premise test is a real guard, not decoration. Note also that had the stub *not*
intercepted, the real `spk_*` would have errored on `f("arg_one", key = "arg_two")`
rather than returning `"SENTINEL"` — so the test fails toward failure in that case
too. The `expect_deprecated()` choice over a bare `expect_warning()` is correct and
the comment explaining the 8-hour dedupe window is accurate.

**NEWS.md's behaviour-change claims are accurate.** Verified against source:

- `spacehakr/R/spk_geoserv_dlv.R` uses `httr2::request()/req_perform()`, calls
  `cli::cli_abort("Failed to download layer. HTTP Status: {status}")` on non-200,
  and `cli::cli_alert_success()` on success. All three claims hold.
- `spacehakr/R/spk_gdalwarp.R:99` — `if (!is.null(params_add)) params_add,
  # Add before file paths`, ahead of `path_in`/`path_out`. Claim holds.

**Nothing dangling from the removals.** `%||%` and `.ngr_spk_calc` have zero
remaining references across `R/`, `tests/`, and `man/`. `terra::` is gone from `R/`
entirely. Every removed `importFrom()` entry corresponds to a call site that is
fully qualified (e.g. `chk::chk_vector` still used at
`R/ngr_dbqs_filter_predicate.R:109-117`), so no runtime breakage from the NAMESPACE
trim. `R/staticimports.R` defines only `map2` and does not depend on any of it.

**`vignettes/` is fully removed** (the directory no longer exists), so dropping
`VignetteBuilder: knitr` is correct; both vignettes are present in
`spacehakr/vignettes/`. Leaving `knitr` in Suggests is harmless.

**`man/figures/lifecycle-deprecated.svg` exists**, so the `lifecycle::badge()`
figure in every shim's Rd resolves — no missing-file check warning.

**`ngr_str_df_col_agg`'s running example uses a plain `data.frame`**; its
`sf::st_read()` call is inside `\dontrun{}` (confirmed in the generated
`man/ngr_str_df_col_agg.Rd`). The Suggests move does not break any example.

**Counts reconcile.** `NAMESPACE` has 46 `export()` lines, matching the README's
"46 exports across 11 prefixes"; all twelve `ngr_spk_*` are still exported.

---

## Suggested order

1. Finding 1 blocks the merge — nothing installs until the spacehakr tag exists.
2. Finding 2 is one line and turns CI red on any Suggests-less runner.
3. Findings 3 and 4 are cheap and both touch published artifacts (changelog, front page).
4. Findings 5 and 6 are hardening; 6 is pre-existing and can be its own issue.
