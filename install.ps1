$REPO_URL = "https://github.com/username/sigap"
$TMP_DIR = Join-Path $env:TEMP "sigap-install"

Write-Host "Installing SIGAP..."
git clone --depth 1 $REPO_URL $TMP_DIR --quiet

Copy-Item -Recurse "$TMP_DIR\.agents\" .
Copy-Item "$TMP_DIR\skills-lock.json" .

Remove-Item -Recurse -Force $TMP_DIR
Write-Host "Done! SIGAP installed. Gunakan skill help untuk mulai."
