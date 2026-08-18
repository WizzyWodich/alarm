#include "Alarm.h"
#include <chrono>
#include <cmath>
#include <ctime>
#include <stdexcept>

Alarm::Alarm(const std::string &file_path, int hour, int minute, bool is_active)
    : file_path(file_path), hour(hour), minute(minute), is_active(is_active) {
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    throw std::invalid_argument("Invalid time for alarm");
  }
}

void Alarm::Enable() { is_active = true; }

void Alarm::Disable() { is_active = false; }

bool Alarm::IsEnabled() const { return is_active; }

const std::string &Alarm::GetFilePath() const { return file_path; }

int Alarm::GetHour() const { return hour; }

int Alarm::GetMinute() const { return minute; }

bool Alarm::IsTimeReached(){
    if (!is_active) {
        return false;
    }
  auto now = std::chrono::system_clock::now();
  std::time_t now_c = std::chrono::system_clock::to_time_t(now);
  std::tm local_tm = *std::localtime(&now_c);

  auto today_point = std::chrono::floor<std::chrono::days>(now);
  std::chrono::year_month_day today{today_point};

  bool time_matches = (local_tm.tm_hour == hour && local_tm.tm_min == minute);
  bool already_fired_today = (last_fired_date.has_value() && *last_fired_date == today);

  if (time_matches && !already_fired_today) {
    last_fired_date = today;
    return true;
  }

  return false;
}
