$installDir = "$env:LOCALAPPDATA\MP3Alarm"
$binDir = Join-Path $installDir "bin"

New-Item -ItemType Directory -Force -Path $installDir | Out-Null

Write-Host "== Копирование файлов =="
Copy-Item -Path ".\*" -Destination $installDir -Recurse -Force

$corePath = Join-Path $binDir "Alarm.exe"
$guiPath  = Join-Path $binDir "mp3alarm-gui.exe"

Write-Host "== Регистрация автозапуска ядра (Task Scheduler) =="

$action = New-ScheduledTaskAction `
    -Execute $corePath `
    -WorkingDirectory $binDir

$trigger = New-ScheduledTaskTrigger -AtLogOn

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit ([TimeSpan]::Zero)

Register-ScheduledTask `
    -TaskName "MP3AlarmCore" `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Description "MP3 Alarm - фоновый планировщик" `
    -Force

Write-Host "== Ярлык GUI в меню Пуск =="

$startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\MP3 Alarm.lnk"

$shell = New-Object -ComObject WScript.Shell

$shortcut = $shell.CreateShortcut($startMenuPath)
$shortcut.TargetPath = $guiPath
$shortcut.WorkingDirectory = $binDir
$shortcut.IconLocation = $guiPath
$shortcut.Save()

Write-Host ""
Write-Host "Готово."
Write-Host "Ядро: $corePath"
Write-Host "GUI:  $guiPath"
Write-Host ""
Write-Host "Запустить прямо сейчас:"
Write-Host 'Start-ScheduledTask -TaskName "MP3AlarmCore"'