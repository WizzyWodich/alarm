set -e

echo "== Остановка и отключение сервиса =="
systemctl --user disable --now mp3alarm.service || true
rm -f "$HOME/.config/systemd/user/mp3alarm.service"
systemctl --user daemon-reload

echo "== Удаление бинарников =="
rm -f "$HOME/.local/bin/Alarm"
rm -f "$HOME/.local/bin/mp3player"
rm -f "$HOME/.local/bin/mp3alarm-gui"

echo "== Удаление ярлыка из меню приложений =="
rm -f "$HOME/.local/share/applications/mp3alarm-gui.desktop"

echo "mp3alarm полностью удалён."
echo "Конфиг (~/.config/mp3alarm/alarms.json) оставлен нетронутым - удалите вручную, если нужно:"
echo "  rm -rf ~/.config/mp3alarm"