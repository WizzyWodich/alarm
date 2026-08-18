Unregister-ScheduledTask -TaskName "MP3AlarmCore" -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Force "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\MP3 Alarm.lnk" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\MP3Alarm" -ErrorAction SilentlyContinue
Write-Host "MP3Alarm удалён."