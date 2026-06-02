# 🛡️ Harness Engineering in C.A.S.E. — The Reliability Layer

> **"The model is rented. The harness is yours."**
> — Tejas Kumar (IBM Developer Advocate), AI Engineer Europe 2026

This document defines the **Harness Engineering Specification** for the C.A.S.E. Framework. It details how the orchestrating runtime (Harness) wraps around local and cloud models to guarantee deterministic execution, eliminate hallucinations, protect credentials, and minimize context consumption on limited local hardware (such as consumer NVIDIA GPUs).

---

## 1. Why Harness Engineering? (The Core Philosophy)

Traditional LLM development often falls into the trap of **"prompt-hacking"**—attempting to solve every failure by making system prompts longer, stricter, or more aggressive. However, LLMs are fundamentally non-deterministic engines. Under unexpected obstacles (e.g., authentication, rate limits, environment issues), even strong models can panic, hallucinate, or lie about their success.

**Harness Engineering** shifts the reliability burden from the model to the deterministic runtime:
1. **The Model** is the *engine*—it is non-deterministic, rented (or loaded), and responsible solely for choosing the next action based on current context.
2. **The Harness** is the *chassis*—it is deterministic, secure, fully controlled by the developer, and responsible for grounding the model, managing its context, verifying its actual actions, and handling environment-level friction.

By wrapping our local LLM (e.g., running via Llama.cpp) in a robust harness, we can make **cheap, highly-quantized local models** achieve the execution reliability of expensive cloud frontrunners, while spending zero extra tokens.

---

## 2. The Harnessed C.A.S.E. Architecture

In the C.A.S.E. Framework, the **Harness** acts as the execution boundary between the stateless Local Agent (Layer 3) and the physical Task Queue state folders.

```mermaid
graph TD
    subgraph Task Queue (Physical Files)
        R["recipe.md / role.md"]
        S["status.txt"]
        A["action_log.jsonl (Trace)"]
        O["output.md"]
    end

    subgraph Harness Runtime (Deterministic Engine)
        H_Loop["Harness Control Loop"]
        H_Ctx["Active Context Compactor"]
        H_Int["State Interceptors (Auth, Env)"]
        H_Ver["Trace-Based Verifier"]
    end

    subgraph Local LLM (Non-Deterministic Engine)
        LLM["Llama.cpp Server"]
    end

    %% Flow
    H_Loop -->|"1. Trims history & feeds context"| H_Ctx
    H_Ctx -->|"2. Inference Request"| LLM
    LLM -->|"3. Proposed Tool Call"| H_Loop
    H_Loop -->|"4. Inspects state & intercepts"| H_Int
    H_Int -->|"5. Programmatic fix if needed"| H_Loop
    H_Loop -->|"6. Executes Tool"| R
    H_Loop -->|"7. Appends to Action Log"| A
    H_Loop -->|"8. Completed?"| H_Ver
    H_Ver -->|"9. Matches physical trace against recipe"| A
    H_Ver -->|"10. Updates State"| S
```

---

## 3. Four Core Pillars of C.A.S.E. Harness Engineering

To optimize the C.A.S.E. ecosystem, we implement four technical pillars derived from Tejas Kumar’s best practices.

### 🛡️ Pillar A: Trace-Based Verification (Catching Lies & Hallucinations)

AI agents frequently claim success (`"Task complete!"`) when they have failed to write the required files or run tests, or when they encountered silent crashes. 

Under C.A.S.E., the Harness MUST NOT trust the Worker agent’s verbal claims. Instead, it inspects the **action trace** programmatically:

1. **Deterministic Trace Verification**: When the Worker agent calls `submit_for_review`, the Harness intercepts the call and runs a script to read `action_log.jsonl`.
2. **Constraint Validation**: The Harness matches the trace against a deterministic state-check. For example:
   - If the task required editing a file, did the trace record a successful `write_artifact` tool call?
   - If the task required TDD, did the trace record a tool call running the test runner?
3. **Early Rejection**: If the trace does not match the physical requirements, the Harness rejects the task **immediately** without passing it to a Checker model, resetting the status to `PENDING` and logging a programmatic feedback entry: `"Harness Error: Agent claimed success but action_log.jsonl shows no write_artifact call."`

#### 📊 Human-Verifier-Harness Responsibility Matrix

