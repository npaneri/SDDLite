#!/usr/bin/env bash
#
# check_sdd.sh — structural validator for Spec-Driven Development discipline.
#
# Usage:
#   ./scripts/check_sdd.sh [path/to/project]
#
# Exit codes:
#   0  all checks passed (or only warnings)
#   1  at least one check failed
#   2  bad usage / target not found
#
# This inspects STRUCTURE, not semantics. It cannot tell you whether your spec
# is any good. It can tell you whether you have one -- which is the failure mode
# that actually bites.

set -uo pipefail

RED=$'\033[0;31m'; YEL=$'\033[0;33m'; GRN=$'\033[0;32m'; DIM=$'\033[2m'; BLD=$'\033[1m'; RST=$'\033[0m'
if [ ! -t 1 ]; then RED=""; YEL=""; GRN=""; DIM=""; BLD=""; RST=""; fi

FAILURES=0
WARNINGS=0

fail() { printf '  %sFAIL%s  %s\n' "$RED" "$RST" "$1"; FAILURES=$((FAILURES + 1)); }
warn() { printf '  %sWARN%s  %s\n' "$YEL" "$RST" "$1"; WARNINGS=$((WARNINGS + 1)); }
pass() { printf '  %sPASS%s  %s\n' "$GRN" "$RST" "$1"; }
skip() { printf '  %sSKIP%s  %s\n' "$DIM" "$RST" "$1"; }
head_() { printf '\n%s%s%s\n' "$BLD" "$1" "$RST"; }

target="${1:-.}"
if [ ! -d "$target" ]; then
	printf 'error: not a directory: %s\n' "$target" >&2
	exit 2
fi
root="$(cd "$target" && pwd)"

printf '%sSDDLite check%s  %s\n' "$BLD" "$RST" "$root"

# ---------------------------------------------------------------------------
head_ "Spec Kit machinery"

if [ -d "$root/.specify" ]; then
	pass ".specify/ present"
else
	fail ".specify/ missing -- run: specify init <name> --integration <agent>"
fi

# Prefer the CLI's own opinion over our guesses.
if command -v specify >/dev/null 2>&1; then
		if status_out="$(cd "$root" && specify integration status 2>&1)"; then
			# Spec Kit reports OK / WARNING / ERROR. WARNING is usually just
			# locally-modified managed files, which is benign and common.
			if printf '%s' "$status_out" | grep -qi 'Integration status: OK'; then
				pass "specify integration status: OK"
			elif printf '%s' "$status_out" | grep -qi 'Integration status: WARNING'; then
				warn "specify integration status: WARNING -- run 'specify integration status' for detail"
			else
				fail "specify integration status is not OK -- run 'specify integration status'"
			fi
			if printf '%s' "$status_out" | grep -qi 'missing managed files: 0'; then
				pass "no missing managed files"
			else
				fail "managed files are missing -- run 'specify integration upgrade <key>'"
			fi
			if printf '%s' "$status_out" | grep -qi 'modified managed files: 0'; then
				pass "no modified managed files"
			else
				warn "managed files have local modifications (expected if you stripped frontmatter your agent ignores)"
			fi
		else
			warn "'specify integration status' failed; skipping integration checks"
		fi
	else
		skip "'specify' CLI not on PATH -- integration checks skipped"
	fi

# ---------------------------------------------------------------------------
head_ "Command files"

