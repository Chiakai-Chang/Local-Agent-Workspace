#!/bin/sh
# =============================================================================
# C.A.S.E. Framework — Portable Bootstrap Script (POSIX Shell)
# =============================================================================
# Usage:  sh bootstrap.sh [target_project_root]
# Effect: Deploys the complete C.A.S.E. directory structure into the target
#         project root. Safe to re-run (idempotent).
#
# This script requires ZERO external dependencies. It uses only POSIX
# built-ins (mkdir, cp, cat, test, echo). It works on Linux, macOS, WSL,
# Git Bash, and any POSIX-compatible environment.
#
# Author: C.A.S.E. Framework
# License: MIT
# =============================================================================

set -eu

# --- Configuration -----------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"
CASE_DIR="$SCRIPT_DIR"

# Target: first argument, or current directory if omitted
TARGET="${1:-.}"

# Resolve to absolute path
TARGET="$(cd "$TARGET" && pwd)"

echo "========================================================"
echo " C.A.S.E. Framework — Portable Bootstrap"
echo " Target: $TARGET"
echo " Source: $CASE_DIR"
echo "========================================================"

# --- Validation --------------------------------------------------------------
if [ ! -d "$TARGET" ]; then
    echo "[ERROR] Target directory does not exist: $TARGET"
    exit 1
fi

if [ ! -d "$CASE_DIR" ]; then
    echo "[ERROR] .case/ directory not found at: $CASE_DIR"
    exit 1
fi

# --- Create three-layer architecture -----------------------------------------
echo ""
echo "[1/5] Creating three-layer directory structure..."

mkdir -p "$TARGET/00_Constitution"
mkdir -p "$TARGET/01_Roadmap"
mkdir -p "$TARGET/02_Task_Queue"

echo "      ✓ 00_Constitution/"
echo "      ✓ 01_Roadmap/"
echo "      ✓ 02_Task_Queue/"

# --- Copy templates to Constitution & Roadmap --------------------------------
echo ""
echo "[2/5] Copying starter templates..."

cp "$CASE_DIR/templates/core.md" "$TARGET/00_Constitution/core.md"
cp "$CASE_DIR/templates/roadmap.md" "$TARGET/01_Roadmap/roadmap.md" 2>/dev/null || true
cp "$CASE_DIR/templates/global_dod.md" "$TARGET/01_Roadmap/global_dod.md" 2>/dev/null || true

echo "      ✓ 00_Constitution/core.md"
echo "      ✓ 01_Roadmap/roadmap.md"
echo "      ✓ 01_Roadmap/global_dod.md"

# --- Append to .gitignore (idempotent) ---------------------------------------
echo ""
echo "[3/5] Updating .gitignore..."

GITIGNORE="$TARGET/.gitignore"
if [ -f "$GITIGNORE" ]; then
    # Check if already present
    if ! grep -q "02_Task_Queue/" "$GITIGNORE" 2>/dev/null; then
        echo "" >> "$GITIGNORE"
        echo "# C.A.S.E. Framework — task queues are agent workspace" >> "$GITIGNORE"
        echo "02_Task_Queue/" >> "$GITIGNORE"
        echo "      ✓ Appended to .gitignore"
    else
        echo "      ✓ Already in .gitignore (skipped)"
    fi
else
    cat > "$GITIGNORE" << 'GITIGNORE_EOF'
# C.A.S.E. Framework — task queues are agent workspace
02_Task_Queue/

# Generated artifacts
*.case/
GITIGNORE_EOF
    echo "      ✓ Created .gitignore"
fi

# --- Generate MAP.md navigation index ----------------------------------------
echo ""
echo "[4/5] Generating MAP.md navigation index..."

PROJECT_NAME=$(basename "$TARGET")

cat > "$TARGET/MAP.md" << MAP_EOF
# 🗺️ MAP — C.A.S.E. Navigation Index for $PROJECT_NAME

> **Purpose:** This file is the entry point for all agents entering this project.
> Read this file FIRST, then navigate to specific files on-demand.
> Do NOT read all files at once — use this map as a table of contents.

## Three-Layer Architecture

