# FORA — Setup Guide

Everything you need to go from zero to your first live application page, in one afternoon.

---

## How this works

Before you start, here's the mental model. Three pieces, no magic connections between them.

```
┌─────────────────────────────────────────────────────────────────┐
│                        THE THREE PIECES                         │
├─────────────────┬──────────────────────┬────────────────────────┤
│   GitHub        │   Your machine       │   AI chat              │
│   (the repo)    │   (your files)       │   (your thinking tool) │
├─────────────────┼──────────────────────┼────────────────────────┤
│ Holds the       │ profile.json    ←private, never committed      │
│ open-source     │ briefs/*.json   ←private, never committed      │
│ pipeline code   │ output/*.html   ←generated pages               │
│                 │ assets/         ←your media files              │
│ You fork it     │                      │                         │
│ once, clone     │ Terminal runs the    │ You paste prompts in.   │
│ to your mac.    │ scripts here.        │ Copy outputs back.      │
│ That's it.      │                      │ No connection needed.   │
└─────────────────┴──────────────────────┴────────────────────────┘
```

**The AI chat is just a tab in your browser.** There's no plugin, no GitHub connection, no API required to use it. You copy a prompt file, paste it into Claude.ai or ChatGPT, share your career materials, and the AI helps you build `profile.json`. When it's done, you copy the output and save it as a file on your machine. That's the whole loop.

**Terminal is the glue.** `brainstorm.sh` assembles your prompt and copies it to clipboard — one command, then paste into your AI chat. `generate.js` reads your local files, calls the AI, and writes an HTML file. Everything runs locally on your machine.

**Your private data never touches GitHub.** The repo contains the pipeline — prompts, templates, scripts. Your profile, your briefs, your output pages: all gitignored, all local.

---

## Modes — pick yours before starting

FORA works in three modes. You don't need an API key to get a real output.

```
┌──────────────────────────────────────────────────────────────────────┐
│  MODE 1 — Fully manual              FREE, zero API keys              │
│                                                                      │
│  brainstorm.sh → paste into AI chat → save brief                     │
│  paste codegen-prompt.md + brief into AI chat → copy HTML manually   │
│  drag output folder to Netlify drop → live URL                       │
│                                                                      │
│  Best for: trying FORA for the first time, no API keys yet           │
├──────────────────────────────────────────────────────────────────────┤
│  MODE 2A — Automated codegen        Needs: Anthropic API key         │
│                                                                      │
│  brainstorm.sh → paste into AI chat → save brief                     │
│  node generate.js --run brief.json → HTML written automatically      │
│  drag output folder to Netlify drop → live URL                       │
│                                                                      │
│  Best for: regular use, no Vercel account                            │
├──────────────────────────────────────────────────────────────────────┤
│  MODE 2B — Manual codegen + auto deploy   Needs: Vercel only ★       │
│                                                                      │
│  brainstorm.sh → paste into AI chat → save brief                     │
│  paste codegen-prompt.md + brief into AI chat → save HTML manually   │
│  node generate.js --deploy brief.json → live URL returned            │
│                                                                      │
│  Best for: designers who prefer AI chat for generation but want      │
│  a permanent URL without drag-and-drop. Zero Anthropic cost.         │
├──────────────────────────────────────────────────────────────────────┤
│  MODE 3 — Fully automated           Needs: Anthropic + Vercel        │
│                                                                      │
│  node generate.js --publish brief.json → live URL returned           │
│                                                                      │
│  Best for: sending the URL in a cold message the same day            │
└──────────────────────────────────────────────────────────────────────┘

★ Mode 2B is the most practical starting point — automated deploy with zero API cost.
  Anthropic and Vercel keys are independent. You only need what your mode requires.
```

Steps 1–5 are the same for all modes. Steps 6–7 diverge based on mode.

---

## What you'll build

By the end of this guide:

```
✓ A private career knowledge base (profile.json)
✓ A brainstorm run against a real job description
✓ A personalised application landing page
✓ A live URL you can send in a cold message (Mode 3 only)

Result: https://fora-pages.vercel.app/company-role
```

---

## Time breakdown