cmd_dirs=0
for d in .opencode/commands .claude/commands .github/prompts .cursor/commands .specify/commands; do
	if [ -d "$root/$d" ]; then
		n=$(find "$root/$d" -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
		if [ "$n" -gt 0 ]; then
			pass "$d/ has $n command file(s)"
			cmd_dirs=$((cmd_dirs + 1))
		fi
	fi
done
if [ "$cmd_dirs" -eq 0 ]; then
	warn "no agent command files found -- has 'specify init' installed an integration?"
fi

# ---------------------------------------------------------------------------
head_ "Features"

specs_dir="$root/specs"
if [ ! -d "$specs_dir" ]; then
	skip "no specs/ directory yet (normal before the first feature)"
else
	feature_dirs=$(find "$specs_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
	if [ -z "$feature_dirs" ]; then
		skip "specs/ exists but is empty (normal before the first feature)"
	else
		count=0
		while IFS= read -r fd; do
			[ -z "$fd" ] && continue
			count=$((count + 1))
			name="$(basename "$fd")"
			if [ -f "$fd/spec.md" ]; then
				pass "$name/spec.md exists"
				missing=""
				for section in "User Scenarios" "Requirements" "Success Criteria"; do
					grep -qi "^## .*$section" "$fd/spec.md" 2>/dev/null || missing="$missing '$section'"
				done
				if [ -n "$missing" ]; then
					warn "$name/spec.md is missing mandatory section(s):$missing"
				else
					pass "$name/spec.md has all mandatory sections"
				fi
			else
				fail "$name/ has no spec.md"
			fi
			if [ -f "$fd/tasks.md" ] && [ ! -f "$fd/plan.md" ]; then
				fail "$name/ has tasks.md but no plan.md -- tasks must derive from a plan"
			fi
		done <<<"$feature_dirs"
		pass "$count feature director(ies) inspected"
	fi
fi

# ---------------------------------------------------------------------------
head_ "Code-vs-spec drift"

# Heuristic set of directories that indicate real product code.
code_dirs=$(find "$root" -maxdepth 2 -type d \
	-name src -o -maxdepth 2 -type d -name app -o -maxdepth 2 -type d -name lib \
	-o -maxdepth 2 -type d -name backend -o -maxdepth 2 -type d -name frontend \
	-o -maxdepth 2 -type d -name server -o -maxdepth 2 -type d -name api \
	2>/dev/null | grep -v '/node_modules/' | grep -v '/.venv/' | grep -v '/examples/' || true)

has_code=0
for cd in $code_dirs; do
	# only count if it actually contains files
	if [ -n "$(find "$cd" -type f \( -name '*.py' -o -name '*.ts' -o -name '*.tsx' \
		-o -name '*.js' -o -name '*.jsx' -o -name '*.go' -o -name '*.rs' \
		-o -name '*.java' -o -name '*.rb' \) 2>/dev/null | head -1)" ]; then
		has_code=1
		break
	fi
done

has_spec=0
if [ -d "$specs_dir" ] && [ -n "$(find "$specs_dir" -name 'spec.md' -type f 2>/dev/null | head -1)" ]; then
	has_spec=1
fi

if [ "$has_code" -eq 1 ] && [ "$has_spec" -eq 0 ]; then
	fail "product code exists but no spec.md anywhere -- this is THE drift failure.
       Write a spec and reconcile the code with it, or delete the code."
elif [ "$has_code" -eq 1 ]; then
	pass "product code has at least one spec to trace back to"
else
	skip "no product source detected (normal at the start)"
fi

# ---------------------------------------------------------------------------
head_ "Version control"

if [ -d "$root/.git" ]; then
	pass "git repository"

	branch=$(cd "$root" && git symbolic-ref --short HEAD 2>/dev/null || true)
	if [ -z "$branch" ]; then
		branch="(detached or unknown)"
	fi
	if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
		if [ "$has_code" -eq 1 ] && [ "$has_spec" -eq 0 ]; then
			fail "on '$branch' with code but no spec"
		else
			warn "on '$branch' -- SDD prefers feature branches (001-<slug>) for implementation"
		fi
	else
		pass "on branch '$branch'"
	fi

	# Secrets are the one failure worth failing the build over.
	tracked=$(cd "$root" && git ls-files 2>/dev/null | grep -Ei '(^|/)(\.env|\.env\..*|.*\.pem|.*\.key|credentials\.json|secrets?\.(ya?ml|json))$' | grep -v '\.example$' || true)
	if [ -n "$tracked" ]; then
		fail "possible secrets are tracked in git:"
		printf '%s\n' "$tracked" | sed 's/^/          /'
	else
		pass "no obvious secret files tracked"
	fi
else
	skip "not a git repository -- SDD relies on per-feature branches and history"
fi

# ---------------------------------------------------------------------------
printf '\n%sSummary%s  %s failed, %s warning(s)\n' "$BLD" "$RST" "$FAILURES" "$WARNINGS"
if [ "$FAILURES" -gt 0 ]; then
	printf '\n%sSDD discipline is not holding.%s Fix the failures above, or amend the spec\n' "$RED" "$RST"
	printf 'to match what you actually built -- then re-run.\n'
	exit 1
fi
printf '%sStructure looks sound.%s Reminder: this checks structure, not spec quality.\n' "$GRN" "$RST"
exit 0