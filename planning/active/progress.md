# Progress — Deprecate ngr_spk_* and point to spacehakr (#7)

## Session 2026-09-02

- Plan-mode exploration across three areas: ngr's spk surface, spacehakr readiness,
  downstream callers. Findings in `findings.md`.
- **Established the issue body's "Exact 1:1" premise is false** — spacehakr is ahead on
  three functions. Verified against both sources directly, not taken from an agent
  summary. This changes the work: delegation is a behaviour change and needs a NEWS entry.
- User decisions: tag spacehakr v0.1.0 before depending on it; move both vignettes to
  spacehakr; split the 9 downstream call sites into a separate tracking issue.
- Created branch `7-deprecate-ngr-spk-and-point-to-spacehakr` off main.
- Scaffolded `planning/` (first use in this repo) and the PWF baseline with approved phases.
- Next: Phase 1 in `~/Projects/repo/spacehakr`.
