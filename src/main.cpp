#include <QCoreApplication>
#include <QTimer>
#include <QFileSystemWatcher>
#include <iostream>
#include "core/Alarm.h"
#include "core/Scheduler.h"
#include "core/ConfigLoader.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    QCoreApplication::setOrganizationName("mp3alarm");
    QCoreApplication::setApplicationName("mp3alarm");

    Scheduler scheduler;
    QString configPath = ConfigLoader::DefaultConfigPath();

    auto reloadConfig = [&scheduler, &configPath]() {
        scheduler.ClearAlarms();
        std::vector<Alarm> loaded = ConfigLoader::Load(configPath);
        for (const auto &alarm : loaded) {
            scheduler.AddAlarm(alarm);
        }
        std::cout << "Config reloaded (" << loaded.size() << " alarms)" << std::endl;
        scheduler.PrintAll();
    };

    reloadConfig(); // первая загрузка при старте

    QFileSystemWatcher watcher;
    watcher.addPath(configPath);
    QObject::connect(&watcher, &QFileSystemWatcher::fileChanged,
        [&watcher, &configPath, reloadConfig](const QString &path) {
            reloadConfig();
            watcher.addPath(path); 
        });

    QTimer timer;
    QObject::connect(&timer, &QTimer::timeout, [&scheduler]() {
        scheduler.CheckAll();
    });
    timer.start(1000);

    return app.exec();
}