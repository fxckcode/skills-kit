# Triggers

Phrases and signals that should activate this skill.

## Direct activation

- "basic repository setup"
- "I want a good README"
- "create .gitignore and .gitattributes"
- "set up GitHub Actions"
- "I want releases and tags"
- "add a license to the repository"
- "let's make this repo ready for GitHub"
- "prepare the repo for open source"
- "I want professional repo metadata"

## Intent-based activation

Activate the skill even if the user does not name the files explicitly when they want to:

- professionalize a repository
- prepare a project for publishing on GitHub
- get documentation, licensing, and CI in place
- organize release process, tags, or versioning
- improve repository discoverability

## Do not activate automatically if

- the user only wants application code changes
- the change is internal and does not touch repository setup
- they only want help with a single file unrelated to repository onboarding/setup

## Subtopics this skill should detect

- `.gitignore`
- `.gitattributes`
- `README.md`
- `LICENSE`
- community health files
- repository description and topics
- GitHub Actions
- tags, changelog, and releases
