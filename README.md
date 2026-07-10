# FORA

**Turn a job description into a personalised application landing page.**

FORA is an open-source agentic pipeline for designers. You give it a job description. It reads your profile, analyses the role, runs a focused brainstorm, and produces a tailored page — three acts: who you are, what you've done (framed for this company), and what you'll bring in the first 90 days.

No generic applications. No templates that look like templates.

---

## Quick Start

```bash
git clone https://github.com/meetshahco/FORA.git
cd FORA
chmod +x setup.sh brainstorm.sh codegen.sh run.sh

# Step 1 — health check and profile build (once)
./setup.sh

# Step 2 — every application from here on
./run.sh
```

`run.sh` handles everything — brainstorm, mode selection, generate, deploy — in one guided flow. It asks for the JD URL when you run it. No API keys needed to start.

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

## Usage options

FORA is tool-agnostic and cost-optional. You choose how to generate and deploy **per application** — not once during setup. AI provider and Vercel are fully independent.

| Option | Codegen | Deploy | Keys needed |
|--------|---------|--------|-------------|
| 1 | Manual codegen via AI chat | Manual deploy via any static host | None |
| 2 ★ | Manual codegen via AI chat | Auto deploy via Vercel | Vercel token |
| 3 | Auto codegen via AI API | Manual deploy via any static host | Anthropic, Gemini, or OpenAI key |
| 4 | Auto codegen via AI API | Auto deploy via Vercel | AI key + Vercel token |

★ Option 2 is the most practical starting point — permanent URL with zero AI API cost.

`run.sh` detects which keys you have and shows only what's available. Start with option 1, add keys when you're ready, and options unlock automatically — no reconfiguration needed.

**Supported AI providers for auto codegen (options 3 + 4):**
- Anthropic Claude — [console.anthropic.com](https://console.anthropic.com/settings/keys)
- Google Gemini — [aistudio.google.com](https://aistudio.google.com/app/apikey)
- OpenAI — [platform.openai.com](https://platform.openai.com/api-keys)

Add any one key to `.env` — FORA auto-detects which provider to use.

---

## How it works

```
JD URL
  │
  ▼
brainstorm.sh → copies prompt to clipboard → paste into AI chat
  │
  ▼
content_brief.json  (saved automatically)
  │
  ├──→ Auto codegen via AI API           (options 3 + 4 — needs any AI key)
  │         ↓
  └──→ Manual codegen via AI chat        (options 1 + 2 — no API key needed)
            ↓
      assembled HTML page
            │
  ├──→ Auto deploy via Vercel            (options 2 + 4 — needs Vercel token)
  │         ↓ live URL
  │
  └──→ Manual deploy via any static host (options 1 + 3 — no Vercel needed)
            ↓ live URL
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
├── generate.js                   # Main script: --run, --publish, --deploy modes
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

**generate.js** supports three AI providers and three run modes. `--run` assembles the page locally (needs any AI key); `--deploy` deploys an already-generated page to Vercel (needs Vercel only, no AI key); `--publish` does both in one command (needs AI key + Vercel). All are optional depending on your mode.

---

## Privacy

Your `profile.json`, `design-system/default.md`, and all files in `briefs/` and `output/` are gitignored. They live only on your machine. The public repo contains only the pipeline.

---

## Getting started

See [SETUP.md](SETUP.md) for the complete first-afternoon walkthrough.
