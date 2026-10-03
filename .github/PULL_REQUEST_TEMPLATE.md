## What and why

<!-- What does this change, and what failure does it prevent? -->

## Checklist

- [ ] `AGENTS.md` changes are **net neutral or shorter** (see CONTRIBUTING.md)
- [ ] Any new rule is stated imperatively and justified in one line
- [ ] Stack-specific guidance is framed as an example, not a mandate
- [ ] `scripts/check_sdd.sh` still passes `bash -n` and shellcheck
- [ ] Validator behaviour changes come with a test in `.github/workflows/ci.yml`
- [ ] Updated `CHANGELOG.md` under `[Unreleased]`
- [ ] No absolute local paths, usernames, or machine-specific details
- [ ] Docs updated if behaviour changed

## Testing

<!--
How did you verify this? For rule changes: what prompt did you try, and what
did the agent do? A rule nobody has run against a real agent is a guess.
-->

## Notes for reviewers

<!--
Anything you'd particularly like scrutinized. Rule changes are cheap to write
and hard to notice being wrong, so they deserve the scrutiny.
-->
