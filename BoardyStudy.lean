import Std

/-! Candidate protocol, not a model recovered from Boardy's proprietary code.
Events are already authenticated and ordered; extraction is outside this proof.
One state belongs to one pair and one scheduling episode. -/
namespace BoardyStudy

structure State where
  consentA : Bool := false
  consentB : Bool := false
  epoch : Nat := 0
  slot : Option Nat := none
  acceptedA : Bool := false
  acceptedB : Bool := false
  booked : Bool := false
  deriving Repr, DecidableEq

inductive Event where
  | consentA | consentB | revokeA | revokeB | introduce
  | propose (slotId : Nat)
  | acceptA (epoch : Nat) | acceptB (epoch : Nat)
  | confirm | cancel | interest | automatedRecap
  deriving Repr, DecidableEq

/-- Sharing is an output at a particular step, not a revocable historical fact. -/
def releasesContact (s : State) (e : Event) : Bool :=
  decide (e = .introduce) && s.consentA && s.consentB

def invalidate (s : State) : State :=
  { s with epoch := s.epoch + 1, slot := none,
           acceptedA := false, acceptedB := false, booked := false }

def step (s : State) : Event → State
  | .consentA => { s with consentA := true }
  | .consentB => { s with consentB := true }
  | .revokeA => invalidate { s with consentA := false }
  | .revokeB => invalidate { s with consentB := false }
  | .propose slotId =>
      { s with epoch := s.epoch + 1, slot := some slotId, acceptedA := false, acceptedB := false, booked := false }
  | .acceptA epoch =>
      if epoch = s.epoch ∧ s.slot ≠ none then { s with acceptedA := true } else s
  | .acceptB epoch =>
      if epoch = s.epoch ∧ s.slot ≠ none then { s with acceptedB := true } else s
  | .confirm =>
      if s.consentA ∧ s.consentB ∧ s.acceptedA ∧ s.acceptedB ∧ s.slot ≠ none
      then { s with booked := true } else s
  | .cancel => invalidate s
  | .introduce | .interest | .automatedRecap => s

def Safe (s : State) : Prop :=
  s.booked = true → s.consentA = true ∧ s.consentB = true ∧
    s.acceptedA = true ∧ s.acceptedB = true ∧ s.slot ≠ none

theorem initial_safe : Safe {} := by simp [Safe]

theorem step_preserves_safe (s : State) (e : Event) (h : Safe s) :
    Safe (step s e) := by
  cases e <;> simp_all [step, invalidate, Safe] <;> split <;> simp_all

def run : State → List Event → State
  | s, [] => s
  | s, e :: es => run (step s e) es

theorem run_preserves_safe (s : State) (es : List Event) (h : Safe s) :
    Safe (run s es) := by
  induction es generalizing s with
  | nil => exact h
  | cons e es ih => exact ih (step s e) (step_preserves_safe s e h)

theorem reachable_booking_has_both_acceptances (es : List Event)
    (h : (run {} es).booked = true) :
    (run {} es).acceptedA = true ∧ (run {} es).acceptedB = true := by
  have hs := run_preserves_safe {} es initial_safe h
  exact ⟨hs.2.2.1, hs.2.2.2.1⟩

theorem contact_release_requires_both_consents (s : State) (e : Event)
    (h : releasesContact s e = true) : s.consentA = true ∧ s.consentB = true := by
  simp_all [releasesContact]

theorem stale_acceptance_A_ignored (s : State) (old : Nat) (h : old ≠ s.epoch) :
    step s (.acceptA old) = s := by simp [step, h]

theorem stale_acceptance_B_ignored (s : State) (old : Nat) (h : old ≠ s.epoch) :
    step s (.acceptB old) = s := by simp [step, h]

theorem cancellation_invalidates (s : State) :
    (step s .cancel).booked = false ∧ (step s .cancel).epoch = s.epoch + 1 ∧
    (step s .cancel).acceptedA = false ∧ (step s .cancel).acceptedB = false := by
  simp [step, invalidate]

theorem proposal_requires_new_acceptance (s : State) (slot : Nat) :
    (step s (.propose slot)).acceptedA = false ∧
    (step s (.propose slot)).acceptedB = false ∧
    (step s (.propose slot)).booked = false := by simp [step]

theorem recap_cannot_create_booking (s : State) : step s .automatedRecap = s := rfl
theorem interest_cannot_create_booking (s : State) : step s .interest = s := rfl

/-- Evidence gate: no deadline is represented by none, never an invented date. -/
inductive Support where
  | proposal | automatedRecap | explicitAcceptance
  deriving DecidableEq, Repr

structure Commitment where
  owner : Nat
  support : Support
  deadline : Option Nat
  completed : Bool
  deriving Repr

def commitmentOwed (c : Commitment) (me : Nat) : Bool :=
  decide (c.owner = me) && decide (c.support = .explicitAcceptance) && !c.completed

theorem completed_not_owed (c : Commitment) (me : Nat) (h : c.completed = true) :
    commitmentOwed c me = false := by simp [commitmentOwed, h]

theorem automated_action_not_confirmed (c : Commitment) (me : Nat)
    (h : c.support = .automatedRecap) : commitmentOwed c me = false := by
  simp [commitmentOwed, h]

end BoardyStudy
