# Contributing to FORA

Thanks for your interest. FORA is an early-stage open-source project — contributions are welcome but scope is intentionally narrow while the MVP is being validated.

---

## What's in scope

- Bug fixes in `generate.js`, `run.sh`, `brainstorm.sh`, `setup.sh`
- New section HTML templates (`templates/sections/`)
- New template JSON definitions (`templates/`)
- Prompt improvements — with a CHANGELOG entry required (see below)
- Windows and Linux testing and compatibility fixes
- Documentation corrections and improvements

## What's not in scope yet

These are planned for V2, after the MVP has been validated with real applications:

- Agent layer or automatic job crawler
- Confidence scorer or match scoring
- Analytics dashboard or PostHog integration
- MCP integration
- Multi-page output or additional template formats

If you're interested in V2 features, open an issue to discuss — don't build in isolation.

---

## How to contribute

1. **Open an issue** describing the problem or change before starting work
2. **Fork the repo** and branch from `main`
3. **Make the change** — keep it focused; one issue per PR
4. **If you changed a prompt file**, add a CHANGELOG entry (see below)
5. **Open a PR** referencing the issue number

---

## Prompt changes

Prompt files (`brainstorm-prompt.md`, `codegen-chat-prompt.md`) are versioned because changes affect output quality in ways that are hard to predict. Every prompt change must include:

- What output problem you observed (screenshot or description)
- What you changed in the prompt
- Example output before and after (even a description is fine)

Without this context, prompt changes are very hard to review. PRs without it will be asked to add it before merging.

---

## Code style

- No external npm dependencies in the core pipeline — use Node.js built-ins only
- Shell scripts must be POSIX-compatible where possible; macOS-specific commands (`pbcopy`, `open`) must have fallbacks
- All user-facing messages use the existing `ok`, `info`, `warn`, `fail`, `dim` helpers in `generate.js` and the equivalent in shell scripts
- New features should not require changes to `.env.example` unless genuinely necessary

---

## Questions

Open an issue with the `question` label. Response time varies — this is a side project.
