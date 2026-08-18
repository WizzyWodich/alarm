$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host "        MP3 Alarm Installer"
Write-Host "========================================"
Write-Host ""

# ============================================================
# Пути
# ============================================================

$installDir = "$env:ProgramFiles\MP3Alarm"
$binDir = Join-Path $installDir "bin"

$corePath = Join-Path $binDir "Alarm.exe"
$guiPath  = Join-Path $binDir "mp3alarm-gui.exe"

Write-Host "Install directory:"
Write-Host $installDir
Write-Host ""

# ============================================================
# Создание директории
# ============================================================

Write-Host "== Создание директории =="

New-Item `
    -ItemType Directory `
    -Force `
    -Path $binDir | Out-Null

# ============================================================
# Копирование файлов
# ============================================================

Write-Host "== Копирование файлов =="

Copy-Item `
    -Path ".\*" `
    -Destination $installDir `
    -Recurse `
    -Force

# ============================================================
# Проверка файлов
# ============================================================

Write-Host "== Проверка файлов =="

if (-not (Test-Path $corePath)) {
    throw "Alarm.exe не найден: $corePath"
}

if (-not (Test-Path $guiPath)) {
    throw "mp3alarm-gui.exe не найден: $guiPath"
}

Write-Host "Alarm.exe:"
Write-Host "  $corePath"

Write-Host "GUI:"
Write-Host "  $guiPath"

Write-Host ""

# ============================================================
# Удаляем старую задачу
# ============================================================

Write-Host "== Удаление старой задачи =="

schtasks /Delete `
    /TN "MP3AlarmCore" `
    /F 2>$null

# ============================================================
# Создание задачи
# ============================================================

Write-Host "== Создание задачи MP3AlarmCore =="

$taskCommand = "`"$corePath`""

schtasks /Create `
    /TN "MP3AlarmCore" `
    /TR $taskCommand `
    /SC ONLOGON `
    /RU "$env:USERNAME" `
    /RL LIMITED `
    /F

if ($LASTEXITCODE -ne 0) {
    throw "Не удалось создать задачу MP3AlarmCore"
}

Write-Host "Задача успешно создана."
Write-Host ""

# ============================================================
# Проверка задачи
# ============================================================

Write-Host "== Проверка задачи =="

schtasks /Query `
    /TN "MP3AlarmCore" `
    /V `
    /FO LIST

Write-Host ""

# ============================================================
# Запуск ядра сразу после установки
# ============================================================

Write-Host "== Запуск MP3AlarmCore =="

schtasks /Run `
    /TN "MP3AlarmCore"

if ($LASTEXITCODE -ne 0) {
    throw "Не удалось запустить MP3AlarmCore"
}

Write-Host "MP3AlarmCore запущен."
Write-Host ""

# ============================================================
# Ярлык в меню Пуск
# ============================================================

Write-Host "== Создание ярлыка в меню Пуск =="

$startMenuDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"

New-Item `
    -ItemType Directory `
    -Force `
    -Path $startMenuDir | Out-Null

$startMenuShortcut = Join-Path `
    $startMenuDir `
    "MP3 Alarm.lnk"

$shell = New-Object -ComObject WScript.Shell

$shortcut = $shell.CreateShortcut($startMenuShortcut)

$shortcut.TargetPath = $guiPath
$shortcut.WorkingDirectory = $binDir
$shortcut.IconLocation = $guiPath

$shortcut.Save()

Write-Host "Создан:"
Write-Host $startMenuShortcut
Write-Host ""

# ============================================================
# Ярлык на рабочем столе
# ============================================================

Write-Host "== Создание ярлыка на рабочем столе =="

$desktopDir = [Environment]::GetFolderPath("Desktop")

$desktopShortcut = Join-Path `
    $desktopDir `
    "MP3 Alarm.lnk"

$shortcut = $shell.CreateShortcut($desktopShortcut)

$shortcut.TargetPath = $guiPath
$shortcut.WorkingDirectory = $binDir
$shortcut.IconLocation = $guiPath

$shortcut.Save()

Write-Host "Создан:"
Write-Host $desktopShortcut
Write-Host ""

# ============================================================
# Готово
# ============================================================

Write-Host "========================================"
Write-Host "        Установка завершена"
Write-Host "========================================"
Write-Host ""

Write-Host "Core:"
Write-Host "  $corePath"

Write-Host ""

Write-Host "GUI:"
Write-Host "  $guiPath"

Write-Host ""

Write-Host "Task:"
Write-Host "  MP3AlarmCore"

Write-Host ""

Write-Host "Проверить процесс:"
Write-Host '  Get-Process Alarm'

Write-Host ""

Write-Host "Проверить задачу:"
Write-Host '  schtasks /Query /TN "MP3AlarmCore" /V /FO LIST'

Write-Host ""