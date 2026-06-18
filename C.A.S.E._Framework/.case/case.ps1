# C.A.S.E. Framework Controller Tool (case.ps1)
# ============================================
# PowerShell equivalent of case.py to ensure zero-dependency execution on Windows without Python installed.
# Supports: init, start, submit, check.

$ErrorActionPreference = "Stop"

function Get-IsoTime {
    return (Get-Date -Format "o")
}

function Run-Git {
    param([string[]]$ArgsList)
    try {
        $res = & git @ArgsList 2>$null
        return $res
    } catch {
        return $null
    }
}

function Case-Init {
    param([string]$Goal)
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "🚀 Initializing C.A.S.E. Setup via PowerShell" -ForegroundColor Cyan
    Write-Host "==========================================================" -ForegroundColor Cyan

    $currentFiles = Get-ChildItem -Name
    $projectType = "Generic"
    if ($currentFiles -contains "package.json") {
        $projectType = "JavaScript/TypeScript"
    } elseif ($currentFiles -contains "requirements.txt" -or $currentFiles -contains "pyproject.toml") {
        $projectType = "Python"
    } elseif ($currentFiles -contains "Cargo.toml") {
        $projectType = "Rust"
    } elseif ($currentFiles -contains "go.mod") {
        $projectType = "Go"
    }
    Write-Host "👁️  Detected Project Type: $projectType"

    if (-not $Goal) {
        Write-Host "`n📝 What is the primary development goal/objective for the AI Agent in this repository?"
        $Goal = Read-Host "👉 Enter Goal (e.g. 'Build user auth & profile page')"
        if (-not $Goal) {
            $Goal = "Refactor and optimize the current codebase."
            Write-Host "⚠️  No goal specified. Defaulting to: '$Goal'" -ForegroundColor Yellow
        }
    }

    $folders = @("00_Constitution", "01_Roadmap", "02_Task_Queue")
    foreach ($folder in $folders) {
        if (-not (Test-Path $folder)) {
            New-Item -ItemType Directory -Path $folder | Out-Null
            Write-Host "📁 Created folder: $folder/"
        } else {
            Write-Host "ℹ️  Folder already exists: $folder/"
        }
    }

    # Generate core.md
    $corePath = Join-Path "00_Constitution" "core.md"
    if (-not (Test-Path $corePath)) {
        $coreContent = @"
# 📂 Global Constitution

## 1. Core Mission Objective
- **Target Goal**: $Goal
- **Project Context**: $projectType Development

## 2. Universal Principles
- **No Hallucinations**: Always base assertions on physical codebase search. Do not assume APIs exist without importing or viewing their implementation.
- **Strict Typing**: Maintain type safety and avoid implicit conversions (where language supports it).
- **Code Reuse**: Always search the codebase for existing utility functions before writing redundant code.

## 3. Forbidden Operations
- Never bypass tests or delete test files without user confirmation.
- Never write credentials, database passwords, or secret keys to source files.
"@
        Set-Content -Path $corePath -Value $coreContent -Encoding UTF8
        Write-Host "📄 Generated core constitution: $corePath"
    }

    # Generate learnings.md
    $learningsPath = Join-Path "00_Constitution" "learnings.md"
    if (-not (Test-Path $learningsPath)) {
        $learningsContent = @"
# 🧠 C.A.S.E. Trainable Learnings (SkillOpt Space)

This document is the trainable state of this repository. The AI Agent writes findings here and reads them during task initialization.

## ## Anti-Patterns & Mistakes
*(AI Checker will auto-populate this section when mistakes are identified or tasks are rejected)*

## ## Reusable Patterns & Discoveries
*(AI Checker will auto-populate this section when new patterns or configurations are completed)*
"@
        Set-Content -Path $learningsPath -Value $learningsContent -Encoding UTF8
        Write-Host "📄 Generated learnings template: $learningsPath"
    }

    # Generate archive_learnings.md
    $archivePath = Join-Path "00_Constitution" "archive_learnings.md"
    if (-not (Test-Path $archivePath)) {
        $iso = Get-IsoTime
        $archiveContent = @"
# 🗄️ C.A.S.E. Learnings Archive (Cold Storage)

This file stores consolidated and archived historical learnings to keep the active learnings context window small.

## ## Historical Anti-Patterns & Archival Notes
- Archival started on: $iso
"@
        Set-Content -Path $archivePath -Value $archiveContent -Encoding UTF8
        Write-Host "📄 Generated cold learning archive: $archivePath"
    }

    # Generate roadmap.md & global_dod.md
    $roadmapPath = Join-Path "01_Roadmap" "roadmap.md"
    if (-not (Test-Path $roadmapPath)) {
        $roadmapContent = @"
# 🗺️ Project Roadmap - $Goal

## Phase 1: Context Auditing
- [ ] Task_001_InitialScan: Perform deep file structure scan and identify optimization targets.

## Phase 2: Feature Implementation
- [ ] Task_002_CoreImplementation: Implement main logic according to spec.
- [ ] Task_003_UnitTestSuite: Create unit test cases covering edge behaviors.
"@
        Set-Content -Path $roadmapPath -Value $roadmapContent -Encoding UTF8
        Write-Host "📄 Generated roadmap: $roadmapPath"
    }

    $dodPath = Join-Path "01_Roadmap" "global_dod.md"
    if (-not (Test-Path $dodPath)) {
        $dodContent = @"
# ✅ Global Definition of Done (Global DoD)

The entire project is considered completed and shippable only when:
1. All task queues in `02_Task_Queue/` are marked as `DONE` and validated by Checkers.
2. The compiler/transpiler executes with 0 warnings/errors.
3. Test suites execute successfully with no failing test cases.
4. No structural placeholders (TODO, FIXME) remain in production code.
"@
        Set-Content -Path $dodPath -Value $dodContent -Encoding UTF8
        Write-Host "📄 Generated Global DoD: $dodPath"
    }

    # Setup Initial Task
    $taskDir = Join-Path "02_Task_Queue" "Task_001_InitialScan"
    if (-not (Test-Path $taskDir)) {
        New-Item -ItemType Directory -Path $taskDir | Out-Null
        
        $recipeContent = @"
# Task Recipe: Initial Project Scan

## Objective
Analyze current directory structures and draft an implementation plan for: "$Goal".

## Input Sources
- Existing source files in the project root.

## Output Specification
- Write a report to `output.md` containing files to be modified and architectural suggestions.

## Local Definition of Done (DoD)
- [ ] List all core directories and their languages/frameworks.
- [ ] Scan for potential codebase dependencies or conflicts.
- [ ] List at least 3 concrete steps for the upcoming implementation tasks.

## Constraints
- Do not modify any production source files.
"@
        Set-Content -Path (Join-Path $taskDir "recipe.md") -Value $recipeContent -Encoding UTF8
        Set-Content -Path (Join-Path $taskDir "role.md") -Value "You are an expert system auditor. Examine the current workspace structure and output a meticulous audit report." -Encoding UTF8
        Set-Content -Path (Join-Path $taskDir "status.txt") -Value "PENDING" -Encoding UTF8
        Write-Host "📂 Setup initial task: $taskDir"
    }

    # Configure .cursorrules
    $cursorrulesContent = @"
# C.A.S.E. Framework Guardrails
- Before modifying any code, identify the active task folder inside `02_Task_Queue/` (where `status.txt` is `PENDING` or `IN_PROGRESS`).
- Use the CLI helper: `powershell -File .case/case.ps1 start <task_id>` to initiate your plan.
- Load that task's `role.md` as your System Prompt and `recipe.md` as your instruction manual.
- Write a `planning.md` file within the task folder detailing execution steps before editing production code.
- Modify files ONLY as specified in `recipe.md > Input Sources / Output Specification`.
- Track and append all tool calls to `action_log.jsonl` in the current task folder.
- Do NOT modify task status to DONE yourself. Run `powershell -File .case/case.ps1 submit <task_id> "<summary>"` to submit.
"@
    if (-not (Test-Path ".cursorrules")) {
        Set-Content -Path ".cursorrules" -Value $cursorrulesContent -Encoding UTF8
        Write-Host "🔗 Injected C.A.S.E. rules into `.cursorrules`."
    } else {
        $existing = Get-Content ".cursorrules" -Raw
        if ($existing -notlike "*C.A.S.E. Framework*") {
            Add-Content -Path ".cursorrules" -Value ("`n`n" + $cursorrulesContent) -Encoding UTF8
            Write-Host "🔗 Appended C.A.S.E. rules to your existing `.cursorrules`."
        } else {
            Write-Host "ℹ️  .cursorrules already contains C.A.S.E. rules."
        }
    }

    # Gitignore
    $ignoreLines = @(
        "",
        "# C.A.S.E. Execution Logs and Caches",
        "02_Task_Queue/*/inputs/",
        "02_Task_Queue/*/action_log.jsonl",
        "worktrees/"
    )
    $gitIgnoreContent = if (Test-Path ".gitignore") { Get-Content ".gitignore" } else { @() }
    $updatedIgnore = [System.Collections.Generic.List[string]]::new()
    if ($gitIgnoreContent) {
        if ($gitIgnoreContent -is [string]) {
            $updatedIgnore.Add($gitIgnoreContent) | Out-Null
        } else {
            foreach ($line in $gitIgnoreContent) {
                $updatedIgnore.Add($line) | Out-Null
            }
        }
    }
    foreach ($line in $ignoreLines) {
        if (-not ($gitIgnoreContent -contains $line)) {
            $updatedIgnore.Add($line) | Out-Null
        }
    }
    Set-Content -Path ".gitignore" -Value $updatedIgnore -Encoding UTF8
    Write-Host "🛡  Added C.A.S.E. worktree & cache paths to `.gitignore`."

    Write-Host "`n==========================================================" -ForegroundColor Green
    Write-Host "🎉 C.A.S.E. Framework has been successfully initialized!" -ForegroundColor Green
    Write-Host "👉 Run: powershell -File .case/case.ps1 start Task_001_InitialScan" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
}

