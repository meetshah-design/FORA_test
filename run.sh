#!/usr/bin/env bash
# FORA — run.sh
# Version: 1.0.0
#
# Per-application script. Run this for every new job you apply to.
# It guides you through brainstorm → generate → deploy in one flow.
#
# Usage:
#   ./run.sh                              — interactive, prompts for JD URL
#   ./run.sh https://company.com/jobs/x  — pass JD URL directly
#   ./run.sh --brief briefs/[slug].json  — skip brainstorm, use existing brief

set -e

# ── Colours ──────────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
DIM='\033[2m'
CYAN='\033[0;36m'
RESET='\033[0m'

ok()   { echo -e "${GREEN}✓${RESET} $1"; }
fail() { echo -e "${RED}✗${RESET} $1"; }
warn() { echo -e "${YELLOW}⚠${RESET}  $1"; }
info() { echo -e "${BOLD}→${RESET} $1"; }
dim()  { echo -e "${DIM}$1${RESET}"; }
step() { echo -e "\n${BOLD}${CYAN}[$1]${RESET} ${BOLD}$2${RESET}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

JD_URL=""
BRIEF_PATH=""
SKIP_BRAINSTORM=false

# ── Parse args ────────────────────────────────────────────────────────────────
if [[ "$1" == "--brief" && -n "$2" ]]; then
  BRIEF_PATH="$2"
  SKIP_BRAINSTORM=true
elif [[ "$1" == http* ]]; then
  JD_URL="$1"
fi

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}FORA — New Application${RESET}"
echo "──────────────────────────────────────────────────────"

# ── Pre-flight checks ─────────────────────────────────────────────────────────

# Check setup has been run
if [[ ! -f "profile/profile.json" ]]; then
  fail "profile/profile.json not found."
  echo ""
  echo "  Run ./setup.sh first to complete your setup."
  echo ""
  exit 1
fi

if [[ ! -f "design-system/default.md" ]]; then
  fail "design-system/default.md not found."
  echo ""
  echo "  Run ./setup.sh to restore your setup."
  echo ""
  exit 1
fi

# Load .env
ENV_FILE=".env"
ANTHROPIC_KEY=""
VERCEL_TOKEN=""
VERCEL_PROJECT="fora-pages"

if [[ -f "$ENV_FILE" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    k="${line%%=*}"; v="${line#*=}"
    v="${v%\"*}"; v="${v#\"}"
    case "$k" in
      ANTHROPIC_API_KEY)   ANTHROPIC_KEY="$v" ;;
      VERCEL_TOKEN)        VERCEL_TOKEN="$v" ;;
      VERCEL_PROJECT_NAME) VERCEL_PROJECT="$v" ;;
    esac
  done < "$ENV_FILE"
fi

# Determine mode
if [[ -n "$ANTHROPIC_KEY" && -n "$VERCEL_TOKEN" ]]; then
  MODE=3
  MODE_LABEL="Mode 3 — fully automated"
elif [[ -n "$ANTHROPIC_KEY" ]]; then
  MODE="2a"
  MODE_LABEL="Mode 2A — auto codegen"
elif [[ -n "$VERCEL_TOKEN" ]]; then
  MODE="2b"
  MODE_LABEL="Mode 2B — manual codegen, auto deploy"
else
  MODE=1
  MODE_LABEL="Mode 1 — fully manual"
fi

dim "  $MODE_LABEL"
dim "  Run ./setup.sh to switch mode anytime"

# ════════════════════════════════════════════════════════════════════════════
# STEP 1 — BRAINSTORM
# ════════════════════════════════════════════════════════════════════════════

if $SKIP_BRAINSTORM; then
  # Brief passed directly — validate and skip to generate
  if [[ ! -f "$BRIEF_PATH" ]]; then
    fail "Brief not found: $BRIEF_PATH"
    echo ""
    exit 1
  fi
  ok "Using existing brief: $BRIEF_PATH"

