# Repo Metadata

## Contents

- Minimum elements
- Description
- Topics
- Alignment with README
- Related community health files
- Operational heuristic for the skill
- Useful commands
- Anti-patterns
- Source base

Repository metadata improves discoverability, onboarding, and alignment with the README.

## Minimum elements

- short description
- topics
- project/docs URL when available
- social preview or branding when the project benefits from it

## Description

A good description is:

- one line
- concrete
- clear about what the project is and who or what it is for

Useful template:

- `<project type> for <primary use case> in/with <stack or domain>`

Examples:

- `CLI for validating commit conventions in Node.js repositories`
- `Python library for transforming Stripe events into typed models`
- `GitHub Actions template for JavaScript monorepo CI`

Avoid:

- "awesome project"
- "my repo"
- repeating the repo name without explaining its purpose

## Topics

Practical rule:

- use 3 to 8
- mix:
  - language or runtime
  - domain
  - project type
  - key technology

Examples:

- `nodejs`, `cli`, `linting`, `developer-tools`
- `python`, `sdk`, `stripe`, `typed-models`
- `github-actions`, `template`, `ci`, `automation`

Avoid:

- topics so generic that they add no value
- topics the repo does not actually represent
- keyword stuffing for SEO

## Alignment with README

- The repository description and the `README.md` summary should tell the same story.
- If the README promises more than the metadata suggests, refine the description.
- If the repo is very technical, use topics that help users filter by use case and stack.

## Related community health files

If relevant, consider:

- `CODE_OF_CONDUCT.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- issue templates
- pull request template

More likely to matter for:

- open-source projects with community participation
- libraries and SDKs
- tools with external adoption

Less urgent for:

- personal prototypes
- small internal repos

## Operational heuristic for the skill

1. Summarize the project in one sentence.
2. Extract 3 to 8 topics from stack + domain + repo type.
3. Check whether the project needs community health files.
4. If the user wants it, apply metadata with `gh repo edit`.

## Useful commands

- `gh repo edit --description "CLI for ..." --add-topic "cli" --add-topic "nodejs"`
- `gh repo edit --homepage "https://..."` if official docs or a project site exists

## Anti-patterns

- vague description
- false or overly broad topics
- metadata misaligned with the real README
- adding a generic `SECURITY.md` that nobody will maintain

## Source base

- GitHub Docs: [Classifying your repository with topics](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics)
- GitHub Docs: [Adding a code of conduct to your project](https://docs.github.com/communities/setting-up-your-project-for-healthy-contributions/adding-a-code-of-conduct-to-your-project)
- GitHub Docs: [Adding a security policy to your repository](https://docs.github.com/code-security/getting-started/adding-a-security-policy-to-your-repository)
