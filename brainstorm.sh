#!/usr/bin/env bash
# FORA — brainstorm.sh
# Fetches a JD, assembles the brainstorm prompt + your profile.json,
# and copies everything to clipboard. Paste once into any AI chat.
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
RESET="\033[0m"

ok()   { echo -e "${GREEN}✓${RESET} $1"; }
info() { echo -e "${BOLD}→${RESET} $1"; }
warn() { echo -e "${YELLOW}⚠${RESET}  $1"; }
fail() { echo -e "${RED}✗${RESET} $1"; exit 1; }

# ── Paths ───────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$SCRIPT_DIR/prompts/brainstorm-prompt.md"
PROFILE_FILE="$SCRIPT_DIR/profile/profile.json"

# ── Check dependencies ───────────────────────────────────────────────────────
check_deps() {
  local missing=()

  # curl for fetching JD
  command -v curl &>/dev/null || missing+=("curl")

  # clipboard: pbcopy (macOS), xclip or xsel (Linux)
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

# ── Fetch JD text from URL ───────────────────────────────────────────────────
fetch_jd() {
  local url="$1"
  local raw

  info "Fetching job description from $url"

  # Fetch raw HTML, strip tags crudely with sed, collapse whitespace
  raw=$(curl -sL --max-time 15 \
    -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    "$url" 2>/dev/null) || fail "Could not fetch URL. Check your connection or paste the JD manually."

  # Strip HTML tags, decode common entities, collapse blank lines
  local text
  text=$(echo "$raw" \
    | sed 's/<[^>]*>//g' \
    | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&nbsp;/ /g; s/&#39;/'"'"'/g; s/&quot;/"/g' \
    | sed '/^[[:space:]]*$/d' \
    | tr -s ' ' \
    | head -n 300)

  if [[ -z "$text" ]]; then
    fail "Fetched page was empty or unreadable. Try pasting the JD text manually (see Option B in brainstorm-prompt.md)."
  fi

  echo "$text"
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

  # Check required files
  [[ -f "$PROMPT_FILE" ]] || fail "brainstorm-prompt.md not found at $PROMPT_FILE"
  [[ -f "$PROFILE_FILE" ]] || fail "profile.json not found at $PROFILE_FILE

  Run profile-builder-prompt.md first to create your profile:
    1. Open a new AI chat
    2. Paste the contents of prompts/profile-builder-prompt.md
    3. Share your resume or career materials
    4. Save the output to profile/profile.json"

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
  ok "Copied to clipboard ($line_count lines, ~$char_count chars)"
  echo ""
  echo -e "${BOLD}Next step:${RESET}"
  echo "  1. Open a new AI chat (Claude.ai, Cursor, etc.)"
  echo "  2. Paste  ⌘V  — the full prompt + profile + JD is ready"
  echo "  3. The agent runs Phase 1 automatically"
  echo "  4. Review the brainstorm, refine if needed"
  echo "  5. When the agent outputs content_brief.json, save it:"
  echo ""
  echo "       briefs/[company-role-slug].json"
  echo ""
  echo "  6. Then run:"
  echo ""
  echo -e "       ${BOLD}node generate.js --run briefs/[company-role-slug].json${RESET}"
  echo ""
}

main "$@"
