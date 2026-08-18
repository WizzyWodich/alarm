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
    -TaskName "MP3AlarmCore" `
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

    $alarmProcesses | Stop-Process -Force

    Write-Host "Alarm.exe остановлен."

}
else {

    Write-Host "Alarm.exe не запущен."
}

Write-Host ""

# ============================================================
# Удаление ярлыка из меню Пуск
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
# Удаление ярлыка с рабочего стола
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
# Удаление программы
# ============================================================

Write-Host "== Удаление MP3 Alarm =="

if (Test-Path $installDir) {

    Remove-Item `
        $installDir `
        -Recurse `
        -Force

    Write-Host "Файлы программы удалены."

}
else {

    Write-Host "Директория программы не найдена."
}

Write-Host ""

# ============================================================
# Готово
# ============================================================

Write-Host "========================================"
Write-Host "        Удаление завершено"
Write-Host "========================================"
Write-Host ""

Write-Host "MP3 Alarm полностью удалён."
Write-Host ""