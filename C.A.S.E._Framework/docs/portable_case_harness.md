# 📦 Portable C.A.S.E. Harness — "CASE.md" Ruleset

> **Concept**: Transform C.A.S.E. from a documentation framework into a **plug-and-play declarative ruleset (`CASE.md`)** that can be dropped inside *any* repository.
> When an IDE AI agent (Cursor, Claude Code, Windsurf) opens the repository, it natively reads `CASE.md` and immediately adapts to the C.A.S.E. structured workflow, directory boundaries, and trace logging protocols—without executing any host-level code.

---

## 1. The Core Vision: Portable Declarative Ruleset

For general users, executing setup scripts on host machines creates security friction. By mimicking the standard `CLAUDE.md` and `.cursorrules` developer experience, C.A.S.E. provides a **single, secure markdown ruleset (`CASE.md`)** that:
1. **Requires Zero Code Execution**: No script execution, no RCE hazards. Just download a static Markdown file.
2. **Auto-Configures AI Agents**: Natively programs Cursor, Claude Code, or Windsurf to respect C.A.S.E. boundaries (Worker role, Task Queue folders, action trace logging) out-of-the-box.
3. **Maintains System Integrity**: Separates the codebase's main files from active task queues, keeping development tracked and clean.

---

## 2. Folder Layout: The `.case/` Bootstrap Directory

When a user runs the bootstrap command or clones C.A.S.E. into their repo, a lightweight `.case/` folder is initialized in their project root:

```
<your_project_root>/
│
├── .case/                     # Dropped in via clone/bootstrap
│   ├── init.py                # The CLI bootstrapper script (Interactive)
│   ├── agent_skills.md        # Unified System Instructions (Agent-readable)
│   ├── templates/             # Starter templates for core.md, recipe.md, etc.
│   └── verifiers/             # Pre-built Trace Verifiers (e.g. check_git.js)
│
├── 00_Constitution/           # Initialized by init.py (Core limits)
│   └── core.md
│
├── 01_Roadmap/                # Initialized by init.py (Project task map)
│   ├── roadmap.md
│   └── global_dod.md
│
├── 02_Task_Queue/             # Excluded from main Git commits if temporary
│   └── Task_001_initial_scan/
│
└── .gitignore                 # Automatically appended by init.py
```

---

## 3. The 3-Step Portable Workflow

```
[ Step 1: Bootstrap ] ──► [ Step 2: Auto-Config AI ] ──► [ Step 3: Run & Decompose ]
User clones/downloads     Script generates rules          Orchestrator generates
.case/ & runs init.py     (.cursorrules, claudecode)      roadmaps, tasks, and verifiers
```

### ⚙️ Step 1: Bootstrap & Interactive Scan
The user downloads `.case/` into their project directory and runs:
```bash
python .case/init.py
```
The script performs the following actions:
1. **Codebase Scan**: Identifies the primary languages, frameworks, test runners, and file structures.
2. **Prompt for Target**: Asks the user: *"What is the core goal of this AI development run?"* (e.g. *"Refactor my database into Prisma"*, *"Add user authentication"*).
3. **Generate Core Files**: Generates a standard `00_Constitution/core.md` and `01_Roadmap/roadmap.md` pre-populated with code guidelines tailored to their language.

### 🛡️ Step 2: Auto-Configuring Commercial AI Tools
The bootstrapper script automatically bridges C.A.S.E. with whatever commercial IDE or terminal-based AI tools the developer is using. It writes tailored configuration files directly to the root:

#### A. For Cursor / Windsurf Users (`.cursorrules`)
The script generates or appends a `.cursorrules` file in the root containing:
```markdown
# C.A.S.E. Agent Protocol Enabled
You are operating within a C.A.S.E. Framework repository. Before making any edits:
1. Read `.case/agent_skills.md` for your operating guidelines.
2. Locate the active task folder inside `02_Task_Queue/` where the status.txt is `PENDING` or `IN_PROGRESS`.
3. Load that task's `role.md` as your persona and `recipe.md` as your instruction manual.
4. Execute edits ONLY in files specified in recipe.md > Input/Output.
5. Record every action you take in `action_log.jsonl`.
6. Set status.txt to `REVIEW` and invoke the verifier when done. Do not self-approve.
```

#### B. For Claude Code Users (`.claudecode.json` / system injection)
Creates configuration pointers ensuring that terminal-based agents immediately check the `02_Task_Queue` to find their current ticket rather than editing arbitrary files in a panic.

### 🔍 Step 3: Git-Ignore Smart Check
The script asks the user:
> *"Do you want to append C.A.S.E. workspace execution files to your `.gitignore`?"*
* **Choice A: Reference Only (Recommended)**: Appends `02_Task_Queue/` and execution caches to `.gitignore`.
  * *Why*: The execution steps and raw action logs remain on the user's disk for local agent memory but do not clutter their production codebase commits. Only the high-level `00_Constitution/` and `01_Roadmap/` are tracked in Git.
* **Choice B: Full Audit History**: Keeps all C.A.S.E. folders tracked.
  * *Why*: Essential for teams requiring high digital compliance or full audit-logs of AI activities.

---

## 4. Interactive Bootstrapper Blueprint (`init.py`)

Here is a concrete blueprint of how the interactive python bootstrapper script handles initialization:

