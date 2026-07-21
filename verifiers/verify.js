/**
 * C.A.S.E. Framework — Task Verifier (Node.js)
 * 
 * Validates a task's completeness before submission.
 * Run: node verify.js <task_folder_path>
 * 
 * Exit codes: 0 = PASS, 1 = FAIL (with reason printed to stderr)
 */

const fs = require('fs');
const path = require('path');

function verify(taskDir) {
  const errors = [];
  const warnings = [];
  let status = 'PENDING';

  // 1. Check required files exist
  const requiredFiles = ['recipe.md', 'role.md', 'status.txt', 'output.md'];
  for (const file of requiredFiles) {
    const filePath = path.join(taskDir, file);
    if (!fs.existsSync(filePath)) {
      errors.push(`Missing required file: ${file}`);
    }
  }

  // 2. Check status.txt has valid token
  const statusPath = path.join(taskDir, 'status.txt');
  if (fs.existsSync(statusPath)) {
    status = fs.readFileSync(statusPath, 'utf8').trim();
    const validStatuses = ['PENDING', 'IN_PROGRESS', 'REVIEW', 'DONE', 'ESCALATED'];
    if (!validStatuses.includes(status)) {
      errors.push(`Invalid status token: "${status}" (must be one of: ${validStatuses.join(', ')})`);
    }
  }

  // 3. Check action_log.jsonl (or fallback log.md) exists and has valid log entries
  const logPath = path.join(taskDir, 'action_log.jsonl');
  const fallbackLogPath = path.join(taskDir, 'log.md');
  if (fs.existsSync(logPath)) {
    const lines = fs.readFileSync(logPath, 'utf8').trim().split('\n').filter(l => l.trim());
    if (lines.length > 0) {
      let validLines = 0;
      for (const line of lines) {
        try {
          JSON.parse(line);
          validLines++;
        } catch {
          warnings.push(`action_log.jsonl has ${lines.length - validLines} invalid JSON line(s)`);
        }
      }
      if (validLines === 0) {
        errors.push('action_log.jsonl has no valid JSON entries');
      }
    }
  } else if (fs.existsSync(fallbackLogPath)) {
    const content = fs.readFileSync(fallbackLogPath, 'utf8').trim();
    if (content.length < 10) {
      warnings.push('log.md fallback exists but appears too short (< 10 chars)');
    }
  } else {
    warnings.push('Missing trace log: Neither action_log.jsonl nor log.md was found in task directory');
  }

  // 4. Check output.md is non-empty
  const outputPath = path.join(taskDir, 'output.md');
  if (fs.existsSync(outputPath)) {
    const content = fs.readFileSync(outputPath, 'utf8').trim();
    if (content.length < 10) {
      warnings.push('output.md appears very short (< 10 chars) — may be a placeholder');
    }
  }

  // 5. Check recipe.md has DoD section
  const recipePath = path.join(taskDir, 'recipe.md');
  if (fs.existsSync(recipePath)) {
    const recipe = fs.readFileSync(recipePath, 'utf8');
    if (!recipe.includes('## Local Definition of Done')) {
      warnings.push('recipe.md missing "## Local Definition of Done" section');
    }
    if (!recipe.includes('## Objective')) {
      warnings.push('recipe.md missing "## Objective" section');
    }
  }

  // 6. Check for ESCALATED status with feedback
  if (status === 'ESCALATED') {
    const feedbackPath = path.join(taskDir, 'feedback.md');
    if (!fs.existsSync(feedbackPath)) {
      errors.push('ESCALATED status requires feedback.md with failure details');
    }
  }

  // 7. Check planning.md exists with a Self-Review section (Section 6 step 4)
  const planningPath = path.join(taskDir, 'planning.md');
  if (!fs.existsSync(planningPath)) {
    warnings.push('Missing planning.md — Section 6 step 4 requires a plan + Self-Review before execution begins');
  } else {
    const planning = fs.readFileSync(planningPath, 'utf8');
    if (!planning.includes('## Self-Review') && !planning.includes('[R]')) {
      warnings.push('planning.md missing a Self-Review section — the plan must be reviewed against recipe.md before execution (Section 6 step 4)');
    }
  }

  // 8. Check retro.md exists with required sections when status is DONE (Section 13a)
  if (status === 'DONE') {
    const retroPath = path.join(taskDir, 'retro.md');
    if (!fs.existsSync(retroPath)) {
      errors.push('DONE status requires retro.md (Section 13a: mandatory retrospective before every DONE transition)');
    } else {
      const retro = fs.readFileSync(retroPath, 'utf8');
      for (const section of ['Gaps & Missteps', 'Optimization Opportunities', 'Lessons Learned', 'Feedback to CASE']) {
        if (!retro.includes(section)) {
          warnings.push(`retro.md missing expected section: "${section}" (Section 13a requires all four)`);
        }
      }
    }
  }

  // Report
  if (errors.length > 0) {
    console.error('❌ VERIFICATION FAILED:');
    errors.forEach(e => console.error(`  • ${e}`));
    if (warnings.length > 0) {
      console.error('\n⚠️  WARNINGS:');
      warnings.forEach(w => console.error(`  • ${w}`));
    }
    return { success: false, errors, warnings };
  }

  console.log('✅ VERIFICATION PASSED');

  // Run memory tiering automatically if status is DONE or REVIEW
  if (['DONE', 'REVIEW'].includes(status)) {
    const projectRoot = path.resolve(taskDir, '..', '..');
    let targetRoot = projectRoot;
    if (!fs.existsSync(path.join(projectRoot, '00_Constitution'))) {
      targetRoot = path.resolve(taskDir, '..');
    }
    if (fs.existsSync(path.join(targetRoot, '00_Constitution'))) {
      try {
        const { execSync } = require('child_process');
        const tieringScript = path.join(__dirname, 'memory_tiering.py');
        if (fs.existsSync(tieringScript)) {
          try {
            execSync(`python "${tieringScript}" "${targetRoot}"`, { stdio: 'inherit' });
          } catch (err) {
            execSync(`python3 "${tieringScript}" "${targetRoot}"`, { stdio: 'inherit' });
          }
        }
      } catch (ex) {
        warnings.push(`Could not run memory tiering: ${ex.message}`);
      }
    }
  }

  if (warnings.length > 0) {
    console.log('\n⚠️  WARNINGS:');
    warnings.forEach(w => console.log(`  • ${w}`));
  }
  return { success: true, errors: [], warnings };
}

// CLI entry point
if (require.main === module) {
  const taskDir = process.argv[2];
  if (!taskDir) {
    console.error('Usage: node verify.js <task_folder_path>');
    process.exit(1);
  }
  const resolved = path.resolve(taskDir);
  if (!fs.existsSync(resolved)) {
    console.error(`Error: Directory not found: ${resolved}`);
    process.exit(1);
  }
  const result = verify(resolved);
  process.exit(result.success ? 0 : 1);
}

module.exports = { verify };
