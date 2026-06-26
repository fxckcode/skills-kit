---
name: npm-supply-chain-security
description: >
  Three-layer npm supply chain security: consumer basics, PNPM hardening, and publisher best practices (OIDC, Provenance, 2FA). Use when securing npm projects, auditing dependencies, evaluating install risks, or after supply chain attacks.
license: Apache-2.0
metadata:
  author: fxckcode
  version: "1.0"
---

# npm Supply Chain Security

## What This Skill Owns

- Auditing and hardening npm dependency chains across three layers
- Consumer-side security (ignore-scripts, lockfile validation, cooldown)
- PNPM-specific hardening (strictDepBuilds, onlyBuiltDependencies, minimumReleaseAge)
- Publisher-side practices (OIDC, Provenance, Trusted Publishers, 2FA)
- Post-attack response and verification

## When to Use

- User says "secure my npm project", "supply chain security", "npm audit hardening"
- After news of a supply chain attack (AnBe-style)
- When onboarding a new npm project that needs dependency hardening
- User asks about postinstall risks, lockfile injection, or PNPM security

## Primary Capabilities

| Capability | Description |
|---|---|
| Consumer hardening | ignore-scripts, version pinning, cooldown periods, npq/sfw wrappers |
| PNPM security | strictDepBuilds, onlyBuiltDependencies, lockfile-lint, minimumReleaseAge |
| Publisher security | OIDC tokens, npm provenance, Trusted Publishers, 2FA, files allow list |
| Verification | Lockfile URL validation, postinstall scanning, secret exposure checks |

## Three-Layer Model

### Layer 1: Consumer Basics

Apply these to ANY npm project immediately:

```bash
npm config set ignore-scripts true
# Use exact versions, never latest
npm install paquete@1.2.3 --ignore-scripts
# Cooldown: 3 days before installing new packages
# In .npmrc:
minimumReleaseAge=4320
```

### Layer 2: PNPM Hardening

When using PNPM (recommended over npm):

```yaml
# pnpm-workspace.yaml
onlyBuiltDependencies:
  - protobufjs
  - '@prisma/engines'
  # add what your project actually needs
```

```bash
# Validate lockfile URLs
npx lockfile-lint --path pnpm-lock.yaml --allowed-hosts npm --validate-https
```

### Layer 3: Publisher

If you publish npm packages:

1. **OIDC + Provenance** — GitHub Actions with `id-token: write` permission + `npm publish --provenance`
2. **Trusted Publisher** — Configure on npmjs.com so only your GHA workflow can publish
3. **2FA** — Required, preferably with passkey
4. **files allow list** — `"files": ["dist/", "README.md", "LICENSE"]` in package.json

## Pitfalls

- `postinstall` is the most common attack vector — always review before updating
- `ERR_PNPM_IGNORED_BUILDS` in pnpm 11+: approve builds with `pnpm approve-builds <pkg>` or add to `onlyBuiltDependencies`
- OIDC publish fails without `id-token: write` permission in the workflow
- Cooldown blocks urgent CVEs — maintain an exceptions list
