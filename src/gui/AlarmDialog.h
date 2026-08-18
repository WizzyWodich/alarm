#pragma once
#include <QDialog>
#include <QLineEdit>
#include <QTimeEdit>
#include <QCheckBox>

class AlarmDialog : public QDialog {
    Q_OBJECT
public:
    explicit AlarmDialog(QWidget *parent = nullptr);

    QString filePath() const;
    int hour() const;
    int minute() const;
    bool enabled() const;

private slots:
    void browseFile();

private:
    QLineEdit *m_pathEdit;
    QTimeEdit *m_timeEdit;
    QCheckBox *m_enabledCheck;
};