else
  step "1/3" "Brainstorm"

  # Get JD URL if not passed as arg
  if [[ -z "$JD_URL" ]]; then
    echo ""
    echo -e "  Paste the job description URL:"
    echo -e "  ${DIM}(or press Enter to copy the prompt manually)${RESET}"
    read -rp "  → " JD_URL
  fi

  if [[ -n "$JD_URL" ]]; then
    echo ""
    info "Fetching JD and assembling prompt..."
    if bash brainstorm.sh "$JD_URL" 2>/dev/null; then
      echo ""
      ok "Prompt copied to clipboard"
    else
      warn "Could not fetch JD automatically."
      echo ""
      echo "  Some job boards block automated fetches."
      echo "  Fallback: copy the JD text manually and paste it into your AI chat"
      echo "  along with the contents of prompts/brainstorm-prompt.md and your profile.json"
      echo ""
    fi
  else
    # Manual fallback — tell them what to paste
    echo ""
    info "Manual brainstorm"
    echo ""
    echo "  Open a new AI chat and paste these three things in one message:"
    echo ""
    echo "  1. Contents of: prompts/brainstorm-prompt.md"
    echo "  2. Contents of: profile/profile.json"
    echo "  3. The full job description text"
    echo ""
  fi

  # Brainstorm conversation happens in AI chat
  echo ""
  echo -e "${BOLD}  Now complete the brainstorm in your AI chat.${RESET}"
  echo ""
  echo "  The AI will:"
  echo "  → Analyse the JD and score the match"
  echo "  → Propose content for all three acts"
  echo "  → Ask about visuals (optional)"
  echo "  → Output a content_brief.json"
  echo ""
  echo "  When done, save the brief the AI outputs to the briefs/ folder."
  echo "  Example: briefs/acme-senior-designer.json"
  echo ""
  echo -e "  ${DIM}What filename did you save the brief as?${RESET}"
  echo -e "  ${DIM}(just the name, e.g. acme-senior-designer.json)${RESET}"
  read -rp "  → " BRIEF_NAME

  # Clean up the input — strip briefs/ prefix if they included it
  BRIEF_NAME="${BRIEF_NAME#briefs/}"
  BRIEF_NAME="${BRIEF_NAME%.json}.json"
  BRIEF_PATH="briefs/$BRIEF_NAME"

  if [[ ! -f "$BRIEF_PATH" ]]; then
    fail "Brief not found: $BRIEF_PATH"
    echo ""
    echo "  Make sure you saved the file to: $BRIEF_PATH"
    echo "  Then run: ./run.sh --brief $BRIEF_PATH"
    echo ""
    exit 1
  fi

  ok "Brief found: $BRIEF_PATH"
fi

# ════════════════════════════════════════════════════════════════════════════
# STEP 2 — GENERATE
# ════════════════════════════════════════════════════════════════════════════
step "2/3" "Generate"
echo ""

# Derive slug from brief
SLUG=$(node -e "
  try {
    const b = require('./$BRIEF_PATH');
    const s = (b._meta.company + '-' + b._meta.role)
      .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-\$/g, '');
    console.log(s);
  } catch(e) { console.log(''); }
" 2>/dev/null)

if [[ -z "$SLUG" ]]; then
  fail "Could not read brief. Make sure $BRIEF_PATH is valid JSON."
  echo ""
  exit 1
fi

OUTPUT_FILE="output/$SLUG/index.html"

