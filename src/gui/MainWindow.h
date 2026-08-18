#pragma once
#include <QWidget>
#include <QListWidget>
#include <vector>
#include "core/Alarm.h"

class MainWindow : public QWidget {
    Q_OBJECT
public:
    explicit MainWindow(QWidget *parent = nullptr);

private slots:
    void addAlarm();
    void removeAlarm();
    void toggleAlarm();
    void saveConfig();

private:
    QListWidget *m_list;
    std::vector<Alarm> m_alarms;
    QString m_configPath;

    void refreshList();
};