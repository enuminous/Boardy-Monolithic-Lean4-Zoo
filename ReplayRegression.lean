import ReplayProtected
open ReplayProtected
open BoardyStudy (commitmentOwed)

-- The sixteen baseline cases, lifted to the freshness-aware protocol.

-- Positive control: the gate can book, so safety is not just permanent refusal.
example : (run {} [.consentA 0, .consentB 0, .propose 9,
    .acceptA 1, .acceptB 1, .confirm]).booked = true := by decide
-- One acceptance is insufficient.
example : (run {} [.consentA 0, .consentB 0, .propose 9,
    .acceptA 1, .confirm]).booked = false := by decide
-- Repeated proposal for the same slot still invalidates old acceptance.
example : (run {} [.consentA 0, .consentB 0, .propose 9, .acceptA 1,
    .acceptB 1, .propose 9, .acceptA 1, .acceptB 1, .confirm]).booked = false := by decide
-- Revocation cannot be repaired by an old confirmation.
example : (run {} [.consentA 0, .consentB 0, .propose 9,
    .acceptA 1, .acceptB 1, .confirm, .revokeB, .confirm]).booked = false := by decide
example : (run {} [.consentA 0, .consentB 0, .propose 9, .acceptA 1,
    .acceptB 1, .cancel, .acceptA 1, .acceptB 1, .confirm]).booked = false := by decide
example : releasesContact { consentA := true } .introduce = false := by decide
example : releasesContact { consentA := true, consentB := true } .introduce = true := by decide
example : commitmentOwed ⟨1, .explicitAcceptance, none, true⟩ 1 = false := by decide
example : commitmentOwed ⟨2, .explicitAcceptance, none, false⟩ 1 = false := by decide
example : commitmentOwed ⟨1, .explicitAcceptance, none, false⟩ 1 = true := by decide
example : commitmentOwed ⟨1, .automatedRecap, none, false⟩ 1 = false := by decide

-- Mutation witnesses: weak guards fail the intended policy.
def weakRelease (a b : Bool) := a || b
example : weakRelease true false = true := by decide
example : releasesContact { consentA := true } .introduce ≠ weakRelease true false := by decide
def weakConfirm (s : State) := { s with booked := true }
example : ¬ Safe (weakConfirm {}) := by simp [Safe, BoardyStudy.Safe, weakConfirm]

-- Negative result for THIS model: release is not idempotent.
example : let s : State := { consentA := true, consentB := true }
    releasesContact s .introduce = true ∧
    releasesContact (step s .introduce) .introduce = true := by decide

-- A proposal and recap do not imply attendance or even a booking.
example : (run {} [.propose 9, .interest, .automatedRecap]).booked = false := by decide

#print axioms step_preserves_safe
#print axioms run_preserves_safe
#print axioms reachable_booking_has_both_acceptances
#print axioms contact_release_requires_both_consents
#print axioms BoardyStudy.completed_not_owed

-- Explicit baseline attack: the *same* original event is replayed after withdrawal.
def baselineAliceOriginal : BoardyStudy.Event := .consentA
def baselineReplayTrace : List BoardyStudy.Event :=
  [baselineAliceOriginal, .consentB, .revokeA, baselineAliceOriginal]
example : (BoardyStudy.run {} baselineReplayTrace).consentA = true := by decide
example : BoardyStudy.releasesContact (BoardyStudy.run {} baselineReplayTrace)
    .introduce = true := by decide
-- Even the original safety invariant holds: it cannot express message freshness.
example : BoardyStudy.Safe (BoardyStudy.run {} baselineReplayTrace) :=
  BoardyStudy.run_preserves_safe {} baselineReplayTrace BoardyStudy.initial_safe
example : (BoardyStudy.run {} (baselineReplayTrace ++
    [.propose 9, .acceptA 2, .acceptB 2, .confirm])).booked = true := by decide