```python
# Pseudo-code for .case/init.py
import os
import sys
import shutil

def run_bootstrap():
    print("🚀 Initializing C.A.S.E. Portable Harness...")
    
    # 1. Detect project context
    project_files = os.listdir('.')
    has_package_json = 'package.json' in project_files
    has_requirements_txt = 'requirements.txt' in project_files
    
    lang = "Python" if has_requirements_txt else ("JavaScript/TypeScript" if has_package_json else "Generic")
    print(f"👁️ Detected project type: {lang}")
    
    # 2. Ask user for their development target
    print("\n📝 What is the major goal or task for the AI Agent in this repository?")
    user_goal = input("👉 Enter Goal: ").strip()
    
    # 3. Create C.A.S.E folders
    for folder in ["00_Constitution", "01_Roadmap", "02_Task_Queue"]:
        os.makedirs(folder, exist_ok=True)
        
    # 4. Generate 00_Constitution/core.md
    with open("00_Constitution/core.md", "w", encoding="utf-8") as f:
        f.write(f"""# Global Constitution
Core Objective: {user_goal}
Language Rules: Language is {lang}. Maintain strict typing where applicable.
Forbidden: Never delete raw user database files or disable security settings without confirmation.
""")

    # 5. Generate initial roadmap task
    os.makedirs("02_Task_Queue/Task_001_InitialScan", exist_ok=True)
    with open("02_Task_Queue/Task_001_InitialScan/recipe.md", "w", encoding="utf-8") as f:
        f.write(f"""# Task Recipe: Initial Project Scan
## Objective
Analyze the current codebase structure and suggest milestones for: "{user_goal}".

## Local Definition of Done
- [ ] List all core files and folders in inputs/
- [ ] Identify potential technical debt or gaps
- [ ] Output a suggested milestones plan to output.md
""")
        
    with open("02_Task_Queue/Task_001_InitialScan/role.md", "w", encoding="utf-8") as f:
        f.write("You are an expert system auditor. Analyze the files in the workspace and plan steps.")
        
    with open("02_Task_Queue/Task_001_InitialScan/status.txt", "w", encoding="utf-8") as f:
        f.write("PENDING")

    # 6. Auto-Inject rules for IDE Agents (Cursor, etc.)
    inject_cursorrules()
    
    # 7. Ask for .gitignore preferences
    manage_gitignore()

    print("\n✅ C.A.S.E. Portable Harness initialized successfully!")
    print("🤖 Your AI Agent (Cursor, Claude, etc.) will now automatically detect C.A.S.E. guidelines.")
    print("👉 Open 02_Task_Queue/Task_001_InitialScan/recipe.md to begin execution!")

def inject_cursorrules():
    cursorrules_content = """# C.A.S.E. Framework Guardrails
- Always look for the active task in 02_Task_Queue/
- Follow the instructions in recipe.md and act as the role defined in role.md
- Document your progress in action_log.jsonl
- Never self-approve task completion
"""
    if not os.path.exists('.cursorrules'):
        with open('.cursorrules', 'w', encoding='utf-8') as f:
            f.write(cursorrules_content)
        print("🔗 Injected C.A.S.E. rules into `.cursorrules` for Cursor/Windsurf compatibility.")
    else:
        # Append safely
        with open('.cursorrules', 'a', encoding='utf-8') as f:
            f.write("\n\n" + cursorrules_content)
        print("🔗 Appended C.A.S.E. rules to your existing `.cursorrules`.")

def manage_gitignore():
    print("\n📁 Would you like to add the active execution folders (e.g. 02_Task_Queue/) to `.gitignore`?")
    print("  [1] Yes - Keep active logs and caches local (Prevents Git pollution, Recommended)")
    print("  [2] No  - Track every single execution file in Git (Full Audit Trail)")
    choice = input("👉 Enter choice (1/2): ").strip()
    
    if choice == '1':
        git_ignore_lines = ["\n# C.A.S.E. Execution Workspace", "02_Task_Queue/*/inputs/", "02_Task_Queue/*/action_log.jsonl"]
        with open('.gitignore', 'a+', encoding='utf-8') as f:
            f.seek(0)
            content = f.read()
            for line in git_ignore_lines:
                if line not in content:
                    f.write(line + "\n")
        print("🛡️ Added active C.A.S.E execution cache paths to `.gitignore`.")
```

---

## 5. Practicality & Benefits for General AI Projects

By designing C.A.S.E. as a **portable, self-bootstrapping harness**, users unlock immediate benefits across all their AI endeavors:

### 🧩 A. Instant Agent Synchronization
When you use multiple AI assistants (e.g., you start coding on Cursor, then switch to a terminal agent like Claude Code, and then use a web agent), they all share the **same source of truth**. The `.cursorrules` and physical task files tell every agent where to pick up, preventing the "agent context fragmentation" that occurs when switching platforms.

### 📈 B. Progressive Task-Level Memory
Because state is stored in files (`status.txt`, `action_log.jsonl`, `output.md`), the AI never "loses its memory" when the chat history exceeds the context window. The Harness simply feeds the current state snapshot back into the model's active attention pool, ensuring perfect continuity.

### 🛡️ C. Protection Against "Agent Panic"
When a cheap local or cloud model makes a mistake, the Harness's L0 Trace-Based Verifier catches the error before it can corrupt the codebase, programmatically rolling back changes and prompting the agent to try a different execution route.

---

🔗 **References**:
- [Harness Engineering Design](harness_engineering.md)
- [System Protocols for AI Agents](for_agents.md)
- [Ecosystem README](../README.md)
