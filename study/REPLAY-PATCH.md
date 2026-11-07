# Consent freshness extension

Date: November 7, 2026. Baseline: `enuminous/Boardy-Monolithic-Lean4-Zoo`
commit `d6aa6c19bab34d65a40014b9e04c51358dc0f76b`.
Publication approved by Matthew on November 7, 2026.

## Finding and scope

The independent reference protocol accepts the same `.consentA` event both
before and after `.revokeA`. Its scheduling epoch prevents stale acceptance,
but contains no consent-message freshness check. This does not establish a
vulnerability in Boardy's deployed system.

`ReplayRegression.lean` defines `baselineAliceOriginal` once and reuses that
same event in `baselineReplayTrace`:

```text
original Alice consent; Bob consent; Alice withdrawal; original Alice consent
```

Kernel-checked examples show Alice's consent restored and contact release
enabled. The original safety invariant still holds. Adding a new proposal and
current scheduling acceptances even permits booking. Thus the counterexample
exposes a missing policy property, not a contradiction in the original proof.

## Small extension

`ReplayProtected.State` extends the original state with two natural-number
consent generations, initially zero. Each consent event carries one generation.
Withdrawal increments only that participant's generation, even if consent was
already absent. An unequal generation (older or future) is rejected as a complete
state no-op. Matching consent is passed to the original transition function.

These are the only added state fields and event payloads. The scheduling epoch
is unchanged. Independent generations avoid making proposals, cancellations or
the other participant's withdrawal invalidate a pending consent authorization.
No message-ID history, timestamp, signature placeholder or new cryptographic
primitive is introduced. Retransmission within one consent generation is
idempotent; exactly-once delivery and duplicate introductions are not solved.

| Alice event | Generation after event | Alice consent | Contact release with Bob's consent |
|---|---:|---|---|
| Original consent carrying 0 | 0 | true | allowed |
| Withdrawal | 1 | false | blocked |
| Replay of that same consent carrying 0 | 1 | false | blocked |
| Legitimate reauthorization carrying 1 | 1 | true | allowed |

## Preserved and extended proofs

`BoardyStudy.lean`, `Regression.lean`, the original study and November 5
verification record remain byte-for-byte unchanged. The extension delegates
accepted events to the baseline transition and proves the identical `Safe`
predicate on the projected state, with no new premise or weaker conclusion.
All eleven baseline protocol theorem statements are also proved for the new
state/event types; the two unchanged commitment theorems remain in the baseline.

Additional theorems establish exact refinement of admitted steps, rejected
steps as no-ops, freshness rejection, successful current-generation consent,
withdrawal invalidation, monotone generations and rejection of pre-withdrawal
consent after **any finite intervening event sequence**. A separate one-step
theorem for each participant shows that withdrawn consent stays false unless
a matching consent event occurs. No fairness or delivery assumption is required
for these state-transition safety results.

## Executed verification

Linux x86_64; official Lean 4.24.0, compiler commit
`797c613eb9b6d4ec95db23e3e00af9ac6657f24b`.
The downloaded archive matched the existing workflow's SHA-256 pin:
`b14f5e5159219dd1a1956c3b806813319f5e94ccd5bdfd56f54520609a5bb5ec`.

Commands from the review workspace (with `baseline/` and `candidate/`):

```sh
mkdir -p toolchain
curl --fail --silent --show-error --location --retry 2 --max-time 180 \
  https://github.com/leanprover/lean4/releases/download/v4.24.0/lean-4.24.0-linux.tar.zst \
  -o toolchain/lean.tar.zst
echo 'b14f5e5159219dd1a1956c3b806813319f5e94ccd5bdfd56f54520609a5bb5ec  toolchain/lean.tar.zst' | sha256sum --check
tar --zstd -xf toolchain/lean.tar.zst -C toolchain
export PATH="$PWD/toolchain/lean-4.24.0-linux/bin:$PATH"
lean --version
(cd baseline && python3 verify.py)
(cd candidate && python3 verify.py)
```

All commands completed successfully. The verifier executes `lake build`,
`lake env lean -DwarningAsError=true Regression.lean`, and the generated
named-theorem dependency audit. The candidate additionally checks
`ReplayRegression.lean` with the same warning policy and audits both modules.

| Check | Executed result |
|---|---|
| Original pinned verifier | PASS: 13 named theorems, 16 examples |
| Extended pinned verifier | PASS: 40 named theorems, 60 examples total |
| Extension contribution | 27 named theorems; 44 examples (16 lifted cases, 4 baseline gap witnesses, 24 new cases) |
| Theorem dependencies | Baseline: `propext` or none; extension: `propext`, with `Quot.sound` in the two arbitrary-suffix replay proofs |
| Proof-escape scan | PASS for both models and both regression files; original banned constructs unchanged |
| Zoo ledger | PASS for the original 46 entries, all still unresolved / not run on Boardy |

Raw outputs: [baseline verification](replay-evidence/baseline-verify.log),
[extension verification](replay-evidence/candidate-verify.log), and
[clean applied-patch verification](replay-evidence/applied-patch-verify.log).
These record local executed results. For remote CI, consult the
[workflow runs](https://github.com/enuminous/Boardy-Monolithic-Lean4-Zoo/actions)
for the exact published revision.

## Remaining obligations

- **Authentication — assumed externally.** An implementation must authenticate
  and integrity-bind the participant, pair/episode, consent action and generation
  to the original authorization. A current integer alone is not authentication.
  Identity resolution, key management and authorization to withdraw remain outside
  this model. This patch only partially addresses the broader authentication concern.
- **Faithful extraction and issuance — assumed externally.** Extract the original
  generation; never stamp an old message with the receiver's current generation.
  The sender must explicitly authorize the current generation, issued after the
  relevant withdrawal; the model does not prove that UI/issuance process or exclude
  forged or pre-issued future-generation authorizations.
- **Delivery and order — outside the model.** Events may be replayed, but the
  receiver processes a serialized stream. Withdrawal takes effect when processed,
  not at the time of an undelivered human message. No delivery, eventual booking,
  concurrent transaction or wall-clock liveness claim is made.
- **Persistence and scope — implementation obligations.** Preserve monotone
  generations across crashes; prohibit rollback, reset and integer wraparound
  within an episode; bind tokens to the correct pair/episode. Lean's `Nat` does
  not overflow. Cross-episode replay and recovery are not modeled.
- **Other boundaries remain.** Duplicate introductions are still possible, as
  retained regressions demonstrate. Acceptance authentication, calendar execution,
  actual sharing and external side effects remain unproved. The baseline remains
  available for comparison; an implementation must explicitly use the protected
  transition and cannot bypass the gate through the baseline module.

Before operational use, review and model the authenticated message envelope,
generation issuance and storage, then test the real adapter against the retained
replay traces. No result here certifies a deployed service or demonstrates a
new cryptographic construction.
