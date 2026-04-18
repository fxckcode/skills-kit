# github-setup-skill

[![Release](https://img.shields.io/github/v/release/fxckcode/github-setup-skill?sort=semver)](https://github.com/fxckcode/github-setup-skill/releases)
[![License](https://img.shields.io/github/license/fxckcode/github-setup-skill)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/fxckcode/github-setup-skill)](https://github.com/fxckcode/github-setup-skill/commits/main)

Current version: v0.1.0

Expert skill for professional Git/GitHub repository setup: `.gitignore`, `.gitattributes`, value-driven README files, licensing, repository metadata, tags and releases, and production-quality GitHub Actions with testing.

## Purpose

This skill replaces ad-hoc setup with a guided workflow that:

- inspects the repo before writing
- asks only for what cannot be inferred
- creates or refines high-quality baseline files
- adds GitHub Actions automation
- establishes clear rules for tags and releases

## Skill Files

- `SKILL.md`
- `references/triggers.md`
- `references/workflow.md`
- `references/templates.md`
- `references/github-actions.md`
- `references/releases.md`
- `references/licenses.md`
- `references/repo-metadata.md`
- `references/testing.md`
- `scripts/README.md`

## Install

Copy this folder into your skills directory. Example:

```bash
cp -R git-setup-skill "$HOME/.agents/skills/git-setup-skill"
```

## Usage

Typical trigger phrases:

- "I need a good .gitignore"
- "I want a README with real value"
- "set up GitHub Actions"
- "prepare releases and tags"
- "add a license to the repository"

## What it produces

- `.gitignore` and `.gitattributes` tailored to the stack
- `README.md` with useful sections
- `LICENSE` matched to the licensing strategy
- `CODE_OF_CONDUCT.md` / `SECURITY.md` when appropriate
- GitHub Actions workflows for CI and releases
- repository metadata such as description and topics

## Compatibility

- Requires `git` and `gh` for metadata and release tasks.
- On Windows, use a shell compatible with `bash` if scripts are added later.

## Contributing

See `CONTRIBUTING.md`.