| Layer | Directory | Authority | Read/Write |
|-------|-----------|-----------|------------|
| **Constitution** | \`00_Constitution/\` | Human Architect | Read-only for AI |
| **Roadmap** | \`01_Roadmap/\` | Layer 2 (Macro) | Read-only for Layer 3 |
| **Task Queue** | \`02_Task_Queue/\` | Layer 3 (Micro) | Read/Write (own task only) |

## File Map

### 📜 Constitution (Read-Only)
- \`00_Constitution/core.md\` — Mission, constraints, domain rules
- \`00_Constitution/learnings.md\` — Trainable patterns & anti-patterns (auto-managed)

### 🗺️ Roadmap (Read-Only for Executors)
- \`01_Roadmap/roadmap.md\` — Phase breakdown & milestones
- \`01_Roadmap/global_dod.md\` — Global Definition of Done

### 📋 Task Queue (Agent Workspace)
- \`02_Task_Queue/\` — Active task folders
  - Each task folder: \`Task_<NNN>_<slug>/\`
  - Contains: role.md, recipe.md, status.txt, inputs/, output.md, feedback.md, action_log.jsonl

### 📖 Documentation
- \`CASE_framework_for_agents.md\` — Full agent protocol (if deployed)
- \`docs/\` — Additional documentation

## Quick Reference

### For AI Agents
1. Read \`MAP.md\` ← You are here
2. Read \`00_Constitution/core.md\` for constraints
3. Read \`01_Roadmap/roadmap.md\` for context
4. Find your task in \`02_Task_Queue/\`
5. Read \`role.md\` and \`recipe.md\` in your task folder
6. Begin execution

### Status Machine
\`PENDING\` → \`IN_PROGRESS\` → \`REVIEW\` → \`DONE\`
\`IN_PROGRESS\` → \`ESCALATED\` (on failure)
\`REVIEW\` → \`IN_PROGRESS\` (if feedback requires changes)

### Key Rules
- Worker MUST NOT self-approve (dual-track verification)
- All context materialized as files (file-as-state)
- Maximum 3 self-healing attempts before escalation
- Git commit after every meaningful change

---
*MAP.md is auto-generated by bootstrap.sh. Do not edit manually.*
MAP_EOF

echo "      ✓ MAP.md generated"

# --- Generate CASE.md (minimal ruleset for project root) ---------------------
echo ""
echo "[5/5] Generating CASE.md ruleset..."

cat > "$TARGET/CASE.md" << 'CASE_EOF'
# C.A.S.E. Framework — Project Rules

> This project uses the C.A.S.E. (Constitution-Architecture-State-Execution) framework.
> All AI agents MUST read and follow the rules below.

## Directory Structure
```
00_Constitution/    — READ-ONLY: Global constraints (core.md)
01_Roadmap/         — READ-ONLY: Phase plan (roadmap.md, global_dod.md)
02_Task_Queue/      — READ-WRITE: Agent workspace (task folders)
```

## Agent Operating Rules
1. **Read MAP.md first** — it is your navigation index
2. **Obey the Constitution** — never modify `00_Constitution/` or `01_Roadmap/`
3. **Stay in your lane** — only read/write your assigned task folder
4. **File-as-State** — all progress lives in files, not conversation context
5. **Dual-track verification** — Worker and Checker roles must be separate
6. **Git small steps** — commit after every meaningful change
7. **3-strike self-healing** — max 3 attempts before escalating

## Status Machine
`PENDING` → `IN_PROGRESS` → `REVIEW` → `DONE`
`IN_PROGRESS` → `ESCALATED` (on persistent failure)

## For Humans
To deploy the full agent protocol, run:
```bash
sh .case/bootstrap.sh
```
Then instruct your AI agent: "This project uses C.A.S.E. framework. Read CASE.md."
CASE_EOF

echo "      ✓ CASE.md generated"

# --- Summary ---------------------------------------------------------------
echo ""
echo "========================================================"
echo " ✅ C.A.S.E. Framework Bootstrap Complete!"
echo ""
echo " Next steps:"
echo "  1. Edit 00_Constitution/core.md with your mission"
echo "  2. Edit 01_Roadmap/roadmap.md with your phases"
echo "  3. Instruct your AI agent:"
echo "     \"This project uses C.A.S.E. framework. Read CASE.md.\""
echo "========================================================"
