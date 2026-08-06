/**
 * C.A.S.E. Framework — Task Verifier (Node.js)
 *
 * Validates a task's completeness before submission.
 *
 * Run:
 *   node verify.js <task_folder_path> [--strict] [--tier-memory]
 *   node verify.js --queue <02_Task_Queue_path> [--strict]
 *
 * Exit codes: 0 = PASS, 1 = FAIL (with reason printed to stderr)
 *
 *   --strict        Treat warnings as errors. Ten of the fifteen checks were
 *                   warnings, so a task with no audit trail, no local
 *                   Definition of Done, no plan and a one-character output.md
 *                   printed "VERIFICATION PASSED" — the "format passes,
 *                   function missing" shape the protocol's own convergence gate
 *                   warns against. The default stays permissive so existing
 *                   queues keep their exit codes.
 *   --tier-memory   Run memory tiering after a successful task verification. It
 *                   used to run automatically on DONE or REVIEW, so a command
 *                   named `verify` rewrote 00_Constitution/learnings.md as a
 *                   side effect and could not be run twice for one answer.
 *   --queue         Check invariants that span the queue: at most one task
 *                   IN_PROGRESS, and tasks finished in order. "One task at a
 *                   time" is what the queue is for, and nothing checked it.
 *
 * Kept in step with verifiers/verify.py on purpose: a verifier that lags the
 * protocol lets every new mandatory step go silently unchecked.
 */

const fs = require('fs');
const path = require('path');

const VALID_STATUSES = ['PENDING', 'IN_PROGRESS', 'REVIEW', 'DONE', 'ESCALATED'];
const TASK_DIR_RE = /^Task_(\d+)_/;

/**
 * Print the outcome and return the result object.
 *
 * Shared by verify() and verifyQueue() so the two cannot drift into printing
 * different things for the same condition.
 */
function report(errors, warnings, okMessage) {
  if (errors.length > 0) {
    console.error('❌ VERIFICATION FAILED:');
    errors.forEach(e => console.error(`  • ${e}`));
    if (warnings.length > 0) {
      console.error('\n⚠️  WARNINGS:');
      warnings.forEach(w => console.error(`  • ${w}`));
    }
    return { success: false, errors, warnings };
  }
  console.log(okMessage);
  if (warnings.length > 0) {
    console.log('\n⚠️  WARNINGS:');
    warnings.forEach(w => console.log(`  • ${w}`));
  }
  return { success: true, errors: [], warnings };
}

/**
 * Check what only exists across the whole queue.
 *
 * A task package can be perfect on its own while the queue around it is not
 * being worked one task at a time. Directories that are not task packages are
 * skipped rather than reported — the queue folder may hold other things.
 */
function verifyQueue(queueDir, options = {}) {
  const strict = !!options.strict;
  const errors = [];
  let warnings = [];
  const tasks = [];

  if (!fs.existsSync(queueDir) || !fs.statSync(queueDir).isDirectory()) {
    return report([`Queue directory not found: ${queueDir}`], [], '');
  }

  for (const name of fs.readdirSync(queueDir).sort()) {
    const full = path.join(queueDir, name);
    const m = TASK_DIR_RE.exec(name);
    if (!m || !fs.statSync(full).isDirectory()) continue;
    const statusPath = path.join(full, 'status.txt');
    if (!fs.existsSync(statusPath)) {
      errors.push(`${name}: missing status.txt — the queue cannot be read without it`);
      continue;
    }
    const status = fs.readFileSync(statusPath, 'utf8').trim();
    if (!VALID_STATUSES.includes(status)) {
      errors.push(`${name}: invalid status token "${status}" `
        + `(must be one of: ${VALID_STATUSES.join(', ')})`);
      continue;
    }
    tasks.push({ index: parseInt(m[1], 10), name, status });
  }

  const active = tasks.filter(t => t.status === 'IN_PROGRESS').map(t => t.name);
  if (active.length > 1) {
    errors.push(`More than one task is IN_PROGRESS (${active.join(', ')}) `
      + '— the queue is worked one task at a time');
  }

  // Finishing out of order is legitimate when tasks are genuinely independent,
  // so it warns by default and fails for callers who want the order to mean
  // something.
  for (const t of tasks) {
    if (t.status !== 'DONE') continue;
    const earlier = tasks.filter(o => o.index < t.index && o.status !== 'DONE').map(o => o.name);
    if (earlier.length > 0) {
      warnings.push(`${t.name} is DONE out of order — still open before it: ${earlier.join(', ')}`);
    }
  }

  if (strict && warnings.length > 0) {
    errors.push(...warnings);
    warnings = [];
  }

  return report(errors, warnings, `✅ QUEUE VERIFICATION PASSED (${tasks.length} task(s))`);
}

function verify(taskDir, options = {}) {
  const strict = !!options.strict;
  const tierMemory = !!options.tierMemory;
  const errors = [];
  let warnings = [];
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
    if (!VALID_STATUSES.includes(status)) {
      errors.push(`Invalid status token: "${status}" (must be one of: ${VALID_STATUSES.join(', ')})`);
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

  // Under --strict every check counts. The split between "error" and "warning"
  // was never about severity — a missing audit trail is not a lesser problem
  // than a missing file — it was about not breaking queues that predate each
  // new rule.
  if (strict && warnings.length > 0) {
    errors.push(...warnings);
    warnings = [];
  }

  const result = report(errors, warnings, '✅ VERIFICATION PASSED');
  if (!result.success) return result;

  // Only when asked. This used to run on every DONE or REVIEW verification, so
  // `verify` rewrote 00_Constitution/learnings.md without being asked to.
  if (tierMemory && ['DONE', 'REVIEW'].includes(status)) {
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
        console.log(`  • Could not run memory tiering: ${ex.message}`);
        result.warnings.push(`Could not run memory tiering: ${ex.message}`);
      }
    }
  }

  return result;
}

// CLI entry point
if (require.main === module) {
  const argv = process.argv.slice(2);
  const strict = argv.includes('--strict');
  const tierMemory = argv.includes('--tier-memory');
  const queueMode = argv.includes('--queue');
  const target = argv.find(a => !a.startsWith('--'));

  if (!target) {
    console.error('Usage: node verify.js <task_folder_path> [--strict] [--tier-memory]');
    console.error('       node verify.js --queue <02_Task_Queue_path> [--strict]');
    process.exit(1);
  }
  const resolved = path.resolve(target);
  if (!fs.existsSync(resolved)) {
    console.error(`Error: Directory not found: ${resolved}`);
    process.exit(1);
  }
  const result = queueMode
    ? verifyQueue(resolved, { strict })
    : verify(resolved, { strict, tierMemory });
  process.exit(result.success ? 0 : 1);
}

module.exports = { verify, verifyQueue };