function Case-Start {
    param([string]$TaskId)
    $taskDir = Join-Path "02_Task_Queue" $TaskId
    if (-not (Test-Path $taskDir)) {
        Write-Error "Task folder '$taskDir' does not exist."
        exit 1
    }

    $statusFile = Join-Path $taskDir "status.txt"
    $currentStatus = "PENDING"
    if (Test-Path $statusFile) {
        $currentStatus = (Get-Content $statusFile).Trim()
    }

    if ($currentStatus -ne "PENDING" -and $currentStatus -ne "IN_PROGRESS" -and $currentStatus -ne "REVIEW") {
        Write-Host "⚠️  Task is currently '$currentStatus'. Proceed with caution." -ForegroundColor Yellow
    }

    Set-Content -Path $statusFile -Value "IN_PROGRESS" -Encoding UTF8
    Write-Host "🔄 Task $TaskId status updated to: IN_PROGRESS"

    # planning.md
    $planPath = Join-Path $taskDir "planning.md"
    if (-not (Test-Path $planPath)) {
        $planContent = @"
# 📝 Task Micro-Plan: $TaskId

[T] Constraints/Truths
- No modifications outside recipe constraints.
- Read learnings.md before executing.

[A] Planned Actions
- [A] Scan directories => draft suggestions
- [A] Create output.md

[V] Verification Criteria
- [V] output.md matches recipe DoD items
"@
        Set-Content -Path $planPath -Value $planContent -Encoding UTF8
        Write-Host "📄 Scaffolded planning layout: $planPath"
    }

    # action_log.jsonl
    $logPath = Join-Path $taskDir "action_log.jsonl"
    $logEntry = @{
        ts = Get-IsoTime
        role = "worker"
        tool = "case_start"
        args = @{ task_id = $TaskId }
        result = "ok"
    } | ConvertTo-Json -Compress
    Add-Content -Path $logPath -Value $logEntry -Encoding UTF8
    Write-Host "📝 Appended start log trace to: $logPath"
}

