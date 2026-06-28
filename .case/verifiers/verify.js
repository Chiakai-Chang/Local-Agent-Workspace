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
    const status = fs.readFileSync(statusPath, 'utf8').trim();
    const validStatuses = ['PENDING', 'IN_PROGRESS', 'REVIEW', 'DONE', 'ESCALATED'];
    if (!validStatuses.includes(status)) {
      errors.push(`Invalid status token: "${status}" (must be one of: ${validStatuses.join(', ')})`);
    }
  }

  // 3. Check action_log.jsonl exists and has valid JSON lines
  const logPath = path.join(taskDir, 'action_log.jsonl');
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
  if (fs.existsSync(statusPath)) {
    const status = fs.readFileSync(statusPath, 'utf8').trim();
    if (status === 'ESCALATED') {
      const feedbackPath = path.join(taskDir, 'feedback.md');
      if (!fs.existsSync(feedbackPath)) {
        errors.push('ESCALATED status requires feedback.md with failure details');
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
