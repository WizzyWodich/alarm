$installDir = "$env:LOCALAPPDATA\MP3Alarm"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

Write-Host "== Копирование файлов =="
Copy-Item -Path ".\*" -Destination $installDir -Recurse -Force

$corePath = Join-Path $installDir "Alarm.exe"
$guiPath    = Join-Path $installDir "mp3alarm-gui.exe"

Write-Host "== Регистрация автозапуска ядра (Task Scheduler) =="
$action  = New-ScheduledTaskAction -Execute $corePath
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit ([TimeSpan]::Zero)

Register-ScheduledTask -TaskName "MP3AlarmCore" `
    -Action $action -Trigger $trigger -Settings $settings `
    -Description "MP3 Alarm - фоновый сервис-планировщик" `
    -Force

Write-Host "== Ярлык GUI в меню Пуск =="
$startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\MP3 Alarm.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($startMenuPath)
$shortcut.TargetPath = $guiPath
$shortcut.WorkingDirectory = $installDir
$shortcut.IconLocation = $guiPath
$shortcut.Save()

Write-Host ""
Write-Host "Готово."
Write-Host "Ядро запустится автоматически при следующем входе в Windows."
Write-Host "Запустить прямо сейчас: Start-ScheduledTask -TaskName MP3AlarmCore"
Write-Host "GUI-конфигуратор: ищите 'MP3 Alarm' в меню Пуск, или запустите $guiPath"