function Case-Submit {
    param([string]$TaskId, [string]$Summary)
    $taskDir = Join-Path "02_Task_Queue" $TaskId
    if (-not (Test-Path $taskDir)) {
        Write-Error "Task folder '$taskDir' does not exist."
        exit 1
    }

    $outputPath = Join-Path $taskDir "output.md"
    if (-not (Test-Path $outputPath) -or (Get-Item $outputPath).Length -eq 0) {
        Write-Error "'output.md' is missing or empty. Cannot submit."
        exit 1
    }

    $statusFile = Join-Path $taskDir "status.txt"
    Set-Content -Path $statusFile -Value "REVIEW" -Encoding UTF8
    Write-Host "🔄 Task $TaskId status updated to: REVIEW"

    # Log entry
    $logPath = Join-Path $taskDir "action_log.jsonl"
    $logEntry = @{
        ts = Get-IsoTime
        role = "worker"
        tool = "case_submit"
        args = @{ task_id = $TaskId; summary = $Summary }
        result = "ok"
    } | ConvertTo-Json -Compress
    Add-Content -Path $logPath -Value $logEntry -Encoding UTF8

    # Git
    $gitStatus = Run-Git @("status", "--porcelain", $taskDir)
    if ($gitStatus) {
        Run-Git @("add", $taskDir)
        $commitMsg = "agent: worker submitted $TaskId - $Summary"
        Run-Git @("commit", "-m", $commitMsg)
        Write-Host "💾 Automatically committed $TaskId changes to Git."
    } else {
        Write-Host "ℹ️  No changes detected; Git commit skipped."
    }
}

