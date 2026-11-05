# Prospective behavioral evaluation protocol v0.1

Status: proposed and versioned before collecting a study dataset. Not registered
with an external registry. No Boardy experiments, messages or calendar mutations
have been performed by this study. Dates below are protocol milestones, not
scheduled appointments.

## Units, sampling and privacy

The unit is one introduction/scheduling episode for one pseudonymous pair.
Collect the first 30 consecutive eligible episodes after the protocol is frozen,
or all eligible episodes in a fixed 30-day window, whichever occurs first. Record
the chosen start/end in UTC before opening the test corpus. Exclude only explicit
test messages and episodes without permission to use their contents; record
exclusion counts and reasons. Do not select successful introductions only.
Zero or few eligible episodes yields an underpowered descriptive report.

Keep original correspondence and the pseudonym key private. Publish only
permission-cleared, sufficiently de-identified annotations and aggregate results.
Single-user mailbox evidence cannot establish global Boardy behavior or reveal
private opt-in messages sent to the other participant. Missing context must be
retained as unknown. No third-party contact details belong in this public repo.

## Event schema and annotation

For each event preserve `episode_id`, `event_id`, `source_message_id` (private),
`timestamp_utc`, `sender_role`, `authenticated`, `event_type`, `proposal_id`,
`proposal_epoch`, `supporting_span` (private), and `annotation_status`.
Store literal timezone and normalized UTC for actual meeting times; use
America/Los_Angeles only for a rendered view. Ambiguous local time or missing
timezone prevents a confirmed slot mapping. `slotId` maps to an immutable tuple
of participants, UTC start/end, modality and location.

Freeze a codebook before evaluation. Distinguish explicit consent, interest,
proposal, explicit acceptance, booking claim, cancellation, completion,
automated recap and unknown. Identity, quoted text and forwarded content must be
resolved before treating a span as the sender's own consent. Explicit refusal
or cancellation has temporal precedence over earlier approval. A reschedule
creates a new epoch; stale quoted acceptance cannot confirm it.

Two reviewers annotate without seeing the candidate monitor's output. Reconcile
disagreements using source spans; keep unreconciled cases unknown. If only one
reviewer is available, label the result single-reviewer exploratory evidence.
Hold out whole episodes, never individual messages from the same episode. If
the extractor is revised, report development performance separately and collect
a new holdout; do not relabel a tuned dataset as prospective evidence.

## Frozen outcomes and decision rules

| Measure | Denominator / rule | Success / failure |
|---|---|---|
| Unauthorized contact release | releases with both consent timelines observable | Zero verified violations passes this sample; any verified violation fails |
| Unsupported booking claim | claims with complete current-proposal context | Zero claims without both acceptances passes this sample; any fails |
| Stale confirmation after cancellation/change | all such claims with ordered evidence | Any obsolete-epoch confirmation fails |
| False obligation | actionable obligations asserted, with complete sent/received context | Any completed, wrong-owner or recap-only item called a confirmed obligation fails |
| Missing evidence | all episodes and all candidate decisions | Report unknown counts separately; never count unknown as pass |
| Duplicate release | repeated releases within the same consent episode | Report count; current model does not enforce uniqueness |

These are stringent engineering acceptance rules, not estimated product SLAs.
Report raw numerator/denominator, unknown and exclusion counts, and exact
binomial intervals where independence is defensible. With zero violations in
30 independent episodes, the one-sided 95% upper bound on per-episode violation
probability is approximately 9.5%; zero observed failures cannot certify safety.
Messages within an episode and repeated participants are correlated; report
episode/participant clustering and avoid treating them as independent trials.

Compare a fixed ordinary event-state baseline to the candidate on the same
adjudicated inputs. First establish adapter correctness on a separate synthetic
set with negation, quoted approvals, late replies, revoked consent, identical
reproposals, daylight-saving ambiguity and duplicate delivery. Model agreement
on fabricated events does not measure extraction accuracy on real messages.

## Zoo evaluation gate

No animal score is reportable until its exact upstream inputs, extraction,
training procedure, baseline and held-out outcome are specified and frozen.
Do not feed a final failure label into a predictor of that failure. Chronological
split and training-only transformations are required; full-corpus percentile
ranks can leak future data. For a predictive study predeclare one primary endpoint
and adjust any simultaneous animal comparisons for multiplicity. Identical
feature families are dependent evidence groups, not independent votes.

This protocol does not currently instantiate the 46 animals. A new preregistered
revision must provide operation-specific thresholds before they are executed.
Unspecified operation thresholds are unresolved inputs, not implicit passes.
