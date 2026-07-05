# FORA

**Turn a job description into a deployed, personalised application page — in one command.**

FORA is an open-source agentic pipeline for designers. You give it a job description. It reads your profile, analyses the role, runs a focused brainstorm, and generates a tailored HTML page — hosted live, ready to send.

Every page has three acts: who you are, what you've done (framed for this company), and what you'll bring in the first 90 days. The design adapts to the company's visual system if one is available. The content is never generic.

---

## How it works

```
JD URL
  │
  ▼
brainstorm-prompt.md + profile.json  →  AI chat  →  content_brief.json
                                                             │
                                                             ▼
                                                      generate.js --run
                                                             │
                                                             ▼
                                                    assembled HTML page
                                                             │
                                                             ▼
                                              generate.js --publish  →  live URL
```

1. **Build your profile.** Run `profile-builder-prompt.md` once with your resume and case studies. Outputs `profile.json` — your private source of truth.
2. **Run a brainstorm.** Use `brainstorm.sh [JD URL]` (or paste manually). The AI analyses the JD, proposes content for all three acts, and locks a `content_brief.json`.
3. **Generate the page.** `node generate.js --run briefs/[slug].json` assembles the HTML from your brief, your profile, and the design system.
4. **Publish.** `node generate.js --publish briefs/[slug].json` deploys to Vercel and returns a live URL.

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
│   └── codegen-prompt.md         # Used internally by generate.js — not for manual use
│
├── briefs/
│   ├── example-brief.json        # Reference schema for content_brief.json
│   └── *.json                    # Your briefs — gitignored, never committed
│
├── templates/
│   ├── three-act.json            # Default template: hero → work → bring → cta
│   ├── work-first.json           # Leads with proof of work
│   ├── single-statement.json     # Minimal: one statement + one case study + cta
│   └── sections/
│       ├── _base.html            # Injected into every page head (fonts, tokens, reset)
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
├── output/                       # Generated HTML — gitignored, never committed
│
├── generate.js                   # Main script: --run and --publish modes
├── brainstorm.sh                 # Helper: fetches JD, assembles prompt, copies to clipboard
├── .env.example                  # Environment variables you need to set
├── DEVPLAN.md                    # MVP and V1 build plan
└── SETUP.md                      # Step-by-step first-afternoon setup guide
```

---

## Key concepts

**profile.json** is private and powerful. It contains your career, case studies, philosophy, and tone of voice. It never gets committed. Every application pulls from it — so the more specific it is, the better every application gets.

**content_brief.json** is the contract between brainstorm and code. The AI writes it; `generate.js` reads it. It specifies which works to show, what to say in each act, the template to use, and the design system direction.

**Templates** control section order and layout behaviour. Three templates are included: `three-act` (default), `work-first` (leads with proof), and `single-statement` (minimal). The brainstorm agent recommends one based on the role.

**Design system** defaults to your own (`design-system/default.md`). For companies with a public DS, the page can adopt their visual language — colours, typography — as a signal that you understand their craft.

**generate.js** has two modes: `--run` assembles the page locally into `output/`; `--publish` deploys it to Vercel and returns a URL.

---

## What FORA is not

- A resume builder or CV formatter
- A mass-application tool — every brief requires a focused brainstorm
- A scraper or auto-submitter
- A portfolio builder — it generates single-purpose pages, not permanent portfolio sites

---

## Privacy

Your `profile.json`, `design-system/default.md`, and all files in `briefs/` and `output/` are gitignored. They live only on your machine. The public repo contains only the pipeline — prompts, templates, and scripts.

---

## Getting started

See [SETUP.md](SETUP.md) for a complete first-afternoon walkthrough.
