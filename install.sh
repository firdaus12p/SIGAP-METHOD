#!/bin/bash
set -e

REPO_URL="https://github.com/username/sigap"
TMP_DIR=$(mktemp -d)

echo "Installing SIGAP..."
git clone --depth 1 "$REPO_URL" "$TMP_DIR/sigap" --quiet

cp -r "$TMP_DIR/sigap/.agents/" .
cp "$TMP_DIR/sigap/skills-lock.json" .

rm -rf "$TMP_DIR"
echo "Done! SIGAP installed. Gunakan skill help untuk mulai."
