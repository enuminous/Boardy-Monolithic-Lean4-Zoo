# An introduction, reconsidered

**Fictional conversation.** Alex is a generic tech founder; Dana is a fictional
operations lead; Boardy is simulated. No actual communication or calendar action
occurs. The EFMW-inspired recursive reviewer is an illustration. The consent
and scheduling snapshots are checked against the repository’s Lean model.

[Interactive index](../index.html) · [Scope and verification](README.md)

## 1. A broad request

**Alex · founder:** I run a small AI infrastructure startup. Can you introduce me to someone who could help us grow?

**Recursive review receipt:**

- Pass 1: Choose a contact — revise. The purpose is still unresolved.
- Pass 2: Clarify the goal — permitted. This response fits the current record and makes no unsupported commitment.

**Boardy (simulated):** What would make an introduction useful right now: a pilot customer, an investor, or a technical partner?

## 2. The goal becomes specific

**Alex · founder:** A pilot customer. We need an operations team to try our workflow tool for 30 days. We are not raising money.

**Recursive review receipt:**

- Pass 1: Suggest an investor — revise. The founder asked for a pilot customer, not fundraising.
- Pass 2: Suggest a pilot partner — permitted. This response fits the current record and makes no unsupported commitment.

**Boardy (simulated):** Then I’ll focus on operators who could run a pilot. For this example, Dana leads an operations team. Would you like an introduction to her specifically?

## 3. One yes is not two

**Alex · founder:** Dana sounds like a good fit. Yes, you can introduce us about the pilot.

**Recursive review receipt:**

- Pass 1: Release the introduction — revise. Dana has not yet opted in.
- Pass 2: Request Dana’s consent — permitted. This response fits the current record and makes no unsupported commitment.

**Boardy (simulated):** I have your permission for Dana. I’ll ask whether she wants the introduction too; your yes alone does not authorize sharing both parties’ contact details.

## 4. A correction changes what is allowed

**Alex · founder:** Actually, hold that introduction. Our security review is not finished. Do not introduce us yet.

**Recursive review receipt:**

- Pass 1: Release the introduction — revise. Alex’s current consent is absent; historical approval cannot replace it.
- Pass 2: Keep the introduction paused — permitted. This response fits the current record and makes no unsupported commitment.

**Boardy (simulated):** Paused. I remember that you previously said yes, but that approval is now historical. I will wait for a new authorization.

## 5. Old words return; old permission does not

**Delayed message · replay:** A duplicate of Alex’s earlier “Yes, you can introduce us” arrives, still carrying the original consent generation 0.

**Recursive review receipt:**

- Incoming event: The replay is rejected before review: generation 0 ≠ current generation 1.
- Pass 1: Release the introduction — revise. Alex’s current consent is absent; historical approval cannot replace it.
- Pass 2: Keep the introduction paused — permitted. This response fits the current record and makes no unsupported commitment.

**Boardy (simulated):** That is an old copy of your approval. Your later withdrawal still controls. The introduction stays paused.

## 6. The other party opts in

**Dana · fictional operations lead:** Yes, I would be interested in an introduction about the 30-day pilot.

**Recursive review receipt:**

- Pass 1: Release the introduction — revise. Alex’s current consent is absent; historical approval cannot replace it.
- Pass 2: Keep the introduction paused — permitted. This response fits the current record and makes no unsupported commitment.

**Boardy (simulated):** Dana has opted in. Your withdrawal still stands, so I need fresh authorization from you before proceeding.

## 7. Fresh authorization changes the answer

**Alex · founder:** The security review is complete. I now authorize a new introduction to Dana about the pilot.

**Recursive review receipt:**

- Pass 1: Release the introduction — permitted. Both participants currently consent; Alex’s new authorization is generation 1.

**Boardy (simulated):** You have both opted in. Alex, meet Dana: you’re exploring a 30-day workflow pilot. The introduction is now authorized in this simulation.

