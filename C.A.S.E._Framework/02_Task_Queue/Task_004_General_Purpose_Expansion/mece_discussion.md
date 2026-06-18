# 💬 C.A.S.E. General-Purpose Expansion MECE Discussion

> **Task**: Task_004_General_Purpose_Expansion
> **Date**: 2026-06-18
> **Objective**: Analyze the cognitive friction of using a code-centric framework for non-programming tasks (patrolling, thesis writing, slide creation, data analysis, etc.) and design domain-agnostic enhancements.

---

## 👥 Simulated Roles & Stakeholder Registry

To ensure a Mutually Exclusive and Collectively Exhaustive (MECE) analysis, the following roles and stakeholders participate in the debate:

### 🛠️ Professional Expert Roles
1.  **OSINT & Intelligence Analyst (IA)**: Focuses on web patrolling, threat/gambling intelligence gathering, scouting logs, and evidence audit trails.
2.  **Creative Producer & Content Editor (CE)**: Focuses on slide presentation design, plot analysis, creative copywriting, script structural coherence, and layout aesthetics.
3.  **Academic Literature Researcher (AR)**: Focuses on thesis/paper writing, scientific logic, quote attribution, citation verification, and plagiarism checking.
4.  **Data Analytics & Systems Architect (DA)**: Focuses on raw data parsing, pattern mining, mathematical accuracy, layout formatting, and structural mapping.
5.  **Prompt & Cognitive UX Designer (CD)**: Focuses on the developer experience (DX) and user experience (UX) for non-technical operators, ensuring instructions map clean to AI behaviors without developer jargon.

### 💼 Stakeholder Roles
1.  **Law Enforcement / Security Manager (LESM)**: Requires high auditability, legal admissibility, non-repudiable logs, and rigid evidence-backed validation.
2.  **Academic Journal Editor (AJE)**: Requires zero hallucinations, absolute factual integrity, and exact references.
3.  **Business Consultant / Executive (BCE)**: Requires fast visual output, concise summaries, zero boilerplate, and immediate presentation readiness (decks).
4.  **Non-Technical User (NTU)**: Requires zero dependency on developer tools (Git, npm, pytest) and intuitive language (no jargon).

---

## ⚔️ Multi-Round MECE Debate Transcript

### 🔄 Round 1: Exposing Jargon Gaps in Non-Code Workloads

*   **NTU (Non-Technical User)**: "When I use Cursor or Claude Code to write a literature review or scan for illegal gambling forums, the system instructions keep telling the AI to 'write unit tests first' and follow 'RED-GREEN-REFACTOR'. The AI gets confused, starts trying to write python scripts or mock tests when all I want is a markdown report or a table of facts. This is massive cognitive friction."
*   **AR (Academic Researcher)**: "Exactly. In academic writing, a 'test' is fact-checking: checking if a citation actually exists and supports the claim. If the instruction says 'Run unit tests', the AI thinks it needs code. We need to generalize 'unit test' to 'verification check' or 'facts validation'."
*   **IA (Intelligence Analyst)**: "For intelligence patrolling, our 'DoD' is proving that we visited a site and logged the evidence. A unit test here is verifying that the scanned URLs are active, extracting their server IPs, and checking if they trigger gambling flags. We need the AI to understand that 'tests' can be network checks, fact-checks, or logic-checks."
*   **CE (Creative Producer)**: "In presentation design, a test is verifying if the slide structure matches the target page count, if the type scale is readable, and if the layout is correct. Telling the AI to follow RED-GREEN-REFACTOR makes it write test code instead of adjusting layout parameters."

---

### 🔄 Round 2: Abstracting Tools, Deliverables, and Environments

*   **DA (Data Analyst)**: "In software, we run `npm run test` or `pytest`. In non-software tasks, the execution environment uses search tools (`search_web`), page scrapers (`read_url_content`), data summary scripts, or layout rendering engines. C.A.S.E. should abstract 'Verification Tool' to cover any method of fact-checking or inspection."
*   **LESM (Security Manager)**: "For patrolling and OSINT, auditing is critical. We cannot just accept the AI's word. The `action_log.jsonl` (or fallback `log.md`) must capture the exact search queries and source URLs visited. This is our non-repudiable evidence chain. It is the equivalent of a test coverage report."
*   **AJE (Journal Editor)**: "Agreed. Hallucination is our worst enemy. If the AI writes a thesis chapter, the verification criteria must check every quotation against source texts. This means we need the prompt to mandate 'Source Verification checks' before setting a task to REVIEW."
*   **CD (UX Designer)**: "Let's map out a domain-agnostic translation table. We must replace code-specific terms in `for_agents.md` and `agent_skills.md` with abstract counterparts that cover both programming and content workloads."

---

### 🔄 Round 3: Designing the Generalized C.A.S.E. Architecture

*   **SA (Systems Architect)**: "I propose the following mapping to achieve a **General-Purpose C.A.S.E. (GP-C.A.S.E.)** framework:
    *   **Unit Tests / Assertions** $\rightarrow$ **Verification Tests / Facts Validation (驗證測試 / 事實核對)**.
    *   **Code Modifications** $\rightarrow$ **Deliverable Editing / Content Creation (編修產出 / 內容創作)**.
    *   **Compiler / Test Runner** $\rightarrow$ **Verification Tools / Fact-Check Inspections (驗證工具 / 事實檢核)**.
    *   **Write Defense (Git / Pre-commit)** $\rightarrow$ **Integrity & Access Defense (防篡改防護 / 內容完整性校驗)**.
    *   **RED-GREEN-REFACTOR** $\rightarrow$ **DRAFT-VERIFY-REFINE (起草 - 驗證 - 潤飾)**.
*   **AR (Academic Researcher)**: "This fits thesis writing perfectly. A 'Draft' is the initial text. 'Verify' is checking facts, citations, and plagiarism. 'Refine' is editing for flow, tone, and formatting."
*   **IA (Intelligence Analyst)**: "And for patrolling: 'Draft' is compiling the initial list of suspected sites. 'Verify' is running active link scans and check IP addresses. 'Refine' is organizing them into a standard law enforcement reporting table."
*   **CE (Creative Producer)**: "This is great. Let's update the scaffolding blueprints inside `docs/for_agents.md` and `docs/agent_skills.md` to show this generalized structure. We should include examples of how a non-code recipe looks so agents can copy the pattern."

---

## 🏆 Final Consensus & Action Plan

1.  **docs/agent_skills.md & docs/for_agents.md**:
    *   Replace all code-only jargon (unit tests, code files, compilers) with generalized counterparts.
    *   Redefine BDD Spec-by-Example to cover logic/fact verification.
    *   Provide a non-code General-Purpose example of `recipe.md` and `planning.md` templates.
2.  **docs/for_humans.md & README.md**:
    *   Update descriptions to explicitly declare C.A.S.E. as a domain-agnostic task protocol.
    *   Add examples showing how C.A.S.E. manages intelligence patrolling, thesis editing, and deck preparation.
3.  **C.A.S.E._Framework/.cursorrules**:
    *   Update system instructions to be fully domain-agnostic, supporting non-programming workflows seamlessly.
