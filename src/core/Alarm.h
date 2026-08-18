#pragma once
#include <chrono>
#include <optional>
#include <string>
class Alarm
{
    private:
        std::string file_path;
        int hour;
        int minute;
        bool is_active;
        std::optional<std::chrono::year_month_day> last_fired_date;
    public:
        Alarm(const std::string& file_path, int hour, int minute, bool is_active = false);
        ~Alarm() = default;

        void Enable();
        void Disable();
        bool IsEnabled() const;
        bool IsTimeReached();

        const std::string& GetFilePath() const;
        int GetHour() const;
        int GetMinute() const;
};


