# =============================================================================
# C.A.S.E. Framework — Portable Bootstrap Script (PowerShell)
# =============================================================================
# Usage:  .\bootstrap.ps1 [target_project_root]
# Effect: Deploys the complete C.A.S.E. directory structure into the target
#         project root. Safe to re-run (idempotent).
# =============================================================================

Param(
    [string]$TargetDir = "."
)

$ErrorActionPreference = "Stop"

# --- Configuration -----------------------------------------------------------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CaseDir = Split-Path -Parent $ScriptDir

# Resolve target directory to absolute path
$ResolvedTarget = Resolve-Path $TargetDir
$TargetAbsPath = $ResolvedTarget.Path

Write-Host "========================================================" -ForegroundColor Green
Write-Host " C.A.S.E. Framework — Portable PowerShell Bootstrap"
Write-Host " Target: $TargetAbsPath"
Write-Host " Source: $CaseDir"
Write-Host "========================================================" -ForegroundColor Green

# --- Validation --------------------------------------------------------------
if (-not (Test-Path -Path $TargetAbsPath -PathType Container)) {
    Write-Error "Target directory does not exist: $TargetAbsPath"
}

if (-not (Test-Path -Path $CaseDir -PathType Container)) {
    Write-Error "C.A.S.E. root directory not found at: $CaseDir"
}

# --- Create three-layer architecture -----------------------------------------
Write-Host ""
Write-Host "[1/5] Creating three-layer directory structure..." -ForegroundColor Cyan

$Layers = @("00_Constitution", "01_Roadmap", "02_Task_Queue")
foreach ($Layer in $Layers) {
    $Path = Join-Path -Path $TargetAbsPath -ChildPath $Layer
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
        Write-Host "      ✓ Created $Layer/" -ForegroundColor Gray
    } else {
        Write-Host "      ✓ $Layer/ already exists (skipped)" -ForegroundColor Gray
    }
}

# --- Copy templates to Constitution & Roadmap --------------------------------
Write-Host ""
Write-Host "[2/5] Copying starter templates..." -ForegroundColor Cyan

$TemplateMappings = @{
    "core.md"       = "00_Constitution\core.md"
    "roadmap.md"    = "01_Roadmap\roadmap.md"
    "global_dod.md" = "01_Roadmap\global_dod.md"
}

foreach ($Template in $TemplateMappings.Keys) {
    $Src = Join-Path -Path $CaseDir -ChildPath "templates\$Template"
    $Dest = Join-Path -Path $TargetAbsPath -ChildPath $TemplateMappings[$Template]
    
    if (Test-Path -Path $Src) {
        if (-not (Test-Path -Path $Dest)) {
            Copy-Item -Path $Src -Destination $Dest -Force
            Write-Host "      ✓ Created $Dest" -ForegroundColor Gray
        } else {
            Write-Host "      ✓ $Dest already exists (skipped)" -ForegroundColor Gray
        }
    }
}

# --- Append to .gitignore (idempotent) ---------------------------------------
Write-Host ""
Write-Host "[3/5] Updating .gitignore..." -ForegroundColor Cyan

$GitignorePath = Join-Path -Path $TargetAbsPath -ChildPath ".gitignore"
$IgnoreContent = @(
    "",
    "# C.A.S.E. Framework — task queues are agent workspace",
    "02_Task_Queue/",
    "*.case/"
)

if (Test-Path -Path $GitignorePath) {
    $Existing = Get-Content -Path $GitignorePath
    $NeedsUpdate = $false
    foreach ($Line in $IgnoreContent) {
        if ($Line -ne "" -and $Existing -notcontains $Line) {
            $NeedsUpdate = $true
            break
        }
    }
    
    if ($NeedsUpdate) {
        Add-Content -Path $GitignorePath -Value $IgnoreContent
        Write-Host "      ✓ Appended task queue entries to .gitignore" -ForegroundColor Gray
    } else {
        Write-Host "      ✓ .gitignore is already up to date (skipped)" -ForegroundColor Gray
    }
} else {
    Set-Content -Path $GitignorePath -Value $IgnoreContent
    Write-Host "      ✓ Created .gitignore with C.A.S.E. rules" -ForegroundColor Gray
}

