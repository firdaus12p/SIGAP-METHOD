#!/bin/bash
set -e

REPO_URL="https://github.com/firdaus12p/MACCA-METHOD"
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

# ─── Update hanya skill yang terinstall (baca dari skills-lock.json) ─────────
INSTALLED_SKILLS=()
if command -v python3 &>/dev/null && [ -f "skills-lock.json" ]; then
  mapfile -t INSTALLED_SKILLS < <(python3 -c "
import json
with open('skills-lock.json') as f:
  d = json.load(f)
for k in d.get('skills', {}):
  print(k)
")
fi

if [ ${#INSTALLED_SKILLS[@]} -gt 0 ]; then
  # Hapus semua skill, lalu copy hanya yang dulu terpasang
  rm -rf .agents/skills
  mkdir -p .agents/skills
  echo "  Memperbarui skill:"
  for SKILL in "${INSTALLED_SKILLS[@]}"; do
    if [ -d "$TMP_DIR/macca/.agents/skills/$SKILL" ]; then
      cp -r "$TMP_DIR/macca/.agents/skills/$SKILL" .agents/skills/
      echo "    + $SKILL"
    fi
  done
else
  echo "  skills-lock.json tidak ditemukan — semua skill diupdate."
  cp -r "$TMP_DIR/macca/skills-lock.json" .
fi

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