function Consolidate-Learnings {
    $learningsPath = Join-Path "00_Constitution" "learnings.md"
    $archivePath = Join-Path "00_Constitution" "archive_learnings.md"

    if (-not (Test-Path $learningsPath)) { return }

    $lines = Get-Content $learningsPath
    if ($lines.Count -le 40) { return }

    Write-Host "🧠 Consolidation Threshold Exceeded (learnings.md > 40 lines). Activating SkillOpt Consolidation..." -ForegroundColor Cyan

    $headerSection = [System.Collections.Generic.List[string]]::new()
    $antipatterns = [System.Collections.Generic.List[string]]::new()
    $discoveries = [System.Collections.Generic.List[string]]::new()

    $currentSec = $null
    foreach ($line in $lines) {
        if ($line.StartsWith("# ") -or $line -like "*This document*") {
            $headerSection.Add($line)
        } elseif ($line -like "*## Anti-Patterns*" -or $line -like "*## ## Anti-Patterns*") {
            $currentSec = "anti"
        } elseif ($line -like "*## Reusable Patterns*" -or $line -like "*## ## Reusable Patterns*") {
            $currentSec = "pattern"
        } elseif ([string]::IsNullOrWhiteSpace($line)) {
            continue
        } else {
            if ($currentSec -eq "anti") { $antipatterns.Add($line) }
            elseif ($currentSec -eq "pattern") { $discoveries.Add($line) }
            else { $headerSection.Add($line) }
        }
    }

    $keepCount = 5
    $archiveAnti = if ($antipatterns.Count -gt $keepCount) { $antipatterns.GetRange(0, $antipatterns.Count - $keepCount) } else { @() }
    $keepAnti = if ($antipatterns.Count -gt $keepCount) { $antipatterns.GetRange($antipatterns.Count - $keepCount, $keepCount) } else { $antipatterns }

    $archivePat = if ($discoveries.Count -gt $keepCount) { $discoveries.GetRange(0, $discoveries.Count - $keepCount) } else { @() }
    $keepPat = if ($discoveries.Count -gt $keepCount) { $discoveries.GetRange($discoveries.Count - $keepCount, $keepCount) } else { $discoveries }

    if ($archiveAnti.Count -gt 0 -or $archivePat.Count -gt 0) {
        $iso = Get-IsoTime
        $archiveHeading = "`n### Consolidated on $iso"
        Add-Content -Path $archivePath -Value $archiveHeading -Encoding UTF8
        if ($archiveAnti.Count -gt 0) {
            Add-Content -Path $archivePath -Value "#### Archived Anti-Patterns:" -Encoding UTF8
            Add-Content -Path $archivePath -Value ($archiveAnti -join "`n") -Encoding UTF8
        }
        if ($archivePat.Count -gt 0) {
            Add-Content -Path $archivePath -Value "#### Archived Reusable Patterns:" -Encoding UTF8
            Add-Content -Path $archivePath -Value ($archivePat -join "`n") -Encoding UTF8
        }
        Write-Host "🗄️  Archived cold memories to archive_learnings.md."
    }

    # Re-write learnings.md
    $newContent = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $headerSection) { $newContent.Add($line) | Out-Null }
    $newContent.Add("`n## ## Anti-Patterns & Mistakes") | Out-Null
    if ($keepAnti.Count -gt 0) {
        foreach ($line in $keepAnti) { $newContent.Add($line) | Out-Null }
    } else {
        $newContent.Add("*(AI Checker will auto-populate this section when mistakes are identified or tasks are rejected)*") | Out-Null
    }
    $newContent.Add("`n## ## Reusable Patterns & Discoveries") | Out-Null
    if ($keepPat.Count -gt 0) {
        foreach ($line in $keepPat) { $newContent.Add($line) | Out-Null }
    } else {
        $newContent.Add("*(AI Checker will auto-populate this section when new patterns or configurations are completed)*") | Out-Null
    }

    Set-Content -Path $learningsPath -Value $newContent -Encoding UTF8
    Write-Host "🧹 learnings.md successfully compacted." -ForegroundColor Green
}

