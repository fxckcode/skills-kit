# Licenses

## Contents

- Rule zero
- Recommended defaults
- How to decide by project type
- Signals to ask instead of assuming
- Cases where you should not improvise
- How to phrase the recommendation
- How to implement it in the repo
- Operational heuristic for the skill
- Common warnings
- Source base

Use this reference to choose a license based on reasoning, not just popularity.

## Rule zero

- If the user does not want to share the code freely, do not propose an open-source license by default.
- If the repository will be public and has no license, remember that "public" does not mean "free to use": without a license, other people do not automatically have permission to use, modify, or distribute the code.
- If the user does not know which license to choose, first identify:
  - whether they want maximum adoption
  - whether they want patent protection
  - whether they want to require sharing derivative work
  - whether there will be external contributions or commercial use

## Recommended defaults

- `MIT`:
  - simple default for libraries, templates, tooling, educational repos, and projects where the priority is low-friction adoption
  - avoid using it as the default if the user explicitly mentions patent concerns
- `Apache-2.0`:
  - strong default for libraries, SDKs, CLIs, and business-facing projects where an explicit patent grant is valuable
  - a very good option when the project may be used by companies or integrated into commercial products
- `GPL-3.0`:
  - use when the goal is strong copyleft and the user wants distributed derivatives to remain under the same license
  - do not choose it by default if the user wants maximum adoption in corporate environments
- `BSD-3-Clause`:
  - permissive, similar to MIT, useful when the team prefers a short and well-known alternative outside GitHub's MIT bias

## How to decide by project type

### Libraries and SDKs

- Prioritize `MIT` or `Apache-2.0`
- Prefer `Apache-2.0` if:
  - there is serious commercial interest
  - the domain touches algorithms, protocols, or implementations with patent risk
  - the project will likely have more formal governance

### Apps, SaaS, and internal products

- Many apps do not need an open-source license if they will not be distributed as reusable software.
- If the repo is private or internal, ask whether they really want a license or just an ownership notice.
- If it is an internal template reused across teams, a permissive license can still be useful.

### Templates, boilerplates, examples, and educational material

- `MIT` is often the most natural choice because it is simple and easy to reuse.

### Infrastructure or security tools

- `Apache-2.0` is often a better starting recommendation than `MIT` because of the patent clause.

### Community project with a copyleft philosophy

- `GPL-3.0` fits when the user wants distributed derivative software to remain open.

## Signals to ask instead of assuming

- The user mentions "open core", "restricted commercial use", "I do not want resale", "I do not want closed forks", or "I want dual licensing".
- The project mixes code with non-software content.
- There are dependencies or files with unclear or potentially incompatible licenses.
- The repo belongs to a company, university, or client and may require legal approval.

## Cases where you should NOT improvise

- Dual licensing
- AGPL, LGPL, MPL, SSPL, BSL, or other licenses with more subtle obligations
- Repos with multiple authors and unclear ownership
- Migrating a published repo from one license to another

In these cases, explain the tradeoffs and recommend explicit confirmation from the user.

## How to phrase the recommendation

Give a short, justified recommendation. Examples:

- "I recommend `MIT` because this looks like a library/template and the priority appears to be simple adoption."
- "I recommend `Apache-2.0` because it provides explicit patent protection and fits an SDK with business use."
- "I recommend `GPL-3.0` because you want distributed derivatives to remain open."

## How to implement it in the repo

- Use the official template for the chosen license.
- Fill in `year` and `copyright holder` only if the user provides them or they can be inferred with high confidence.
- If the owner cannot be inferred, leave the file ready but ask for confirmation before locking in a legal name.
- Keep `README.md` and repository metadata aligned with the final license.

## Operational heuristic for the skill

1. Detect whether the repo is open source, internal, educational, or commercial.
2. If the user did not choose a license:
   - suggest `MIT` for simplicity
   - suggest `Apache-2.0` if there are signals of enterprise use, a library/SDK context, or patent concern
   - suggest `GPL-3.0` only when there is a clear copyleft preference
3. If there is legal uncertainty, do not present the decision as settled: mark it as a recommendation.

## Common warnings

- Do not confuse "code visible on GitHub" with "open-source software".
- Do not treat non-open-source licenses as if they were equivalent to MIT/Apache/GPL.
- Do not promise license compatibility across dependencies unless it has actually been verified.
- Do not choose a license just because "everyone uses it".

## Source base

- GitHub Docs: [Adding a license to a repository](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
- GitHub Choose a License: [choosealicense.com](https://choosealicense.com/)
- GitHub Choose a License repo: [github/choosealicense.com](https://github.com/github/choosealicense.com)
- Open Source Guides: [The legal side of open source](https://opensource.guide/legal/)