## 8. An introduction is not a booked meeting

**Alex · founder:** Could we meet Wednesday, November 11, from 10:00 to 10:30 a.m. Pacific? I accept that time.

**Recursive review receipt:**

- Pass 1: Confirm the meeting — revise. Both acceptances of the current proposal are required.
- Pass 2: Keep the current slot pending — permitted. This response fits the current record and makes no unsupported commitment.

**Boardy (simulated):** Wednesday, November 11, 10:00–10:30 a.m. Pacific is proposed, and you have accepted. I’m still waiting for Dana. It is not booked yet.

## 9. Review the proposed wording, too

**Alex · founder:** Can you send me a recap saying the meeting is booked?

**Recursive review receipt:**

- Pass 1: Describe the meeting as booked — revise. A recap cannot create a booking; Dana’s acceptance is still missing.
- Pass 2: Describe the meeting as pending — permitted. This response fits the current record and makes no unsupported commitment.

**Boardy (simulated):** Here is the accurate recap: Wednesday is proposed, you have accepted, and Dana’s acceptance is pending. I cannot call it booked yet.

## 10. A new time invalidates earlier acceptance

**Alex · founder:** Move it to Thursday, November 12, from 11:00 to 11:30 a.m. Pacific. I accept the new time.

**Recursive review receipt:**

- Pass 1: Confirm the meeting — revise. Both acceptances of the current proposal are required.
- Pass 2: Keep the current slot pending — permitted. This response fits the current record and makes no unsupported commitment.

**Boardy (simulated):** I’ve replaced Wednesday with Thursday, November 12, 11:00–11:30 a.m. Pacific. Your acceptance is recorded; Dana still needs to accept this new proposal.

## 11. A delayed acceptance belongs to its old proposal

**Delayed message · Dana:** Dana’s “Wednesday at ten works” arrives after the move to Thursday. It refers to scheduling epoch 2.

**Recursive review receipt:**

- Incoming event: The acceptance is ignored: epoch 2 ≠ current scheduling epoch 3.
- Pass 1: Confirm the meeting — revise. Both acceptances of the current proposal are required.
- Pass 2: Keep the current slot pending — permitted. This response fits the current record and makes no unsupported commitment.

**Boardy (simulated):** That acceptance was for Wednesday. It cannot confirm Thursday. The new time remains pending until Dana accepts it.

## 12. Both accept the current proposal

**Dana · fictional operations lead:** Thursday, November 12, from 11:00 to 11:30 a.m. Pacific works for me. I accept that proposal.

**Recursive review receipt:**

- Pass 1: Confirm the meeting — permitted. Both parties accepted epoch 3 and both still consent.

**Boardy (simulated):** Both of you have accepted Thursday, November 12, 11:00–11:30 a.m. Pacific. The reference model now marks it booked. No real calendar event is created by this demonstration.

## 13. The summary is checked against the revised history

**Alex · founder:** What changed from my original request? And what do you remember now?

**Recursive review receipt:**

- Pass 1: Summarize the original Wednesday plan — revise. Wednesday was superseded. The summary must use Thursday’s current record.
- Pass 2: Summarize the current record — permitted. This response fits the current record and makes no unsupported commitment.

**Boardy (simulated):** “Help us grow” became a specific pilot-customer goal. Your first yes was withdrawn; a replay could not revive it. Your fresh yes enabled the introduction. Wednesday was then replaced by Thursday, which both of you accepted. I retain the changes without treating superseded instructions as current.

## Interpretation

The updated record feeds the next check. Failed proposals are revised and checked
again. A prior “yes” remains part of history after withdrawal but no longer grants
current permission; an old meeting acceptance remains evidence about its old slot
without confirming the replacement. The summary is checked against those updates too.

This demonstrates a bounded recursive policy, not a measured claim about Boardy
or a proof of EFMW dynamics or superiority.
