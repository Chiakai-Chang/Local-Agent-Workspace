"""Tests for the C.A.S.E. task verifier.

Zero dependencies — `python -m unittest discover -s tests` from the repo root.

These exist because of what the verifier could not say. Of its fifteen checks,
ten were warnings that leave the exit code at 0, so a task with no audit trail,
no local Definition of Done, no plan, and a one-character `output.md` printed
"VERIFICATION PASSED". The protocol's own convergence gate warns against exactly
that shape — "format passes, function missing" — and the tool that enforces the
protocol was producing it.

Three changes are covered here:

  --strict        treat warnings as failures, for callers that want the whole
                  protocol enforced. The default is untouched, so existing task
                  queues keep their exit codes.
  --tier-memory   memory tiering no longer runs as a side effect of verifying.
                  A command named `verify` must not modify `learnings.md`, and
                  running it twice must mean the same thing as running it once.
  --queue         the invariant the framework exists for — one task at a time —
                  had no check at all. verify only ever saw a single task
                  package, so two directories could sit at IN_PROGRESS
                  simultaneously and nothing would notice.
"""

import os
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "verifiers"))

import verify as V  # noqa: E402


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(text)


def make_task(root, name, status="REVIEW", complete=True):
    """A task package. `complete` decides whether the optional-but-expected
    parts exist — the ones the verifier only ever warned about."""
    d = os.path.join(root, name)
    os.makedirs(d, exist_ok=True)
    write(os.path.join(d, "status.txt"), status)
    write(os.path.join(d, "role.md"), "# Role\nWorker.\n")
    write(os.path.join(d, "output.md"), "A real deliverable with enough text to count.\n")
    recipe = "# Recipe\n## Objective\nDo the thing.\n"
    if complete:
        recipe += "## Local Definition of Done\n- it is done\n"
    write(os.path.join(d, "recipe.md"), recipe)
    if complete:
        write(os.path.join(d, "planning.md"), "# Plan\n## Self-Review\nChecked against recipe.\n")
        write(os.path.join(d, "action_log.jsonl"), '{"tool":"write","path":"output.md"}\n')
        write(os.path.join(d, "retro.md"),
              "# Retro\n## Gaps & Missteps\n-\n## Optimization Opportunities\n-\n"
              "## Lessons Learned\n-\n## Feedback to CASE\n-\n")
    return d


class TestStrictMode(unittest.TestCase):
    """Warnings that cannot fail are how a protocol gets followed in name only."""

    def setUp(self):
        self.root = tempfile.mkdtemp(prefix="case-verify-")
        self.addCleanup(shutil.rmtree, self.root, ignore_errors=True)

    def test_a_task_missing_everything_optional_still_passes_by_default(self):
        """Backward compatibility: existing queues must not break."""
        d = make_task(self.root, "Task_001_Thing", complete=False)
        self.assertTrue(V.verify(d)["success"])

    def test_the_same_task_fails_under_strict(self):
        d = make_task(self.root, "Task_001_Thing", complete=False)
        result = V.verify(d, strict=True)
        self.assertFalse(result["success"])
        joined = " ".join(result["errors"])
        self.assertIn("Definition of Done", joined)

    def test_a_complete_task_passes_under_strict(self):
        d = make_task(self.root, "Task_001_Thing", complete=True)
        result = V.verify(d, strict=True)
        self.assertTrue(result["success"], result["errors"])

    def test_strict_reports_the_missing_audit_trail(self):
        """The audit trail was a warning, which made it optional in practice."""
        d = make_task(self.root, "Task_001_Thing", complete=True)
        os.remove(os.path.join(d, "action_log.jsonl"))
        result = V.verify(d, strict=True)
        self.assertFalse(result["success"])
        self.assertTrue(any("trace log" in e for e in result["errors"]), result["errors"])


class TestVerifyDoesNotModifyAnything(unittest.TestCase):
    """A command called `verify` that rewrites learnings.md is a surprise, and
    it makes verification non-idempotent."""

    def setUp(self):
        self.root = tempfile.mkdtemp(prefix="case-verify-")
        self.addCleanup(shutil.rmtree, self.root, ignore_errors=True)
        os.makedirs(os.path.join(self.root, "00_Constitution"), exist_ok=True)
        self.learnings = os.path.join(self.root, "00_Constitution", "learnings.md")
        write(self.learnings, "# Learnings\n- one\n")
        self.queue = os.path.join(self.root, "02_Task_Queue")
        os.makedirs(self.queue, exist_ok=True)

    def test_verifying_a_done_task_leaves_learnings_untouched(self):
        d = make_task(self.queue, "Task_001_Thing", status="DONE")
        before = open(self.learnings, encoding="utf-8").read()
        V.verify(d)
        self.assertEqual(open(self.learnings, encoding="utf-8").read(), before)

    def test_tiering_still_available_behind_a_flag(self):
        d = make_task(self.queue, "Task_001_Thing", status="DONE")
        result = V.verify(d, tier_memory=True)
        self.assertTrue(result["success"], result["errors"])


