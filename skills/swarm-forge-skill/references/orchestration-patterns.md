# Development Patterns

Use this reference when choosing between the four supported development patterns of this skill: `TDD`, `BDD`, `ATDD`, and `SDD`.

## `TDD`

What it is:

- a development style where coding, testing, and refactoring are tightly interwoven
- the common loop is red -> green -> refactor

Best fit:

- implementation-heavy codebases
- teams that want unit tests to guide design and implementation details
- repositories already using unit test frameworks such as Jest or pytest

Typical artifacts:

- unit test files close to source or in a `tests/` tree
- framework-specific test config
- fast local test commands

Core sources:

- [Agile Alliance: TDD](https://agilealliance.org/glossary/tdd/)
- [Jest getting started](https://jestjs.io/docs/next/getting-started)
- [pytest docs](https://docs.pytest.org/)

## `BDD`

What it is:

- a collaborative behavior-focused process built around concrete examples and shared understanding
- often expressed through Given/When/Then scenarios

Best fit:

- user-facing workflows
- teams with product, QA, and engineering collaboration
- systems where behavior and examples matter more than low-level implementation detail

Typical artifacts:

- `.feature` files
- Given/When/Then scenarios
- step definitions

Core sources:

- [Cucumber: Behaviour-Driven Development](https://cucumber.io/docs/bdd/)
- [Cucumber docs](https://cucumber.io/docs)
- [Agile Alliance: BDD](https://agilealliance.org/glossary/bdd/)

## `ATDD`

What it is:

- acceptance tests are written collaboratively in advance of implementing functionality
- often centered on customer, developer, and tester perspectives

Best fit:

- feature work with explicit acceptance criteria
- stakeholder-heavy workflows
- systems where acceptance tests are the clearest contract for delivery

Typical artifacts:

- acceptance test files
- acceptance criteria docs
- collaboration notes from three-amigos style sessions

Core sources:

- [Agile Alliance: ATDD](https://agilealliance.org/glossary/atdd/)
- [FitNesse User Guide](https://fitnesse.org/FitNesse/UserGuide.html)
- [Cucumber example mapping](https://cucumber.io/docs/bdd/example-mapping/)

## `SDD`

What it is:

- specs act as the primary source of implementation context
- structured artifacts such as requirements, design, and tasks are created before or alongside implementation

Best fit:

- AI-agent workflows
- large or ambiguous features
- repositories that benefit from explicit plans, specs, and reusable context

Typical artifacts:

- spec documents
- plan documents
- task breakdowns
- structured change folders or spec trees

Common tool examples:

- GitHub Spec Kit
- Kiro
- OpenSpec

Core sources:

- [Microsoft: Spec-Driven Development with Spec Kit](https://developer.microsoft.com/blog/spec-driven-development-spec-kit)
- [Kiro overview](https://kiro.dev/)
- [OpenSpec](https://github.com/Fission-AI/OpenSpec/)

## Selection Heuristics

- Prefer `TDD` when the user wants implementation driven by unit tests and refactoring.
- Prefer `BDD` when the user wants shared behavior understanding and scenario language.
- Prefer `ATDD` when the user wants acceptance criteria and stakeholder collaboration to drive development.
- Prefer `SDD` when the user wants specs, plans, tasks, and structured context to guide implementation.
