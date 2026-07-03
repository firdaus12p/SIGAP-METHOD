#!/bin/bash
set -e

REPO_URL="https://github.com/firdaus12p/SIGAP---METHOD"
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

# ─── Tool selection menu ──────────────────────────────────────────────────────────
echo ""
echo "  Pilih AI tool yang kamu gunakan:"
echo "  (ketik nomor, pisahkan spasi — contoh: 1 3 4)"
echo "  (ketik 0 untuk pilih semua)"
echo ""
echo "  [1] GitHub Copilot       → .github/skills/"
echo "  [2] Cursor               → .claude/skills/  (Claude Code compatible)"
echo "  [3] Claude Code          → .claude/skills/"
echo "  [4] Windsurf             → .windsurf/skills/"
echo "  [5] Gemini CLI           → .gemini/skills/"
echo "  [6] OpenCode             → .opencode/skill/"
echo "  [7] Kilo Code            → .kilo/skills/"
echo "  [8] Codex (OpenAI)       → .agents/skills/  (native — tidak perlu konfigurasi tambahan)"
echo "  [9] Kimi CLI             → ~/.config/agents/skills/"
echo ""
read -r -p "  Pilihanmu: " CHOICES </dev/tty

if [[ -z "$CHOICES" ]]; then
  echo ""
  echo "  Tidak ada pilihan — menggunakan .agents/skills/ sebagai default."
  echo "  ℹ  Format ini kompatibel dengan:"
  echo "      Codex (OpenAI) · GitHub Copilot · Gemini CLI · Windsurf · Continue.dev"
  SELECTED+=("codex")
else
  [[ "$CHOICES" == "0" ]] && CHOICES="1 2 3 4 5 6 7 8 9"
  echo ""
  echo "  Menyalin skills:"
  for NUM in $CHOICES; do
    install_tool "$NUM"
  done
fi

# ─── Save selected tools ───────────────────────────────────────────────────────────
printf '%s\n' "${SELECTED[@]}" > .agents/macca-tools.txt

# ─── Nama developer & project ───────────────────────────────────────────────────────────────────────────────────
echo ""
read -r -p "  Kamu mau di panggil apa? (kosongkan untuk skip): " DEV_NAME </dev/tty
read -r -p "  Nama project ini apa?    (kosongkan untuk skip): " PROJECT_NAME </dev/tty
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
