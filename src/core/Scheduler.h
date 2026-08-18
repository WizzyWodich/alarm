#pragma once
#include <string>
#include <vector>
#include "Alarm.h"

class Scheduler
{
    private:
        std::vector<Alarm> alarms;
        void LaunchPlayer(const std::string& file_path);
    public:
        Scheduler() = default;
        ~Scheduler() = default;
        void AddAlarm(const Alarm& alarm);

        void PrintAll() const;
        void CheckAll();
        void ClearAlarms();
        Alarm* FindAlarm(const std::string& file_path);
        bool RemoveAlarm(const std::string& file_path);
        bool EnableAlarm(const std::string& file_path);
        bool DisableAlarm(const std::string& file_path);    

};

