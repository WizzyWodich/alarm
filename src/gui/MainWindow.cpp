#include "MainWindow.h"
#include "AlarmDialog.h"
#include "core/ConfigLoader.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QPushButton>
#include <QMessageBox>
#include <QLabel>
#include <QFileInfo>

MainWindow::MainWindow(QWidget *parent) : QWidget(parent)
{
    setWindowTitle("MP3 Alarm - настройки");
    resize(440, 380);

    setStyleSheet(R"(
        QWidget {
            background-color: #1e1e1e;
            color: #e0e0e0;
            font-family: sans-serif;
        }
        QPushButton {
            background-color: #2d2d2d;
            border: 1px solid #444;
            border-radius: 6px;
            padding: 8px 16px;
            font-size: 14px;
        }
        QPushButton:hover {
            background-color: #3a3a3a;
        }
        QPushButton:pressed {
            background-color: #444;
        }
        QPushButton#saveButton {
            background-color: #2e7d32;
            border: 1px solid #4caf50;
            font-weight: bold;
        }
        QPushButton#saveButton:hover {
            background-color: #388e3c;
        }
        QListWidget {
            background-color: #262626;
            border: 1px solid #444;
            border-radius: 6px;
            padding: 6px;
            font-size: 13px;
        }
        QListWidget::item {
            padding: 8px;
            border-radius: 4px;
            margin-bottom: 2px;
        }
        QListWidget::item:selected {
            background-color: #2e7d32;
            color: #ffffff;
        }
        QListWidget::item:hover {
            background-color: #333333;
        }
        QLabel#header {
            font-size: 18px;
            font-weight: bold;
        }
    )");

    auto *headerLabel = new QLabel("Мои будильники", this);
    headerLabel->setObjectName("header");

    m_configPath = ConfigLoader::DefaultConfigPath();
    m_alarms = ConfigLoader::Load(m_configPath);

    m_list = new QListWidget(this);

    auto *addBtn = new QPushButton("+ Добавить", this);
    auto *removeBtn = new QPushButton("Удалить", this);
    auto *toggleBtn = new QPushButton("Вкл/Выкл", this);
    auto *saveBtn = new QPushButton("Сохранить", this);
    saveBtn->setObjectName("saveButton");

    auto *buttonRow = new QHBoxLayout();
    buttonRow->setSpacing(8);
    buttonRow->addWidget(addBtn);
    buttonRow->addWidget(removeBtn);
    buttonRow->addWidget(toggleBtn);

    auto *layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);
    layout->addWidget(headerLabel);
    layout->addWidget(m_list);
    layout->addLayout(buttonRow);
    layout->addWidget(saveBtn);

    connect(addBtn, &QPushButton::clicked, this, &MainWindow::addAlarm);
    connect(removeBtn, &QPushButton::clicked, this, &MainWindow::removeAlarm);
    connect(toggleBtn, &QPushButton::clicked, this, &MainWindow::toggleAlarm);
    connect(saveBtn, &QPushButton::clicked, this, &MainWindow::saveConfig);

    refreshList();
}

void MainWindow::refreshList()
{
    m_list->clear();
    for (const auto &alarm : m_alarms) {
        QString status = alarm.IsEnabled() ? "🟢" : "⚪";
        QString text = QString("%1  %2:%3 — %4")
            .arg(status)
            .arg(alarm.GetHour(), 2, 10, QChar('0'))
            .arg(alarm.GetMinute(), 2, 10, QChar('0'))
            .arg(QFileInfo(QString::fromStdString(alarm.GetFilePath())).fileName());
        m_list->addItem(text);
    }
}

void MainWindow::addAlarm()
{
    AlarmDialog dialog(this);
    if (dialog.exec() == QDialog::Accepted) {
        if (dialog.filePath().isEmpty()) {
            QMessageBox::warning(this, "Ошибка", "Файл не выбран.");
            return;
        }
        m_alarms.emplace_back(dialog.filePath().toStdString(),
                               dialog.hour(), dialog.minute(), dialog.enabled());
        refreshList();
    }
}

void MainWindow::removeAlarm()
{
    int row = m_list->currentRow();
    if (row < 0) return;
    m_alarms.erase(m_alarms.begin() + row);
    refreshList();
}

void MainWindow::toggleAlarm()
{
    int row = m_list->currentRow();
    if (row < 0) return;
    if (m_alarms[row].IsEnabled()) {
        m_alarms[row].Disable();
    } else {
        m_alarms[row].Enable();
    }
    refreshList();
}

void MainWindow::saveConfig()
{
    if (ConfigLoader::Save(m_configPath, m_alarms)) {
        QMessageBox::information(this, "Сохранено", "Конфигурация сохранена.");
    } else {
        QMessageBox::warning(this, "Ошибка", "Не удалось сохранить файл.");
    }
}