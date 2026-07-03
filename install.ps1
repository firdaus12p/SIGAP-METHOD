$REPO_URL     = "https://github.com/firdaus12p/MACCA-METHOD"
$TMP_DIR      = Join-Path $env:TEMP "macca-install"
$Selected     = @()
$ClaudeCopied = $false

# ─── Banner ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ╭─────────────────────────────────────────╮"
Write-Host "  │      MACCA — AI Spec-Driven Dev          │"
Write-Host "  ╰─────────────────────────────────────────╯"
Write-Host ""

# ─── Clone & copy skills ───────────────────────────────────────────────────────
Write-Host "  Mengunduh skills..."
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

Copy-Item -Recurse "$TMP_DIR\.agents" . -Force
Copy-Item "$TMP_DIR\skills-lock.json" . -Force

# ─── Helper: copy all skill folders to destination ────────────────────────────
function Copy-Skills($Dest) {
  New-Item -ItemType Directory -Force -Path $Dest | Out-Null
  foreach ($Dir in (Get-ChildItem ".agents\skills" -Directory)) {
    $Target = Join-Path $Dest $Dir.Name
    if (Test-Path $Target) { Remove-Item -Recurse -Force $Target }
    Copy-Item -Recurse $Dir.FullName $Target
  }
}

# ─── Tool selection (checkbox) ────────────────────────────────────────────────
$AllToolNames = @("GitHub Copilot","Cursor","Claude Code","Windsurf","Gemini CLI","OpenCode","Kilo Code","Codex (OpenAI)","Kimi CLI")
$AllToolPaths = @(".github\skills\",".claude\skills\",".claude\skills\",".windsurf\skills\",".gemini\skills\",".opencode\skill\",".kilo\skills\",".agents\skills\ (native)","AppData\Roaming\agents\skills\")
$AllToolKeys  = @("copilot","cursor","claude","windsurf","gemini","opencode","kilo","codex","kimi")
$ToolSelected = [System.Collections.ArrayList]@()

function Show-ToolCheckboxes {
  Write-Host ""
  for ($i = 0; $i -lt $AllToolNames.Count; $i++) {
    $mark = if ($ToolSelected -contains $AllToolKeys[$i]) { "[x]" } else { "[ ]" }
    Write-Host ("    {0} {1,2}. {2,-20} -> {3}" -f $mark, ($i + 1), $AllToolNames[$i], $AllToolPaths[$i])
  }
  Write-Host ""
}

function Toggle-Tool($Num) {
  $idx = [int]$Num - 1
  if ($idx -ge 0 -and $idx -lt $AllToolKeys.Count) {
    $key = $AllToolKeys[$idx]
    if ($ToolSelected -contains $key) { $ToolSelected.Remove($key) | Out-Null }
    else { $ToolSelected.Add($key) | Out-Null }
  }
}

Write-Host ""
Write-Host "  Pilih AI tool yang kamu gunakan:"
Write-Host "  ketik nomor untuk centang/hapus centang, Enter untuk konfirmasi"
Show-ToolCheckboxes

while ($true) {
  $Input = Read-Host "  >"
  if ([string]::IsNullOrWhiteSpace($Input)) { break }
  foreach ($Num in ($Input -split '\s+')) {
    if ($Num -match '^\d+$') { Toggle-Tool $Num }
  }
  Show-ToolCheckboxes
}

if ($ToolSelected.Count -eq 0) {
  Write-Host ""
  Write-Host "  Tidak ada AI tool dipilih — menggunakan .agents\skills\ sebagai default."
  $Selected += 'codex'
} else {
  Write-Host ""
  Write-Host "  Menyalin skills:"
  foreach ($Key in $ToolSelected) {
    switch ($Key) {
      'copilot'  { Copy-Skills ".github\skills";   $Selected += 'copilot';  Write-Host "  v GitHub Copilot  -> .github\skills\" }
      'cursor'   { if (-not $ClaudeCopied) { Copy-Skills ".claude\skills"; $ClaudeCopied = $true }; $Selected += 'cursor';  Write-Host "  v Cursor          -> .claude\skills\" }
      'claude'   { if (-not $ClaudeCopied) { Copy-Skills ".claude\skills"; $ClaudeCopied = $true }; $Selected += 'claude';  Write-Host "  v Claude Code     -> .claude\skills\" }
      'windsurf' { Copy-Skills ".windsurf\skills";  $Selected += 'windsurf'; Write-Host "  v Windsurf        -> .windsurf\skills\" }
      'gemini'   { Copy-Skills ".gemini\skills";    $Selected += 'gemini';   Write-Host "  v Gemini CLI      -> .gemini\skills\" }
      'opencode' { Copy-Skills ".opencode\skill";   $Selected += 'opencode'; Write-Host "  v OpenCode        -> .opencode\skill\" }
      'kilo'     { Copy-Skills ".kilo\skills";      $Selected += 'kilo';     Write-Host "  v Kilo Code       -> .kilo\skills\" }
      'codex'    { $Selected += 'codex'; Write-Host "  v Codex (OpenAI)  -> .agents\skills\ (native)" }
      'kimi'     { $KimiDir = Join-Path $env:APPDATA "agents\skills"; Copy-Skills $KimiDir; $Selected += 'kimi'; Write-Host "  v Kimi CLI        -> $KimiDir" }
    }
  }
}

# ─── Save selected tools ───────────────────────────────────────────────────────
Set-Content ".agents\macca-tools.txt" ($Selected -join "`n")

# ─── Nama developer & project ─────────────────────────────────────────────────
Write-Host ""
$DEV_NAME     = Read-Host "  Kamu mau di panggil apa? (Kosong = Skip)"
$PROJECT_NAME = Read-Host "  Nama project ini apa? (Kosong = Skip)"
if ($DEV_NAME -ne "" -or $PROJECT_NAME -ne "") {
  Set-Content -Path ".agents\developer-config.json" -Value "{`n  `"name`": `"$DEV_NAME`",`n  `"project`": `"$PROJECT_NAME`"`n}"
  if ($DEV_NAME -ne "")     { Write-Host "  Nama developer disimpan: $DEV_NAME" }
  if ($PROJECT_NAME -ne "") { Write-Host "  Nama project disimpan:   $PROJECT_NAME" }
}

# ─── Cleanup & done ────────────────────────────────────────────────────────────
Remove-Item -Recurse -Force $TMP_DIR
Write-Host ""
Write-Host "  v MACCA installed!
Write-Host ""
