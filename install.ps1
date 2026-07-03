$REPO_URL     = "https://github.com/firdaus12p/macca-workflow"
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
git clone --depth 1 $REPO_URL $TMP_DIR --quiet

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

# ─── Tool selection menu ───────────────────────────────────────────────────────
Write-Host ""
Write-Host "  Pilih AI tool yang kamu gunakan:"
Write-Host "  (ketik nomor, pisahkan spasi - contoh: 1 3 4)"
Write-Host "  (ketik 0 untuk pilih semua)"
Write-Host ""
Write-Host "  [1] GitHub Copilot       -> .github\skills\"
Write-Host "  [2] Cursor               -> .claude\skills\  (Claude Code compatible)"
Write-Host "  [3] Claude Code          -> .claude\skills\"
Write-Host "  [4] Windsurf             -> .windsurf\skills\"
Write-Host "  [5] Gemini CLI           -> .gemini\skills\"
Write-Host "  [6] OpenCode             -> .opencode\skill\"
Write-Host "  [7] Kilo Code            -> .kilo\skills\"
Write-Host "  [8] Codex (OpenAI)       -> .agents\skills\  (native — tidak perlu konfigurasi tambahan)"
Write-Host "  [9] Kimi CLI             -> AppData\Roaming\agents\skills\"
Write-Host ""
$RawChoice = Read-Host "  Pilihanmu"
$Choices   = ($RawChoice -split ' ') | Where-Object { $_ -ne "" }

if ([string]::IsNullOrWhiteSpace($RawChoice)) {
  Write-Host ""
  Write-Host "  Tidak ada pilihan — menggunakan .agents\skills\ sebagai default."
  Write-Host "  i  Format ini kompatibel dengan:"
  Write-Host "      Codex (OpenAI) · GitHub Copilot · Gemini CLI · Windsurf · Continue.dev"
  $Selected += 'codex'
} else {
  if ($Choices -contains '0') { $Choices = '1','2','3','4','5','6','7','8','9' }
  Write-Host ""
  Write-Host "  Menyalin skills:"
}

foreach ($Num in $Choices) {
  switch ($Num.Trim()) {
    '1' {
      Copy-Skills ".github\skills"
      $Selected += 'copilot'
      Write-Host "  v GitHub Copilot    -> .github\skills\"
    }
    '2' {
      if (-not $ClaudeCopied) { Copy-Skills ".claude\skills"; $ClaudeCopied = $true }
      $Selected += 'cursor'
      Write-Host "  v Cursor            -> .claude\skills\ (Claude Code compatible)"
    }
    '3' {
      if (-not $ClaudeCopied) { Copy-Skills ".claude\skills"; $ClaudeCopied = $true }
      $Selected += 'claude'
      Write-Host "  v Claude Code       -> .claude\skills\"
    }
    '4' {
      Copy-Skills ".windsurf\skills"
      $Selected += 'windsurf'
      Write-Host "  v Windsurf          -> .windsurf\skills\"
    }
    '5' {
      Copy-Skills ".gemini\skills"
      $Selected += 'gemini'
      Write-Host "  v Gemini CLI        -> .gemini\skills\"
    }
    '6' {
      Copy-Skills ".opencode\skill"
      $Selected += 'opencode'
      Write-Host "  v OpenCode          -> .opencode\skill\"
    }
    '7' {
      Copy-Skills ".kilo\skills"
      $Selected += 'kilo'
      Write-Host "  v Kilo Code         -> .kilo\skills\"
    }
    '8' {
      $Selected += 'codex'
      Write-Host "  v Codex (OpenAI)    -> .agents\skills\ (format native Codex, tidak ada file tambahan)"
    }
    '9' {
      $KimiDir = Join-Path $env:APPDATA "agents\skills"
      Copy-Skills $KimiDir
      $Selected += 'kimi'
      Write-Host "  v Kimi CLI          -> $KimiDir"
    }
  }
}

# ─── Save selected tools ───────────────────────────────────────────────────────
Set-Content ".agents\macca-tools.txt" ($Selected -join "`n")

# ─── Developer name ────────────────────────────────────────────────────────────
Write-Host ""
$DEV_NAME = Read-Host "  Kamu mau di panggil apa? (kosongkan untuk skip)"
if ($DEV_NAME -ne "") {
  Set-Content -Path ".agents\developer-config.json" -Value "{`n  `"name`": `"$DEV_NAME`"`n}"
  Write-Host "  Nama developer disimpan."
}

# ─── Cleanup & done ────────────────────────────────────────────────────────────
Remove-Item -Recurse -Force $TMP_DIR
Write-Host ""
Write-Host "  v MACCA installed! Ketik: gunakan skill help"
Write-Host ""
