#pragma once
#include <vector>
#include <QString>
#include "Alarm.h"

class ConfigLoader {
public:
    static QString DefaultConfigPath();
    static std::vector<Alarm> Load(const QString &path);
    static bool Save(const QString &path, const std::vector<Alarm> &alarms);
};