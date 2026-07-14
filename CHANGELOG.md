# FORA — Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Fixed
- DS token cascade order in `_base.html` — tokens now inject after base styles so they correctly override defaults
- `applications.json` logging schema aligned across `--run` and `--publish` modes
- CTA button spec aligned between `default.md` and `codegen-prompt.md` — ghost button (white text, no fill, 1px white border)
- `_base.html`: added `text-size-adjust` for iOS Safari orientation change; CTA anchor colour override; `fora-section__intro` max-width corrected to 620px
- Vercel deploy URL now derived from stable project alias, not per-deploy hash URL
- `vercel.json` with `cleanUrls: true` included in every deployment so `/slug` resolves correctly
- `brainstorm.sh`: job board URLs (LinkedIn, Greenhouse, Lever, etc.) now use `job-<id>` as filename instead of board domain name
- `generate.js`: DS token extraction regex now correctly finds `:root {}` block in `default.md`
- `generate.js`: preview path changed to cross-platform `file://` URI
- `setup.sh`: removed false `node_modules` check — pipeline has no npm dependencies
- `setup.sh`: context-aware settings menu replaces vague "Update API keys?" prompt

---

## [0.1.0] — 2026-07-08

### Added
- `generate.js` — six-module pipeline: Planner, KnowledgeLoader, DSLoader, Codegen, Assembler, Publisher
- Multi-provider AI support: Anthropic Claude, Google Gemini, OpenAI (auto-detected from `.env`)
- Exit codes: 0 = all sections succeeded, 1 = total failure, 2 = partial failure
- Proactive error recovery: `.fora_error` written on failure, `run.sh` reads it and offers inline fix
- `brainstorm.sh` — JD fetch, prompt assembly, clipboard copy, brief save with conflict handling
- `run.sh` — end-to-end guided flow with per-run mode selection (4 modes)
- `setup.sh` — health check, dependency check, `.env` writer
- `brainstorm-prompt.md` v1 — three-act structure, DS direction decision
- `codegen-chat-prompt.md` v1 — section-specific rules, media rendering spec
- `default.md` — complete design system as LLM-consumable instructions
- `_base.html` — reset, tokens injection point, global utilities, font loading
- Section HTML templates: `nav`, `act1_hero`, `act2_work`, `act3_bring`, `direct_cta`, `footer`
- Template JSON definitions: `three-act`, `work-first`, `single-statement`
- `examples/alex-rivera/` — fictional example with profile and brief
- `SETUP.md` — complete first-time and operational walkthrough
- `README.md`
- `.env.example`

### Architecture decisions
- Tool-agnostic brainstorm — any AI chat works, no lock-in
- No external npm dependencies for core pipeline
- DS decision at brief level: `own` vs `company`, runtime fetch
- Three AI providers supported with auto-detection
- Mode selection per application, not per setup
- Profile, briefs, output all gitignored — only pipeline code is public
