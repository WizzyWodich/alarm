$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host "        MP3 Alarm Installer"
Write-Host "========================================"
Write-Host ""

# ============================================================
# Проверка прав администратора
# ============================================================

$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)

if (-not $currentPrincipal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)) {
    throw "Установщик необходимо запускать от имени администратора."
}

# ============================================================
# Пути
# ============================================================

$installDir = Join-Path $env:ProgramFiles "MP3Alarm"
$binDir = Join-Path $installDir "bin"

$corePath = Join-Path $binDir "Alarm.exe"
$guiPath = Join-Path $binDir "mp3alarm-gui.exe"

Write-Host "Install directory:"
Write-Host "  $installDir"
Write-Host ""

# ============================================================
# Создание директории
# ============================================================

Write-Host "== Создание директории =="

New-Item `
    -ItemType Directory `
    -Path $binDir `
    -Force |
    Out-Null

# ============================================================
# Копирование файлов
# ============================================================

Write-Host "== Копирование файлов =="

$sourceDir = Split-Path -Parent $PSScriptRoot

Copy-Item `
    -Path (Join-Path $sourceDir "*") `
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
# Удаление старой задачи
# ============================================================

Write-Host "== Удаление старой задачи =="

Unregister-ScheduledTask `
    -TaskName "MP3AlarmCore" `
    -Confirm:$false `
    -ErrorAction SilentlyContinue

Write-Host "Старая задача удалена."
Write-Host ""

# ============================================================
# Создание Scheduled Task
# ============================================================

Write-Host "== Создание задачи MP3AlarmCore =="

$taskUser = "$env:USERDOMAIN\$env:USERNAME"

Write-Host "Пользователь:"
Write-Host "  $taskUser"

Write-Host "Executable:"
Write-Host "  $corePath"

Write-Host "Working directory:"
Write-Host "  $binDir"

Write-Host ""

# ------------------------------------------------------------
# Action
# ------------------------------------------------------------

$action = New-ScheduledTaskAction `
    -Execute $corePath `
    -WorkingDirectory $binDir

# ------------------------------------------------------------
# Trigger
# ------------------------------------------------------------

$trigger = New-ScheduledTaskTrigger `
    -AtLogOn `
    -User $taskUser

# ------------------------------------------------------------
# Principal
# ------------------------------------------------------------

$principal = New-ScheduledTaskPrincipal `
    -UserId $taskUser `
    -LogonType Interactive `
    -RunLevel Limited

# ------------------------------------------------------------
# Settings
# ------------------------------------------------------------

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries

# ------------------------------------------------------------
# Register
# ------------------------------------------------------------

Register-ScheduledTask `
    -TaskName "MP3AlarmCore" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Force

Write-Host "Задача MP3AlarmCore создана."
Write-Host ""

# ============================================================
# Проверка созданной задачи
# ============================================================

Write-Host "== Проверка задачи =="

$task = Get-ScheduledTask `
    -TaskName "MP3AlarmCore" `
    -ErrorAction Stop

Write-Host "Task:"
Write-Host "  $($task.TaskName)"

Write-Host "State:"
Write-Host "  $($task.State)"

Write-Host ""

# ============================================================
# Запуск Alarm.exe
# ============================================================

Write-Host "== Запуск MP3AlarmCore =="

Start-ScheduledTask `
    -TaskName "MP3AlarmCore"

Start-Sleep -Seconds 2

# ============================================================
# Проверка процесса
# ============================================================

$process = Get-Process `
    -Name "Alarm" `
    -ErrorAction SilentlyContinue

if ($null -ne $process) {

    Write-Host ""
    Write-Host "Alarm.exe успешно запущен."

}
else {

    Write-Host ""
    Write-Warning "Alarm.exe не обнаружен после запуска задачи."

    $taskInfo = Get-ScheduledTaskInfo `
        -TaskName "MP3AlarmCore"

    Write-Host ""
    Write-Host "Last run:"
    Write-Host "  $($taskInfo.LastRunTime)"

    Write-Host "Last result:"
    Write-Host "  $($taskInfo.LastTaskResult)"
}

Write-Host ""

# ============================================================
# Ярлыки
# ============================================================

$startMenuDir = Join-Path `
    $env:APPDATA `
    "Microsoft\Windows\Start Menu\Programs"

$desktopDir = [Environment]::GetFolderPath("Desktop")

$startMenuShortcut = Join-Path `
    $startMenuDir `
    "MP3 Alarm.lnk"

$desktopShortcut = Join-Path `
    $desktopDir `
    "MP3 Alarm.lnk"

# ============================================================
# Создание ярлыков
# ============================================================

Write-Host "== Создание ярлыков =="

New-Item `
    -ItemType Directory `
    -Path $startMenuDir `
    -Force |
    Out-Null

$WScriptShell = New-Object -ComObject WScript.Shell

# ------------------------------------------------------------
# Start Menu
# ------------------------------------------------------------

$shortcut = $WScriptShell.CreateShortcut($startMenuShortcut)

$shortcut.TargetPath = $guiPath
$shortcut.WorkingDirectory = $binDir
$shortcut.Description = "MP3 Alarm"
$shortcut.Save()

# ------------------------------------------------------------
# Desktop
# ------------------------------------------------------------

$shortcut = $WScriptShell.CreateShortcut($desktopShortcut)

$shortcut.TargetPath = $guiPath
$shortcut.WorkingDirectory = $binDir
$shortcut.Description = "MP3 Alarm"
$shortcut.Save()

Write-Host "Ярлыки созданы."
Write-Host ""

# ============================================================
# Готово
# ============================================================

Write-Host "========================================"
Write-Host "        Установка завершена"
Write-Host "========================================"
Write-Host ""

Write-Host "Установлено в:"
Write-Host "  $installDir"

Write-Host ""

Write-Host "Core:"
Write-Host "  $corePath"

Write-Host ""

Write-Host "GUI:"
Write-Host "  $guiPath"

Write-Host ""

Write-Host "Scheduled Task:"
Write-Host "  MP3AlarmCore"

Write-Host ""

Write-Host "Alarm.exe будет запускаться при входе пользователя:"
Write-Host "  $taskUser"

Write-Host ""

Write-Host "Перезагрузка не требуется."
Write-Host ""