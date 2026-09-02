# Findings — Deprecate ngr_spk_* and point to spacehakr (#7)

## The issue's "Exact 1:1" claim is false

The issue body states the twelve ngr functions and the twelve spacehakr functions are
"Exact 1:1". Reading both sources shows **spacehakr is ahead of ngr on two of them**,
carrying real bugfixes. Verified by direct source comparison, 2026-09-02.
(A third was recorded here and retracted — see below.)

| function | divergence | evidence |
|---|---|---|
| `spk_gdalwarp` | ngr appends `params_add` **after** `path_in`/`path_out`; spacehakr injects before them. Consequence is narrow — see the measurement below. | `ngr/R/ngr_spk_gdalwarp.R:111-112` vs `spacehakr/R/spk_gdalwarp.R:100` |
| `spk_geoserv_dlv` | ngr: `httr::GET` + `cat("Error: … HTTP Status:", …)` then returns `invisible(file_out)` anyway — **soft-fail**. spacehakr: `httr2` + `cli::cli_abort()` — **it throws**. | `ngr/…:90,107` vs `spacehakr/…:92-95,113` |

**Retracted: `spk_join` is not a divergence.** Recorded here initially as a third
bugfix. It is not. `dplyr::select()` on an `sf` object is sticky — `select.sf`
re-attaches the geometry column — so spacehakr's explicit `all_of(geom_col)` is
redundant rather than a fix. Measured:

```r
p <- st_as_sf(data.frame(id = 1:3, attr = letters[1:3], x = 0:2, y = 0:2), coords = c("x", "y"))
names(dplyr::select(p, dplyr::all_of(c("id", "attr"))))
#> "id" "attr" "geometry"
```

Caught by plan review. **There are two real divergences, not three** — which
matters, because putting the third in NEWS would assert a behaviour change that
never happened.

The remaining ten differ only cosmetically (quote style, `return(x)` → bare `x`,
trailing semicolons).

**The `gdalwarp` consequence was also overstated.** The original wording here
said ngr "emits a malformed command whenever `params_add` is supplied". GDAL's
parser is order-tolerant for flags — measured:

```
$ gdalwarp /nonexistent_src.tif /nonexistent_dst.tif -co COMPRESS=LZW
ERROR 4: /nonexistent_src.tif: No such file or directory     # reached file-open, so -co parsed
```

The real failure is narrower: a `params_add` whose trailing token is a bare
non-option string becomes the destination. Measured against a real raster —
`gdalwarp <real.tif> /tmp/intended_out.tif a_bare_token` reported
`Failed to open source file /tmp/intended_out.tif`, i.e. the intended output was
demoted to a source.

**Consequence for the plan:** delegation is a behaviour change, not a no-op. The
`geoserv_dlv` soft-fail → abort change lands on a live caller
(`restoration_wedzin_kwa_2024/scripts/gis/esi_state_of_watershed.R:47`) — the very
caller the issue names. It must be documented in NEWS, not slipped in.

## ngr-side surface

- **Clean cut.** `grep -rn "ngr_spk_" R/ --include=*.R | grep -v "^R/ngr_spk_"` → zero
  hits. No non-spk ngr function touches the family.
- **One internal spk→spk call**: `R/ngr_spk_rast_rm_empty.R:30` passes
  `ngr_spk_rast_not_empty` *by value* to `purrr::keep`. **Moot in the end, twice over.**
  The shim delegates wholesale, so that line ceases to exist and the internal call
  resolves inside spacehakr. And the premise was wrong anyway: `deprecate_warn()`
  dedupes by message on an 8-hour window, so even the counterfactual fires once.
  Both caught by plan review.
- `lifecycle (>= 1.0.0)` already in Imports; `@importFrom lifecycle deprecated` at
  `R/ngr-package.R:5`; badge precedent at `R/ngr_sed_replace_in_files.R:5`. No new
  dependency needed for the deprecation machinery.
