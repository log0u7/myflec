# ~/.bashrc.d/opencode.bash
# opencode - AI coding agent (https://opencode.ai)
#
# Purpose: environment defaults for the opencode-workflow-guard and
# opencode-worktree-guard plugins. Sane defaults: caller-provided values
# win. Everything is guarded by `command -v opencode`: without the
# binary, the module is a no-op.

if command -v opencode >/dev/null 2>&1; then
	# workflow-guard: skip the secondary review gate on PR creation (solo work).
	export WORKFLOW_GUARD_REQUIRE_REVIEW="${WORKFLOW_GUARD_REQUIRE_REVIEW:-0}"

	# worktree-guard: protected branches (sessions on these bypass the
	# bootstrap gate; worktree_done reconciles against them).
	export OPENCODE_WORKTREE_GUARD_MAIN_BRANCHES="${OPENCODE_WORKTREE_GUARD_MAIN_BRANCHES:-main}"

	# Emergency escape: uncomment to suspend worktree-guard enforcement.
	# export OPENCODE_WORKTREE_GUARD_DISABLE=1
fi
