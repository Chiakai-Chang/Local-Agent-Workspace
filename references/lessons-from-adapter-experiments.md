# Lessons from Agent Adapter Experiments

> This document records portable lessons extracted from the Pi adapter experiments. It is guidance for protocol and verifier design, not a claim that every host adapter behaves the same way.

## Why this exists

C.A.S.E. uses files and status transitions to make agent work inspectable. That makes the protocol auditable, but it also creates a recurring risk: a valid-looking state or a green verifier can be mistaken for proof that the user's goal was completed.

The lessons below should remain separate from host-specific details. Pi event names, Windows paths, model templates, shell quirks, and local inference-server behavior belong in the relevant adapter repository.

## Portable lessons

### 1. State is not completion

`REVIEW`, `DONE`, or a fully green status table is not evidence that the declared deliverables exist or that the project objective was met.

Protocol implication:

- A transition into `REVIEW` must verify the task's declared artifacts.
- A transition into `DONE` must verify the Local Definition of Done and the user's actual objective.
- Queue-wide state must not be used as a substitute for goal completion.

### 2. Deliverables are evidence, not intention

An agent may describe a report, plan, or fix without successfully saving it. A blocked write may discard the content the model believed it had produced.

Protocol implication:

- The verifier checks the resulting files, not only the tool request or the agent's narration.
- A blocked mutation must explicitly tell the agent whether its content was saved or lost.
- Recovery instructions must direct the agent to recreate the missing artifact.

### 3. Configuration is not delivery

Seeing a setting, registered skill, or enabled flag proves only that configuration text exists. It does not prove that the receiving runtime loaded it or that the agent acted on it.

Protocol implication:

- Verification should observe the receiving end whenever possible.
- “Injected” and “received” are separate claims.
- “Received” and “changed behavior” are also separate claims.

### 4. Imported handlers are not executed handlers

A test suite can import an extension and still miss runtime failures inside an event handler.

Protocol implication:

- Every critical handler needs at least one invocation-level test with a minimal event fixture.
- Syntax/import coverage must not be reported as behavioral coverage.
- Host adapters should document which handlers require a real runtime and remain untested in a bare environment.

### 5. Guard coverage needs adversarial evidence

Testing only the happy path demonstrates that normal work is allowed. It does not demonstrate that the guard catches the failure shape it claims to prevent.

Protocol implication:

- Add deliberate mutation or failure-shape tests for every safety-critical guard.
- Record surviving mutations as coverage gaps rather than silently treating the guard as complete.
- Distinguish “guard exists,” “guard fired,” and “agent recovered.”

### 6. Negative results are first-class results

An experiment that fails to establish an effect is still valuable if its configuration, sample, outcome, and limitation are recorded.

Protocol implication:

- Keep failed hypotheses and unproven claims visible in the ledger.
- Do not promote a mechanism to a protocol guarantee without outcome evidence.
- Do not delete a task merely because its intended effect was not observed; close it as negative, unproven, or host-limited.

### 7. Format gates can create Goodhart failures

When a verifier requires a visible format, an agent may satisfy the format while making the underlying result worse—for example, producing unsupported or fabricated evidence merely because a citation-shaped string is required.

Protocol implication:

- Validate provenance and semantic correctness, not only surface shape.
- Treat an increase in counts or markers as insufficient evidence of quality.
- Add counter-metrics for likely gaming behavior.

## Evidence boundary

These lessons were extracted from the CK's Pi Code Agent Harness experiment ledger and should be validated against other adapters before becoming hard normative requirements. The source repository contains the host-specific observations and measurements: [negative results](https://github.com/Chiakai-Chang/CKs_PI_Code_Agent_Harness/blob/main/docs/experiments/negative-results.md) and [progress ledger](https://github.com/Chiakai-Chang/CKs_PI_Code_Agent_Harness/blob/main/PROGRESS.md).

No claim in this document says that C.A.S.E. guarantees reliable autonomous execution. It defines evidence and verifier design principles intended to reduce false completion claims.
