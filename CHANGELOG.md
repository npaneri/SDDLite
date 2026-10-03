# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] — 2026-10-03

Initial release.

### Added

- `AGENTS.md` — generic, stack-agnostic agent operating rules for Spec-Driven
  Development:
  - Six non-negotiable discipline rules, including a table defining what counts
    as product code versus tooling
  - Nine-step canonical workflow with a step-gate table, precondition per command
  - The four most common step skips, named explicitly
  - Skip protocol for when a user asks to bypass a gate
  - Validation gates, with the requirements-checklist-vs-progress-tracker
    distinction called out
  - Framework-agnostic test-stack selection guidance plus two universal test laws
    (no wall-clock sleeps, fake-timer isolation)
  - Requirements-interrogation protocol, and how it differs from `/speckit.clarify`
  - Skill-usage rules, including a warning about skills that duplicate Spec Kit
    commands
  - Agent completion-reporting behaviour for integrations without `handoffs`
    support
  - An adoption checklist for tailoring the file to a real project
- `scripts/check_sdd.sh` — structural validator for SDD discipline
- `examples/001-url-shortener/` — a complete worked example (spec, plan, tasks)
- `docs/getting-started.md`, `docs/workflow.md`, `docs/adapting.md`
- `requirements.txt` pinning the Spec Kit CLI and its script dependency
- CI workflow, issue and pull-request templates, Dependabot config
- MIT license, contributing guide, code of conduct

[Unreleased]: https://github.com/npaneri/SDDLite/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/npaneri/SDDLite/releases/tag/v0.1.0