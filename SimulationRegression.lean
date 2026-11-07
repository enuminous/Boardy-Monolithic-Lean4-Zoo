import ReplayProtected
open ReplayProtected

-- Conversation snapshot 1
example : let s := run {} []
    s.consentA = false ∧ s.consentB = false ∧ s.epoch = 0 ∧ s.slot = none ∧ s.acceptedA = false ∧ s.acceptedB = false ∧ s.booked = false ∧ s.consentGenerationA = 0 ∧ s.consentGenerationB = 0 := by decide

-- Conversation snapshot 2
example : let s := run {} []
    s.consentA = false ∧ s.consentB = false ∧ s.epoch = 0 ∧ s.slot = none ∧ s.acceptedA = false ∧ s.acceptedB = false ∧ s.booked = false ∧ s.consentGenerationA = 0 ∧ s.consentGenerationB = 0 := by decide

-- Conversation snapshot 3
example : let s := run {} [.consentA 0]
    s.consentA = true ∧ s.consentB = false ∧ s.epoch = 0 ∧ s.slot = none ∧ s.acceptedA = false ∧ s.acceptedB = false ∧ s.booked = false ∧ s.consentGenerationA = 0 ∧ s.consentGenerationB = 0 := by decide

-- Conversation snapshot 4
example : let s := run {} [.consentA 0, .revokeA]
    s.consentA = false ∧ s.consentB = false ∧ s.epoch = 1 ∧ s.slot = none ∧ s.acceptedA = false ∧ s.acceptedB = false ∧ s.booked = false ∧ s.consentGenerationA = 1 ∧ s.consentGenerationB = 0 := by decide

-- Conversation snapshot 5
example : let s := run {} [.consentA 0, .revokeA, .consentA 0]
    s.consentA = false ∧ s.consentB = false ∧ s.epoch = 1 ∧ s.slot = none ∧ s.acceptedA = false ∧ s.acceptedB = false ∧ s.booked = false ∧ s.consentGenerationA = 1 ∧ s.consentGenerationB = 0 := by decide

-- Conversation snapshot 6
example : let s := run {} [.consentA 0, .revokeA, .consentA 0, .consentB 0]
    s.consentA = false ∧ s.consentB = true ∧ s.epoch = 1 ∧ s.slot = none ∧ s.acceptedA = false ∧ s.acceptedB = false ∧ s.booked = false ∧ s.consentGenerationA = 1 ∧ s.consentGenerationB = 0 := by decide

-- Conversation snapshot 7
example : let s := run {} [.consentA 0, .revokeA, .consentA 0, .consentB 0, .consentA 1, .introduce]
    s.consentA = true ∧ s.consentB = true ∧ s.epoch = 1 ∧ s.slot = none ∧ s.acceptedA = false ∧ s.acceptedB = false ∧ s.booked = false ∧ s.consentGenerationA = 1 ∧ s.consentGenerationB = 0 := by decide

-- Conversation snapshot 8
example : let s := run {} [.consentA 0, .revokeA, .consentA 0, .consentB 0, .consentA 1, .introduce, .propose 101, .acceptA 2]
    s.consentA = true ∧ s.consentB = true ∧ s.epoch = 2 ∧ s.slot = some 101 ∧ s.acceptedA = true ∧ s.acceptedB = false ∧ s.booked = false ∧ s.consentGenerationA = 1 ∧ s.consentGenerationB = 0 := by decide

-- Conversation snapshot 9
example : let s := run {} [.consentA 0, .revokeA, .consentA 0, .consentB 0, .consentA 1, .introduce, .propose 101, .acceptA 2, .automatedRecap]
    s.consentA = true ∧ s.consentB = true ∧ s.epoch = 2 ∧ s.slot = some 101 ∧ s.acceptedA = true ∧ s.acceptedB = false ∧ s.booked = false ∧ s.consentGenerationA = 1 ∧ s.consentGenerationB = 0 := by decide

-- Conversation snapshot 10
example : let s := run {} [.consentA 0, .revokeA, .consentA 0, .consentB 0, .consentA 1, .introduce, .propose 101, .acceptA 2, .automatedRecap, .propose 102, .acceptA 3]
    s.consentA = true ∧ s.consentB = true ∧ s.epoch = 3 ∧ s.slot = some 102 ∧ s.acceptedA = true ∧ s.acceptedB = false ∧ s.booked = false ∧ s.consentGenerationA = 1 ∧ s.consentGenerationB = 0 := by decide

-- Conversation snapshot 11
example : let s := run {} [.consentA 0, .revokeA, .consentA 0, .consentB 0, .consentA 1, .introduce, .propose 101, .acceptA 2, .automatedRecap, .propose 102, .acceptA 3, .acceptB 2]
    s.consentA = true ∧ s.consentB = true ∧ s.epoch = 3 ∧ s.slot = some 102 ∧ s.acceptedA = true ∧ s.acceptedB = false ∧ s.booked = false ∧ s.consentGenerationA = 1 ∧ s.consentGenerationB = 0 := by decide

-- Conversation snapshot 12
example : let s := run {} [.consentA 0, .revokeA, .consentA 0, .consentB 0, .consentA 1, .introduce, .propose 101, .acceptA 2, .automatedRecap, .propose 102, .acceptA 3, .acceptB 2, .acceptB 3, .confirm]
    s.consentA = true ∧ s.consentB = true ∧ s.epoch = 3 ∧ s.slot = some 102 ∧ s.acceptedA = true ∧ s.acceptedB = true ∧ s.booked = true ∧ s.consentGenerationA = 1 ∧ s.consentGenerationB = 0 := by decide

-- Conversation snapshot 13
example : let s := run {} [.consentA 0, .revokeA, .consentA 0, .consentB 0, .consentA 1, .introduce, .propose 101, .acceptA 2, .automatedRecap, .propose 102, .acceptA 3, .acceptB 2, .acceptB 3, .confirm]
    s.consentA = true ∧ s.consentB = true ∧ s.epoch = 3 ∧ s.slot = some 102 ∧ s.acceptedA = true ∧ s.acceptedB = true ∧ s.booked = true ∧ s.consentGenerationA = 1 ∧ s.consentGenerationB = 0 := by decide