case "$MODE" in
  3|2a)
    info "Running generate.js --run..."
    echo ""
    if node generate.js --run "$BRIEF_PATH"; then
      echo ""
      ok "Page generated → $OUTPUT_FILE"
    else
      fail "generate.js failed. Check the error above."
      echo ""
      echo "  Common fixes:"
      echo "  → Check ANTHROPIC_API_KEY in .env is valid"
      echo "  → Check $BRIEF_PATH is valid JSON"
      echo "  → Run ./setup.sh --check to verify your setup"
      echo ""
      exit 1
    fi
    ;;

  2b|1)
    # Manual codegen
    echo -e "${BOLD}  Manual codegen step.${RESET}"
    echo ""
    echo "  Open a new AI chat and paste these two things:"
    echo ""
    echo "  1. Contents of: prompts/codegen-prompt.md"
    echo "  2. Contents of: $BRIEF_PATH"
    echo ""
    echo "  Ask the AI to generate each section. When all sections are ready,"
    echo "  assemble them and save the complete HTML to:"
    echo ""
    echo "  → $OUTPUT_FILE"
    echo ""
    echo -e "  ${DIM}Press Enter when $OUTPUT_FILE is saved...${RESET}"
    read -r

    if [[ ! -f "$OUTPUT_FILE" ]]; then
      fail "File not found: $OUTPUT_FILE"
      echo ""
      echo "  Make sure you saved the HTML to exactly: $OUTPUT_FILE"
      echo "  (create the folder output/$SLUG/ if it doesn't exist)"
      echo "  Then run: ./run.sh --brief $BRIEF_PATH"
      echo ""
      exit 1
    fi

    ok "Page found → $OUTPUT_FILE"
    ;;
esac

# Preview
echo ""
ABS_PATH="$(cd "$(dirname "$OUTPUT_FILE")" && pwd)/$(basename "$OUTPUT_FILE")"
echo -e "  ${BOLD}Preview:${RESET}"
echo -e "  ${DIM}file://$ABS_PATH${RESET}"
echo ""
echo -e "  ${DIM}Open that path in your browser to review before deploying.${RESET}"
echo ""
echo -e "  ${DIM}Happy with it? (Y/n)${RESET}"
read -rp "  → " LOOKS_GOOD

if [[ "$LOOKS_GOOD" =~ ^[Nn]$ ]]; then
  echo ""
  echo "  No problem. Edit your brief and re-run:"
  echo ""
  case "$MODE" in
    3|2a) echo "  node generate.js --run $BRIEF_PATH" ;;
    2b|1) echo "  Re-paste the brief into your AI chat and regenerate the sections." ;;
  esac
  echo ""
  echo "  Or re-run this script when you're ready:"
  echo "  ./run.sh --brief $BRIEF_PATH"
  echo ""
  exit 0
fi

# ════════════════════════════════════════════════════════════════════════════
# STEP 3 — DEPLOY
# ════════════════════════════════════════════════════════════════════════════
step "3/3" "Deploy"
echo ""

case "$MODE" in
  3)
    info "Running generate.js --publish..."
    echo ""
    if node generate.js --publish "$BRIEF_PATH"; then
      echo ""
      ok "Done."
    else
      fail "Deploy failed. Check the error above."
      echo ""
      echo "  Common fixes:"
      echo "  → Check VERCEL_TOKEN in .env is valid"
      echo "  → Make sure your Vercel project exists at vercel.com/new"
      echo ""
      exit 1
    fi
    ;;

  2b)
    info "Running generate.js --deploy..."
    echo ""
    if node generate.js --deploy "$BRIEF_PATH"; then
      echo ""
      ok "Done."
    else
      fail "Deploy failed. Check the error above."
      echo ""
      echo "  Common fixes:"
      echo "  → Check VERCEL_TOKEN in .env is valid"
      echo "  → Make sure your Vercel project exists at vercel.com/new"
      echo ""
      exit 1
    fi
    ;;

  2a|1)
    echo "  Deploy manually — pick any of these:"
    echo ""
    echo "  Netlify drop (free, no account needed):"
    echo "  → Go to https://app.netlify.com/drop"
    echo "  → Drag your output/$SLUG/ folder in"
    echo ""
    echo "  GitHub Pages, Cloudflare Pages, or any static host:"
    echo "  → The output is a single self-contained index.html"
    echo ""
    echo "  Add Vercel for automated deploy (no Anthropic key needed):"
    echo "  → Run ./setup.sh and switch to Mode 2B"
    echo ""
    ;;
esac

# ════════════════════════════════════════════════════════════════════════════
# DONE
# ════════════════════════════════════════════════════════════════════════════
echo ""
echo "──────────────────────────────────────────────────────"
echo -e "${GREEN}${BOLD}Application ready.${RESET}"
echo ""
echo "  Next application: ./run.sh [JD URL]"
echo "  Check your setup: ./setup.sh --check"
echo ""