- `_pkgdown.yml` is 4 lines with **no `reference:` section** — the index is
  auto-generated. Removing or shimming exports needs no YAML edit; adding a "Deprecated"
  section would require authoring the full index over all ~46 exports.
- 6 of 12 have tests. `test-ngr_spk_stac_calc.R` has 6 blocks exercising the unexported
  `.ngr_spk_calc` and `%||%` via `ngr:::` — those follow the implementation out.
- `%||%` is defined at `R/ngr_spk_stac_calc.R:340` (`@noRd`) and used at exactly one
  site, `:201`. Nothing else in `R/` needs it.

## spacehakr readiness

- Path `~/Projects/repo/spacehakr`, remote `NewGraphEnvironment/spacehakr`, public,
  HEAD `534d196`, clean, in sync with origin.
- **Not installed on this machine** — `system.file(package="spacehakr")` returns `""`.
  Confirms the issue's claim that callers silently resolve to the ngr copy.
- NAMESPACE exports exactly the twelve, zero extras. 12 `.Rd`, 12 test files.
- `Version: 0.0.0.9000`. **No tags, no releases.** Only CI is `pkgdown.yaml` and
  `claude.yml` — **no R-CMD-check**, so the 12 test files have never run automatically.
- `Depends: R (>= 4.1.0)` (uses native `|>` and `\(x)`). ngr declared `R (>= 2.10)`.
  **This is a correction, not a consequence** — `R/ngr_s3_dl.R` and
  `R/ngr_xl_map_formulas.R` already use the native pipe, so ngr's declared floor had
  been wrong independently of spacehakr. Caught by plan review.
- No `Remotes:` field; all imports are CRAN. No dependency on ngr — the
  `ngr -> spacehakr` edge is acyclic.
- Open upstream issue #16 proposes a `spk_join()` signature change that would break
  parity — a reason to pin a tag rather than float `main`.

## Downstream callers (out of scope, tracked separately)

9 live call sites, all fully-qualified `ngr::ngr_spk_*`, none in package code:

| repo | file:line | function |
|---|---|---|
| restoration_wedzin_kwa_2024 | `scripts/gis/uav_process.Rmd:38,59` | `res` |
| restoration_wedzin_kwa_2024 | `scripts/gis/uav_process.Rmd:69,81` | `gdalwarp` |
| restoration_wedzin_kwa_2024 | `scripts/gis/esi_state_of_watershed.R:47` | `geoserv_dlv` |
| restoration_wedzin_kwa_2024 | `scripts/gis/esi_state_of_watershed.R:61` | `layer_info` |
| restoration_wedzin_kwa_2024 | `scripts/gis/prioritize.R:367` | `layer_info` |
| restoration_wedzin_kwa_2024 | `scripts/gis/prioritize.R:414,440` | `join` |
| stac_uav_bc | `scripts/odm_process.R:72,119,165` | `odm` |
| fish_passage_peace_2024_reporting | `scripts/wsg_update.R:11` | `join` |

**Six of twelve have zero external callers**: `poly_to_points`, `q_layer_info`,
`rast_ext`, `rast_not_empty`, `rast_rm_empty`, `stac_calc`.

None of the three script repos pins ngr. `rfp` is the only true package declaring ngr
(`Suggests` + `Remotes`), and its single hit is a commented-out line in a test.

## Pre-existing defects found while exploring

Most of these turned out **moot** — they live in roxygen blocks the shim rewrite
replaces wholesale, or in test files that were deleted. Recorded because they are
evidence for the same underlying point: ngr has no `R-CMD-check` workflow, so none
of it was ever caught.

