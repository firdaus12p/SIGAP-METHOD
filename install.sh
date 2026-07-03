#!/bin/bash
set -e

REPO_URL="https://github.com/firdaus12p/MACCA-METHOD"
TMP_DIR=$(mktemp -d)
SELECTED=()
CLAUDE_COPIED=0

# ─── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo "  ╭─────────────────────────────────────────╮"
echo "  │      MACCA — AI Spec-Driven Dev          │"
echo "  ╰─────────────────────────────────────────╯"
echo ""

# ─── Clone & copy skills ────────────────────────────────────────────────────────
echo "  Mengunduh skills..."
if ! git clone --depth 1 "$REPO_URL" "$TMP_DIR/macca" --quiet 2>&1; then
  echo ""
  echo "  ✗ Gagal mengunduh. Periksa:"
  echo "    · Koneksi internet aktif"
  echo "    · Repo tersedia di: $REPO_URL"
  rm -rf "$TMP_DIR"
  exit 1
fi

cp -r "$TMP_DIR/macca/.agents/" .
cp "$TMP_DIR/macca/skills-lock.json" .

# ─── Copy skills to a tool's folder ─────────────────────────────────────────────
copy_skills() {
  local DEST="$1"
  mkdir -p "$DEST"
  cp -r .agents/skills/. "$DEST/"
}

# ─── Install per tool ────────────────────────────────────────────────────────────
install_tool() {
  local TOOL="$1"
  case "$TOOL" in
    1|copilot)
      copy_skills .github/skills
      SELECTED+=("copilot")
      echo "  ✓ GitHub Copilot    → .github/skills/"
      ;;
    2|cursor)
      if [[ $CLAUDE_COPIED -eq 0 ]]; then copy_skills .claude/skills; CLAUDE_COPIED=1; fi
      SELECTED+=("cursor")
      echo "  ✓ Cursor            → .claude/skills/ (Claude Code compatible)"
      ;;
    3|claude)
      if [[ $CLAUDE_COPIED -eq 0 ]]; then copy_skills .claude/skills; CLAUDE_COPIED=1; fi
      SELECTED+=("claude")
      echo "  ✓ Claude Code       → .claude/skills/"
      ;;
    4|windsurf)
      copy_skills .windsurf/skills
      SELECTED+=("windsurf")
      echo "  ✓ Windsurf          → .windsurf/skills/"
      ;;
    5|gemini)
      copy_skills .gemini/skills
      SELECTED+=("gemini")
      echo "  ✓ Gemini CLI        → .gemini/skills/"
      ;;
    6|opencode)
      copy_skills .opencode/skill
      SELECTED+=("opencode")
      echo "  ✓ OpenCode          → .opencode/skill/"
      ;;
    7|kilo)
      copy_skills .kilo/skills
      SELECTED+=("kilo")
      echo "  ✓ Kilo Code         → .kilo/skills/"
      ;;
    8|codex)
      SELECTED+=("codex")
      echo "  ✓ Codex (OpenAI)    → .agents/skills/ (format native Codex, tidak ada file tambahan)"
      ;;
    9|kimi)
      copy_skills "$HOME/.config/agents/skills"
      SELECTED+=("kimi")
      echo "  ✓ Kimi CLI          → ~/.config/agents/skills/"
      ;;
  esac
}

# ─── Tool selection (checkbox) ────────────────────────────────────────────────
ALL_TOOL_NAMES=("GitHub Copilot" "Cursor" "Claude Code" "Windsurf" "Gemini CLI" "OpenCode" "Kilo Code" "Codex (OpenAI)" "Kimi CLI")
ALL_TOOL_PATHS=(".github/skills/" ".claude/skills/" ".claude/skills/" ".windsurf/skills/" ".gemini/skills/" ".opencode/skill/" ".kilo/skills/" ".agents/skills/ (native)" "~/.config/agents/skills/")
ALL_TOOL_KEYS=("copilot" "cursor" "claude" "windsurf" "gemini" "opencode" "kilo" "codex" "kimi")
TOOL_SELECTED=()

show_tool_checkboxes() {
  for i in "${!ALL_TOOL_NAMES[@]}"; do
    local mark="[ ]"
    for s in "${TOOL_SELECTED[@]}"; do
      [[ "$s" == "${ALL_TOOL_KEYS[$i]}" ]] && mark="[x]" && break
    done
    printf "    %s %2d. %-20s → %s\n" "$mark" "$((i+1))" "${ALL_TOOL_NAMES[$i]}" "${ALL_TOOL_PATHS[$i]}"
  done
  echo ""
}

toggle_tool() {
  local IDX=$(($1 - 1))
  local KEY="${ALL_TOOL_KEYS[$IDX]}"
  local FOUND=false
  local NEW=()
  for s in "${TOOL_SELECTED[@]}"; do
    [[ "$s" == "$KEY" ]] && FOUND=true || NEW+=("$s")
  done
  if [ "$FOUND" = true ]; then
    TOOL_SELECTED=("${NEW[@]+"${NEW[@]}"}")
  else
    TOOL_SELECTED+=("$KEY")
  fi
}

echo ""
echo "  Pilih AI tool yang kamu gunakan:"
echo "  ketik nomor untuk centang/hapus centang, Enter untuk konfirmasi"
show_tool_checkboxes

while true; do
  read -r -p "  > " INPUT </dev/tty
  [[ -z "$INPUT" ]] && break
  for NUM in $INPUT; do
    [[ "$NUM" =~ ^[0-9]+$ ]] || continue
    IDX=$((NUM - 1))
    [[ $IDX -ge 0 && $IDX -lt ${#ALL_TOOL_KEYS[@]} ]] && toggle_tool "$NUM"
  done
  show_tool_checkboxes
done

if [ ${#TOOL_SELECTED[@]} -eq 0 ]; then
  echo ""
  echo "  Tidak ada AI tool dipilih — menggunakan .agents/skills/ sebagai default."
  SELECTED+=("codex")
else
  echo ""
  echo "  Menyalin skills:"
  for KEY in "${TOOL_SELECTED[@]}"; do
    install_tool "$KEY"
  done
fi

# ─── Save selected tools ───────────────────────────────────────────────────────────
printf '%s\n' "${SELECTED[@]}" > .agents/macca-tools.txt

# ─── Nama developer & project ───────────────────────────────────────────────────────────────────────────────────
echo ""
read -r -p "  Kamu mau di panggil apa? (Kosong = Skip): " DEV_NAME </dev/tty
read -r -p "  Nama project ini apa? (Kosong = Skip): " PROJECT_NAME </dev/tty
if [ -n "$DEV_NAME" ] || [ -n "$PROJECT_NAME" ]; then
  printf '{\n  "name": "%s",\n  "project": "%s"\n}\n' "$DEV_NAME" "$PROJECT_NAME" > .agents/developer-config.json
  [ -n "$DEV_NAME" ]     && echo "  Nama developer disimpan: $DEV_NAME"
  [ -n "$PROJECT_NAME" ] && echo "  Nama project disimpan:   $PROJECT_NAME"
fi

# ─── Cleanup & done ────────────────────────────────────────────────────────────────
rm -rf "$TMP_DIR"
echo ""
echo "  ✓ MACCA installed!"
echo ""