| Step | What you're doing | Required? | Time |
|------|-------------------|-----------|-----:|
| 1 | Fork + clone the repo | Yes | 2 min |
| 2 | Build your profile | Yes | ~15 min |
| 3 | Set up your design system | Optional | 5 min |
| 4 | Configure API keys | Mode 2A + 3 need Anthropic. Mode 2B + 3 need Vercel. | 5 min |
| 5 | Run your first application | Yes | ~15 min |

Step 2 is the only real work — but the AI does the heavy lifting. You paste your resume (or LinkedIn export, or any career notes) and it drafts your full `profile.json`. You review and correct. Most designers are done in 15 minutes. The profile is the foundation everything else builds on — do it once, reuse it forever.

Throughout this guide, steps are labelled by where you're working:
`[Terminal]` `[Browser]` `[Editor]`

---

## Before you start

**Required for all modes:**
- Node.js 18+ installed ([nodejs.org](https://nodejs.org))
- Your resume, LinkedIn export, or any career materials (for Step 2)
- An AI chat open — Claude.ai, ChatGPT, Gemini, or any model you prefer

**Mode 2A + 3 only — automated codegen:**
- An Anthropic API key — [console.anthropic.com](https://console.anthropic.com/settings/keys)

**Mode 2B + 3 only — automated deploy:**
- A Vercel account — [vercel.com](https://vercel.com) (free tier works)
- A Vercel token — [vercel.com/account/tokens](https://vercel.com/account/tokens)

Anthropic and Vercel are independent. You only need what your mode requires.

---

## Step 1 — Fork and clone the repo
*~2 min*

`[Browser]` Go to [github.com/meetshahco/FORA](https://github.com/meetshahco/FORA) and click **Fork** (top right). This creates your own copy at `github.com/yourhandle/FORA`. You only need to do this once.

`[Terminal]` Clone your fork and run the setup script:
```bash
git clone https://github.com/yourhandle/FORA.git
cd FORA
chmod +x setup.sh brainstorm.sh
./setup.sh
```

Replace `yourhandle` with your GitHub username.

`setup.sh` is a re-runnable health check. It verifies your environment, walks you through mode selection and API keys, and tells you exactly what's missing. Run it anytime — first setup, after changing keys, or on a new machine.

**You should now have:**
```
✓ FORA/ folder on your machine
✓ Node version confirmed
✓ Mode selected and .env written (if using Mode 2B/3)
```

---

## Step 2 — Build your profile
*~15 min — the AI does the heavy lifting*

Your profile is your private career knowledge base. It lives only on your machine and is the source of truth for every application you generate. Build it once, update it as your work grows.

`[Browser]` Open any AI chat — Claude.ai, ChatGPT, Gemini, Cursor, whatever you use.

`[Editor]` Open `prompts/profile-builder-prompt.md` and copy the full contents.

`[Browser]` Paste it into your AI chat, then share your raw materials in the same message — paste your resume text, LinkedIn export, or any career notes you have. The AI drafts a complete `profile.json` from whatever you give it, then walks you through reviewing it section by section. You correct anything that's wrong or missing.

The more you share, the richer the profile. But even a resume paste is enough to get started.

`[Editor]` When you're happy with the output, save the JSON to:

```
profile/profile.json
```

**You should now have:**
```
✓ profile/profile.json
```

This file is gitignored — it will never be committed or pushed.

**Want to try FORA quickly before investing in a full profile?**
See `examples/` — a complete worked example with a fictional designer's profile, brief, and generated page. You can run it end-to-end without building your own profile first.

---

## Step 3 — Set up your design system
*~5 min*

Your design system is the visual baseline for every page you generate. The default is clean, neutral, and typographic — designed to look intentional without being templated.

**Option A — Use the defaults (recommended for your first run)**
Skip this step entirely. The defaults work well out of the box. Come back to this once you've generated your first page and know what you want to change.

**Option B — Configure it to match your personal brand**
`[Browser]` Open any AI chat. Paste `prompts/ds-builder-prompt.md`.

Then share any combination of:
- Your portfolio URL
- A link to your public design system or Storybook
- A DS file (Figma tokens JSON, CSS variables, anything)
- A plain description of your visual style

The assistant extracts your visual language, asks a few focused questions, and outputs a complete configured `design-system/default.md`. Save it and you're done.

`[Editor]` Or skip the AI and edit `design-system/default.md` directly — it's a plain markdown file with annotated tokens.

**You should now have:**
```
✓ design-system/default.md  (already in the repo — edit or leave as-is)
```

---

## Step 4 — Configure environment variables
*~5 min — skip if using Mode 1 (manual, zero cost)*

FORA works without any API keys in fully manual mode. Configure this step only if you want automated codegen (`--run`) or automated deploy (`--publish`).

`[Terminal]`
```bash
cp .env.example .env
```

`[Editor]` Open `.env` and fill in what you need:

```
# For generate.js --run (automated codegen)
ANTHROPIC_API_KEY=your_key_here

# For generate.js --publish (automated deploy to Vercel)
VERCEL_TOKEN=your_vercel_token
VERCEL_PROJECT_NAME=fora-pages
```

To get your Vercel token: `[Browser]` vercel.com/account/tokens → Create Token.

If you're skipping automated deploy, you can use Netlify drop, GitHub Pages, or any static host — `generate.js --run` produces a plain HTML file that works anywhere.

**You should now have (if applicable):**
```
✓ .env with your keys
```

---

## Step 5 — Run your first brainstorm
*~15 min*

Here's what happens in this step and the next:

```
  Your machine                  AI chat (browser tab)            Your machine
  ─────────────                 ─────────────────────            ─────────────
  brainstorm.sh                                                  
  + profile.json   ──────────→  paste once                      
  + JD text                     ↓                               
                                brainstorm conversation          
                                ↓                               
                   ←──────────  content_brief.json              
  save to                                                        
  briefs/[slug].json                                             
       ↓                                                         
  generate.js          (Mode 2+3 only: calls Anthropic API)      
       ↓                                                         
  output/[slug]/                                                 
  index.html       ──────────→  open in browser                 
```

Find a job description you want to apply to. Copy the URL.

`[Terminal]`
```bash
./brainstorm.sh https://company.com/jobs/senior-designer
```

This fetches the JD, assembles the brainstorm prompt with your `profile.json`, and copies everything to your clipboard.

`[Browser]` Open any AI chat and paste. The FORA brainstorm agent will:
1. Analyse the JD and score the match against your profile
2. Propose content for all three acts — who you are, what you've done, what you'll bring
3. Ask if you have any visuals to attach (screenshots, Loom links, Figma URLs)
4. Ask for your input or refinements
5. Lock a `content_brief.json` and give you an assets checklist

`[Editor]` Save the brief the agent outputs:
```
briefs/acme-senior-designer.json
```

`[Terminal]` If the agent listed any local files in the assets checklist, drop them in:
```bash
# e.g. cp ~/Desktop/kwikpay-dashboard.png assets/
```

**You should now have:**
```
✓ briefs/
    acme-senior-designer.json
✓ assets/
    [any local files you attached]
```

Brief files are gitignored — they won't be committed.

---

## Step 6 — Generate your page
*~2 min (Mode 2A + 3) or ~15 min (Mode 1 + 2B)*

**Mode 2A + 3 — Automated codegen (Anthropic API key required):**

`[Terminal]`
```bash
node generate.js --run briefs/acme-senior-designer.json
```

This calls the API per section, assembles your page, and writes it locally.

**Mode 1 + 2B — Manual codegen (no Anthropic key needed):**

`[Browser]` Open any AI chat. Paste `prompts/codegen-prompt.md`, then paste the contents of your brief. Ask the assistant to generate each section one at a time.

`[Editor]` Create the output folder and save the HTML:
```
output/acme-senior-designer/index.html
```

`[Terminal]` Preview your page:
```bash
open output/acme-senior-designer/index.html
# or on Windows/Linux: use the file:// path printed by generate.js --run
```

**You should now have:**
```
✓ output/
    acme-senior-designer/
        index.html
```

If something looks off, edit the brief and re-run (or re-paste into AI chat). The brief is the source of truth.

---

## Step 7 — Deploy
*~2 min — Mode 2B + 3 only*

**Mode 2B — Manual codegen + auto deploy (Vercel, no Anthropic key):**

You've already generated `output/acme-senior-designer/index.html` manually in Step 6.
Now deploy it with one command:

`[Terminal]`
```bash
node generate.js --deploy briefs/acme-senior-designer.json
```

Returns a live URL: `https://fora-pages.vercel.app/acme-senior-designer`

**Mode 3 — Fully automated (Anthropic + Vercel):**

`[Terminal]`
```bash
node generate.js --publish briefs/acme-senior-designer.json
```

Generates the page and deploys in one command.

**Both modes:** Your Vercel project must exist before the first deploy — `[Browser]` create it once at [vercel.com/new](https://vercel.com/new) (empty project, no framework, no git connection needed).

---

**No Vercel? Use Netlify drop instead (Mode 1 + 2A):**

`[Browser]` Go to [app.netlify.com/drop](https://app.netlify.com/drop), drag your `output/acme-senior-designer/` folder in. Done — free, no account needed.

The output is a single self-contained `index.html`. It works on any static host: GitHub Pages, Cloudflare Pages, S3 — anything.

**You should now have:**
```
✓ A live URL to send
```

---

## Maintaining FORA

**Update your profile** — when you ship new work, get promoted, or change roles:

`[Browser]` Open a new AI chat. Paste `prompts/profile-builder-prompt.md`, then paste your current `profile.json` and describe what changed ("I just shipped X at Y company — here are the details"). The AI merges the update. Save the output back to `profile/profile.json`.

Or `[Editor]` edit `profile/profile.json` directly — the schema has inline instructions on every field.

---

**Update your design system** — when you rebrand or want a different visual feel:

`[Browser]` Open a new AI chat. Paste `prompts/ds-builder-prompt.md`. Share your portfolio URL, a DS file, or just describe your aesthetic. The AI outputs a configured `design-system/default.md`. Save it.

Or `[Editor]` edit `design-system/default.md` directly — all tokens are in the `TOKEN BLOCK` section at the top.

---

**Switch mode** — if you get an API key or want to change your setup:

`[Terminal]`
```bash
./setup.sh
```

Select "switch mode" when prompted. Your `.env` is rewritten.

---

**Health check** — if something stops working:

`[Terminal]`
```bash
./setup.sh --check
```

Runs all five checks silently, reports exactly what's missing.

---

**Re-run an existing application** — if you want to tweak the brief and regenerate:

`[Editor]` Edit `briefs/[slug].json` directly.

`[Terminal]`
```bash
./run.sh --brief briefs/[slug].json
```

Skips the brainstorm, goes straight to generate and deploy.

---

## What's next

**Apply again.** `[Terminal]` Run `./run.sh` with a new JD URL — it handles brainstorm, generate, and deploy in one guided flow. Your profile stays — each application takes 15–20 minutes once you're set up.

**Update your profile.** When you ship new work, `[Editor]` open `profile/profile.json` and update the relevant entry. Or `[Browser]` re-run `profile-builder-prompt.md` with your current profile + what changed — the assistant handles the merge.

**Customise your design system.** `[Editor]` Edit `design-system/default.md` to adjust colours, typography, or spacing. Changes apply to every page you generate from that point.

**Track your applications.** Application history tracking is coming in V1 — a local `applications/applications.json` that logs every brief you've run, every page you've deployed, and every response. The system gets richer with every application.

---

## Troubleshooting

**`brainstorm.sh` says permission denied**

`[Terminal]`
```bash
chmod +x brainstorm.sh
```

**generate.js fails with API error**

`[Editor]` Check your `ANTHROPIC_API_KEY` in `.env`. Make sure there are no extra spaces or quotes.

**Vercel deploy fails**

`[Editor]` Check `VERCEL_TOKEN` and `VERCEL_PROJECT_NAME` in `.env`. Your Vercel project must exist before the first deploy.

**The page looks unstyled**

Check that `design-system/default.md` exists. It ships with the repo — if it's missing, re-clone or restore it from git.

**brainstorm.sh fetched an empty or broken JD**

Some job boards block automated fetches. `[Browser]` Copy the JD text manually, open your AI chat, and paste `prompts/brainstorm-prompt.md` + your `profile.json` + the JD text directly.
