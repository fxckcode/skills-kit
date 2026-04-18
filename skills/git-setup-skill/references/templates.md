# Templates

## Contents

- Recommended README structure
- README quality rules
- Useful summary formulas
- Recommended `.gitattributes` baseline
- `.gitattributes` criteria
- `.gitignore` baseline
- `.gitignore` criteria
- Community files
- Source base

Use these templates as starting points. Always adapt them to the stack and to facts that are actually true about the repo.

## Recommended README structure

- `Title`
- `Summary`
- `Why this project exists` or `Problem`
- `Features` or `Use cases`
- `Requirements`
- `Install / Setup`
- `Usage`
- `Configuration` if relevant
- `Development`
- `Testing`
- `Release` if relevant
- `License`

## README quality rules

- The summary should explain value, not just the name.
- If the repo is a library, show a short usage example.
- If it is an app or CLI, explain how to run it.
- If it is a template, clarify what the user must customize.
- If there are no tests or build steps, do not invent sections with fake commands.

## Useful summary formulas

- `Tool for <main task> in <context>`
- `<stack> library for <specific need>`
- `Base template for <project type> with <key capabilities>`

## Recommended `.gitattributes` baseline

```gitattributes
* text=auto eol=lf
*.md text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.sh text eol=lf
*.ps1 text eol=crlf
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.pdf binary
```

## `.gitattributes` criteria

- `text=auto eol=lf` is a good default for cross-platform repos.
- Mark known binary files to avoid unwanted transformations.
- For PowerShell scripts, `crlf` can be reasonable in Windows-centric repos.
- Only add `linguist-*` rules if there is a clear classification need in GitHub.

## `.gitignore` baseline

Include only what the project actually needs. Starting point:

- `node_modules/`
- `dist/`
- `build/`
- `.env`
- `.env.*`
- `.DS_Store`
- `Thumbs.db`
- `*.log`
- `.coverage`
- `.pytest_cache/`
- `.venv/`

## `.gitignore` criteria

- Team-shared ignores belong in `.gitignore`.
- Personal developer noise can go in `.git/info/exclude` or a global ignore file.
- Do not ignore lockfiles without a clear reason.
- Do not ignore required sample config files such as `.env.example`.
- If the repo intentionally versions distributable artifacts, do not ignore those paths automatically.

## Community files

### `CODE_OF_CONDUCT.md`

Useful when:

- the project accepts external contributions
- you want clear expectations for community behavior

### `SECURITY.md`

Useful when:

- the project is used externally
- there is a real channel for reporting vulnerabilities

Do not add it if nobody will respond or maintain it.

## Source base

- Git docs: [gitattributes](https://git-scm.com/docs/gitattributes)
- Git docs: [gitignore](https://git-scm.com/docs/gitignore)
- GitHub gitignore templates: [github/gitignore](https://github.com/github/gitignore)
