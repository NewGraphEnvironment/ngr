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

- [ ] Add `.github/workflows/R-CMD-check.yaml`
- [ ] Run `devtools::test()` — 12 test files, never executed by CI. Fix failures.
- [ ] Run `devtools::check(vignettes = FALSE)`
- [ ] Bump DESCRIPTION Version `0.0.0.9000` → `0.1.0`
- [ ] Open PR; tag `v0.1.0` after merge

## Phase 2: ngr takes the dependency

- [ ] DESCRIPTION: `spacehakr` into Imports (alphabetical)
- [ ] DESCRIPTION: `Remotes:` gains `NewGraphEnvironment/spacehakr@v0.1.0`
- [ ] DESCRIPTION: `Depends: R (>= 4.1.0)` — forced by spacehakr
- [ ] Verify Remotes resolves in pkgdown CI (tidyxl precedent says this is flaky)

## Phase 3: twelve wrappers

- [ ] Rewrite all twelve `R/ngr_spk_*.R` as delegating shims; delete implementation bodies
- [ ] Forward arguments, do not re-specify defaults (`geoserv_dlv`'s `layer_name_out`
      default is a lazily-evaluated expression over `layer_name_raw`)
- [ ] `ngr_spk_rast_rm_empty` calls `spacehakr::spk_rast_not_empty` directly, not the
      deprecated ngr shim, or it warns once per raster
- [ ] Delete `.ngr_spk_calc` and `%||%` from `R/ngr_spk_stac_calc.R`
- [ ] Prune `@importFrom` lines and the DESCRIPTION Imports only spk used — verify each
- [ ] Incidental fixes: missing `@family` on `geoserv_dlv`; duplicate `@family` at
      `ngr_spk_odm.R:17`; `ngr_spk_geoserv_dl()` typo; `test.tif` → `test1.tif`

## Phase 4: tests

- [ ] Rewrite the 6 spk test files to assert deprecation + delegation, not behaviour
- [ ] Drop the 6 blocks testing `ngr:::.ngr_spk_calc` and `ngr:::%||%`
- [ ] Remove the unguarded top-level `processx::run("gdalwarp", …)` in
      `test-ngr_spk_gdalwarp.R`
- [ ] `devtools::test()` clean

## Phase 5: vignettes move to spacehakr

- [ ] Move both `.Rmd` to `spacehakr/vignettes/`; rewrite calls; update title and
      `VignetteIndexEntry`
- [ ] spacehakr DESCRIPTION: `VignetteBuilder: knitr` + vignette Suggests
- [ ] ngr: delete both vignettes; prune now-unused Suggests
- [ ] `README.Rmd`: family table row, worked example, roadmap entry (says 11; it is 12)
- [ ] Re-knit `README.Rmd` → `README.md`

## Phase 6: downstream tracking issue

- [ ] Open an issue enumerating the 9 live call sites so #7 can close

## Phase 7: bookkeeping

- [ ] `NEWS.md` — deprecation entry and the three behaviour changes
- [ ] Correct the issue body's "Exact 1:1" claim
- [ ] `devtools::document()`; read output for unexpected `.Rd` writes
- [ ] Version bump as the final commit

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean on each commit
- [ ] `grep -c "^export(" NAMESPACE` does not fall — all twelve stay exported as shims
- [ ] `ngr_spk_rast_rm_empty()` warns once, not once per raster
- [ ] Restore-the-bug check: a delegation test must fail when spacehakr is absent
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion
