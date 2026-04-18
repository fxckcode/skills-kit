# Releases and Tags

## Contents

- Recommended convention
- When to bump the version
- First release
- Tags
- GitHub releases
- Automatic release notes
- Changelog
- Recommended strategies
- Latest release and pre-releases
- Operational heuristic for the skill
- Anti-patterns
- Source base

Use this reference to version and publish releases without improvising the process.

## Recommended convention

- Use SemVer: `MAJOR.MINOR.PATCH`
- Use annotated tags with a `v` prefix, for example `v1.2.0`
- Stay consistent: do not mix `1.2.0` and `v1.2.0` in the same repo

## When to bump the version

- `MAJOR`: breaking change
- `MINOR`: backward-compatible new functionality
- `PATCH`: backward-compatible bug fix
- Pre-release: `v1.0.0-rc.1`, `v0.9.0-beta.2` when the release is not yet stable

## First release

- If the project is early or experimental, suggest `v0.1.0`
- If there is already a stable API, stable CLI, or meaningful adoption, `v1.0.0` may be appropriate
- Do not promise `v1.0.0` just because the repo has a README and CI

## Tags

Base commands:

- `git tag -a v1.2.0 -m "Release v1.2.0"`
- `git push origin v1.2.0`

Prefer `git push origin <tag>` over `git push --tags` if you want to avoid publishing unrelated local tags.

## GitHub releases

Options:

- manual: `gh release create v1.2.0 --generate-notes`
- manual with curated notes: `gh release create v1.2.0 --notes-file CHANGELOG.md`
- automatic from tags through GitHub Actions if the user wants it

## Automatic release notes

- They are a good baseline for repos with a steady pull request flow.
- They can be customized by category and can exclude labels or users.
- They do not replace a narrative changelog when the project needs more editorial release communication.

## Changelog

- If the repo already maintains `CHANGELOG.md`, keep it aligned with releases.
- If there is no formal changelog:
  - use automatic notes at minimum
  - avoid inventing history the repo does not actually have

## Recommended strategies

### Small or personal repo

- Manual tags
- `gh release create --generate-notes`
- Simple SemVer

### Library or SDK

- Requires more disciplined versioning
- A changelog or well-categorized automated notes is recommended
- A tag-triggered release workflow can save time

### Monorepo or complex project

- Do not assume a single global strategy
- It may require per-package versioning, specialized tools, or team-specific conventions
- If it is unclear, ask before implementing automation

## Latest release and pre-releases

- Do not mark a pre-release as stable if the project is still in beta/rc.
- Use the pre-release flag when appropriate.
- Check whether the repo needs a clear "latest release" for installers or badges.

## Operational heuristic for the skill

1. Detect whether the repo already has tags or a current version in project files.
2. If there is no release history, suggest starting with `v0.1.0`.
3. If the user wants automation, separate:
   - versioning strategy
   - release notes generation
   - release publishing
4. If the artifact is not distributed, do not force a publish pipeline.

## Anti-patterns

- Pushing `--tags` without checking
- Creating release automation without an agreed versioning strategy
- Mixing manual and automatic notes inconsistently
- Publishing unstable builds as `latest`

## Source base

- GitHub Docs: [Managing releases in a repository](https://docs.github.com/repositories/releasing-projects-on-github/managing-releases-in-a-repository)
- GitHub Docs: [Automatically generated release notes](https://docs.github.com/repositories/releasing-projects-on-github/automatically-generated-release-notes)
- Semantic Versioning: [semver.org](https://semver.org/)
