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

$runtimeDir = Join-Path $env:ProgramData "MP3Alarm"
$launcherPath = Join-Path $runtimeDir "run-core.ps1"

$taskName = "MP3AlarmCore"

Write-Host "Install directory:"
Write-Host "  $installDir"

Write-Host "Runtime directory:"
Write-Host "  $runtimeDir"

Write-Host ""

# ============================================================
# Создание директорий
# ============================================================

Write-Host "== Создание директорий =="

New-Item `
    -ItemType Directory `
    -Path $binDir `
    -Force |
    Out-Null

New-Item `
    -ItemType Directory `
    -Path $runtimeDir `
    -Force |
    Out-Null

# ============================================================
# Копирование файлов программы
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
# Создание launcher
# ============================================================

Write-Host "== Создание Core launcher =="

$launcherContent = @"
`$ErrorActionPreference = "Stop"

Set-Location -LiteralPath "$binDir"

Start-Process `
    -FilePath "$corePath" `
    -WorkingDirectory "$binDir"
"@

Set-Content `
    -Path $launcherPath `
    -Value $launcherContent `
    -Encoding UTF8 `
    -Force

Write-Host "Launcher:"
Write-Host "  $launcherPath"

Write-Host ""

# ============================================================
# Удаление старой Scheduled Task
# ============================================================

Write-Host "== Удаление старой задачи =="

Unregister-ScheduledTask `
    -TaskName $taskName `
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

Write-Host ""

# ============================================================
# Action
# ============================================================

$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$launcherPath`"" `
    -WorkingDirectory $runtimeDir

# ============================================================
# Trigger
# ============================================================

$trigger = New-ScheduledTaskTrigger `
    -AtLogOn `
    -User $taskUser

# ============================================================
# Principal
# ============================================================

$principal = New-ScheduledTaskPrincipal `
    -UserId $taskUser `
    -LogonType Interactive `
    -RunLevel Limited

# ============================================================
# Settings
# ============================================================

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries

# ============================================================
# Register
# ============================================================

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Force

Write-Host "Задача MP3AlarmCore создана."
Write-Host ""

# ============================================================
# Проверка Action
# ============================================================

Write-Host "== Проверка Scheduled Task =="

$registeredTask = Get-ScheduledTask `
    -TaskName $taskName `
    -ErrorAction Stop

$registeredAction = $registeredTask.Actions

Write-Host "Execute:"
Write-Host "  $($registeredAction.Execute)"

Write-Host "Arguments:"
Write-Host "  $($registeredAction.Arguments)"

Write-Host "WorkingDirectory:"
Write-Host "  $($registeredAction.WorkingDirectory)"

Write-Host ""

# ============================================================
# Запуск задачи
# ============================================================

Write-Host "== Запуск MP3AlarmCore =="

Start-ScheduledTask `
    -TaskName $taskName

Start-Sleep -Seconds 3

# ============================================================
# Проверка процесса
# ============================================================

$process = Get-Process `
    -Name "Alarm" `
    -ErrorAction SilentlyContinue

if ($null -ne $process) {

    Write-Host "Alarm.exe успешно запущен."

}
else {

    Write-Warning "Alarm.exe не обнаружен после запуска задачи."

    $taskInfo = Get-ScheduledTaskInfo `
        -TaskName $taskName

    Write-Host ""
    Write-Host "LastRunTime:"
    Write-Host "  $($taskInfo.LastRunTime)"

    Write-Host "LastTaskResult:"
    Write-Host "  $($taskInfo.LastTaskResult)"
}

Write-Host ""

# ============================================================
# Пути ярлыков
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

$shortcut = $WScriptShell.CreateShortcut(
    $startMenuShortcut
)

$shortcut.TargetPath = $guiPath
$shortcut.WorkingDirectory = $binDir
$shortcut.Description = "MP3 Alarm"

$shortcut.Save()

# ------------------------------------------------------------
# Desktop
# ------------------------------------------------------------

$shortcut = $WScriptShell.CreateShortcut(
    $desktopShortcut
)

$shortcut.TargetPath = $guiPath
$shortcut.WorkingDirectory = $binDir
$shortcut.Description = "MP3 Alarm"

$shortcut.Save()

Write-Host "Ярлыки созданы."
Write-Host ""

# ============================================================
# Завершение
# ============================================================

Write-Host "========================================"
Write-Host "        Установка завершена"
Write-Host "========================================"
Write-Host ""

Write-Host "Program:"
Write-Host "  $installDir"

Write-Host ""

Write-Host "Core:"
Write-Host "  $corePath"

Write-Host ""

Write-Host "GUI:"
Write-Host "  $guiPath"

Write-Host ""

Write-Host "Launcher:"
Write-Host "  $launcherPath"

Write-Host ""

Write-Host "Scheduled Task:"
Write-Host "  $taskName"

Write-Host ""

Write-Host "User:"
Write-Host "  $taskUser"

Write-Host ""

Write-Host "Alarm.exe будет запускаться при входе пользователя."

Write-Host ""
Write-Host "Перезагрузка не требуется."
Write-Host ""