class TestQueueInvariants(unittest.TestCase):
    """One task at a time is the promise the framework is built on, and nothing
    checked it: verify only ever looked at one task package."""

    def setUp(self):
        self.queue = tempfile.mkdtemp(prefix="case-queue-")
        self.addCleanup(shutil.rmtree, self.queue, ignore_errors=True)

    def test_one_in_progress_is_fine(self):
        make_task(self.queue, "Task_001_A", status="DONE")
        make_task(self.queue, "Task_002_B", status="IN_PROGRESS")
        make_task(self.queue, "Task_003_C", status="PENDING")
        self.assertTrue(V.verify_queue(self.queue)["success"])

    def test_two_in_progress_is_the_failure_this_exists_for(self):
        make_task(self.queue, "Task_001_A", status="IN_PROGRESS")
        make_task(self.queue, "Task_002_B", status="IN_PROGRESS")
        result = V.verify_queue(self.queue)
        self.assertFalse(result["success"])
        self.assertTrue(any("IN_PROGRESS" in e for e in result["errors"]), result["errors"])

    def test_an_empty_queue_is_not_an_error(self):
        self.assertTrue(V.verify_queue(self.queue)["success"])

    def test_finishing_out_of_order_warns_by_default_and_fails_under_strict(self):
        make_task(self.queue, "Task_001_A", status="PENDING")
        make_task(self.queue, "Task_002_B", status="DONE")
        loose = V.verify_queue(self.queue)
        self.assertTrue(loose["success"])
        self.assertTrue(any("out of order" in w.lower() for w in loose["warnings"]), loose["warnings"])
        self.assertFalse(V.verify_queue(self.queue, strict=True)["success"])

    def test_an_unreadable_status_is_reported_not_ignored(self):
        d = make_task(self.queue, "Task_001_A", status="PENDING")
        os.remove(os.path.join(d, "status.txt"))
        result = V.verify_queue(self.queue)
        self.assertFalse(result["success"])
        self.assertTrue(any("status.txt" in e for e in result["errors"]), result["errors"])

    def test_a_bad_status_token_is_caught_at_queue_level_too(self):
        make_task(self.queue, "Task_001_A", status="FINISHED")
        result = V.verify_queue(self.queue)
        self.assertFalse(result["success"])

    def test_directories_that_are_not_task_packages_are_skipped(self):
        os.makedirs(os.path.join(self.queue, "_archive"), exist_ok=True)
        make_task(self.queue, "Task_001_A", status="DONE")
        self.assertTrue(V.verify_queue(self.queue)["success"])


def node_available():
    return shutil.which("node") is not None


@unittest.skipUnless(node_available(), "node not installed")
class TestBothVerifiersAgree(unittest.TestCase):
    """A verifier that lags the protocol lets every new mandatory step go
    silently unchecked, and there are two of them.

    Comparing exit codes rather than output: the two are allowed to word things
    differently, but they must never disagree about whether a task passes.
    """

    def setUp(self):
        self.root = tempfile.mkdtemp(prefix="case-parity-")
        self.addCleanup(shutil.rmtree, self.root, ignore_errors=True)
        self.js = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                               "verifiers", "verify.js")

    def js_exit(self, *args):
        import subprocess
        return subprocess.run(["node", self.js, *args], capture_output=True,
                              text=True, encoding="utf-8", errors="replace",
                              timeout=120).returncode

    def py_exit(self, *args):
        return V.main(list(args))

    def assert_agree(self, *args):
        self.assertEqual(self.py_exit(*args), self.js_exit(*args),
                         "python and node verifiers disagree on: %s" % (args,))

    def test_a_complete_task_agrees(self):
        d = make_task(self.root, "Task_001_A", complete=True)
        self.assert_agree(d)
        self.assert_agree(d, "--strict")

    def test_an_incomplete_task_agrees_in_both_modes(self):
        d = make_task(self.root, "Task_001_A", complete=False)
        self.assert_agree(d)
        self.assert_agree(d, "--strict")

    def test_queue_mode_agrees(self):
        q = os.path.join(self.root, "02_Task_Queue")
        make_task(q, "Task_001_A", status="IN_PROGRESS")
        make_task(q, "Task_002_B", status="IN_PROGRESS")
        self.assert_agree("--queue", q)

    def test_out_of_order_queue_agrees_in_both_modes(self):
        q = os.path.join(self.root, "02_Task_Queue")
        make_task(q, "Task_001_A", status="PENDING")
        make_task(q, "Task_002_B", status="DONE")
        self.assert_agree("--queue", q)
        self.assert_agree("--queue", q, "--strict")


if __name__ == "__main__":
    unittest.main()