# --- Generate MAP.md navigation index ----------------------------------------
Write-Host ""
Write-Host "[4/5] Generating MAP.md navigation index..." -ForegroundColor Cyan

$ProjectName = Split-Path -Leaf $TargetAbsPath

$MapTemplate = @"
# 🗺️ MAP — C.A.S.E. Navigation Index for $ProjectName

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
- [00_Constitution/core.md](00_Constitution/core.md) — Mission, constraints, domain rules
- [00_Constitution/learnings.md](00_Constitution/learnings.md) — Trainable patterns & anti-patterns (auto-managed)

### 🗺️ Roadmap (Read-Only for Executors)
- [01_Roadmap/roadmap.md](01_Roadmap/roadmap.md) — Phase breakdown & milestones
- [01_Roadmap/global_dod.md](01_Roadmap/global_dod.md) — Global Definition of Done

### 📋 Task Queue (Agent Workspace)
- [02_Task_Queue/](02_Task_Queue/) — Active task folders
  - Each task folder: \`Task_<NNN>_<slug>/\`
  - Contains: role.md, recipe.md, status.txt, inputs/, output.md, feedback.md, action_log.jsonl

### 📖 Documentation
- [CASE_framework_for_agents.md](CASE_framework_for_agents.md) — Full agent protocol (if deployed)
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
*MAP.md is auto-generated by bootstrap.ps1. Do not edit manually.*
"@

$MapPath = Join-Path -Path $TargetAbsPath -ChildPath "MAP.md"
Set-Content -Path $MapPath -Value $MapTemplate -Encoding utf8
Write-Host "      ✓ MAP.md generated" -ForegroundColor Gray

# --- Generate CASE.md (minimal ruleset for project root) ---------------------
Write-Host ""
Write-Host "[5/5] Generating CASE.md ruleset..." -ForegroundColor Cyan

$CaseTemplate = @"
# C.A.S.E. Framework — Project Rules

> This project uses the C.A.S.E. (Constitution-Architecture-State-Execution) framework.
> All AI agents MUST read and follow the rules below.

## Directory Structure
\`\`\`
00_Constitution/    — READ-ONLY: Global constraints (core.md)
01_Roadmap/         — READ-ONLY: Phase plan (roadmap.md, global_dod.md)
02_Task_Queue/      — READ-WRITE: Agent workspace (task folders)
\`\`\`

## Agent Operating Rules
1. **Read MAP.md first** — it is your navigation index
2. **Obey the Constitution** — never modify \`00_Constitution/\` or \`01_Roadmap/\`
3. **Stay in your lane** — only read/write your assigned task folder
4. **File-as-State** — all progress lives in files, not conversation context
5. **Dual-track verification** — Worker and Checker roles must be separate
6. **Git small steps** — commit after every meaningful change
7. **3-strike self-healing** — max 3 attempts before escalating

## Status Machine
\`PENDING\` → \`IN_PROGRESS\` → \`REVIEW\` → \`DONE\`
\`IN_PROGRESS\` → \`ESCALATED\` (on persistent failure)

## For Humans
To deploy the full agent protocol, run:
```powershell
.\scripts\bootstrap.ps1 .
```
Or for POSIX:
```bash
sh scripts/bootstrap.sh .
```
Then instruct your AI agent: "This project uses C.A.S.E. framework. Read CASE.md."
"@

$CasePath = Join-Path -Path $TargetAbsPath -ChildPath "CASE.md"
Set-Content -Path $CasePath -Value $CaseTemplate -Encoding utf8
Write-Host "      ✓ CASE.md generated" -ForegroundColor Gray

# --- Summary ---------------------------------------------------------------
Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host " ✅ C.A.S.E. Framework Bootstrap Complete!" -ForegroundColor Green
Write-Host ""
Write-Host " Next steps:"
Write-Host "  1. Edit 00_Constitution/core.md with your mission"
Write-Host "  2. Edit 01_Roadmap/roadmap.md with your phases"
Write-Host "  3. Instruct your AI agent:"
Write-Host "     `"This project uses C.A.S.E. framework. Read CASE.md.`""
Write-Host "========================================================" -ForegroundColor Green
