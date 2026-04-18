# GitHub Actions

## Contents

- Core goal
- Recommended minimum CI
- Most important rule
- Operational best practices
- Caching
- Patterns by stack
- Fork pull requests and security
- Release automation
- When not to add Actions yet
- Operational heuristic for the skill
- Anti-patterns
- Source base

Use this reference to propose CI and automation based on the real stack in the repository, while avoiding decorative or unsafe workflows.

## Core goal

- Validate the project on every `push` and `pull_request`
- Run real project commands
- Keep execution time reasonable with sensible caching
- Maintain minimum permissions
- Avoid inventing release automation when the user does not want it

## Recommended minimum CI

Include:

- `on:`
  - `push`
  - `pull_request`
- `actions/checkout`
- setup for the correct runtime
- dependency cache when it adds value
- reproducible installation
- `lint`, `test`, and `build` only if those commands actually exist

## Most important rule

- Never add steps like `npm run lint` or `npm run build` if the project does not have those scripts.
- Before creating the workflow, inspect files such as:
  - `package.json`
  - `pyproject.toml`
  - `requirements.txt`
  - `go.mod`
  - `Cargo.toml`
  - `Makefile`
  - `justfile`

## Operational best practices

- Use stable, maintained versions of actions.
- Prefer official GitHub actions when available.
- Set explicit, minimal `permissions:`.
- If the workflow only reads code, use `contents: read`.
- Use matrices only when they provide real signal, such as multiple supported runtime versions.
- If the project is small, avoid unnecessary matrices that multiply cost and noise.

## Caching

- Cache dependencies, not arbitrary build artifacts.
- Use built-in caching support from setup actions when available.
- Do not cache directories that harm reproducibility or mix build output with dependencies.

## Patterns by stack

### Node.js

- Prefer `npm ci` when `package-lock.json` exists.
- Use `pnpm/action-setup` or an equivalent setup only if the repo truly uses `pnpm`.
- If `yarn.lock` exists, do not force `npm`.
- Build and test should come from existing `scripts`.

### Python

- Use the Python version declared by the project when it can be inferred.
- Install with the repo's actual toolchain (`pip`, `poetry`, `uv`, etc.).
- Do not mix tools without a reason.

### Go

- Use `go test ./...`
- Add build only if the project actually compiles binaries or modules that need it.

### Rust

- `cargo test`
- `cargo clippy` and `cargo fmt --check` only if the team already uses them or they clearly fit the repo

## Fork pull requests and security

- Be careful with secrets.
- Do not expose tokens or secrets to untrusted code.
- Avoid `pull_request_target` unless there is a clear need and the risk is understood.
- If using `GITHUB_TOKEN`, scope permissions as tightly as possible.

## Release automation

Valid options:

- Manual with `gh release create`
- Publish on push of tags like `v*`
- Release Drafter or similar if the repo already follows that model

Only add a release workflow if:

- the user asked for it
- there is a clear versioning strategy
- the repo is actually ready to publish artifacts or releases

## When NOT to add Actions yet

- The repo does not build yet or has no stable commands
- The stack is still unclear
- The user only wants initial documentation
- The project is still an early draft with no tests or real build steps

In those cases, explain that it is better to stabilize the base commands first.

## Operational heuristic for the skill

1. Detect runtime, package manager, and real scripts.
2. Propose a minimum viable workflow.
3. Keep `permissions` minimal.
4. Add cache only if the package manager supports it clearly.
5. Separate CI from release workflows if both exist.

## Anti-patterns

- Workflow with invented commands
- Workflow using `latest` carelessly in third-party actions
- Granting write permissions by default
- Mixing CI and deployment without a reason
- Creating a huge matrix for a repo with no declared multi-platform support

## Source base

- GitHub Docs: [Workflow syntax for GitHub Actions](https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions)
- GitHub Docs: [Use GITHUB_TOKEN for authentication in workflows](https://docs.github.com/actions/security-for-github-actions/security-guides/automatic-token-authentication)
- GitHub Docs: [Dependency caching](https://docs.github.com/actions/concepts/workflows-and-actions/dependency-caching)
