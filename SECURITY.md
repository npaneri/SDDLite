# Security Policy

## Scope

SDDLite is a set of Markdown files and one shell script. There is very little to
attack, and the honest summary is what that means.

**In scope:**

- `scripts/check_sdd.sh` — the only executable code
- `AGENTS.md` and `docs/` — these instruct an AI agent. Content that makes an
  agent exfiltrate data, disable safety behaviour, or ignore the user's actual
  intent is a security issue, because the agent is the execution surface.

**Out of scope:**

- Vulnerabilities in [GitHub Spec Kit](https://github.com/github/spec-kit), the
  `specify` CLI, or any agent. Report those upstream.
- Generated `.specify/` directories in projects using this template.

## Reporting a vulnerability

Use GitHub's private vulnerability reporting, or open a public issue if private
reporting is unavailable. Please do not include a working exploit in a public
issue.

Expect an acknowledgement within a few days. Include: what the content does, which
file, and the agent behaviour it provokes.

## What is *not* a vulnerability

**Instructions that constrain an agent.** The entire purpose of this project is
to tell agents not to write code before a spec exists. That is intended.

**Content in `examples/`.** The URL shortener spec describes a deliberately
minimal service with no auth by design. It is not a deployment target.

**`check_sdd.sh` reading a repository you point it at.** It reads files and runs
`git ls-files`; it does not execute anything from the target project, and it does
not follow symlinks out of the tree.

## Hardening notes for users

`check_sdd.sh` shells out to `specify integration status` when the CLI is on
`PATH`. That call executes the Spec Kit CLI in the target directory. Only run the
validator on repositories you trust — the same reason you would not run an
unknown project's install script.