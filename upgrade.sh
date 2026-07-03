#!/bin/bash
set -e

REPO_URL="https://github.com/firdaus12p/macca-workflow"
TMP_DIR=$(mktemp -d)

echo ""
echo "  Updating MACCA skills..."

# ─── Backup user configs ──────────────────────────────────────────────────────
CONFIG_BACKUP=""
[ -f ".agents/developer-config.json" ] && CONFIG_BACKUP=$(cat ".agents/developer-config.json")
TOOLS_BACKUP=""
[ -f ".agents/macca-tools.txt" ] && TOOLS_BACKUP=$(cat ".agents/macca-tools.txt")

# ─── Update skills ────────────────────────────────────────────────────────────
if ! git clone --depth 1 "$REPO_URL" "$TMP_DIR/macca" --quiet 2>&1; then
  echo ""
  echo "  ✗ Gagal mengunduh. Periksa:"
  echo "    · Koneksi internet aktif"
  echo "    · Repo tersedia di: $REPO_URL"
  rm -rf "$TMP_DIR"
  exit 1
fi

rm -rf .agents
cp -r "$TMP_DIR/macca/.agents/" .
cp "$TMP_DIR/macca/skills-lock.json" .

# ─── Restore user configs ─────────────────────────────────────────────────────
[ -n "$CONFIG_BACKUP" ] && echo "$CONFIG_BACKUP" > .agents/developer-config.json
[ -n "$TOOLS_BACKUP" ]  && echo "$TOOLS_BACKUP"  > .agents/macca-tools.txt

# ─── Helper ───────────────────────────────────────────────────────────────────
copy_skills() {
  local DEST="$1"
  mkdir -p "$DEST"
  cp -r .agents/skills/. "$DEST/"
}

# ─── Re-copy updated skills to each tool's folder ────────────────────────────
if [ -f ".agents/macca-tools.txt" ]; then
  CLAUDE_COPIED=0
  echo "  Memperbarui skills untuk:"
  while IFS= read -r TOOL; do
    case "$TOOL" in
      copilot)  copy_skills .github/skills   && echo "  ✓ GitHub Copilot" ;;
      cursor)
        if [[ $CLAUDE_COPIED -eq 0 ]]; then copy_skills .claude/skills; CLAUDE_COPIED=1; fi
        echo "  ✓ Cursor"
        ;;
      claude)
        if [[ $CLAUDE_COPIED -eq 0 ]]; then copy_skills .claude/skills; CLAUDE_COPIED=1; fi
        echo "  ✓ Claude Code"
        ;;
      windsurf) copy_skills .windsurf/skills && echo "  ✓ Windsurf" ;;
      gemini)   copy_skills .gemini/skills   && echo "  ✓ Gemini CLI" ;;
      opencode) copy_skills .opencode/skill  && echo "  ✓ OpenCode" ;;
      kilo)     copy_skills .kilo/skills     && echo "  ✓ Kilo Code" ;;
      codex)    echo "  ✓ Codex (OpenAI) — .agents/skills/ adalah format native, tidak ada file tambahan" ;;
      kimi)     copy_skills "$HOME/.config/agents/skills" && echo "  ✓ Kimi CLI" ;;
    esac
  done < .agents/macca-tools.txt
else
  echo "  (Tidak ada macca-tools.txt — jalankan install ulang untuk pilih tools)"
fi

# ─── Cleanup & done ───────────────────────────────────────────────────────────
rm -rf "$TMP_DIR"
echo ""
echo "  ✓ MACCA updated to latest version."
echo ""
