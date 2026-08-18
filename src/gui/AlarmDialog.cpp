#include "AlarmDialog.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QPushButton>
#include <QFileDialog>
#include <QLabel>
#include <QDialogButtonBox>

AlarmDialog::AlarmDialog(QWidget *parent) : QDialog(parent)
{
    setWindowTitle("Новый будильник");
    setFixedWidth(360);

    setStyleSheet(R"(
        QDialog, QWidget {
            background-color: #1e1e1e;
            color: #e0e0e0;
            font-family: sans-serif;
        }
        QLineEdit, QTimeEdit {
            background-color: #2a2a2a;
            border: 1px solid #444;
            border-radius: 6px;
            padding: 6px 8px;
        }
        QCheckBox {
            padding: 4px 0;
        }
        QPushButton {
            background-color: #2d2d2d;
            border: 1px solid #444;
            border-radius: 6px;
            padding: 8px 16px;
        }
        QPushButton:hover {
            background-color: #3a3a3a;
        }
        QDialogButtonBox QPushButton[text="OK"] {
            background-color: #2e7d32;
            border: 1px solid #4caf50;
        }
    )");

    auto *layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(10);

    layout->addWidget(new QLabel("MP3 файл:"));
    auto *fileRow = new QHBoxLayout();
    m_pathEdit = new QLineEdit(this);
    auto *browseBtn = new QPushButton("Обзор...", this);
    fileRow->addWidget(m_pathEdit);
    fileRow->addWidget(browseBtn);
    layout->addLayout(fileRow);

    layout->addWidget(new QLabel("Время:"));
    m_timeEdit = new QTimeEdit(QTime(9, 0), this);
    m_timeEdit->setDisplayFormat("HH:mm");
    layout->addWidget(m_timeEdit);

    m_enabledCheck = new QCheckBox("Включён", this);
    m_enabledCheck->setChecked(true);
    layout->addWidget(m_enabledCheck);

    auto *buttons = new QDialogButtonBox(QDialogButtonBox::Ok | QDialogButtonBox::Cancel, this);
    layout->addWidget(buttons);

    connect(browseBtn, &QPushButton::clicked, this, &AlarmDialog::browseFile);
    connect(buttons, &QDialogButtonBox::accepted, this, &QDialog::accept);
    connect(buttons, &QDialogButtonBox::rejected, this, &QDialog::reject);
}

void AlarmDialog::browseFile()
{
    QString file = QFileDialog::getOpenFileName(this, "Выберите MP3", QString(), "Audio (*.mp3 *.wav *.ogg)");
    if (!file.isEmpty()) {
        m_pathEdit->setText(file);
    }
}

QString AlarmDialog::filePath() const { return m_pathEdit->text(); }
int AlarmDialog::hour() const { return m_timeEdit->time().hour(); }
int AlarmDialog::minute() const { return m_timeEdit->time().minute(); }
bool AlarmDialog::enabled() const { return m_enabledCheck->isChecked(); }