$installDir = "$env:LOCALAPPDATA\MP3Alarm"

New-Item -ItemType Directory -Force -Path $installDir | Out-Null

Write-Host "== Копирование файлов =="
Copy-Item -Path ".\*" -Destination $installDir -Recurse -Force

$corePath = Join-Path $installDir "bin\Alarm.exe"
$guiPath  = Join-Path $installDir "bin\mp3alarm-gui.exe"

Write-Host "== Проверка файлов =="

if (-not (Test-Path $corePath)) {
    Write-Error "Alarm.exe не найден: $corePath"
    exit 1
}

if (-not (Test-Path $guiPath)) {
    Write-Error "mp3alarm-gui.exe не найден: $guiPath"
    exit 1
}

Write-Host "Core: $corePath"
Write-Host "GUI:  $guiPath"

Write-Host "== Регистрация автозапуска ядра =="

schtasks /Delete /TN "MP3AlarmCore" /F 2>$null

$taskCommand = "`"$corePath`""

schtasks /Create `
    /TN "MP3AlarmCore" `
    /TR $taskCommand `
    /SC ONLOGON `
    /RL LIMITED `
    /F

if ($LASTEXITCODE -ne 0) {
    Write-Error "Не удалось создать задачу MP3AlarmCore"
    exit 1
}

Write-Host "== Запуск ядра =="

schtasks /Run /TN "MP3AlarmCore"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Не удалось запустить MP3AlarmCore"
    exit 1
}

Write-Host "== Ярлык GUI в меню Пуск =="

$startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\MP3 Alarm.lnk"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($startMenuPath)

$shortcut.TargetPath = $guiPath
$shortcut.WorkingDirectory = Split-Path $guiPath
$shortcut.IconLocation = $guiPath

$shortcut.Save()

Write-Host ""
Write-Host "Готово."
Write-Host ""
Write-Host "Ядро:"
Write-Host $corePath
Write-Host ""
Write-Host "GUI:"
Write-Host $guiPath
Write-Host ""
Write-Host "Запустить ядро сейчас:"
Write-Host 'schtasks /Run /TN "MP3AlarmCore"'