#include "ConfigLoader.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QStandardPaths>
#include <QDir>
#include <iostream>

QString ConfigLoader::DefaultConfigPath()
{
    QString dir = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    QDir().mkpath(dir); 
    return dir + "/alarms.json";
}

std::vector<Alarm> ConfigLoader::Load(const QString &path)
{
    std::vector<Alarm> result;

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        std::cout << "Config file not found: " << path.toStdString() << std::endl;
        return result; 
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        std::cerr << "JSON parse error: " << parseError.errorString().toStdString() << std::endl;
        return result;
    }

    QJsonArray alarmsArray = doc.object()["alarms"].toArray();

    for (const QJsonValue &value : alarmsArray) {
        QJsonObject obj = value.toObject();
        std::string filePath = obj["file"].toString().toStdString();
        int hour = obj["hour"].toInt();
        int minute = obj["minute"].toInt();
        bool enabled = obj["enabled"].toBool();

        result.emplace_back(filePath, hour, minute, enabled);
    }

    return result;
}

bool ConfigLoader::Save(const QString &path, const std::vector<Alarm> &alarms)
{
    QJsonArray alarmsArray;
    for (const auto &alarm : alarms) {
        QJsonObject obj;
        obj["file"] = QString::fromStdString(alarm.GetFilePath());
        obj["hour"] = alarm.GetHour();
        obj["minute"] = alarm.GetMinute();
        obj["enabled"] = alarm.IsEnabled();
        alarmsArray.append(obj);
    }

    QJsonObject root;
    root["alarms"] = alarmsArray;
    QJsonDocument doc(root);

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        return false;
    }
    file.write(doc.toJson());
    file.close();
    return true;
}