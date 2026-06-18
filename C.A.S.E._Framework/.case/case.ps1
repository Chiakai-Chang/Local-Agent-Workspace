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
    Write-Host "`n💡 [拓撲協同最佳實踐 / Topology Setup Tip]:" -ForegroundColor Cyan
    Write-Host "   雖然 C.A.S.E. 支援「單一本地模型」跑完全流程，但若能「雙軌協同」效果更佳：" -ForegroundColor Cyan
    Write-Host "   1. 宏觀規劃層：交由雲端高推理模型 (如 Claude/Gemini) 進行 Roadmap 拆解與 Recipe 生成（不需提供代碼，僅供目錄樹結構）。" -ForegroundColor Cyan
    Write-Host "   2. 微觀執行層：交由本地模型 (如本機 27B) 專注在 Task 沙箱內做代碼修改與單元測試，保障敏感代碼絕不外流並節省費用。" -ForegroundColor Cyan
    Write-Host "   詳細分工與時機，請參閱：docs/for_humans.md Section 2.5`n" -ForegroundColor Cyan
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

    if ($currentStatus -eq "DONE" -or $currentStatus -eq "REVIEW") {
        Write-Error "Cannot start task. Task $TaskId is already in status '$currentStatus'."
        exit 1
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

    $statusFile = Join-Path $taskDir "status.txt"
    $currentStatus = "PENDING"
    if (Test-Path $statusFile) {
        $currentStatus = (Get-Content $statusFile).Trim()
    }

    if ($currentStatus -ne "IN_PROGRESS") {
        Write-Error "Task status is '$currentStatus'. Only 'IN_PROGRESS' tasks can be submitted."
        exit 1
    }

    $outputPath = Join-Path $taskDir "output.md"
    if (-not (Test-Path $outputPath) -or (Get-Item $outputPath).Length -eq 0) {
        Write-Error "'output.md' is missing or empty. Cannot submit."
        exit 1
    }

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

function Parse-MarkdownBlocks {
    param([string[]]$SectionLines)
    $blocks = [System.Collections.Generic.List[string]]::new()
    $currentBlock = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $SectionLines) {
        $trimmed = $line.TrimStart()
        if ($trimmed.StartsWith("- ") -or $trimmed.StartsWith("* ")) {
            if ($currentBlock.Count -gt 0) {
                $blocks.Add(($currentBlock -join "`r`n") + "`r`n")
                $currentBlock.Clear()
            }
        }
        $currentBlock.Add($line)
    }
    if ($currentBlock.Count -gt 0) {
        $blocks.Add(($currentBlock -join "`r`n") + "`r`n")
    }
    return $blocks
}

