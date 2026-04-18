# Workflow

## Contents

- Inspect before proposing
- Identify the project type
- Detect gaps and risks
- Ask only what cannot be inferred
- Decide in layers
- Write without risky overwrites
- Report like an advisor, not a blind generator
- Quick decision rules

Recommended operational flow for using this skill with professional judgment.

## 1. Inspect before proposing

Review:

- repository structure
- language and runtime
- package manager
- real scripts and commands
- existing setup files
- presence of `.github/`, `README.md`, `LICENSE`, `CHANGELOG.md`

## 2. Identify the project type

Classify the repo as one of:

- library or SDK
- app or service
- CLI
- template or boilerplate
- internal repository
- educational or demo project

This classification changes the README, license, metadata, and release recommendations.

## 3. Detect gaps and risks

Ask yourself:

- is documentation missing or just weak
- is a license needed, or should the repo stay closed
- are there enough commands for CI
- are there signals of external community use
- do releases make sense yet, or is it still too early

## 4. Ask only what cannot be inferred

Legitimate common questions:

- project goal and audience
- desired license when there is uncertainty
- test/build commands if they cannot be detected
- whether they want CI, releases, or both
- whether they want `CODE_OF_CONDUCT.md` and `SECURITY.md`

## 5. Decide in layers

### Minimum layer

- `.gitignore`
- `.gitattributes`
- `README.md`
- license or license recommendation

### Professional layer

- CI
- repository metadata
- `CONTRIBUTING.md`
- community health files

### Distribution layer

- changelog
- tags
- releases
- release automation

## 6. Write without risky overwrites

- always review existing content
- merge by section when a file already has value
- avoid deleting user decisions
- mark assumptions and follow-ups

## 7. Report like an advisor, not a blind generator

At the end, report:

- files created
- files updated
- files skipped and why
- key decisions and reasoning
- assumptions
- next steps

## Quick decision rules

- license:
  - `MIT` for simplicity
  - `Apache-2.0` for patent protection or business context
  - `GPL-3.0` only with a clear copyleft preference
- CI:
  - only with real commands
- releases:
  - only if there is a versioning strategy
- metadata:
  - whenever the repo will live on GitHub with meaningful visibility
