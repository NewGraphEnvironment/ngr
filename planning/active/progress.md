# Progress — Deprecate ngr_spk_* and point to spacehakr (#7)

## Session 2026-09-02

### Planning

- Plan-mode exploration across three areas: ngr's spk surface, spacehakr readiness,
  downstream callers. Findings in `findings.md`.
- **Established the issue body's "Exact 1:1" premise is false** — spacehakr is ahead on
  two functions. Verified against both sources directly, not taken from an agent
  summary. This changed the work: delegation is a behaviour change and needs a NEWS entry.
- User decisions: tag spacehakr v0.1.0 before depending on it; move both vignettes to
  spacehakr; split the 9 downstream call sites into a separate tracking issue.
- Created branch `7-deprecate-ngr-spk-and-point-to-spacehakr`, scaffolded `planning/`
  (first use in this repo) and the PWF baseline. Commit `e44e6de`.

### Plan review

Spawned concurrently, not blocking. Returned 20+ findings; four changed the work:

| finding | outcome |
|---|---|
| `spk_join` divergence is false — `dplyr::select()` on sf is sticky | **Confirmed by measurement.** Retracted from findings, the shim roxygen and NEWS. Two divergences, not three. |
| the gdalwarp "malformed command" claim is overstated | **Confirmed by probing gdalwarp.** Reworded to the narrow, measured failure. |
| the prune list is wrong on four of six Imports | **Confirmed by my own audit before the review landed** — only `terra` was orphaned. |
| spacehakr has the *same* unguarded gdalwarp shell-out, which the new CI would hit on 5 runners | **Confirmed. Fixed** — a hazard I had introduced by adding the workflow. |
| `expect_warning(class=)` is wrong for `deprecate_warn()` (8-hour dedupe) | Adopted `lifecycle::expect_deprecated()`. |
| the "restore-the-bug when spacehakr absent" acceptance test is unrunnable | Replaced with a `mockery::stub` delegation assertion. |
| the `rast_rm_empty` mitigation is moot | Retired — wholesale delegation removes the call site. |

### Phase 1 — spacehakr v0.1.0

- Added `R-CMD-check` workflow. It immediately caught an **`R CMD check` ERROR**: `rlang`
  imported by `spk_join()` but never declared. Would have become a broken install in ngr.
- Guarded the top-level `gdalwarp` shell-out. Verified against both answers: gdalwarp
  present → PASS 2 / SKIP 0; stripped from PATH → PASS 1 / SKIP 1, no error.
- Set `--no-build-vignettes` so the incoming network-bound STAC vignettes don't run on
  all five runners.
- Suite: `FAIL 0 | PASS 126`. Check: 0 errors, 0 warnings, 1 cosmetic NOTE.
- PR [spacehakr#17](https://github.com/NewGraphEnvironment/spacehakr/pull/17). **Tag
  pending merge.**

### Phases 2–5 — ngr

- DESCRIPTION: `spacehakr` into Imports, `Remotes` pinned `@v0.1.0`, `Depends: R (>= 4.1.0)`,
  `terra` dropped, `sf` → Suggests, vignette-only Suggests removed, `VignetteBuilder` gone.
- Twelve shims generated from one script rather than twelve hand-edits. Pure `...`
  forwarding so spacehakr owns every default.
- Six behaviour test files deleted (coverage is preserved upstream — spacehakr carries
  near-identical copies); one table-driven `test-ngr_spk_deprecated.R` replaces them.
- Both vignettes moved to spacehakr and rewritten; README.Rmd updated and re-knit.
- Fixed `R/ngr_s3_dl.R`'s commented-out `\dontrun{` — incidental, but it was the first
  of ngr's `R CMD check` example errors.

### Verification

- `devtools::test()` — `FAIL 0 | SKIP 0 | PASS 200`. The 4 WARNs are pre-existing, from
  `ngr_sed_replace_in_files()`'s own superseded notice.
- **Restore-the-bug**: broke delegation in one shim (patching both the namespace and the
  attached binding, and printing a value proving the broken version was live) →
  `FAIL 3`, from `FAIL 0`. The delegation test genuinely detects non-delegation.
- `grep -c "^export(" NAMESPACE` = 46, unchanged. All twelve still exported.
- `R CMD check` = 1 ERROR, 5 NOTEs — **measured identical on `main`** via a throwaway
  worktree, so the branch is check-neutral. The remaining error
  (`ngr_s3_files_to_index`, writes to a non-existent directory) is pre-existing.

### Phases 6–7

- Downstream tracking issue [#35](https://github.com/NewGraphEnvironment/ngr/issues/35).
- Issue #7 body corrected — the "Exact 1:1" premise replaced with the measured position.
- NEWS entry for 0.0.2 documenting both behaviour changes; version bumped.

### Code check — three rounds, 14 findings, all fixed

R code was clean from round 1 onward. Every finding was in the surrounding
apparatus, and three were half-fixes of my own earlier fixes.

| round | findings | notable |
|---|---|---|
| 1 | 6 | `sf` moved to Suggests while a test used it unguarded at file top level; README.md regenerated with `knitr::knit()` leaving raw YAML front matter; `.Rbuildignore` missing `^planning$`/`^dev$`/`^CLAUDE\.md$`/`^\.git$`; a NEWS claim that was half wrong (`ngr_xl_map_formulas`'s `\|>` is in a comment) |
| 2 | 3 | all publication-side. `clean: false` meant the deleted vignettes would never unpublish (both were live, 200). **`CLAUDE.md` was being published to the public pkgdown site** — `.Rbuildignore` does not reach pkgdown, so the round-1 fix looked complete and was not |
| 3 | 2 | the new allowlist gate passed the empty case only because bash leaves unmatched globs literal — under `nullglob` it would exit 0 over an empty site, the repo's own "empty result set is not a pass". And `clean: true` made a pre-existing favicon flakiness consequential |

**Half-fixes are the theme.** Three separate times a fix was correct in the
dimension it was written for and silent in an adjacent one:

- `.Rbuildignore` fixed the tarball; the website kept publishing `CLAUDE.md`.
- `.gitignore` stopped `README.html` reaching git; `R CMD build` ships it anyway,
  because `.gitignore` does not cover the build. Caught by my own tarball check
  *after* round 3, not by any reviewer.
- The gate was tested against both known answers and still had a third.

Also closed a blind spot round 2 named: `mockery::stub()` never resolves the real
symbol, so a shim and its test table sharing a typo would pass everything and fail
at a user's first call. Added an assertion against `getNamespaceExports("spacehakr")`
— an external oracle rather than self-consistency. Verified it fails on a planted
typo (FAIL 4, from 0).

Every guard added here was tested against both answers: the gate under `nullglob`
and against a `authors index` substring attack; the `sf` file-level skip against a
nonexistent package; the delegation tests against a restored defect.

### Next

- spacehakr#17 merges → `git tag v0.1.0 && git push --tags`. Until then ngr's
  `Remotes: ...@v0.1.0` cannot resolve and ngr's pkgdown CI will be red.
- Then `/planning-archive`.
