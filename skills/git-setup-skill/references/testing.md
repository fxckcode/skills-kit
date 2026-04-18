# Testing

## Contents

- Goal
- Cases it should cover
- Suggested test scenarios
- Evaluation workflow
- Evaluation files
- Signals of poor quality
- Acceptance heuristic
- Minimum manual validation

Use this reference to validate that the skill produces useful repository setups rather than pretty checklists with no connection to the actual repo.

## Goal

Verify that the skill:

- inspects before writing
- asks only what is necessary
- makes coherent decisions
- does not break existing files
- produces actionable output

## Cases it should cover

### Stack detection

- correctly detects language, runtime, and package manager
- recognizes when the stack is unclear
- avoids assuming `npm` when there is `pnpm-lock.yaml`, `yarn.lock`, or other contrary signals

### README

- the summary explains real value
- sections match the project's actual capabilities
- it does not invent commands
- it does not promise CI, releases, or security work that does not exist

### Licenses

- recommends a license with justification
- asks when there is legal uncertainty
- does not choose `MIT` mechanically in sensitive or corporate contexts

### GitHub Actions

- uses existing commands
- configures minimum permissions
- does not create unnecessary matrices
- does not add release automation without a versioning strategy

### Metadata

- concrete description
- useful, truthful topics
- alignment with the README

## Suggested test scenarios

- open-source Node library with `npm test` and `npm run build`
- Python CLI with no tests yet
- internal repo with no intention of being open source
- GitHub Actions template repo
- monorepo where it is unclear whether there should be a single workflow

## Evaluation workflow

1. Run the task without the skill and record the baseline behavior.
2. Run the same task with the skill enabled.
3. Compare the result against the expected behavior in the matching eval file.
4. Note missed decisions, bad assumptions, or unnecessary questions.
5. Tighten the skill only where the eval exposes a real gap.

## Evaluation files

Use these concrete scenarios as the starting evaluation set:

- `evals/node-library.json`
- `evals/internal-service.json`
- `evals/monorepo-release-strategy.json`

Run them with each model you care about. At minimum, compare the fast/small model you expect to use most often against the stronger model you use for complex repository setup.

## Signals of poor quality

- overly generic responses
- files full of placeholders
- workflows that would fail on first run
- license chosen without explanation
- long `README.md` with little useful information

## Acceptance heuristic

The skill passes if:

- every proposed change is backed by evidence from the repo or by a clearly marked assumption
- the user can understand why the license, CI, and release strategy were chosen
- the result reduces real manual work

## Minimum manual validation

1. Inspect an example repo.
2. Ask for a partial setup and then a full setup.
3. Verify that the missing questions are few and relevant.
4. Confirm that proposed commands actually exist.
5. Confirm that sensitive existing files are not overwritten without review.
