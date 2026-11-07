# EFMW + Boardy: recursive introduction simulation

This is a deterministic, fictional conversation between Alex, a generic tech
founder, and a simulated Boardy. Dana is a fictional operations lead. It uses the
reference protocol at commit `d9481ca1485f79cbb440f5eff4cea198cc894cc2`.
It does not use Boardy production code, API access, contact data or real messages.

## View

- [Interactive index](../index.html): download and open in a browser, or serve
  the repository with `python3 -m http.server 8000` and visit `http://localhost:8000/`.
- [Complete transcript](TRANSCRIPT.md): readable directly in GitHub.
- GitHub Pages: select **Deploy from a branch**, **main**, **/(root)** in the
  repository's Settings → Pages and save. `.nojekyll` preserves the static files.
  The HTML does not need a build step. Adding an index does not enable Pages by itself.

## What recurs

Each incoming message updates the remembered goal and protocol state. An explicit
symbolic reviewer checks a proposed action. If it fails a stated condition, a
repair becomes the next input to the same reviewer, up to three passes. Accepted
introduction/confirmation actions feed into subsequent protocol state. Historical
messages remain in the transcript without superseded permissions staying current.

The simulation contains both conversation-level checks (pilot customers versus
fundraising, accurate summaries) and protocol checks (current consent, current
slot acceptance). The first group is scripted illustrative policy, not Lean-proved
semantics, an EFMW field-equation solver, or a measured advantage over other methods.
Review receipts are explicit executable rule results, not a language model's
private reasoning trace.

## Files and reproduction

| File | Purpose |
|---|---|
| `fragment.html` | Editable simulation, dialogue, recursive reviewer and small JS protocol model |
| `../index.html` | Standalone exported display, including the same fragment and its required styling |
| `verify.cjs` | Scenario assertions, export consistency, and comparison to committed Lean snapshots |
| `../SimulationRegression.lean` | Thirteen exact snapshots checked using `ReplayProtected.run` |

Run `python3 verify.py` from the repository root with pinned Lean 4.24.0 and
Node.js 20+ on PATH. This runs the simulation assertions, builds both original
Lean modules, checks all three regression files and audits all 40 named theorem
dependencies. There are now **73 regression examples**: 16 baseline, 44 replay
extension and 13 conversation snapshots. The original 60 examples are retained.

The browser script was executed under Node.js 24.22.1 during local development.
All thirteen snapshot equalities compiled under Lean 4.24.0. The same checks are
part of the repository verification workflow. This establishes agreement on these
specific snapshots, not a proof that the JavaScript implementation refines Lean
for every input. The local cloud-browser preview was unavailable; no completed
visual browser test is claimed.

The index was exported from the conversation fragment using the visualization
renderer, with a repository navigation header added. To update it, export the
changed fragment again, preserve the navigation header, regenerate/review any
changed snapshot expectations, and rerun `python3 verify.py`. The verifier rejects
an index whose embedded fragment differs from `fragment.html`.

## Boundaries

Authentication, faithful message extraction, pair/episode binding, persistent
generations, delivery and calendar execution remain external assumptions or
implementation obligations. The generation and epoch values here are small
synthetic integers. The model still does not prevent duplicate introductions.
Matching quality, actual business outcomes and any distinct EFMW benefit remain
unmeasured. A fictional successful meeting booking is a scenario endpoint, not
an observed outcome or empirical result.
