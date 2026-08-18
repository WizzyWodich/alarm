#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/../.."

echo "== Сборка =="
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)"

echo "== Установка бинарников =="
mkdir -p "$HOME/.local/bin"
cp build/Alarm "$HOME/.local/bin/Alarm"
cp build/mp3player       "$HOME/.local/bin/mp3player"
cp build/mp3alarm-gui    "$HOME/.local/bin/mp3alarm-gui"

echo "== Установка systemd --user сервиса (ядро) =="
mkdir -p "$HOME/.config/systemd/user"
cp packaging/linux/mp3alarm.service "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
systemctl --user enable --now mp3alarm.service

echo "== Установка ярлыка GUI в меню приложений =="
mkdir -p "$HOME/.local/share/applications"
sed "s|%h|$HOME|g" packaging/linux/mp3alarm-gui.desktop \
    > "$HOME/.local/share/applications/mp3alarm-gui.desktop"

echo
echo "Готово."
echo "Сервис (ядро):   systemctl --user status mp3alarm"
echo "GUI-конфигуратор: ищите 'MP3 Alarm' в меню приложений, или запустите:"
echo "                  $HOME/.local/bin/mp3alarm-gui"