| defect | location |
|---|---|
| example references `test.tif`; the shipped file is `test1.tif`, so `system.file()` returns `""` — verified | `R/ngr_spk_res.R:22` |
| example calls `ngr_spk_geoserv_dl()` — missing trailing `v` | `R/ngr_spk_geoserv_dlv.R:33` |
| no `@family` tag at all (the only one of the twelve) | `R/ngr_spk_geoserv_dlv.R` |
| duplicate `@family spacehakr` | `R/ngr_spk_odm.R:17` |
| `processx::run("gdalwarp", …)` at **file top level, unguarded** — errors the whole test file on a machine without the GDAL CLI | `tests/testthat/test-ngr_spk_gdalwarp.R:33-39` |
| roadmap says the family is "11 functions"; it is 12 | `README.Rmd:80` — **fixed** |
| `@examples` block whose `\dontrun{` is commented out (`#' # \dontrun{`), so `R CMD check` runs it against a non-existent bucket | `R/ngr_s3_dl.R:30` — **fixed**, it was the first of ngr's example errors |

`R CMD check` on ngr is `1 ERROR, 5 NOTEs` — and **measured identical on `main`**, via a
throwaway worktree. The branch is check-neutral; the remaining example error
(`ngr_s3_files_to_index`, which writes to a directory that does not exist) is
pre-existing and out of scope.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `devtools::install(upgrade = "never")` → `` `upgrade` must be a single TRUE, FALSE, or NA `` | `upgrade = FALSE`. Unlike `pak`, devtools does not take the string form. |
| spacehakr `R CMD check`: `Namespace dependency missing from DESCRIPTION Imports/Depends entries: 'rlang'` | Added `rlang` to spacehakr Imports. `spk_join()` had `@importFrom rlang .data` with no declaration; invisible because spacehakr had no R-CMD-check. |
| `env PATH=/usr/bin:/bin Rscript` → `env: 'Rscript': No such file or directory` | Rscript is at `/usr/local/bin`. Strip only the directory holding the binary under test (`/opt/homebrew/bin`), not the whole PATH. |
| `$(ls path)` embedded ANSI colour codes in a variable, making a valid path unopenable | `ls` is aliased to `--color` in this shell. Use the literal path or `find`; never capture `ls` output. Documented in CLAUDE.md and it still caught me. |
| A commit intended for `7-ngr-deprecation-prep-v0-1-0` landed on `chore/claude-md-soul-conventions` and was pushed there | **Shared-working-tree collision.** A parallel session checked its own branch out in `~/Projects/repo/spacehakr` mid-session, moving this one off its branch. Recovered by cherry-picking forward through a throwaway worktree, per CLAUDE.md — their pushed branch was not rewritten. See below. |

### Shared-working-tree collision in spacehakr (2026-09-02)

The exact failure CLAUDE.md documents under *"Two agent sessions must not share one
git working tree"*. Sequence:

1. This session branched `7-ngr-deprecation-prep-v0-1-0` and committed `ed63dcf`, pushed.
2. A parallel session created `chore/claude-md-soul-conventions` **off that commit** and
   checked it out in the shared `~/Projects/repo/spacehakr` tree.
3. This session's next commit (`82fd41a`, the gdalwarp guard) therefore landed on *their*
   branch and was pushed there. PR #17 still had only `ed63dcf`.

**Two things hid it.** `git push -q ... | tail -2` followed by
`echo "pushed: $(git rev-parse --short HEAD)"` prints local HEAD whether or not the push
succeeded — the wrapper's-exit-is-not-the-work trap. And `git rev-list --count '@{u}..HEAD'`
returned **0**, correctly, because `@{u}` had followed the branch switch. The count was
answering a different question than the one being asked.

**What actually surfaced it:** comparing `git ls-remote` against local HEAD — the artifact,
not the push output. `git log --oneline main..HEAD` showing a commit nobody here wrote was
the confirming signal.

**Recovery:** cherry-picked `82fd41a` onto the correct branch through a throwaway worktree,
so their checkout was never touched and their pushed branch was not rewritten. Their branch
still carries a duplicate of that commit; git merges identical content cleanly, so it is
harmless, but it is theirs to drop if they would rather.
