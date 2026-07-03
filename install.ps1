$REPO_URL = "https://github.com/firdaus12p/SIGAP---METHOD"
$TMP_DIR = Join-Path $env:TEMP "sigap-install"

if (Test-Path $TMP_DIR) { Remove-Item -Recurse -Force $TMP_DIR }

Write-Host "Installing SIGAP..."
git clone --depth 1 $REPO_URL $TMP_DIR --quiet

Copy-Item -Recurse "$TMP_DIR\.agents" . -Force
Copy-Item "$TMP_DIR\skills-lock.json" . -Force

Remove-Item -Recurse -Force $TMP_DIR

$DEV_NAME = Read-Host "Masukkan nama developer (kosongkan untuk skip)"
if ($DEV_NAME -ne "") {
  New-Item -ItemType Directory -Force -Path ".agents" | Out-Null
  Set-Content -Path ".agents\developer-config.json" -Value "{`n  `"name`": `"$DEV_NAME`"`n}"
  Write-Host "Nama developer disimpan."
}

Write-Host "Done! SIGAP installed. Gunakan skill help untuk mulai."
