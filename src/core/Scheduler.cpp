#include "Scheduler.h"
#include "Alarm.h"
#include <iostream>
#include <ostream>
#include <QProcess>
#include <QCoreApplication>
#include <string>

void Scheduler::AddAlarm(const Alarm& alarm)
{
    alarms.push_back(alarm);
}

void Scheduler::PrintAll() const 
{
    for (const auto& alarm : alarms) {
        std::cout << "Alarm: " << alarm.GetFilePath() 
                  << " at " << alarm.GetHour() << ":" << alarm.GetMinute() 
                  << " is " << (alarm.IsEnabled() ? "enabled" : "disabled") 
                  << std::endl;
    }
}

void Scheduler::CheckAll(){
    for (auto& alarm : alarms) {
        if(alarm.IsTimeReached()){
            std::cout << "Alarm fired: " << alarm.GetFilePath() << std::endl;
            LaunchPlayer(alarm.GetFilePath());
        }
    }
}

void Scheduler::ClearAlarms()
{
    alarms.clear();
}

Alarm* Scheduler::FindAlarm(const std::string& file_path)
{
    for (auto& alarm : alarms) {
        if (alarm.GetFilePath() == file_path) {
            return &alarm;
        }
    }
    return nullptr; 
}

bool Scheduler::RemoveAlarm(const std::string& file_path)
{
    for (auto it = alarms.begin(); it != alarms.end(); ++it) {
        if (it -> GetFilePath() == file_path) {
           alarms.erase(it);
           return true;
        }
    }

    return false;
}

bool Scheduler::EnableAlarm(const std::string& file_path){
    Alarm* alarm = FindAlarm(file_path);
    if (alarm) {
        alarm->Enable();
        return true;
    }
    else{
        return false;
    }
}

bool Scheduler::DisableAlarm(const std::string& file_path){
    Alarm* alarm = FindAlarm(file_path);
    if (alarm) {
        alarm -> Disable();
        return true;
    }
    else {
        return false;
    }
}

void Scheduler::LaunchPlayer(const std::string& file_path){
    QString playerPath = QCoreApplication::applicationDirPath() + "/mp3player";

    auto *process = new QProcess();
    QStringList args;
    args << QString::fromStdString(file_path);

    QObject::connect(process, &QProcess::finished, process,
            [process](int exitCode, QProcess::ExitStatus exitStatus) {
            if (exitStatus == QProcess::CrashExit) {
                std::cout << "Player crashed or was killed!" << std::endl;
            } else if (exitCode == 0) {
                std::cout << "Player finished normally." << std::endl;
            } else if (exitCode == 2) {
                std::cout << "Player stopped early by user." << std::endl;
            } else {
                std::cout << "Player exited with error code " << exitCode << std::endl;
            }

            process->deleteLater();
        });

    process->start(playerPath, args);
}
