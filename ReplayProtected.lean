import BoardyStudy

/-! Bounded extension of the independent reference protocol.
The baseline is unchanged. Consent carries a participant-specific revocation
generation. Authentication must bind that generation, the participant, pair,
episode and consent action to the original message; extraction must not retag
old messages. These are assumptions, not cryptographic proofs. Delivery and
the mapping from real messages to this serialized event stream remain external.
-/
namespace ReplayProtected

structure State extends BoardyStudy.State where
  consentGenerationA : Nat := 0
  consentGenerationB : Nat := 0
  deriving Repr, DecidableEq

inductive Event where
  | consentA (generation : Nat) | consentB (generation : Nat)
  | revokeA | revokeB | introduce
  | propose (slotId : Nat)
  | acceptA (epoch : Nat) | acceptB (epoch : Nat)
  | confirm | cancel | interest | automatedRecap
  deriving Repr, DecidableEq

/-- Forget the added metadata only after checking it. -/
def erase : Event → BoardyStudy.Event
  | .consentA _ => .consentA
  | .consentB _ => .consentB
  | .revokeA => .revokeA
  | .revokeB => .revokeB
  | .introduce => .introduce
  | .propose slot => .propose slot
  | .acceptA epoch => .acceptA epoch
  | .acceptB epoch => .acceptB epoch
  | .confirm => .confirm
  | .cancel => .cancel
  | .interest => .interest
  | .automatedRecap => .automatedRecap

def admitted (s : State) : Event → Bool
  | .consentA generation => decide (generation = s.consentGenerationA)
  | .consentB generation => decide (generation = s.consentGenerationB)
  | _ => true

def step (s : State) (e : Event) : State :=
  if admitted s e then
    { toState := BoardyStudy.step s.toState (erase e)
      consentGenerationA := s.consentGenerationA + if e = .revokeA then 1 else 0
      consentGenerationB := s.consentGenerationB + if e = .revokeB then 1 else 0 }
  else s

def run : State → List Event → State
  | s, [] => s
  | s, e :: es => run (step s e) es

/-- Exactly the baseline invariant, with no added premise or weaker conclusion. -/
def Safe (s : State) : Prop := BoardyStudy.Safe s.toState

def releasesContact (s : State) (e : Event) : Bool :=
  BoardyStudy.releasesContact s.toState (erase e)

theorem admitted_step_refines_baseline (s : State) (e : Event)
    (h : admitted s e = true) :
    (step s e).toState = BoardyStudy.step s.toState (erase e) := by
  simp [step, h]

theorem rejected_step_is_noop (s : State) (e : Event)
    (h : admitted s e = false) : step s e = s := by
  simp [step, h]

theorem initial_safe : Safe {} := BoardyStudy.initial_safe

theorem step_preserves_safe (s : State) (e : Event) (h : Safe s) :
    Safe (step s e) := by
  unfold step
  split
  · exact BoardyStudy.step_preserves_safe s.toState (erase e) h
  · exact h

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
    (h : releasesContact s e = true) : s.consentA = true ∧ s.consentB = true :=
  BoardyStudy.contact_release_requires_both_consents s.toState (erase e) h

theorem stale_acceptance_A_ignored (s : State) (old : Nat) (h : old ≠ s.epoch) :
    step s (.acceptA old) = s := by
  simp [step, admitted, erase, BoardyStudy.step, h]

theorem stale_acceptance_B_ignored (s : State) (old : Nat) (h : old ≠ s.epoch) :
    step s (.acceptB old) = s := by
  simp [step, admitted, erase, BoardyStudy.step, h]

theorem cancellation_invalidates (s : State) :
    (step s .cancel).booked = false ∧ (step s .cancel).epoch = s.epoch + 1 ∧
    (step s .cancel).acceptedA = false ∧ (step s .cancel).acceptedB = false := by
  simp [step, admitted, erase, BoardyStudy.step, BoardyStudy.invalidate]

theorem proposal_requires_new_acceptance (s : State) (slot : Nat) :
    (step s (.propose slot)).acceptedA = false ∧
    (step s (.propose slot)).acceptedB = false ∧
    (step s (.propose slot)).booked = false := by
  simp [step, admitted, erase, BoardyStudy.step]

theorem recap_cannot_create_booking (s : State) : step s .automatedRecap = s := by
  simp [step, admitted, erase, BoardyStudy.step]

