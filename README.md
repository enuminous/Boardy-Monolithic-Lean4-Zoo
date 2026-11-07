# Boardy × Monolithic: a formal study

**Version 0.1 — November 5, 2026.** A Lean 4 reference protocol and an empirical
study design for an AI networking assistant. Independent work; no Boardy
endorsement or access to Boardy's implementation is implied.

**Result:** the candidate protocol preserves its booking safety invariant over
arbitrary finite event sequences. It blocks contact release without mutual
consent and ignores acceptance from obsolete scheduling epochs. These are
properties of this repository's code, **not a certification of Boardy**.

The study also preserves a negative result: this version does not prevent
duplicate introductions. No real Boardy behavioral dataset has been evaluated.

## Consent replay extension — November 7, 2026

[ReplayProtected.lean](ReplayProtected.lean) adds per-participant consent
generations while retaining the original model and regressions unchanged as the
baseline. [ReplayRegression.lean](ReplayRegression.lean) demonstrates the baseline
replay gap, rejected replay and successful legitimate reauthorization.
See the [patch explanation and local verification record](study/REPLAY-PATCH.md)
for exact scope, assumptions and results. `python3 verify.py` now checks both
models. Local verification passed 40 named theorems and 60 regression examples.
Authentication and faithful event extraction remain external assumptions;
this extension makes no vulnerability claim about Boardy's deployed system.

## Read the study

- [Formal study and findings](study/STUDY.md): questions, assumptions, proofs,
  counterexamples, novelty and limits.
- [Prospective evaluation protocol](study/PROTOCOL.md): sampling, annotation,
  controls and frozen success/failure criteria.
- [Zoo operation mapping](study/ZOO.md) and [46-entry coverage ledger](study/zoo-coverage.json).
- [Lean model](BoardyStudy.lean), [regression and mutation witnesses](Regression.lean).
- [Verification record](study/VERIFICATION.md).

## Reproduce

Install [Lean using elan](https://lean-lang.org/install/manual/), then:

```sh
python3 verify.py
```

The toolchain is pinned to Lean **4.24.0**. There is no Mathlib or third-party
Lean dependency. The check builds the model with warnings as errors, checks the
regressions in Lean's kernel, audits all named theorem dependencies, and validates
the Zoo coverage ledger. Only the ordinary foundational axioms `propext`,
`Classical.choice`, and `Quot.sound` are allowed. A successful local run is recorded
in the verification document; CI must be checked on the exact revision of interest.

## Boundaries

Input events are assumed to be authenticated, correctly extracted and ordered.
One state represents one pair and one scheduling episode. Natural-number slot
IDs are opaque; timezone resolution, calendar execution, availability conflicts,
message delivery, identity resolution and attendance are outside the model.
The commitment gate covers explicitly accepted obligations; it is not a complete
classifier of unanswered requests. Private correspondence is not included.

The Zoo roster is pinned to an existing source revision, not reinvented for this
case. All 46 entries are **unresolved / not run on Boardy data**. Passing our Lean
model does not count as 46 independent Zoo passes or evidence for EFMW physics.
