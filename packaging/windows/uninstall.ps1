Write-Host "== Удаление задачи MP3AlarmCore =="

schtasks /Delete /TN "MP3AlarmCore" /F

Write-Host "== Удаление ярлыка =="

$startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\MP3 Alarm.lnk"

$desktopPath = [Environment]::GetFolderPath("Desktop")
$desktopShortcutPath = Join-Path $desktopPath "MP3 Alarm.lnk"

if (Test-Path $desktopShortcutPath) {
    Remove-Item $desktopShortcutPath -Force
}

if (Test-Path $startMenuPath) {
    Remove-Item $startMenuPath -Force
}

Write-Host "== Удаление файлов =="

$installDir = "$env:LOCALAPPDATA\MP3Alarm"

if (Test-Path $installDir) {
    Remove-Item $installDir -Recurse -Force
}



Write-Host "Готово."