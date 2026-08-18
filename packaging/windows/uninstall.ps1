$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host "        MP3 Alarm Uninstaller"
Write-Host "========================================"
Write-Host ""

# ============================================================
# Удаление задачи
# ============================================================

Write-Host "== Удаление MP3AlarmCore =="

schtasks /Delete `
    /TN "MP3AlarmCore" `
    /F 2>$null

Write-Host "Задача удалена."
Write-Host ""

# ============================================================
# Остановка Alarm.exe
# ============================================================

Write-Host "== Остановка Alarm.exe =="

Get-Process `
    -Name "Alarm" `
    -ErrorAction SilentlyContinue |
    Stop-Process -Force

Write-Host "Alarm.exe остановлен."
Write-Host ""

# ============================================================
# Пути
# ============================================================

$installDir = "$env:ProgramFiles\MP3Alarm"

$startMenuShortcut = Join-Path `
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs" `
    "MP3 Alarm.lnk"

$desktopDir = [Environment]::GetFolderPath("Desktop")

$desktopShortcut = Join-Path `
    $desktopDir `
    "MP3 Alarm.lnk"

# ============================================================
# Удаление ярлыка из меню Пуск
# ============================================================

Write-Host "== Удаление ярлыка из меню Пуск =="

if (Test-Path $startMenuShortcut) {
    Remove-Item `
        $startMenuShortcut `
        -Force
}

# ============================================================
# Удаление ярлыка с рабочего стола
# ============================================================

Write-Host "== Удаление ярлыка с рабочего стола =="

if (Test-Path $desktopShortcut) {
    Remove-Item `
        $desktopShortcut `
        -Force
}

# ============================================================
# Удаление программы
# ============================================================

Write-Host "== Удаление файлов MP3 Alarm =="

if (Test-Path $installDir) {
    Remove-Item `
        $installDir `
        -Recurse `
        -Force
}

Write-Host ""

Write-Host "========================================"
Write-Host "        Удаление завершено"
Write-Host "========================================"