-- Replay the identical tagged authorization in the protected protocol.
def aliceOriginal : Event := .consentA 0
def bobOriginal : Event := .consentB 0
def aliceWithdrawn : State := run {} [aliceOriginal, bobOriginal, .revokeA]
def bobWithdrawn : State := run {} [aliceOriginal, bobOriginal, .revokeB]
example : aliceWithdrawn.consentA = false ∧ aliceWithdrawn.consentGenerationA = 1 := by decide
example : step aliceWithdrawn aliceOriginal = aliceWithdrawn := by decide
example : step bobWithdrawn bobOriginal = bobWithdrawn := by decide
example : releasesContact (step aliceWithdrawn aliceOriginal) .introduce = false := by decide
example : releasesContact (step bobWithdrawn bobOriginal) .introduce = false := by decide
-- New scheduling acceptances cannot overcome the withdrawn consent.
example : (run aliceWithdrawn [aliceOriginal, .propose 9,
    .acceptA 2, .acceptB 2, .confirm]).booked = false := by decide
example : (run bobWithdrawn [bobOriginal, .propose 9,
    .acceptA 2, .acceptB 2, .confirm]).booked = false := by decide

-- Legitimate reauthorization uses the generation allocated by withdrawal.
example : (step aliceWithdrawn (.consentA 1)).consentA = true := by decide
example : (step bobWithdrawn (.consentB 1)).consentB = true := by decide
example : releasesContact (step aliceWithdrawn (.consentA 1)) .introduce = true := by decide
example : (run aliceWithdrawn [.consentA 1, .propose 9,
    .acceptA 2, .acceptB 2, .confirm]).booked = true := by decide
example : (run bobWithdrawn [.consentB 1, .propose 9,
    .acceptA 2, .acceptB 2, .confirm]).booked = true := by decide
-- Reauthorization does not resurrect the slot or acceptances invalidated by withdrawal.
example : (run {} [.consentA 0, .consentB 0, .propose 9, .acceptA 1,
    .acceptB 1, .confirm, .revokeA, .consentA 1, .acceptA 1,
    .acceptB 1, .confirm]).booked = false := by decide

-- Old generations remain invalid through reconsent and another withdrawal.
example : let s := run aliceWithdrawn [.consentA 1, .revokeA]
    s.consentGenerationA = 2 ∧ step s (.consentA 0) = s ∧
    step s (.consentA 1) = s ∧ (step s (.consentA 2)).consentA = true := by decide
example : let s := run bobWithdrawn [.consentB 1, .revokeB]
    s.consentGenerationB = 2 ∧ step s (.consentB 0) = s ∧
    step s (.consentB 1) = s ∧ (step s (.consentB 2)).consentB = true := by decide
-- Repeated withdrawals also advance the generation, even while already withdrawn.
example : (run aliceWithdrawn [.revokeA, .consentA 1]).consentA = false := by decide
example : (run bobWithdrawn [.revokeB, .consentB 1]).consentB = false := by decide

-- Future tags are rejected, not treated as evidence of fresh authorization.
example : step aliceWithdrawn (.consentA 2) = aliceWithdrawn := by decide
example : step bobWithdrawn (.consentB 2) = bobWithdrawn := by decide
-- Same-generation retransmission is idempotent; this is not exactly-once delivery.
example : let s := run {} [aliceOriginal, bobOriginal]
    step s aliceOriginal = s ∧ step s bobOriginal = s := by decide
-- Scheduling changes do not alter either consent generation.
example : let s := run aliceWithdrawn [.propose 9, .cancel]
    s.consentGenerationA = 1 ∧ s.consentGenerationB = 0 ∧
    (step s (.consentA 1)).consentA = true := by decide
-- One participant's withdrawal does not invalidate the other's consent tag.
example : let s := run {} [.revokeA]
    (step s (.consentB 0)).consentB = true := by decide
example : let s := run {} [.revokeB]
    (step s (.consentA 0)).consentA = true := by decide

-- Mutation witness: bypassing the freshness gate restores the original defect.
def uncheckedConsentA (s : State) : State :=
  { s with toState := BoardyStudy.step s.toState .consentA }
example : (uncheckedConsentA aliceWithdrawn).consentA = true ∧
    (step aliceWithdrawn aliceOriginal).consentA = false := by decide
