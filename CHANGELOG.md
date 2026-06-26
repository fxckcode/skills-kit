# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

- Add 6 new skills: `npm-supply-chain-security`, `verification-loop`, `go-quality`, `env-secrets-management`, `codebase-audit`, `loop-engineering`
- Update README with all 10 skills

## 0.2.0 - 2026-04-18

- Consolidate `git-setup-skill`, `swarm-forge-skill`, and `path-context-skill` into a single repository under `skills/`.
- Remove per-skill `.git/` folders so the repo has a single source of git history.
- Add top-level `LICENSE` (MIT), `.gitattributes`, and `CHANGELOG.md`.
- Update `README.md`, `CLAUDE.md`, and `AGENTS.md` to document all three skills.
- Sync `swarm-forge-skill` to include the 0.2.0 entry from its upstream source.

## 0.1.0 - 2026-03-27

- Initial skills-kit layout with `git-setup-skill` and `swarm-forge-skill` under `skills/`.
