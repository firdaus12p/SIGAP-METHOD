#!/bin/bash
# set -e dihapus — gunakan error handling eksplisit

REPO_URL="https://github.com/firdaus12p/MACCA-METHOD"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR" 2>/dev/null' INT TERM EXIT

echo ""
echo "  Updating MACCA skills..."

# ─── Backup user configs ──────────────────────────────────────────────────────
CONFIG_BACKUP=""
TOOLS_BACKUP=""
[ -f ".agents/developer-config.json" ] && CONFIG_BACKUP=$(cat ".agents/developer-config.json")
[ -f ".agents/macca-tools.txt" ]        && TOOLS_BACKUP=$(cat ".agents/macca-tools.txt")

# ─── Clone repo ───────────────────────────────────────────────────────────────
if ! git clone --depth 1 "$REPO_URL" "$TMP_DIR/macca" --quiet 2>&1; then
  echo ""
  echo "  ✗ Gagal mengunduh. Periksa:"
  echo "    · Koneksi internet aktif"
  echo "    · Repo tersedia di: $REPO_URL"
  exit 1
fi

# ─── Helper: copy langsung dari temp ke folder tool ──────────────────────────
copy_skills() {
  local DEST="$1"
  mkdir -p "$DEST"
  cp -r "$TMP_DIR/macca/.agents/skills/." "$DEST/"
}

# ─── Update skills langsung ke folder masing-masing tool ─────────────────────
HAS_CODEX=false
if [ -f ".agents/macca-tools.txt" ]; then
  echo "  Memperbarui skills untuk:"
  while IFS= read -r TOOL; do
    case "$TOOL" in
      copilot)  copy_skills .github/skills                 && echo "  ✓ GitHub Copilot  → .github/skills/" ;;
      cursor)   copy_skills .cursor/skills                 && echo "  ✓ Cursor          → .cursor/skills/" ;;
      claude)   copy_skills .claude/skills                 && echo "  ✓ Claude Code     → .claude/skills/" ;;
      windsurf) copy_skills .windsurf/skills               && echo "  ✓ Windsurf        → .windsurf/skills/" ;;
      gemini)   copy_skills .gemini/skills                 && echo "  ✓ Gemini CLI      → .gemini/skills/" ;;
      opencode) copy_skills .opencode/skill                && echo "  ✓ OpenCode        → .opencode/skill/" ;;
      kilo)     copy_skills .kilo/skills                   && echo "  ✓ Kilo Code       → .kilo/skills/" ;;
      codex)    HAS_CODEX=true
                copy_skills .agents/skills                 && echo "  ✓ Codex (OpenAI)  → .agents/skills/" ;;
      kimi)     copy_skills "$HOME/.config/agents/skills"  && echo "  ✓ Kimi CLI        → ~/.config/agents/skills/" ;;
    esac
  done < .agents/macca-tools.txt
else
  echo "  (macca-tools.txt tidak ditemukan — jalankan install ulang untuk memilih tools)"
fi

# ─── Bersihkan .agents/skills/ jika bukan codex ──────────────────────────────
if [ "$HAS_CODEX" = false ]; then
  rm -rf .agents/skills
fi

# ─── Update skills-lock.json ──────────────────────────────────────────────────
cp "$TMP_DIR/macca/skills-lock.json" .

# ─── Restore user configs ─────────────────────────────────────────────────────
mkdir -p .agents
[ -n "$CONFIG_BACKUP" ] && echo "$CONFIG_BACKUP" > .agents/developer-config.json
[ -n "$TOOLS_BACKUP" ]  && echo "$TOOLS_BACKUP"  > .agents/macca-tools.txt

# ─── Cleanup & done ───────────────────────────────────────────────────────────
rm -rf "$TMP_DIR"
trap - INT TERM EXIT
echo ""
echo "  ✓ MACCA updated!"
echo ""