function Consolidate-Learnings {
    $learningsPath = Join-Path "00_Constitution" "learnings.md"
    $archivePath = Join-Path "00_Constitution" "archive_learnings.md"

    if (-not (Test-Path $learningsPath)) { return }

    $lines = Get-Content $learningsPath
    if ($lines.Count -le 40) { return }

    Write-Host "🧠 Consolidation Threshold Exceeded (learnings.md > 40 lines). Activating SkillOpt Consolidation..." -ForegroundColor Cyan

    $headerSection = [System.Collections.Generic.List[string]]::new()
    $antipatternLines = [System.Collections.Generic.List[string]]::new()
    $discoveryLines = [System.Collections.Generic.List[string]]::new()

    $currentSec = $null
    foreach ($line in $lines) {
        if ($line.StartsWith("# ") -or $line -like "*This document*") {
            $headerSection.Add($line) | Out-Null
        } elseif ($line -like "*## Anti-Patterns*" -or $line -like "*## ## Anti-Patterns*") {
            $currentSec = "anti"
        } elseif ($line -like "*## Reusable Patterns*" -or $line -like "*## ## Reusable Patterns*") {
            $currentSec = "pattern"
        } else {
            if ($currentSec -eq "anti") { $antipatternLines.Add($line) | Out-Null }
            elseif ($currentSec -eq "pattern") { $discoveryLines.Add($line) | Out-Null }
            else { $headerSection.Add($line) | Out-Null }
        }
    }

    $antipatternBlocks = Parse-MarkdownBlocks -SectionLines $antipatternLines.ToArray()
    $discoveryBlocks = Parse-MarkdownBlocks -SectionLines $discoveryLines.ToArray()

    $keepCount = 5
    $archiveAnti = if ($antipatternBlocks.Count -gt $keepCount) { $antipatternBlocks.GetRange(0, $antipatternBlocks.Count - $keepCount) } else { @() }
    $keepAnti = if ($antipatternBlocks.Count -gt $keepCount) { $antipatternBlocks.GetRange($antipatternBlocks.Count - $keepCount, $keepCount) } else { $antipatternBlocks }

    $archivePat = if ($discoveryBlocks.Count -gt $keepCount) { $discoveryBlocks.GetRange(0, $discoveryBlocks.Count - $keepCount) } else { @() }
    $keepPat = if ($discoveryBlocks.Count -gt $keepCount) { $discoveryBlocks.GetRange($discoveryBlocks.Count - $keepCount, $keepCount) } else { $discoveryBlocks }

    if ($archiveAnti.Count -gt 0 -or $archivePat.Count -gt 0) {
        $iso = Get-IsoTime
        $archiveHeading = "`n### Consolidated on $iso"
        Add-Content -Path $archivePath -Value $archiveHeading -Encoding UTF8
        if ($archiveAnti.Count -gt 0) {
            Add-Content -Path $archivePath -Value "#### Archived Anti-Patterns:" -Encoding UTF8
            Add-Content -Path $archivePath -Value ($archiveAnti -join "") -Encoding UTF8
        }
        if ($archivePat.Count -gt 0) {
            Add-Content -Path $archivePath -Value "#### Archived Reusable Patterns:" -Encoding UTF8
            Add-Content -Path $archivePath -Value ($archivePat -join "") -Encoding UTF8
        }
        Write-Host "🗄️  Archived cold memories to archive_learnings.md."
    }

    # Re-write learnings.md
    $newContent = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $headerSection) { $newContent.Add($line) | Out-Null }
    $newContent.Add("`n## ## Anti-Patterns & Mistakes") | Out-Null
    if ($keepAnti.Count -gt 0) {
        foreach ($block in $keepAnti) {
            foreach ($line in ($block -split "`r`n")) {
                if ($line) { $newContent.Add($line) | Out-Null }
            }
        }
    } else {
        $newContent.Add("*(AI Checker will auto-populate this section when mistakes are identified or tasks are rejected)*") | Out-Null
    }
    $newContent.Add("`n## ## Reusable Patterns & Discoveries") | Out-Null
    if ($keepPat.Count -gt 0) {
        foreach ($block in $keepPat) {
            foreach ($line in ($block -split "`r`n")) {
                if ($line) { $newContent.Add($line) | Out-Null }
            }
        }
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
        Write-Error "Task status is '$status'. Only tasks in 'REVIEW' status can be checked."
        exit 1
    }

    # 1. SECURITY AUDIT: Check if Constitution or Roadmap was modified or if untracked files were added
    $statusOutput = Run-Git @("status", "--porcelain", "00_Constitution", "01_Roadmap")
    $gitRoot = Run-Git @("rev-parse", "--show-toplevel")
    if ($gitRoot) { $gitRoot = $gitRoot.Trim() }

    $toxicFiles = @()
    if ($statusOutput) {
        foreach ($line in ($statusOutput -split "`n")) {
            $trimmed = $line.Trim()
            if (-not $trimmed -or $trimmed.Length -lt 3) { continue }
            $file = $trimmed.Substring(2).Trim()
            
            # Resolve to absolute path
            if ($gitRoot) {
                $absPath = Join-Path $gitRoot $file
            } else {
                $absPath = Resolve-Path $file
            }
            $toxicFiles += $absPath
        }
    }

    if ($toxicFiles.Count -gt 0) {
        Write-Host "🚨 SECURITY VIOLATION: Read-only directories modified by Worker!" -ForegroundColor Red
        foreach ($tf in $toxicFiles) { Write-Host "   ↳ Toxic: $tf" -ForegroundColor Red }
        
        Write-Host "🛡️  Activating Security Defense: Reverting toxic files and removing untracked files..." -ForegroundColor Yellow
        Run-Git @("restore", "--staged") | Out-Null
        Run-Git (@("restore") + $toxicFiles) | Out-Null
        
        foreach ($tf in $toxicFiles) {
            if (Test-Path $tf) {
                if (Test-Path -Path $tf -PathType Container) {
                    Remove-Item -Path $tf -Recurse -Force | Out-Null
                } else {
                    Remove-Item -Path $tf -Force | Out-Null
                }
            }
        }

        Set-Content -Path $statusFile -Value "ESCALATED" -Encoding UTF8
        
        # Format toxic names with just their basenames
        $toxicNames = @()
        foreach ($tf in $toxicFiles) {
            $toxicNames += Split-Path $tf -Leaf
        }
        Set-Content -Path (Join-Path $taskDir "feedback.md") -Value "### Security Rejection`n- Task halted due to unauthorized modification of read-only files: $($toxicNames -join ', '). Reverted." -Encoding UTF8

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

    # ANTI-LYING CHECK: If recipe requires testing, verify structured command runs in action_log.jsonl
    $recipePath = Join-Path $taskDir "recipe.md"
    $needsTest = $false
    if (Test-Path $recipePath) {
        $recipeContent = (Get-Content $recipePath -Raw).ToLower()
        if ($recipeContent.Contains("test") -or $recipeContent.Contains("testing")) {
            $needsTest = $true
        }
    }

    if ($needsTest) {
        $hasTestTrace = $false
        if (Test-Path $logPath) {
            $logLines = Get-Content $logPath
            foreach ($line in $logLines) {
                $trimmedLine = $line.Trim()
                if (-not $trimmedLine) { continue }
                try {
                    $entry = $trimmedLine | ConvertFrom-Json
                    $tool = $entry.tool
                    if ($tool -in @("run_command", "execute", "execute_command", "run_shell_command", "shell_command")) {
                        $args = $entry.args
                        $cmdLine = ""
                        if ($args -is [PSCustomObject] -or $args -is [Hashtable]) {
                            $cmdLine = if ($args.CommandLine) { $args.CommandLine } else { $args.command }
                        } else {
                            $cmdLine = $args.ToString()
                        }
                        if ($cmdLine) {
                            $lowerCmd = $cmdLine.ToLower()
                            if ($lowerCmd.Contains("test") -or $lowerCmd.Contains("pytest") -or $lowerCmd.Contains("npm run test") -or $lowerCmd.Contains("cargo test") -or $lowerCmd.Contains("go test") -or $lowerCmd.Contains("check")) {
                                $hasTestTrace = $true
                                break
                            }
                        }
                    }
                } catch {
                    if ($trimmedLine -notlike "*case_start*" -and $trimmedLine -notlike "*case_submit*") {
                        $lowerLine = $trimmedLine.ToLower()
                        if ($lowerLine.Contains("test") -or $lowerLine.Contains("execute") -or $lowerLine.Contains("run_command")) {
                            $hasTestTrace = $true
                            break
                        }
                    }
                }
            }
        }
        if (-not $hasTestTrace) {
            Write-Host "🚨 VERIFICATION FAILED (Anti-Lying Guard): Lying detected!" -ForegroundColor Red
            Write-Host "   ↳ The recipe specifies 'test' or 'testing' requirements, but no test or command execution traces were found in action_log.jsonl." -ForegroundColor Red
            Set-Content -Path $statusFile -Value "PENDING" -Encoding UTF8
            Set-Content -Path (Join-Path $taskDir "feedback.md") -Value "### Verification Rejected (Anti-Lying)`n- The task checklist specifies testing, but action_log.jsonl contains no execution traces of tests or runtime scripts. Do not claim done without running tests." -Encoding UTF8
            exit 1
        }
    }

    Write-Host "✅ Basic file specifications & Anti-Lying traces validated." -ForegroundColor Green

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

function Case-CreateSubtask {
    param([string]$Slug, [string]$RecipeContent)
    $queueDir = "02_Task_Queue"
    if (-not (Test-Path $queueDir)) {
        Write-Error "Task queue directory '$queueDir' does not exist. Please run init first."
        exit 1
    }

    $existingTasks = Get-ChildItem -Path $queueDir -Directory -Filter "Task_*"
    $maxIdx = 0
    foreach ($task in $existingTasks) {
        $parts = $task.Name.Split("_")
        if ($parts.Count -gt 1) {
            $idx = 0
            if ([int]::TryParse($parts[1], [ref]$idx)) {
                if ($idx -gt $maxIdx) {
                    $maxIdx = $idx
                }
            }
        }
    }

    $nextIdx = $maxIdx + 1
    $newTaskId = "Task_{0:D3}_{1}" -f $nextIdx, $Slug
    $newTaskDir = Join-Path $queueDir $newTaskId

    New-Item -ItemType Directory -Path $newTaskDir | Out-Null

    Set-Content -Path (Join-Path $newTaskDir "status.txt") -Value "PENDING" -Encoding UTF8
    Set-Content -Path (Join-Path $newTaskDir "role.md") -Value "You are a specialized agent tasked with executing: $Slug." -Encoding UTF8
    Set-Content -Path (Join-Path $newTaskDir "recipe.md") -Value $RecipeContent -Encoding UTF8

    # Update Roadmap
    $roadmapPath = Join-Path "01_Roadmap" "roadmap.md"
    if (Test-Path $roadmapPath) {
        Add-Content -Path $roadmapPath -Value "`n- [ ] ${newTaskId}: $Slug (Created dynamically)" -Encoding UTF8
        Write-Host "🗺️  Updated roadmap: Added $newTaskId"
    }

    Write-Host "🎉 Sub-task '$newTaskId' successfully created in queue." -ForegroundColor Green
}

# CLI Router
if ($args.Count -lt 1) {
    Write-Host "C.A.S.E. Controller PowerShell Helper Tools"
    Write-Host "Usage:"
    Write-Host "  powershell -File .case/case.ps1 init [optional goal]"
    Write-Host "  powershell -File .case/case.ps1 start <task_id>"
    Write-Host "  powershell -File .case/case.ps1 submit <task_id> `"summary`""
    Write-Host "  powershell -File .case/case.ps1 check <task_id>"
    Write-Host "  powershell -File .case/case.ps1 create_subtask <slug> `"recipe`""
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
} elseif ($cmd -eq "create_subtask") {
    if ($args.Count -lt 2) { Write-Error "Missing slug"; exit 1 }
    $recipe = if ($args.Count -gt 2) { $args[2] } else { "No description specified." }
    Case-CreateSubtask -Slug $args[1] -RecipeContent $recipe
} else {
    Write-Host "Unknown command. Use no parameters for help."
}
