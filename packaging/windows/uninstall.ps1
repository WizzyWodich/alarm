$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host "        MP3 Alarm Uninstaller"
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
    throw "Удаление необходимо запускать от имени администратора."
}

# ============================================================
# Пути
# ============================================================

$installDir = Join-Path $env:ProgramFiles "MP3Alarm"

$runtimeDir = Join-Path $env:ProgramData "MP3Alarm"

$launcherPath = Join-Path `
    $runtimeDir `
    "run-core.ps1"

$taskName = "MP3AlarmCore"

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
# Удаление Scheduled Task
# ============================================================

Write-Host "== Удаление MP3AlarmCore =="

Unregister-ScheduledTask `
    -TaskName $taskName `
    -Confirm:$false `
    -ErrorAction SilentlyContinue

Write-Host "Задача MP3AlarmCore удалена."
Write-Host ""

# ============================================================
# Остановка Alarm.exe
# ============================================================

Write-Host "== Остановка Alarm.exe =="

$alarmProcesses = Get-Process `
    -Name "Alarm" `
    -ErrorAction SilentlyContinue

if ($null -ne $alarmProcesses) {

    $alarmProcesses |
        Stop-Process -Force

    Write-Host "Alarm.exe остановлен."

}
else {

    Write-Host "Alarm.exe не запущен."
}

Write-Host ""

# ============================================================
# Удаление ярлыка Start Menu
# ============================================================

Write-Host "== Удаление ярлыка из меню Пуск =="

if (Test-Path $startMenuShortcut) {

    Remove-Item `
        $startMenuShortcut `
        -Force

    Write-Host "Ярлык меню Пуск удалён."

}
else {

    Write-Host "Ярлык меню Пуск не найден."
}

Write-Host ""

# ============================================================
# Удаление ярлыка Desktop
# ============================================================

Write-Host "== Удаление ярлыка с рабочего стола =="

if (Test-Path $desktopShortcut) {

    Remove-Item `
        $desktopShortcut `
        -Force

    Write-Host "Ярлык рабочего стола удалён."

}
else {

    Write-Host "Ярлык рабочего стола не найден."
}

Write-Host ""

# ============================================================
# Удаление Program Files
# ============================================================

Write-Host "== Удаление файлов программы =="

if (Test-Path $installDir) {

    Remove-Item `
        $installDir `
        -Recurse `
        -Force

    Write-Host "C:\Program Files\MP3Alarm удалён."

}
else {

    Write-Host "Директория программы не найдена."
}

Write-Host ""

# ============================================================
# Удаление Runtime
# ============================================================

Write-Host "== Удаление Runtime =="

if (Test-Path $runtimeDir) {

    Remove-Item `
        $runtimeDir `
        -Recurse `
        -Force

    Write-Host "C:\ProgramData\MP3Alarm удалён."

}
else {

    Write-Host "Runtime директория не найдена."
}

Write-Host ""

# ============================================================
# Проверка удаления
# ============================================================

Write-Host "== Проверка =="

$taskExists = Get-ScheduledTask `
    -TaskName $taskName `
    -ErrorAction SilentlyContinue

$alarmExists = Get-Process `
    -Name "Alarm" `
    -ErrorAction SilentlyContinue

if ($null -eq $taskExists) {
    Write-Host "Scheduled Task: OK"
}
else {
    Write-Warning "Scheduled Task всё ещё существует."
}

if ($null -eq $alarmExists) {
    Write-Host "Alarm.exe: OK"
}
else {
    Write-Warning "Alarm.exe всё ещё запущен."
}

if (-not (Test-Path $installDir)) {
    Write-Host "Program Files: OK"
}
else {
    Write-Warning "Директория программы всё ещё существует."
}

if (-not (Test-Path $runtimeDir)) {
    Write-Host "ProgramData: OK"
}
else {
    Write-Warning "Runtime директория всё ещё существует."
}

Write-Host ""

# ============================================================
# Завершение
# ============================================================

Write-Host "========================================"
Write-Host "        Удаление завершено"
Write-Host "========================================"
Write-Host ""