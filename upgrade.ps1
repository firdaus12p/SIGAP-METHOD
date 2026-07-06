$REPO_URL = "https://github.com/firdaus12p/MACCA-METHOD"
$TMP_DIR  = Join-Path $env:TEMP "macca-upgrade"

Write-Host ""
Write-Host "  Updating MACCA skills..."

# ─── Backup user configs ───────────────────────────────────────────────────────
$ConfigBackup = $null
$ToolsBackup  = $null
if (Test-Path ".agents\developer-config.json") { $ConfigBackup = Get-Content ".agents\developer-config.json" -Raw }
if (Test-Path ".agents\macca-tools.txt")        { $ToolsBackup  = Get-Content ".agents\macca-tools.txt" -Raw }

# ─── Clone repo ────────────────────────────────────────────────────────────────
if (Test-Path $TMP_DIR) { Remove-Item -Recurse -Force $TMP_DIR }
git clone --depth 1 $REPO_URL $TMP_DIR --quiet 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "  x Gagal mengunduh. Periksa:"
  Write-Host "    - Koneksi internet aktif"
  Write-Host "    - Repo tersedia di: $REPO_URL"
  if (Test-Path $TMP_DIR) { Remove-Item -Recurse -Force $TMP_DIR -ErrorAction SilentlyContinue }
  exit 1
}

# ─── Helper: copy langsung dari temp ke folder tool ───────────────────────────
function Copy-SkillsFromTemp($Dest) {
  New-Item -ItemType Directory -Force -Path $Dest | Out-Null
  $SrcSkills = Join-Path $TMP_DIR ".agents\skills"
  foreach ($Dir in (Get-ChildItem $SrcSkills -Directory)) {
    $Target = Join-Path $Dest $Dir.Name
    if (Test-Path $Target) { Remove-Item -Recurse -Force $Target }
    Copy-Item -Recurse $Dir.FullName $Target
  }
}

# ─── Update skills langsung ke folder masing-masing tool ──────────────────────
$HasCodex = $false
if (Test-Path ".agents\macca-tools.txt") {
  $Tools = Get-Content ".agents\macca-tools.txt" | Where-Object { $_ -ne "" }
  Write-Host "  Memperbarui skills untuk:"
  foreach ($Tool in $Tools) {
    switch ($Tool) {
      'copilot'  { Copy-SkillsFromTemp ".github\skills";   Write-Host "  v GitHub Copilot  -> .github\skills\" }
      'cursor'   { Copy-SkillsFromTemp ".cursor\skills";   Write-Host "  v Cursor          -> .cursor\skills\" }
      'claude'   { Copy-SkillsFromTemp ".claude\skills";   Write-Host "  v Claude Code     -> .claude\skills\" }
      'windsurf' { Copy-SkillsFromTemp ".windsurf\skills"; Write-Host "  v Windsurf        -> .windsurf\skills\" }
      'gemini'   { Copy-SkillsFromTemp ".gemini\skills";   Write-Host "  v Gemini CLI      -> .gemini\skills\" }
      'opencode' { Copy-SkillsFromTemp ".opencode\skill";  Write-Host "  v OpenCode        -> .opencode\skill\" }
      'kilo'     { Copy-SkillsFromTemp ".kilo\skills";     Write-Host "  v Kilo Code       -> .kilo\skills\" }
      'codex'    { $HasCodex = $true; Copy-SkillsFromTemp ".agents\skills"; Write-Host "  v Codex (OpenAI)  -> .agents\skills\" }
      'kimi'     { Copy-SkillsFromTemp (Join-Path $env:APPDATA "agents\skills"); Write-Host "  v Kimi CLI        -> AppData\agents\skills\" }
    }
  }
} else {
  Write-Host "  (macca-tools.txt tidak ditemukan - jalankan install ulang untuk memilih tools)"
}

# ─── Bersihkan .agents\skills\ jika bukan codex ───────────────────────────────
if (-not $HasCodex -and (Test-Path ".agents\skills")) {
  Remove-Item -Recurse -Force ".agents\skills"
}

# ─── Update skills-lock.json ──────────────────────────────────────────────────
Copy-Item "$TMP_DIR\skills-lock.json" . -Force

# ─── Restore user configs ─────────────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path ".agents" | Out-Null
if ($null -ne $ConfigBackup) { Set-Content ".agents\developer-config.json" $ConfigBackup }
if ($null -ne $ToolsBackup)  { Set-Content ".agents\macca-tools.txt"       $ToolsBackup  }

# ─── Cleanup & done ────────────────────────────────────────────────────────────
Remove-Item -Recurse -Force $TMP_DIR
Write-Host ""
Write-Host "  v MACCA updated!"
Write-Host ""
