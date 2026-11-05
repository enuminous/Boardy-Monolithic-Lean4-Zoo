# Formal study v0.1

## Frozen target

Question: can an explicit networking protocol prevent unsupported contact
release and booking claims, and what evidence would establish that Boardy's
observable behavior conforms to it?

Target version: the v0.1 files in this repository. Formal checks concern all
finite traces admitted by `step`; empirical evaluation is prospective and has
not been run. Models, mutants and fixtures were developed together, so the
fixtures are development checks, not an independent holdout.

Boardy's [public FAQ](https://www.boardy.ai/faq), read November 5, 2026, describes
an AI introduction service, says both parties must opt in, and conditions sharing
email/phone details on both agreeing. This is a published product claim, not
measurement of actual compliance. It motivates the contact gate. The scheduling
and commitment rules below are **study requirements**, not attributed Boardy
guarantees. Public profile descriptions are outside the contact-detail gate.

## Specification

`State` stores consent from A and B, a proposal epoch, an optional slot ID,
acceptance by each party, and a booking flag. Slot IDs denote immutable, fully
specified proposals supplied by an external adapter. Changing a proposal, even
to the same slot, increments the epoch and clears both acceptances and booking.
Cancellation and consent withdrawal also invalidate the episode. An acceptance
affects only the matching current epoch with a nonempty slot.

`Safe(s)` means: if booked, both participants consented, both accepted the current
proposal, and a slot exists. Confirmation requires those conditions. Recaps,
interest and introductions do not change booking state. Release is checked at
the instant of an introduction; revocation cannot undo historical disclosure.

`Commitment` separately records an owner, evidence class, optional deadline and
completion. `commitmentOwed` recognizes incomplete, explicitly accepted
commitments owned by the designated user. It excludes mere proposals and
automated recaps. A direct unanswered question may still merit a reply even
without an accepted commitment; that task classifier is not implemented.

## Proof obligations and findings

| Obligation | Artifact / criterion | Result and evidence class |
|---|---|---|
| Initial booking state is safe | `initial_safe` | PASS — demonstrated in the model |
| Safety survives every event | `step_preserves_safe` | PASS — demonstrated in the model |
| Safety survives arbitrary finite traces | `run_preserves_safe` | PASS — demonstrated in the model |
| Reachable booking has both acceptances | `reachable_booking_has_both_acceptances` | PASS — demonstrated in the model |
| Contact release requires both consents | `contact_release_requires_both_consents` | PASS — demonstrated in the model |
| Old acceptance is ignored | `stale_acceptance_A_ignored`, `stale_acceptance_B_ignored` | PASS — demonstrated in the model |
| Cancel/propose invalidates booking and acceptance | `cancellation_invalidates`, `proposal_requires_new_acceptance` | PASS — demonstrated in the model |
| Recap/interest cannot create a booking | corresponding theorems | PASS — demonstrated in the model |
| Completed or recap-only commitments are not owed | final two theorems | PASS — demonstrated in the model |
| Safe system can actually book | positive control in `Regression.lean` | PASS — finite kernel-checked witness |
| At most one introduction per consent episode | duplicate-release witness | FAIL — rejected for this model |
| Boardy's real behavior refines this protocol | would require authenticated traces and an adapter audit | UNRESOLVED |
| Event extraction and participant identity are correct | outside `step` | UNRESOLVED |
| Successful matching or eventual meetings | no liveness, fairness or outcome model | UNRESOLVED |

The safety induction is stronger than checking a fixed trace length: it covers
any finite length and natural-number epoch/slot identifiers. It does not cover
arbitrary invalid initial states. The contact theorem is a checked consequence
of an explicitly chosen guard; it is not independent evidence of that guard's
deployment. No attendance inference is made from a booking flag.

## Falsification and retained counterexamples

1. Replacing mutual consent (`and`) with one-sided consent (`or`) releases a
   contact when only A consents. The regression contrasts those outputs.
2. Unconditionally setting `booked := true` produces an unsafe empty state.
3. The unmodified candidate allows two consecutive introductions to both emit
   contact release. Idempotency requires a future delivery ID/log and a proof
   tying release to that log. Do not describe v0.1 as exactly-once delivery.
4. A permanently silent trace remains safe without producing introductions.
   Safety therefore does not entail usefulness or progress.

These are statements about synthetic models. They are not observed Boardy bugs.

## Trust boundary and independence

Authenticated event attribution, ordering, pair identity, proposal immutability,
correct timezone normalization, and faithful text-to-event extraction are
assumptions, not theorem conclusions. An adversary who can fabricate a consent
event bypasses the interpretation of consent even though the Lean invariant
still holds. Pair-local proofs do not establish global calendar feasibility.
Expiry and recurring-event semantics are not modeled.

Lean kernel checking is an independent mechanical check of derivation, but the
same author selected the definitions and the intended property. Neither the
regressions nor duplicated Zoo operations create independent empirical evidence.
The total evidence available here is public product description, formal
derivation and synthetic counterexamples; there are zero behavioral observations.

## Zoo and novelty

The fixed 46-operation [source roster](ZOO.md) is preserved. A roster entry is
not an executed test. No fabricated rank columns, residuals, fitted parameters,
or arbitrary scores have been supplied to force a verdict.

This is an application of ordinary state-machine invariants, transition
induction, version tokens and evidence provenance to a networking workflow.
The Lean language's [theorem-proving reference](https://lean-lang.org/theorem_proving_in_lean4/)
describes the proof methods used. Classified as **adjacent engineering
formalization**, not a new theorem family or new physics. No priority claim is
made; an exhaustive novelty review has not been conducted.

## Next test

Freeze an independently annotated, consented corpus using [PROTOCOL.md](PROTOCOL.md)
before computing error rates. One verified contact release before mutual consent
fails the observed safety criterion. Missing other-party consent records remain
unknown rather than being scored as either a pass or a violation. Improving the
model's duplicate-release behavior is a separate engineering task; it cannot
be presented as evidence about Boardy.
