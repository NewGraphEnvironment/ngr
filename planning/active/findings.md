# Findings — Deprecate ngr_spk_* and point to spacehakr (#7)

## The issue's "Exact 1:1" claim is false

The issue body states the twelve ngr functions and the twelve spacehakr functions are
"Exact 1:1". Reading both sources shows **spacehakr is ahead of ngr on three of them**,
carrying real bugfixes. Verified by direct source comparison, 2026-09-02.

| function | divergence | evidence |
|---|---|---|
| `spk_gdalwarp` | ngr appends `params_add` **after** `path_in`/`path_out`. gdalwarp takes source/dest positionally last, so ngr emits a malformed command whenever `params_add` is supplied. spacehakr injects before the paths. | `ngr/R/ngr_spk_gdalwarp.R:111-112` vs `spacehakr/R/spk_gdalwarp.R:100` |
| `spk_geoserv_dlv` | ngr: `httr::GET` + `cat("Error: … HTTP Status:", …)` then returns `invisible(file_out)` anyway — **soft-fail**. spacehakr: `httr2` + `cli::cli_abort()` — **it throws**. | `ngr/…:90,107` vs `spacehakr/…:92-95,113` |
| `spk_join` | spacehakr captures `attr(result, "sf_column")` and retains it in the `select()` when `target_col_return != "*"`; ngr drops the geometry column. | `spacehakr/R/spk_join.R` |

The remaining nine differ only cosmetically (quote style, `return(x)` → bare `x`,
trailing semicolons).

**Consequence for the plan:** delegation is a behaviour change, not a no-op. The
`geoserv_dlv` soft-fail → abort change lands on a live caller
(`restoration_wedzin_kwa_2024/scripts/gis/esi_state_of_watershed.R:47`) — the very
caller the issue names. It must be documented in NEWS, not slipped in.

## ngr-side surface

- **Clean cut.** `grep -rn "ngr_spk_" R/ --include=*.R | grep -v "^R/ngr_spk_"` → zero
  hits. No non-spk ngr function touches the family.
- **One internal spk→spk call**: `R/ngr_spk_rast_rm_empty.R:30` passes
  `ngr_spk_rast_not_empty` *by value* to `purrr::keep`, so it is invoked once per raster
  file. A naive deprecation wrapper self-warns N times per call.
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
- `Depends: R (>= 4.1.0)` (uses native `|>` and `\(x)`). ngr declares `R (>= 2.10)`, so
  adopting spacehakr raises ngr's floor. Forced, not optional.
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

Worth fixing in passing, since the same files are being rewritten:

| defect | location |
|---|---|
| example references `test.tif`; the shipped file is `test1.tif`, so `system.file()` returns `""` — verified | `R/ngr_spk_res.R:22` |
| example calls `ngr_spk_geoserv_dl()` — missing trailing `v` | `R/ngr_spk_geoserv_dlv.R:33` |
| no `@family` tag at all (the only one of the twelve) | `R/ngr_spk_geoserv_dlv.R` |
| duplicate `@family spacehakr` | `R/ngr_spk_odm.R:17` |
| `processx::run("gdalwarp", …)` at **file top level, unguarded** — errors the whole test file on a machine without the GDAL CLI | `tests/testthat/test-ngr_spk_gdalwarp.R:33-39` |
| roadmap says the family is "11 functions"; it is 12 | `README.Rmd:80` |

## Errors Encountered

| Error | Resolution |
|-------|------------|
| | |
