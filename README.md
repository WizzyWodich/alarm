# MP3 Alarm

Будильник с ядром-сервисом, отдельным mp3-плеером и GUI-конфигуратором.

## Состав

- `Alarm` - ядро, фоновый процесс, следит за расписанием и запускает плеер
- `mp3player` - плеер, открывается ядром в нужное время, блокирует случайное закрытие
- `mp3alarm-gui` - настройка списка будильников (время, файл, вкл/выкл)

## Требования

- Qt 6 (Core, Multimedia, Widgets)
- CMake 3.16+
- компилятор с поддержкой C++20

Arch Linux:
```
sudo pacman -S qt6-base qt6-multimedia cmake gcc
```

## Установка - Linux

```
git clone <репозиторий> Alarm
cd Alarm
chmod +x packaging/linux/install.sh
./packaging/linux/install.sh
```

Скрипт делает следующее:
- собирает проект через CMake
- копирует бинарники в `~/.local/bin`
- устанавливает systemd `--user` юнит и включает автозапуск ядра
- добавляет ярлык GUI-конфигуратора в меню приложений

Проверка сервиса:
```
systemctl --user status mp3alarm
journalctl --user -u mp3alarm -f
```

## Удаление - Linux

```
./packaging/linux/uninstall.sh
```

Файл конфигурации (`~/.config/mp3alarm/alarms.json`) при удалении не трогается, убирается отдельно:
```
rm -rf ~/.config/mp3alarm
```

## Переустановка - Linux

```
rm -rf build
./packaging/linux/uninstall.sh
./packaging/linux/install.sh
```

## Установка - Windows

Сборка:
```
cmake -B build -S . -DCMAKE_PREFIX_PATH="C:\Qt\6.x\msvc2019_64"
cmake --build build --config Release
```

Сбор зависимостей Qt рядом с exe:
```
cd build\Release
C:\Qt\6.x\msvc2019_64\bin\windeployqt.exe Alarm.exe
C:\Qt\6.x\msvc2019_64\bin\windeployqt.exe mp3player.exe --multimedia
C:\Qt\6.x\msvc2019_64\bin\windeployqt.exe mp3alarm-gui.exe
```

Сборка инсталлятора (NSIS должен быть установлен и виден в PATH):
```
cd ..\..
cpack --config build\CPackConfig.cmake
```

Результат - `MP3Alarm-<версия>-win64.exe` в папке `build`. Установщик:
- копирует бинарники и DLL
- регистрирует автозапуск ядра через Планировщик заданий (триггер - вход пользователя)
- создаёт ярлык GUI в меню Пуск

Деинсталлятор снимает задачу из планировщика и удаляет файлы, доступен через "Программы и компоненты" или из папки установки.

## Настройка будильников

- запустить GUI-конфигуратор (значок "MP3 Alarm" в меню приложений/Пуск)
- добавить будильник: mp3-файл + время
- сохранить

Ядро следит за файлом конфигурации и подхватывает изменения без перезапуска.

## Часовой пояс

Время сравнивается в `Europe/Kyiv`, с fallback на `Europe/Kiev` при устаревшей базе tzdata. Системные часы должны быть синхронизированы (NTP включён), иначе расписание сместится.

## Почему автозапуск не через классический системный сервис

Ядро открывает окно плеера и проигрывает звук - для этого нужен доступ к графической сессии пользователя. Системный демон (Linux, до логина) и Windows Service (сессия 0) такого доступа не имеют. Поэтому автозапуск привязан ко входу пользователя в систему: `graphical-session.target` в systemd, триггер "At Log On" в Планировщике заданий.