| Verification Level | Performed By | Verification Method | Cost | Purpose |
|--------------------|--------------|---------------------|------|---------|
| **L0: Harness Trace** | Deterministic Script | Scans `action_log.jsonl` & file existence | 0 Tokens | Catch outright lying, empty outputs, and missing actions instantly. |
| **L1: Local Checker** | Local LLM (Layer 3) | Compares `output.md` with `recipe.md` DoD | Free (Local VRAM) | Logical and structural check against task specifications. |
| **L2: Global Aggregator**| Cloud LLM (Layer 2) | Compares all task outputs to `global_dod.md` | Low Token Cost | High-level synthesis, checking for overall architectural coherence. |

---

### 💾 Pillar B: Active Context Compaction (Mitigating VRAM Limitations)

Local LLMs running on personal GPUs (such as RTX A4500 with 20GB VRAM) suffer from **Attention Decay** and **VRAM blowup** when conversation logs grow long. Leaving the entire chat history in the LLM's context window is extremely wasteful.

The C.A.S.E. Harness enforces **Dynamic Context Compaction**:

1. **Slide-and-Preserve Compression**: When the message count in the active loop triggers a guardrail (e.g. `max_messages = 8`), the Harness collapses the history.
2. **Context Anatomy**: The compacted context sent to the local model MUST always consist of:
   - **System Prompt**: `00_Constitution/core.md` + task `role.md`.
   - **Core Directives**: `recipe.md` (Objective & Constraints).
   - **State Summary**: A concise, markdown-formatted cumulative summary of completed milestones (maintained by the Harness, not the LLM).
   - **Immediate History**: Only the *last 2 messages* (the most recent tool output and the agent's response).

This ensures the local model's prompt size remains flat and highly focused, maximizing speed (especially when using speculative decoding features like `--draft-mtp`) and eliminating "context forgetting."

---

### 🔑 Pillar C: Programmatic State Interceptors (Friction Isolation)

LLMs are notoriously bad at handling environment authentication, secret handshakes, or protocol negotiations. Pushing credentials (such as DB passwords, Git SSH tokens, or API keys) into the agent's prompt creates major security risks and pollutes the context window.

The C.A.S.E. Harness introduces **State Interceptors**:

1. **Trigger Recognition**: The Harness continuously monitors environmental variables and tool feedback (e.g. current directory state, target URL, console output stream, or execution errors).
2. **Programmatic Intervention**: When the Harness detects a known friction state, it pauses the LLM stream and handles it programmatically:
   - **Auth Interception**: If a tool hits a login/credential barrier, the Harness injects the required tokens/secrets directly into the session environment and performs the handshake.
   - **Recovery Interception**: If a Git merge conflict occurs during an auto-commit, the Harness triggers a standard merge resolution script or reverts the task folder via `revert_task` before resuming the agent.
3. **No-Prompt Rule**: The model is never shown the sensitive credentials, and the system prompts remain clean of authentication scripts. The model only receives: `"Harness Notification: Environmental authentication completed successfully."`

---

### 🧬 Pillar D: Task-Adaptive Harness Generation (Dynamic Harnessing)

As we look toward advanced automation, the optimal harness should be **task-adaptive**. When a task is generated, the environment should dynamically adapt its verification code to the task's specific goals.

In the C.A.S.E. Framework, when the Cloud Architect (Layer 2) splits a Roadmap milestone into an Atomic Task Package, it MUST generate:
1. `role.md` (The Persona)
2. `recipe.md` (The Instructions)
3. **`verify.js` / `verify.py`** (The Local Harness Script)

#### Example of a Task-Adaptive Harness Script:
```javascript
// Generated by Layer 2 and placed in D:/MyProject/Local-Agent-Workspace/02_Task_Queue/Task_003_RefactorDB/verify.js
const fs = require('fs');
const path = require('path');

function verify(taskDir) {
  const logPath = path.join(taskDir, 'action_log.jsonl');
  const outputPath = path.join(taskDir, 'output.md');
  
  // 1. Check physical output existence
  if (!fs.existsSync(outputPath)) {
    return { success: false, reason: "output.md was not generated" };
  }

  // 2. Read action log trace
  const logLines = fs.readFileSync(logPath, 'utf8').trim().split('\n');
  const toolCalls = logLines.map(line => JSON.parse(line));

  // 3. Ensure a test suite was run successfully
  const ranTests = toolCalls.some(call => 
    call.tool === "run_command" && 
    call.args.command.includes("npm test") && 
    call.result.includes("PASS")
  );

  if (!ranTests) {
    return { success: false, reason: "A successful test run (npm test) was not recorded in the action trace." };
  }

  return { success: true };
}

module.exports = verify;
```

When the Worker agent calls `submit_for_review`, the C.A.S.E. Harness executes this localized `verify` script first. If it returns `{ success: false }`, the Harness instantly reverts any toxic file modifications and resets the task to `PENDING` with the script's exact `reason`, completely protecting the codebase from broken builds.

---

## 4. Implementation Blueprint for C.A.S.E. Runtimes

For developers writing or utilizing a C.A.S.E.-compliant orchestrator (such as **CK's Pi Code Agent Harness**), the following loop protocol MUST be implemented:

```python
# Pseudo-code representation of the Harnessed Agent Loop
def run_harnessed_task(task_folder):
    harness = CAsEHarness(task_folder)
    
    # 1. Initialize guardrails
    max_steps = harness.load_config("max_steps", default=10)
    step_count = 0
    
    # Load task files
    harness.change_status("IN_PROGRESS")
    
    while step_count < max_steps:
        # A. Apply Active Context Compaction
        prompt = harness.compact_context()
        
        # B. Query local LLM for next action
        action = local_llm.query(prompt)
        
        # C. Intercept state/auth check
        if harness.detects_auth_boundary(action):
            harness.execute_programmatic_auth()
            continue
            
        # D. Execute requested tool
        result = harness.execute_tool(action.tool, action.args)
        harness.append_to_action_log(action.tool, action.args, result)
        
        # E. Check for worker exit request
        if action.tool == "submit_for_review":
            # F. Deterministic Trace Verification
            verification = harness.run_trace_verification()
            if verification.passed:
                harness.change_status("REVIEW")
                return "Submited successfully for Checker review."
            else:
                # Early rejection due to harness verification failure
                harness.rollback_files()
                harness.append_harness_feedback(verification.reason)
                harness.change_status("PENDING")
                return f"Rejected by Harness: {verification.reason}"
                
        step_count += 1
        
    # Guardrail triggered
    harness.change_status("ESCALATED")
    harness.append_harness_feedback("Harness Error: Maximum iterations exceeded (Guardrail Triggered).")
    raise MaxIterationsExceededException("Harness terminated run due to loop overflow.")
```

---

## 5. Summary of Optimization Benefits

Integrating **Harness Engineering** into the **C.A.S.E. Framework** yields immense practical benefits for development teams operating in resource-constrained local environments:

* **💎 Lower Compute Costs**: Programmatic interceptors and zero-token trace verifiers eliminate the need to run heavy model prompts just to check if files exist or to perform basic logins.
* **⚡ Blazing Fast Local Speed**: Context Compaction keeps context windows small, which dramatically accelerates prompt processing and token generation on consumer VRAM GPUs.
* **🔒 Bulletproof Security**: Secrets, credentials, and API keys are isolated within the deterministic Harness code and never leak into LLM prompts or chat histories.
* **🛡️ Zero Hallucinations on Progress**: Agents can no longer "pretend" to complete a task. The physical Git history and `action_log.jsonl` trace act as the ultimate, unalterable sources of truth.

---

## 🙏 Citing Prior Art & Acknowledgements

The Harness Engineering specifications integrated into the C.A.S.E. Framework are directly inspired by and adapted from the pioneering work of **Tejas Kumar** (IBM Developer Advocate) presented at **AI Engineer Europe 2026**. 

We highly recommend all engineers utilizing this repository to review the following resources for a deeper understanding:

* **📺 Full Presentation (YouTube)**: [Harnesses in AI: A Deep Dive — Tejas Kumar, IBM](https://youtu.be/C_GG5g38vLU?si=NVt8LgZaIRPOO6-Z)
* **💻 Open-Source Reference / Demo Repo**: [TejasQ/agent-harness-demo](https://github.com/TejasQ) (A lightweight browser agent using GPT-3.5 designed to showcase harness-level safety, guardrails, context compaction, programmatic authentication, and trace-based verification)
* **🐦 Connect with the Speaker**:
  - Twitter/X: [@TejasKumar_](https://x.com/TejasKumar_)
  - GitHub: [@TejasQ](https://github.com/TejasQ)
  - Personal Website: [tejaskumar.com](https://tejaskumar.com)

We extend our deep gratitude to Tejas Kumar for formulating these concepts from first principles and showcasing how smart harness engineering can elevate lightweight, affordable models to rival the execution reliability of enterprise-tier black boxes.

---

🔗 **References**:
- [System Protocols for AI Agents](for_agents.md)
- [C.A.S.E. Design Philosophy for Humans](for_humans.md)
- [Ecosystem README](../README.md)
