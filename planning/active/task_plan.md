# Task: Deprecate ngr_spk_* and point to spacehakr — the move is done, two live copies remain (#7)

`spacehakr` exists and exports all twelve `spk_*` functions. **ngr still exports all
twelve `ngr_spk_*` too**, unchanged and unmarked — two live implementations, nothing
saying which is canonical. They will drift, callers silently take the ngr copy, and it
is invisible from where the work happens.

**Correction to the issue body, established during planning:** the two copies are *not*
"Exact 1:1". spacehakr is ahead of ngr on three functions, with real bugfixes — see
`findings.md`. The drift the issue warns about has already happened, so delegating is a
behaviour change, not a no-op.

**Scope.** In: tag spacehakr v0.1.0; wrap + delegate ngr's twelve; relocate both
vignettes to spacehakr; document the behaviour changes. Out: the 9 downstream call
sites — they get their own tracking issue (Phase 6), or this issue never closes.

## Phase 1: spacehakr v0.1.0 (prerequisite, in ~/Projects/repo/spacehakr)

ngr must not depend on an untagged package whose 12 test files have never run in CI.

- [x] Add `.github/workflows/R-CMD-check.yaml`
- [x] Run `devtools::test()` — 12 test files, never executed by CI. Fix failures.
- [x] Run `devtools::check(vignettes = FALSE)`
- [x] Bump DESCRIPTION Version `0.0.0.9000` → `0.1.0`
- [x] Open PR; tag `v0.1.0` after merge

## Phase 2: ngr takes the dependency

- [x] DESCRIPTION: `spacehakr` into Imports (alphabetical)
- [x] DESCRIPTION: `Remotes:` gains `NewGraphEnvironment/spacehakr@v0.1.0`
- [x] DESCRIPTION: `Depends: R (>= 4.1.0)` — forced by spacehakr
- [ ] Verify Remotes resolves in pkgdown CI (tidyxl precedent says this is flaky)

## Phase 3: twelve wrappers

- [x] Rewrite all twelve `R/ngr_spk_*.R` as delegating shims; delete implementation bodies
- [x] Forward arguments, do not re-specify defaults (`geoserv_dlv`'s `layer_name_out`
      default is a lazily-evaluated expression over `layer_name_raw`) — pure `...`
      forwarding, so spacehakr owns every default
- [x] ~~`ngr_spk_rast_rm_empty` calls `spacehakr::spk_rast_not_empty` directly~~ —
      **moot.** Wholesale delegation removes the call site entirely, and
      `deprecate_warn()` dedupes anyway. Retired on review.
- [x] Delete `.ngr_spk_calc` and `%||%` from `R/ngr_spk_stac_calc.R`
- [x] Prune `@importFrom` lines and the DESCRIPTION Imports only spk used — verified
      each: only `terra` was genuinely orphaned; `sf` → Suggests (used by a test);
      `processx`/`httr`/`xml2`/`curl` all still used by non-spk code and kept
- [x] ~~Incidental fixes in the spk roxygen~~ — moot, those blocks were replaced
      wholesale. Did fix `R/ngr_s3_dl.R`'s commented-out `\dontrun{`, which was
      failing `R CMD check`

## Phase 4: tests

- [x] Rewrite the 6 spk test files to assert deprecation + delegation, not behaviour
- [x] Drop the 6 blocks testing `ngr:::.ngr_spk_calc` and `ngr:::%||%`
- [x] Remove the unguarded top-level `processx::run("gdalwarp", …)` in
      `test-ngr_spk_gdalwarp.R` — and guarded the **same defect in spacehakr**, which
      the new R-CMD-check would otherwise have hit on all five runners
- [x] `devtools::test()` clean

## Phase 5: vignettes move to spacehakr

- [x] Move both `.Rmd` to `spacehakr/vignettes/`; rewrite calls; update title and
      `VignetteIndexEntry`
- [x] spacehakr DESCRIPTION: `VignetteBuilder: knitr` + vignette Suggests
- [x] ngr: delete both vignettes; prune now-unused Suggests
- [x] `README.Rmd`: family table row, worked example, vignettes section, roadmap entry
- [x] Re-knit `README.Rmd` → `README.md`

## Phase 6: downstream tracking issue

- [x] Open an issue enumerating the 9 live call sites so #7 can close — [#35](https://github.com/NewGraphEnvironment/ngr/issues/35)

## Phase 7: bookkeeping

- [x] `NEWS.md` — deprecation entry and the **two** behaviour changes
- [x] Correct the issue body's "Exact 1:1" claim
- [x] `devtools::document()`; read output for unexpected `.Rd` writes
- [x] Version bump as the final commit

## Validation

- [x] Tests pass
- [x] `/code-check` — three rounds, 14 findings, all fixed (see `review-round*.md`)
- [x] `grep -c "^export(" NAMESPACE` does not fall — all twelve stay exported as shims
- [x] ~~`ngr_spk_rast_rm_empty()` warns once, not once per raster~~ — vacuous, see Phase 3
- [x] Restore-the-bug check: a delegation test must fail when spacehakr is absent
- [x] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion
