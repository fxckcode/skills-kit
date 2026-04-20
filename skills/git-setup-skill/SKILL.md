---
name: git-setup-skill
description: >
  Prepares Git/GitHub repositories with .gitignore, .gitattributes, README files, licensing, metadata, tags, releases, and GitHub Actions. Use when the user wants to set up or professionalize a repository, add documentation or licensing, configure CI, or prepare releases and repo metadata.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Git Repo Setup

Use this skill when the user wants to professionalize a Git/GitHub repository. The skill should inspect before writing, infer as much as possible from the repo, and behave like a technical advisor: not just generating files, but recommending decisions with clear reasoning.

## What This Skill Owns

- Inspecting the repo before proposing changes
- Classifying the project type: library, app, CLI, template, internal repo, or demo
- Creating or refining `.gitignore` and `.gitattributes`
- Generating or improving `README.md` with useful content
- Recommending and adding an appropriate license
- Configuring repository metadata: description, topics, and homepage when relevant
- Configuring GitHub Actions for CI and releases when they make sense
- Evaluating community health files such as `CODE_OF_CONDUCT.md`, `SECURITY.md`, and issue/PR templates
- Guiding tags and releases with `git` and `gh`

## Primary Use Cases

- "I need a good .gitignore and README"
- "set up GitHub Actions for tests"
- "I want professional releases and tags"
- "add a license and description to the repo"
- "let's make this repo GitHub-ready"
- "prepare this repo for open source"

## Workflow

For full repository setups, follow this checklist:

- Inspect the repository structure
- Identify project type and maturity
- Detect stack, language, runtime, test runner, and package manager
- Review existing files: `README.md`, `.gitignore`, `.gitattributes`, `.github/`, `LICENSE`, `CHANGELOG.md`
- Confirm project purpose, audience, and expected visibility if that cannot be inferred
- Choose a license based on reasoning, not popularity
- Draft or refine the README with sections that match the project type
- Define GitHub Actions only with real commands from the repo
- Configure repository metadata aligned with the README and intended use
- Evaluate community health files if the project is likely to receive external collaboration
- Define a tags and releases strategy only when appropriate
- Report changes, decisions, assumptions, and open follow-ups

## Required Questions

Ask only when the answer cannot be inferred:

- What the project does and who it is for
- Language/runtime and test/build commands
- Desired license type when there is uncertainty
- Whether the user wants CI, release automation, or both
- Initial version and release strategy
- Whether `CODE_OF_CONDUCT.md` or `SECURITY.md` should be created

Ask explicitly if you detect:

- potential need for non-trivial licenses such as `AGPL`, `LGPL`, `MPL`, dual licensing, or non-open-source licenses
- corporate, academic, or client context that may require legal approval
- a monorepo or structure where it is unclear whether there should be one workflow or several

## Writing Rules

- Never overwrite user files without reviewing their contents
- Prefer section merges for README and existing docs
- If the stack is unclear, ask for confirmation
- Avoid placeholders when the repo already provides real facts
- If something is an assumption, label it as such
- Do not invent `lint`, `test`, or `build` commands
- Do not default to `MIT` mechanically if there is enterprise context, patent sensitivity, or a clear copyleft preference
- Do not add generic `SECURITY.md` or community files if nobody will maintain them
- Do not create release automation if there is no release strategy yet

## File Strategy

Use this section for defaults only. For deeper decision-making, read the relevant file under `references/`.

### `.gitignore`

- Base it on the detected language, framework, and tooling
- Include build folders, caches, and local-only files
- Avoid ignoring configuration files the project actually needs
- Remember that team-wide ignores belong in `.gitignore`, while personal ignores can go in `.git/info/exclude` or a global ignore file

### `.gitattributes`

- Use `text=auto eol=lf` as a good cross-platform default
- Mark binaries and files that need special normalization
- Adjust `eol` by file type if the repo is strongly Windows-centric
- Add `linguist-*` rules only when the repository truly needs them

### `README.md`

Include minimum sections:

- Clear summary
- Features or use cases
- Install / setup
- Usage
- Testing
- License

Then adapt by project type:

- library: short usage example
- CLI/app: run command and requirements
- template: what the user must customize
- internal repo: onboarding and operational conventions

### `LICENSE`

- Use the correct template for the chosen license
- Add `year` and `copyright holder` when the user specifies them or they can be inferred with high confidence
- If there is no license and the repo will be public, explain that the code is not automatically reusable
- Recommend:
  - `MIT` for simplicity and adoption
  - `Apache-2.0` when explicit patent protection is useful
  - `GPL-3.0` only when there is a clear copyleft preference
- If the legal case is ambiguous, escalate to the user instead of assuming

### GitHub Actions

- CI: push and pull request using real commands
- Release: tag + `gh release create` or a tag-triggered workflow when appropriate
- Use cache according to the actual package manager
- Set minimal `permissions`
- Separate CI and release workflows when both exist
- Avoid unnecessary matrices and avoid `pull_request_target` unless there is a clear need

### Repo Metadata

- Define a short description and useful topics
- Keep the README aligned with the description
- Use 3 to 8 truthful, specific topics
- Consider homepage and community health files if the repo will be externally visible

## GH CLI Guidance

When the user wants metadata or releases, use `gh`:

- `gh repo edit --description "..." --add-topic "..."`
- `gh repo edit --homepage "https://..."`
- `gh release create vX.Y.Z --generate-notes`

Avoid destructive or forceful git operations.

## When To Read References

- `references/triggers.md` for activation phrases
- `references/workflow.md` for the base operational flow
- `references/templates.md` for reusable snippets and quality criteria
- `references/github-actions.md` for CI, security, and release automation
- `references/releases.md` for tags and versioning
- `references/licenses.md` for license selection with real tradeoffs
- `references/repo-metadata.md` for description, topics, and community health files
- `references/testing.md` for validating the quality of the skill

Use these references as decision guides, not just as a checklist.

## Success Criteria

- Baseline files are created or improved without risky overwrites
- The README is clear, actionable, and aligned with the project
- CI works for the actual stack
- The license is correct or the recommendation is well justified
- Repository metadata is aligned with the project
- Recommendations are justified when tradeoffs exist
- Nothing important is invented or assumed without being marked

## Output Expectations

At the end, report:

- files created
- files updated
- files skipped
- key decisions: license, CI, releases, and metadata
- assumptions and follow-ups for the user
