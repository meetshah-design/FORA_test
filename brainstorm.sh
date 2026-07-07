#!/usr/bin/env bash
# FORA — brainstorm.sh
# Fetches a JD, assembles the brainstorm prompt + your profile.json,
# copies everything to clipboard, then guides you through saving the brief.
#
# Usage:
#   ./brainstorm.sh https://company.com/jobs/senior-designer
#   ./brainstorm.sh                  # will ask you for the URL interactively

set -euo pipefail

# ── Colours for output ──────────────────────────────────────────────────────
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
DIM="\033[2m"
RESET="\033[0m"

ok()   { echo -e "${GREEN}✓${RESET} $1"; }
info() { echo -e "${BOLD}→${RESET} $1"; }
warn() { echo -e "${YELLOW}⚠${RESET}  $1"; }
fail() { echo -e "${RED}✗${RESET} $1"; exit 1; }

# ── Paths ───────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$SCRIPT_DIR/prompts/brainstorm-prompt.md"
PROFILE_FILE="$SCRIPT_DIR/profile/profile.json"
BRIEFS_DIR="$SCRIPT_DIR/briefs"

# ── Check dependencies ───────────────────────────────────────────────────────
check_deps() {
  local missing=()
  command -v curl &>/dev/null || missing+=("curl")
  if ! command -v pbcopy &>/dev/null && \
     ! command -v xclip &>/dev/null && \
     ! command -v xsel  &>/dev/null; then
    missing+=("pbcopy / xclip / xsel (clipboard tool)")
  fi
  if [[ ${#missing[@]} -gt 0 ]]; then
    fail "Missing dependencies: ${missing[*]}"
  fi
}

# ── Copy to clipboard (cross-platform) ──────────────────────────────────────
copy_to_clipboard() {
  local content="$1"
  if command -v pbcopy &>/dev/null; then
    echo "$content" | pbcopy
  elif command -v xclip &>/dev/null; then
    echo "$content" | xclip -selection clipboard
  elif command -v xsel &>/dev/null; then
    echo "$content" | xsel --clipboard --input
  fi
}

# ── Paste from clipboard (cross-platform) ───────────────────────────────────
paste_from_clipboard() {
  if command -v pbpaste &>/dev/null; then
    pbpaste
  elif command -v xclip &>/dev/null; then
    xclip -selection clipboard -o
  elif command -v xsel &>/dev/null; then
    xsel --clipboard --output
  fi
}

# ── Derive slug from URL ─────────────────────────────────────────────────────
derive_slug() {
  local url="$1"
  # Strip protocol, domain, trailing slashes — keep path segments
  echo "$url" \
    | sed 's|https\?://||' \
    | sed 's|www\.||' \
    | awk -F'/' '{for(i=2;i<=NF;i++) printf "%s%s", $i, (i<NF?"-":""); print ""}' \
    | sed 's/[^a-zA-Z0-9-]/-/g' \
    | sed 's/--*/-/g' \
    | sed 's/^-//;s/-$//' \
    | tr '[:upper:]' '[:lower:]' \
    | cut -c1-60
}

# ── Fetch JD text from URL ───────────────────────────────────────────────────
fetch_jd() {
  local url="$1"
  local raw

  info "Fetching job description from $url"

  raw=$(curl -sL --max-time 15 \
    -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    "$url" 2>/dev/null) || fail "Could not fetch URL. Check your connection or paste the JD manually."

  local text
  text=$(echo "$raw" \
    | sed 's/<[^>]*>//g' \
    | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&nbsp;/ /g; s/&#39;/'"'"'/g; s/&quot;/"/g' \
    | sed '/^[[:space:]]*$/d' \
    | tr -s ' ' \
    | head -n 300)

  if [[ -z "$text" ]]; then
    warn "Could not fetch the JD automatically — some job boards block this."
    echo ""
    echo "  Copy the job description text manually from the page,"
    echo "  then paste it into your AI chat alongside the brainstorm prompt."
    echo ""
    echo "  The prompt is already on your clipboard — just add the JD text manually."
    echo ""
    exit 0
  fi

  echo "$text"
}

# ── Save brief interactively ─────────────────────────────────────────────────
save_brief() {
  local slug="$1"
  local brief_path="$BRIEFS_DIR/${slug}.json"

  mkdir -p "$BRIEFS_DIR"

  echo ""
  echo -e "${BOLD}──────────────────────────────────────────────────${RESET}"
  echo -e "${BOLD}Step 2 of 2 — Save the brief${RESET}"
  echo -e "${BOLD}──────────────────────────────────────────────────${RESET}"
  echo ""
  echo "  When the AI gives you the final content_brief.json:"
  echo ""
  echo -e "  ${BOLD}1. Copy the JSON block${RESET} from the AI chat"
  echo -e "  ${BOLD}2. Come back here and press Enter${RESET}"
  echo ""
  read -rp "  Press Enter when you have the JSON copied... "
  echo ""

  # Read from clipboard
  local content
  content=$(paste_from_clipboard 2>/dev/null || true)

  # Fallback: ask user to paste directly in terminal
  if [[ -z "$content" ]]; then
    echo "  Clipboard is empty. Paste the JSON directly below."
    echo -e "  ${DIM}Paste the JSON, then press Ctrl+D on a new line:${RESET}"
    echo ""
    content=$(cat)
  fi

  if [[ -z "$content" ]]; then
    fail "No content received. Run brainstorm.sh again and copy the JSON before pressing Enter."
  fi

  # Validate JSON
  if ! echo "$content" | node -e "process.stdin.resume();process.stdin.setEncoding('utf8');let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{try{JSON.parse(d);process.exit(0)}catch(e){process.exit(1)}});" 2>/dev/null; then
    echo ""
    warn "The content doesn't look like valid JSON."
    echo ""
    echo "  Make sure you copied only the JSON block from the AI chat"
    echo "  (starting with { and ending with }) — not the surrounding text."
    echo ""
    read -rp "  Try again? Copy the JSON and press Enter (or Ctrl+C to exit): "
    content=$(paste_from_clipboard 2>/dev/null || cat)
  fi

  # Save the file
  echo "$content" > "$brief_path"

  echo ""
  ok "Brief saved → briefs/${slug}.json"
  ok "Valid JSON confirmed"
  echo ""
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${BOLD}FORA — Brainstorm${RESET}"
  echo "──────────────────────────────"

  check_deps

  # Get URL
  local jd_url="${1:-}"
  if [[ -z "$jd_url" ]]; then
    echo ""
    read -rp "Job description URL: " jd_url
    echo ""
  fi

  [[ -z "$jd_url" ]] && fail "No URL provided."

  # Derive slug from URL
  local slug
  slug=$(derive_slug "$jd_url")

  # Check required files
  [[ -f "$PROMPT_FILE" ]] || fail "brainstorm-prompt.md not found at $PROMPT_FILE"
  [[ -f "$PROFILE_FILE" ]] || fail "profile.json not found at $PROFILE_FILE

  Build your profile first:
    1. Open a new AI chat (Claude.ai, ChatGPT, etc.)
    2. Run: cat prompts/profile-builder-prompt.md | pbcopy
       then paste into your AI chat
    3. Share your resume or career materials
    4. Copy the JSON output and run: pbpaste > profile/profile.json
    5. Verify: ./setup.sh --check"

  # Fetch JD
  local jd_text
  jd_text=$(fetch_jd "$jd_url")
  ok "Job description fetched ($(echo "$jd_text" | wc -l | tr -d ' ') lines)"

  # Read files
  local prompt profile
  prompt=$(cat "$PROMPT_FILE")
  profile=$(cat "$PROFILE_FILE")

  # Assemble the full paste
  local assembled
  assembled="$(cat <<ASSEMBLED
$prompt

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## DESIGNER PROFILE (profile.json)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

\`\`\`json
$profile
\`\`\`

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## JOB DESCRIPTION
## Source: $jd_url
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$jd_text
ASSEMBLED
)"

  # Copy to clipboard
  copy_to_clipboard "$assembled"

  local char_count=${#assembled}
  local line_count
  line_count=$(echo "$assembled" | wc -l | tr -d ' ')

  echo ""
  ok "Prompt assembled and copied to clipboard ($line_count lines)"
  echo ""
  echo -e "${BOLD}──────────────────────────────────────────────────${RESET}"
  echo -e "${BOLD}Step 1 of 2 — Run the brainstorm${RESET}"
  echo -e "${BOLD}──────────────────────────────────────────────────${RESET}"
  echo ""
  echo "  1. Open your AI chat (Claude.ai, ChatGPT, or any model)"
  echo "  2. Paste  ⌘V  — the full prompt + your profile + JD is ready"
  echo "  3. The agent runs the brainstorm automatically"
  echo "  4. Review and refine the content until you're happy"
  echo "  5. Ask the agent: \"give me the final content_brief.json\""
  echo "  6. Copy the JSON block it outputs"
  echo ""

  # Save the brief
  save_brief "$slug"

  # Print next step based on .env mode
  local env_file="$SCRIPT_DIR/.env"
  local has_anthropic=false
  local has_vercel=false

  if [[ -f "$env_file" ]]; then
    grep -q "^ANTHROPIC_API_KEY=.\+" "$env_file" 2>/dev/null && has_anthropic=true
    grep -q "^VERCEL_TOKEN=.\+" "$env_file" 2>/dev/null && has_vercel=true
  fi

  echo -e "${BOLD}Next step:${RESET}"
  echo ""
  if [[ "$has_anthropic" == true && "$has_vercel" == true ]]; then
    echo -e "  ${BOLD}node generate.js --publish briefs/${slug}.json${RESET}"
    echo -e "  ${DIM}(Mode 3 — generates page + deploys to Vercel)${RESET}"
  elif [[ "$has_anthropic" == true ]]; then
    echo -e "  ${BOLD}node generate.js --run briefs/${slug}.json${RESET}"
    echo -e "  ${DIM}(Mode 2A — generates page locally)${RESET}"
  elif [[ "$has_vercel" == true ]]; then
    echo ""
    echo "  Mode 2B — paste the codegen prompt into your AI chat:"
    echo -e "  ${DIM}cat prompts/codegen-prompt.md | pbcopy${RESET}"
    echo "  Paste into AI chat with your brief. Save the HTML to:"
    echo -e "  ${BOLD}output/${slug}/index.html${RESET}"
    echo ""
    echo "  Then deploy:"
    echo -e "  ${BOLD}node generate.js --deploy briefs/${slug}.json${RESET}"
  else
    echo "  Mode 1 — paste the codegen prompt into your AI chat:"
    echo -e "  ${DIM}cat prompts/codegen-prompt.md | pbcopy${RESET}"
    echo "  Paste into AI chat with your brief. Save the HTML to:"
    echo -e "  ${BOLD}output/${slug}/index.html${RESET}"
    echo "  Then drag the output/${slug}/ folder to https://app.netlify.com/drop"
  fi
  echo ""
}

main "$@"
