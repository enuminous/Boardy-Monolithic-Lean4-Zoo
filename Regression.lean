import BoardyStudy
open BoardyStudy

-- Positive control: the gate can book, so safety is not just permanent refusal.
example : (run {} [.consentA, .consentB, .propose 9,
    .acceptA 1, .acceptB 1, .confirm]).booked = true := by decide
-- One acceptance is insufficient.
example : (run {} [.consentA, .consentB, .propose 9,
    .acceptA 1, .confirm]).booked = false := by decide
-- Repeated proposal for the same slot still invalidates old acceptance.
example : (run {} [.consentA, .consentB, .propose 9, .acceptA 1,
    .acceptB 1, .propose 9, .acceptA 1, .acceptB 1, .confirm]).booked = false := by decide
-- Revocation cannot be repaired by an old confirmation.
example : (run {} [.consentA, .consentB, .propose 9,
    .acceptA 1, .acceptB 1, .confirm, .revokeB, .confirm]).booked = false := by decide
example : (run {} [.consentA, .consentB, .propose 9, .acceptA 1,
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
example : ¬ Safe (weakConfirm {}) := by simp [Safe, weakConfirm]

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
#print axioms completed_not_owed
