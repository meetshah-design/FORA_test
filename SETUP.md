# FORA — Setup Guide

Everything you need to go from zero to your first live application page, in one afternoon.

Estimated time: **60–90 minutes** (most of it is the profile brainstorm, not setup).

---

## Before you start

You'll need:
- Node.js 18+ installed
- A Vercel account (free tier works)
- An Anthropic API key (claude.ai/settings → API)
- Your resume, LinkedIn export, or any raw career materials

---

## Step 1 — Clone the repo

```bash
git clone https://github.com/[your-fork]/FORA.git
cd FORA
npm install
```

---

## Step 2 — Configure environment variables

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

Open `.env` and set:

```
ANTHROPIC_API_KEY=your_key_here
VERCEL_TOKEN=your_vercel_token
VERCEL_PROJECT_NAME=fora-pages
DEPLOY_DOMAIN=                   # optional — custom domain if you have one
AI_MODEL=claude-opus-4-5         # or any Claude model you have access to
```

To get your Vercel token: vercel.com/account/tokens → Create Token.

---

## Step 3 — Build your profile

Your profile is private and lives only on your machine. It's the source of truth for every application you generate.

**Open a new AI chat** (Claude.ai, Cursor, or any model you prefer).

Paste the contents of `prompts/profile-builder-prompt.md` into the chat.

Then share your raw materials — paste your resume, or upload a PDF, or share your LinkedIn export files. The AI will ask a few questions, then draft a complete `profile.json`.

When you're happy with it:

```bash
# Create the profile directory if it doesn't exist
mkdir -p profile

# Paste the output from the AI chat into this file
# (The AI will tell you to do this at the end of Phase 4)
```

Save the JSON to `profile/profile.json`.

**This file is gitignored.** It will never be committed or pushed.

---

## Step 4 — Set up your design system

Your default design system is already included — it's the visual baseline for every page you generate. You can use it as-is, or customise it to match your taste.

```bash
# The default DS lives here — gitignored like your profile
touch design-system/default.md
```

Copy the contents of `design-system/default.md` from the repo into this file. You can edit colours, typography, and spacing to match your personal brand.

If you leave it as-is, pages will use the FORA default: clean, neutral, typographic.

---

## Step 5 — Run your first brainstorm

Find a job description you want to apply to. Copy the URL.

```bash
./brainstorm.sh https://company.com/jobs/senior-designer
```

This fetches the JD, assembles the brainstorm prompt with your `profile.json`, and copies everything to your clipboard.

Paste into a new AI chat. The agent will:
1. Analyse the JD and score the match
2. Propose content for all three acts
3. Ask for your input
4. Lock a `content_brief.json`

When the agent outputs the brief, save it:

```bash
# The agent will tell you the exact filename at the end
# e.g. briefs/company-senior-designer.json
```

**Brief files are gitignored.** They won't be committed.

---

## Step 6 — Generate the page

```bash
node generate.js --run briefs/company-senior-designer.json
```

This assembles your page into `output/company-senior-designer/index.html`.

Open it in a browser to review:

```bash
open output/company-senior-designer/index.html
```

If something looks off, you can go back to the brief and update fields, then re-run.

---

## Step 7 — Publish

When you're happy with the page:

```bash
node generate.js --publish briefs/company-senior-designer.json
```

This deploys to Vercel and returns a live URL. Something like:

```
https://fora-pages.vercel.app/company-senior-designer
```

Send that URL in your cold message.

---

## What's next

**Apply again.** Run `brainstorm.sh` with a new JD. Your profile stays — each application takes 15–20 minutes once you're set up.

**Update your profile.** When you ship new work, open `profile/profile.json` and update the relevant case study. Or paste your current profile into a new chat with the profile-builder-prompt and tell the AI what changed.

**Customise your DS.** Edit `design-system/default.md` to adjust colours or typography. The changes apply to every page you generate from that point.

**Fork and extend.** FORA is open-source. The templates, section HTML, and prompts are all yours to modify. See `DEVPLAN.md` for what's planned next.

---

## Troubleshooting

**`brainstorm.sh` says permission denied**
```bash
chmod +x brainstorm.sh
```

**generate.js fails with API error**
Check your `ANTHROPIC_API_KEY` in `.env` — make sure there are no extra spaces.

**Vercel deploy fails**
Check `VERCEL_TOKEN` and `VERCEL_PROJECT_NAME` in `.env`. Your Vercel project must exist before the first deploy — create it at vercel.com/new.

**The page looks unstyled**
Your `design-system/default.md` might be missing. See Step 4.
