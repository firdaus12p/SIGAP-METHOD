#!/bin/bash
set -e

REPO_URL="https://github.com/firdaus12p/SIGAP---METHOD"
TMP_DIR=$(mktemp -d)

echo "Installing SIGAP..."
git clone --depth 1 "$REPO_URL" "$TMP_DIR/sigap" --quiet

cp -r "$TMP_DIR/sigap/.agents/" .
cp "$TMP_DIR/sigap/skills-lock.json" .

rm -rf "$TMP_DIR"

read -r -p "Masukkan nama developer (kosongkan untuk skip): " DEV_NAME </dev/tty
if [ -n "$DEV_NAME" ]; then
  mkdir -p .agents
  printf '{\n  "name": "%s"\n}\n' "$DEV_NAME" > .agents/developer-config.json
  echo "Nama developer disimpan."
fi

echo "Done! SIGAP installed. Gunakan skill help untuk mulai."
