# FORA

**Turn a job description into a personalised application landing page.**

FORA is an open-source agentic pipeline for designers. You give it a job description. It reads your profile, analyses the role, runs a focused brainstorm, and produces a tailored page — three acts: who you are, what you've done (framed for this company), and what you'll bring in the first 90 days.

No generic applications. No templates that look like templates.

---

## Quick Start

```bash
git clone https://github.com/meetshahco/FORA.git
cd FORA

# Step 1 — build your profile (once)
# Open any AI chat, paste prompts/profile-builder-prompt.md, share your resume
# Save the output to profile/profile.json

# Step 2 — run a brainstorm (per application)
./brainstorm.sh https://company.com/jobs/role
# Paste clipboard into any AI chat → save the brief to briefs/[slug].json

# Step 3 — generate your page
node generate.js --run briefs/[slug].json
open output/[slug]/index.html

# Step 4 — deploy (optional, needs Vercel token in .env)
node generate.js --deploy briefs/[slug].json    # deploy manually-generated HTML (no Anthropic needed)
node generate.js --publish briefs/[slug].json   # generate + deploy in one command (needs Anthropic)
# → https://fora-pages.vercel.app/[slug]
```

---

## What you'll build

In your first afternoon with FORA:

```
✓ Build your private career knowledge base (profile.json)
✓ Brainstorm one application against a real JD
✓ Generate a personalised landing page
✓ Publish it live (optional)

Result: a URL you can send in a cold message
→ https://fora-pages.vercel.app/company-role
```

---

## Usage modes

FORA is tool-agnostic and cost-optional. Anthropic and Vercel are independent — use only what your mode requires.

**Mode 1 — Fully manual (zero cost, no API keys)**
Run `brainstorm.sh` into any AI chat. Ask the same AI to generate HTML section by section using `codegen-prompt.md`. Deploy by dragging the folder to Netlify drop or any static host.

**Mode 2A — Automated codegen (Anthropic key only)**
Same brainstorm flow, but `generate.js --run` handles HTML generation automatically. No Vercel needed — deploy manually after.

**Mode 2B — Manual codegen + auto deploy (Vercel key only) ★**
Generate HTML manually in an AI chat (no Anthropic cost), then run `generate.js --deploy` to get a live URL automatically. The most practical starting point — zero API cost with a permanent URL.

**Mode 3 — Fully automated (Anthropic + Vercel)**
`generate.js --publish` generates and deploys in one command.

See `.env.example` for exactly which keys each mode needs.

---

## How it works

```
JD URL
  │
  ▼
brainstorm-prompt.md + profile.json
  │   (paste into any AI chat)
  ▼
content_brief.json
  │
  ├──→ generate.js --run       ← auto codegen    (Mode 2A + 3, needs Anthropic)
  │         ↓
  └──→ paste codegen-prompt.md manually          (Mode 1 + 2B, no API key needed)
            ↓
  assembled HTML page
            │
  ├──→ generate.js --deploy    ← auto deploy     (Mode 2B + 3, needs Vercel)
  │
  └──→ drag to Netlify / any static host         (Mode 1 + 2A, no Vercel needed)
            ↓
        live URL
```

---

## Repository structure

```
FORA/
├── profile/
│   ├── profile-template.json     # Schema with instructions — copy and fill in
│   └── profile.json              # Your profile — gitignored, never committed
│
├── prompts/
│   ├── profile-builder-prompt.md # Run once to build profile.json from your materials
│   ├── brainstorm-prompt.md      # Run per application — JD → content_brief.json
│   └── codegen-prompt.md         # Used by generate.js — or paste manually for Mode 1
│
├── briefs/
│   ├── example-brief.json        # Reference schema for content_brief.json
│   └── *.json                    # Your briefs — gitignored, never committed
│
├── templates/
│   ├── three-act.json            # Default: hero → work → bring → cta
│   ├── work-first.json           # Leads with proof of work
│   ├── single-statement.json     # Minimal: one statement + one case study + cta
│   └── sections/
│       ├── _base.html            # Injected into every page head
│       ├── nav.html
│       ├── act1_hero.html
│       ├── act2_work.html
│       ├── act3_bring.html
│       ├── signal_cards.html
│       ├── direct_cta.html
│       └── footer.html
│
├── design-system/
│   └── default.md                # Your personal DS — gitignored, never committed
│
├── output/                       # Generated HTML — gitignored
│
├── generate.js                   # Main script: --run and --publish modes
├── brainstorm.sh                 # Fetches JD, assembles prompt, copies to clipboard
├── .env.example                  # Environment variables (all optional depending on mode)
├── DEVPLAN.md                    # MVP and V1 build plan
└── SETUP.md                      # Step-by-step first-afternoon guide
```

---

## Key concepts

**profile.json** is private and lives only on your machine. It contains your career, case studies, philosophy, and tone of voice. Every application pulls from it — the more specific it is, the better every application gets.

**content_brief.json** is the contract between brainstorm and codegen. The AI writes it; `generate.js` (or you, manually) reads it. It specifies which works to show, what to say in each act, which template to use, and design system direction.

**Templates** control section order and layout. Three are included: `three-act` (default), `work-first` (leads with proof), `single-statement` (minimal). The brainstorm agent recommends one based on the role.

**Design system** defaults to your own (`design-system/default.md`). For companies with a public design system, the page can adopt their visual language as a signal that you understand their craft.

**generate.js** has three modes: `--run` assembles the page locally (needs Anthropic); `--deploy` deploys an already-generated page to Vercel (needs Vercel only, no Anthropic); `--publish` does both in one command (needs both). All three are optional depending on your mode.

---

## Privacy

Your `profile.json`, `design-system/default.md`, and all files in `briefs/` and `output/` are gitignored. They live only on your machine. The public repo contains only the pipeline.

---

## Getting started

See [SETUP.md](SETUP.md) for the complete first-afternoon walkthrough.
