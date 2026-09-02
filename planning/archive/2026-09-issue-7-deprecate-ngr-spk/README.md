# Deprecate `ngr_spk_*` and point to spacehakr (#7)

## Outcome

ngr's twelve `ngr_spk_*` functions had been extracted into
[spacehakr](https://github.com/NewGraphEnvironment/spacehakr) as `spk_*`, but ngr kept
its own copies — two live implementations, with callers silently taking ngr's because
spacehakr was installed nowhere. All twelve are now `function(...)` shims that warn via
`lifecycle::deprecate_warn()` and forward to spacehakr, so there is one implementation
again. Pure `...` forwarding, so spacehakr owns every default.

**The issue's premise was false, and finding that out changed the work.** #7 asserted the
copies were "Exact 1:1"; they were not. spacehakr was ahead on two functions, so
delegating is a *behaviour change*: `spk_geoserv_dlv()` aborts on a non-200 where ngr
printed a message and returned success, and `spk_gdalwarp()` orders `params_add` before
the file paths. A third suspected divergence in `spk_join()` was recorded and then
**retracted** — `dplyr::select()` on `sf` is sticky, so spacehakr's explicit geometry
select is redundant rather than a fix. Both real changes are in NEWS; the issue body was
corrected rather than appended to.

The reusable lesson is **half-fixes**: five separate times a fix was correct in the
dimension it was written for and silent in an adjacent one. `.Rbuildignore` fixed the
tarball while pkgdown kept publishing `CLAUDE.md` to the public web; `.gitignore` stopped
`README.html` reaching git but not `R CMD build`; the publish-allowlist gate was tested
against both known answers and still had a third (`nullglob`); `--no-build-vignettes`
solved a network problem and created two `R CMD check` WARNINGs that
`error_on: "warning"` turned into failures on all five runners. Each was found only by
checking the *adjacent* surface, never by re-reading the fix.

A shared-working-tree collision also cost real work: a parallel session checked its
branch out in `~/Projects/repo/spacehakr` mid-session, so a commit landed on their branch
and was pushed there. Two habits hid it — a `git push -q … | tail` followed by an `echo`
of local HEAD, and `git rev-list --count '@{u}..HEAD'` returning 0 because `@{u}` had
followed the switch. It surfaced only on comparing `git ls-remote` against local HEAD.
Every later branch operation used a worktree, and every push was verified against the
remote rather than its own output.

## Measurement

- **spacehakr had never run `R CMD check`.** Adding the workflow immediately surfaced an
  ERROR — `spk_join()` imports `rlang::.data` with `rlang` undeclared — which would have
  become a broken install in ngr. A second defect followed: in a `git worktree` checkout
  `.git` is a **file** holding an absolute developer path, and it was shipping in the
  tarball (1 → 0 entries after the fix).
- **The `gdalwarp` claim was overstated and was narrowed by probing.** `gdalwarp src dst
  -co COMPRESS=LZW` reaches the file-open stage, so flags parse in any position. The real
  failure is a `params_add` ending in a bare token:
  `gdalwarp <real.tif> /tmp/intended_out.tif a_bare_token` →
  `Failed to open source file /tmp/intended_out.tif`, i.e. the intended output demoted to
  a source.
- **Vignettes as articles, measured with CI's exact flags:** `2 WARNINGs, 2 NOTEs` (fails
  under `error_on: "warning"`) → `2 NOTEs`. macOS and Windows went from fail to pass.
- **`R CMD check` on ngr is 1 ERROR / 5 NOTEs — identical on `main`**, measured via a
  throwaway worktree, so the branch was check-neutral. The residual error is a
  pre-existing broken example in `ngr_s3_files_to_index()`.
- **Publication leak closed on the live site**, not just in config. Before: `CLAUDE.html`,
  `CLAUDE.md` and both vignette articles all returned 200. After the first `clean: true`
  deploy at `@53811ac`: all four 404, with `index.html` and `reference/index.html` still
  200 as a control.
- Suite 197 → **200** passing, 0 skipped. Exports 46, unchanged.

## Evidence

- `planning/archive/2026-09-issue-7-deprecate-ngr-spk/review-round*.md` — three
  code-check rounds, 14 findings, all fixed.
- `findings.md` carries the retracted `spk_join` divergence and the error ledger,
  including the branch-collision recovery.

Closed by: PR #36 (merge `53811ac`), tagged `v0.0.2`.
Companion work in spacehakr: PR #18 (`v0.1.0`), PR #19 (articles).
Downstream call sites tracked in [#35](https://github.com/NewGraphEnvironment/ngr/issues/35).