theorem interest_cannot_create_booking (s : State) : step s .interest = s := by
  simp [step, admitted, erase, BoardyStudy.step]

theorem stale_consent_A_ignored (s : State) (old : Nat)
    (h : old ≠ s.consentGenerationA) : step s (.consentA old) = s := by
  simp [step, admitted, h]

theorem stale_consent_B_ignored (s : State) (old : Nat)
    (h : old ≠ s.consentGenerationB) : step s (.consentB old) = s := by
  simp [step, admitted, h]

theorem fresh_consent_A_accepted (s : State) :
    (step s (.consentA s.consentGenerationA)).consentA = true := by
  simp [step, admitted, erase, BoardyStudy.step]

theorem fresh_consent_B_accepted (s : State) :
    (step s (.consentB s.consentGenerationB)).consentB = true := by
  simp [step, admitted, erase, BoardyStudy.step]

theorem revocation_A_invalidates (s : State) :
    (step s .revokeA).consentA = false ∧
    (step s .revokeA).consentGenerationA = s.consentGenerationA + 1 ∧
    (step s .revokeA).consentGenerationB = s.consentGenerationB ∧
    (step s .revokeA).booked = false := by
  simp [step, admitted, erase, BoardyStudy.step, BoardyStudy.invalidate]

theorem revocation_B_invalidates (s : State) :
    (step s .revokeB).consentB = false ∧
    (step s .revokeB).consentGenerationB = s.consentGenerationB + 1 ∧
    (step s .revokeB).consentGenerationA = s.consentGenerationA ∧
    (step s .revokeB).booked = false := by
  simp [step, admitted, erase, BoardyStudy.step, BoardyStudy.invalidate]

theorem generation_A_monotone (s : State) (e : Event) :
    s.consentGenerationA ≤ (step s e).consentGenerationA := by
  unfold step
  split <;> simp

theorem generation_B_monotone (s : State) (e : Event) :
    s.consentGenerationB ≤ (step s e).consentGenerationB := by
  unfold step
  split <;> simp

theorem run_generation_A_monotone (s : State) (es : List Event) :
    s.consentGenerationA ≤ (run s es).consentGenerationA := by
  induction es generalizing s with
  | nil => exact Nat.le_refl _
  | cons e es ih => exact Nat.le_trans (generation_A_monotone s e) (ih (step s e))

theorem run_generation_B_monotone (s : State) (es : List Event) :
    s.consentGenerationB ≤ (run s es).consentGenerationB := by
  induction es generalizing s with
  | nil => exact Nat.le_refl _
  | cons e es ih => exact Nat.le_trans (generation_B_monotone s e) (ih (step s e))

/-- An old token stays invalid after any intervening events, including reconsent. -/
theorem replay_A_after_withdrawal_ignored (s : State) (es : List Event) (old : Nat)
    (h : old ≤ s.consentGenerationA) :
    step (run (step s .revokeA) es) (.consentA old) = run (step s .revokeA) es := by
  apply stale_consent_A_ignored
  have hm := run_generation_A_monotone (step s .revokeA) es
  have hr := (revocation_A_invalidates s).2.1
  omega

theorem replay_B_after_withdrawal_ignored (s : State) (es : List Event) (old : Nat)
    (h : old ≤ s.consentGenerationB) :
    step (run (step s .revokeB) es) (.consentB old) = run (step s .revokeB) es := by
  apply stale_consent_B_ignored
  have hm := run_generation_B_monotone (step s .revokeB) es
  have hr := (revocation_B_invalidates s).2.1
  omega

/-- While withdrawn, no event except a matching consent can restore consent. -/
theorem no_fresh_A_stays_withdrawn (s : State) (e : Event)
    (h : s.consentA = false) (hne : e ≠ .consentA s.consentGenerationA) :
    (step s e).consentA = false := by
  cases e <;> simp_all [step, admitted, erase, BoardyStudy.step, BoardyStudy.invalidate]
  all_goals split <;> simp_all

theorem no_fresh_B_stays_withdrawn (s : State) (e : Event)
    (h : s.consentB = false) (hne : e ≠ .consentB s.consentGenerationB) :
    (step s e).consentB = false := by
  cases e <;> simp_all [step, admitted, erase, BoardyStudy.step, BoardyStudy.invalidate]
  all_goals split <;> simp_all

end ReplayProtected