function Case-Check {
    param([string]$TaskId)
    $taskDir = Join-Path "02_Task_Queue" $TaskId
    if (-not (Test-Path $taskDir)) {
        Write-Error "Task folder '$taskDir' does not exist."
        exit 1
    }

    $statusFile = Join-Path $taskDir "status.txt"
    if (-not (Test-Path $statusFile)) {
        Write-Error "status.txt is missing in task folder."
        exit 1
    }

    $status = (Get-Content $statusFile).Trim()
    if ($status -ne "REVIEW") {
        Write-Host "⚠️  Task status is '$status'. Checking REVIEW status."
    }

    # 1. SECURITY AUDIT
    $modifiedFiles = Run-Git @("diff", "--name-only", "HEAD")
    $toxicFiles = @()
    if ($modifiedFiles) {
        foreach ($file in ($modifiedFiles -split "`n")) {
            $file = $file.Trim()
            if ($file.StartsWith("00_Constitution/") -or $file.StartsWith("01_Roadmap/")) {
                $toxicFiles += $file
            }
        }
    }

    if ($toxicFiles.Count -gt 0) {
        Write-Host "🚨 SECURITY VIOLATION: Read-only directories modified by Worker!" -ForegroundColor Red
        foreach ($tf in $toxicFiles) { Write-Host "   ↳ Toxic: $tf" -ForegroundColor Red }
        
        Write-Host "🛡️  Activating Security Defense: Reverting toxic files..." -ForegroundColor Yellow
        Run-Git @("restore", "--staged") | Out-Null
        Run-Git (@("restore") + $toxicFiles) | Out-Null

        Set-Content -Path $statusFile -Value "ESCALATED" -Encoding UTF8
        Set-Content -Path (Join-Path $taskDir "feedback.md") -Value "### Security Rejection`n- Task halted due to unauthorized modification of read-only files: $($toxicFiles -join ', '). Reverted." -Encoding UTF8

        $logPath = Join-Path $taskDir "action_log.jsonl"
        $logEntry = @{
            ts = Get-IsoTime
            role = "checker"
            tool = "security_audit"
            args = @{ toxic_files = $toxicFiles }
            result = "SECURITY_VIOLATION_REVERTED"
        } | ConvertTo-Json -Compress
        Add-Content -Path $logPath -Value $logEntry -Encoding UTF8
        exit 1
    }

    # 2. Files Check
    $outputPath = Join-Path $taskDir "output.md"
    if (-not (Test-Path $outputPath) -or (Get-Item $outputPath).Length -eq 0) {
        Write-Error "Verification Failed: output.md missing or empty."
        exit 1
    }

    $logPath = Join-Path $taskDir "action_log.jsonl"
    if (-not (Test-Path $logPath) -or (Get-Item $logPath).Length -eq 0) {
        Write-Error "Verification Failed: action_log.jsonl missing or empty."
        exit 1
    }

    Write-Host "✅ Basic file specifications validated." -ForegroundColor Green

    # 3. Mark DONE
    Set-Content -Path $statusFile -Value "DONE" -Encoding UTF8
    Write-Host "🎉 Task $TaskId is approved and marked as DONE!" -ForegroundColor Green

    # Log Done
    $logEntry = @{
        ts = Get-IsoTime
        role = "checker"
        tool = "case_check"
        args = @{ task_id = $TaskId; approved = $true }
        result = "ok"
    } | ConvertTo-Json -Compress
    Add-Content -Path $logPath -Value $logEntry -Encoding UTF8

    # 4. Learning consolidation
    Consolidate-Learnings

    # Commit finalized
    Run-Git @("add", $taskDir, "00_Constitution") | Out-Null
    Run-Git @("commit", "-m", "task($TaskId): checker approved and closed task") | Out-Null
}

# CLI Router
if ($args.Count -lt 1) {
    Write-Host "C.A.S.E. Controller PowerShell Helper Tools"
    Write-Host "Usage:"
    Write-Host "  powershell -File .case/case.ps1 init [optional goal]"
    Write-Host "  powershell -File .case/case.ps1 start <task_id>"
    Write-Host "  powershell -File .case/case.ps1 submit <task_id> `"summary`""
    Write-Host "  powershell -File .case/case.ps1 check <task_id>"
    exit 0
}

$cmd = $args[0]
if ($cmd -eq "init") {
    $goal = if ($args.Count -gt 1) { $args[1] } else { $null }
    Case-Init -Goal $goal
} elseif ($cmd -eq "start") {
    if ($args.Count -lt 2) { Write-Error "Missing task_id"; exit 1 }
    Case-Start -TaskId $args[1]
} elseif ($cmd -eq "submit") {
    if ($args.Count -lt 2) { Write-Error "Missing task_id"; exit 1 }
    $sum = if ($args.Count -gt 2) { $args[2] } else { "completed" }
    Case-Submit -TaskId $args[1] -Summary $sum
} elseif ($cmd -eq "check") {
    if ($args.Count -lt 2) { Write-Error "Missing task_id"; exit 1 }
    Case-Check -TaskId $args[1]
} else {
    Write-Host "Unknown command. Use no parameters for help."
}
