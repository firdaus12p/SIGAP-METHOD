$REPO_URL = "https://github.com/firdaus12p/macca-workflow"
$TMP_DIR  = Join-Path $env:TEMP "macca-upgrade"

Write-Host ""
Write-Host "  Updating MACCA skills..."

# ─── Backup user configs ───────────────────────────────────────────────────────
$ConfigBackup = $null
$ToolsBackup  = $null
if (Test-Path ".agents\developer-config.json") { $ConfigBackup = Get-Content ".agents\developer-config.json" -Raw }
if (Test-Path ".agents\macca-tools.txt")        { $ToolsBackup  = Get-Content ".agents\macca-tools.txt"  -Raw }

# ─── Update skills ─────────────────────────────────────────────────────────────
if (Test-Path $TMP_DIR) { Remove-Item -Recurse -Force $TMP_DIR }
git clone --depth 1 $REPO_URL $TMP_DIR --quiet

if (Test-Path ".agents") { Remove-Item -Recurse -Force ".agents" }
Copy-Item -Recurse "$TMP_DIR\.agents" . -Force
Copy-Item "$TMP_DIR\skills-lock.json" . -Force

# ─── Restore user configs ──────────────────────────────────────────────────────
if ($null -ne $ConfigBackup) { Set-Content ".agents\developer-config.json" $ConfigBackup }
if ($null -ne $ToolsBackup)  { Set-Content ".agents\macca-tools.txt"        $ToolsBackup  }

# ─── Helper ────────────────────────────────────────────────────────────────────
function Copy-Skills($Dest) {
  New-Item -ItemType Directory -Force -Path $Dest | Out-Null
  foreach ($Dir in (Get-ChildItem ".agents\skills" -Directory)) {
    $Target = Join-Path $Dest $Dir.Name
    if (Test-Path $Target) { Remove-Item -Recurse -Force $Target }
    Copy-Item -Recurse $Dir.FullName $Target
  }
}

# ─── Re-copy updated skills to each tool's folder ─────────────────────────────
if (Test-Path ".agents\macca-tools.txt") {
  $Tools        = Get-Content ".agents\macca-tools.txt" | Where-Object { $_ -ne "" }
  $ClaudeCopied = $false
  Write-Host "  Memperbarui skills untuk:"
  foreach ($Tool in $Tools) {
    switch ($Tool) {
      'copilot'  { Copy-Skills ".github\skills";   Write-Host "  v GitHub Copilot" }
      'cursor'   { if (-not $ClaudeCopied) { Copy-Skills ".claude\skills"; $ClaudeCopied = $true }; Write-Host "  v Cursor" }
      'claude'   { if (-not $ClaudeCopied) { Copy-Skills ".claude\skills"; $ClaudeCopied = $true }; Write-Host "  v Claude Code" }
      'windsurf' { Copy-Skills ".windsurf\skills"; Write-Host "  v Windsurf" }
      'gemini'   { Copy-Skills ".gemini\skills";   Write-Host "  v Gemini CLI" }
      'opencode' { Copy-Skills ".opencode\skill";  Write-Host "  v OpenCode" }
      'kilo'     { Copy-Skills ".kilo\skills";     Write-Host "  v Kilo Code" }
      'codex'    { Write-Host "  v Codex (OpenAI) — .agents\skills\ adalah format native, tidak ada file tambahan" }
      'kimi'     { Copy-Skills (Join-Path $env:APPDATA "agents\skills"); Write-Host "  v Kimi CLI" }
    }
  }
} else {
  Write-Host "  (Tidak ada macca-tools.txt - jalankan install ulang untuk pilih tools)"
}

# ─── Cleanup & done ────────────────────────────────────────────────────────────
Remove-Item -Recurse -Force $TMP_DIR
Write-Host ""
Write-Host "  v MACCA updated to latest version."
Write-Host ""
