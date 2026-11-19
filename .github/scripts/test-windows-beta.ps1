$ErrorActionPreference = 'Stop'
$zip = 'dist/PixelFarmSeasons-Windows64.zip'
$expectedHash = (Get-Content "$zip.sha256" -Raw).Trim().Split(' ')[0]
if ((Get-FileHash -Path $zip -Algorithm SHA256).Hash -ine $expectedHash) {
    throw 'O checksum do pacote Windows não confere.'
}

$gameDir = Join-Path $env:RUNNER_TEMP 'pixel-farm-beta'
Expand-Archive -Path $zip -DestinationPath $gameDir
$game = Join-Path $gameDir 'PixelFarmSeasons.exe'
$log = Join-Path $env:RUNNER_TEMP 'pixel-farm-beta.log'
$process = Start-Process -FilePath $game -WorkingDirectory $gameDir -ArgumentList @(
    '--headless', '--quit-after', '120', '--log-file', ('"{0}"' -f $log)
) -PassThru
if (!$process.WaitForExit(60000)) {
    $process.Kill()
    throw 'O executável ultrapassou o tempo do teste.'
}
$output = Get-Content $log -Raw
Write-Output $output
if ($process.ExitCode -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|Failed loading resource|Cannot open file') {
    throw 'Falha ao iniciar o pacote exportado.'
}

$archive = Join-Path $env:RUNNER_TEMP 'godot-editor.zip'
$editorDir = Join-Path $env:RUNNER_TEMP 'godot-editor'
Invoke-WebRequest -Uri 'https://github.com/godotengine/godot-builds/releases/download/4.3-stable/Godot_v4.3-stable_win64.exe.zip' -OutFile $archive
Expand-Archive -Path $archive -DestinationPath $editorDir
$editor = Join-Path $editorDir 'Godot_v4.3-stable_win64_console.exe'

& $editor --headless --path godot --editor --import --quit
if ($LASTEXITCODE -ne 0) { throw 'Falha ao importar o projeto no Godot.' }

foreach ($test in @('campaign_ending_smoke', 'save_store_smoke')) {
    $output = & $editor --headless --path godot --script "res://tests/$test.gd" 2>&1 | Out-String
    Write-Output $output
    if ($LASTEXITCODE -ne 0 -or $output -notmatch 'PASSOU:' -or $output -match 'SCRIPT ERROR|Parse Error:') {
        throw "Falha na regressão $test."
    }
}
