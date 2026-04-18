# Pattern Research

Use this reference when the user asks for deeper justification, examples from real tools, or a structure recommendation grounded in current ecosystem practice for `TDD`, `BDD`, `ATDD`, or `SDD`.

This file summarizes public documentation and well-known open source projects. The directory layouts below are recommended structures for this skill. They are not official standards unless stated otherwise.

## Test Driven Development

What it is:

- a style of programming where unit tests are written before implementation and refactoring is part of the loop

Recommended structure:

```text
src/
tests/
```

or co-located tests such as:

```text
src/
└── feature/
    ├── service.ts
    └── service.spec.ts
```

Why it fits:

- TDD tightly couples test-writing, implementation, and refactoring
- unit-test frameworks such as Jest and pytest support this fast feedback loop directly

Sources:

- [Agile Alliance: TDD](https://agilealliance.org/glossary/tdd/)
- [Jest getting started](https://jestjs.io/docs/next/getting-started)
- [pytest docs](https://docs.pytest.org/)

## Behavior Driven Development

What it is:

- a collaborative process focused on examples and behavior rather than only implementation detail

Recommended structure:

```text
scenarios/
└── features/
steps/
```

Why it fits:

- `.feature` files and Given/When/Then scenarios make behavior visible across roles
- tools like Cucumber treat scenarios as executable specifications

Sources:

- [Cucumber BDD](https://cucumber.io/docs/bdd/)
- [Cucumber docs](https://cucumber.io/docs)
- [Agile Alliance: BDD](https://agilealliance.org/glossary/bdd/)

## Acceptance Test Driven Development

What it is:

- acceptance tests and acceptance criteria are written collaboratively before implementation

Recommended structure:

```text
acceptance/
scenarios/
plans/
```

Why it fits:

- ATDD is explicitly collaborative across customer, development, and testing perspectives
- tools like FitNesse and Cucumber are commonly used to represent and verify acceptance criteria

Sources:

- [Agile Alliance: ATDD](https://agilealliance.org/glossary/atdd/)
- [FitNesse User Guide](https://fitnesse.org/FitNesse/UserGuide.html)
- [Cucumber example mapping](https://cucumber.io/docs/bdd/example-mapping/)

## Spec Driven Development

What it is:

- repository workflow is centered on specs, plans, tasks, and project knowledge before implementation

Recommended structure:

```text
docs/
└── agent-system/
    ├── specs/
    ├── plans/
    ├── tasks/
    ├── contracts/
    └── rules/
```

Why it fits:

- SDD uses structured artifacts such as requirements, design, and task breakdowns as active inputs to implementation
- Spec Kit, Kiro, and OpenSpec all show different concrete codifications of this pattern

Sources:

- [Microsoft: GitHub Spec Kit](https://developer.microsoft.com/blog/spec-driven-development-spec-kit)
- [Thoughtworks on SDD](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)
- [Kiro overview](https://kiro.dev/)
- [OpenSpec](https://github.com/Fission-AI/OpenSpec/)

## Notes

- These layouts are recommended defaults for this skill, not universal standards.
- Prefer extending an existing repository convention over imposing a new tree.
- For most repositories, combine one `setup pattern` with one of the four supported development patterns instead of inventing extra methodology categories.
