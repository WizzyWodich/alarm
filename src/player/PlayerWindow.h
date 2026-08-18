#pragma once
#include <QWidget>
#include <QMediaPlayer>
#include <QAudioOutput>
#include <QProgressBar>
#include <QPushButton>
#include <QLabel>

class PlayerWindow : public QWidget {
    Q_OBJECT
public:
    explicit PlayerWindow(const QString &filePath, QWidget *parent = nullptr);

protected:
    void closeEvent(QCloseEvent *event) override;

private slots:
    void onPositionChanged(qint64 position);
    void onDurationChanged(qint64 duration);
    void togglePause();

private:
    QMediaPlayer *m_player;
    QAudioOutput *m_audioOutput;
    QProgressBar *m_progressBar;
    QPushButton *m_pauseButton;
    QLabel *m_timeLabel;
    QLabel *m_titleLabel;

    bool m_finished = false;
    bool m_userStopped = false;

    QString formatTime(qint64 ms) const;
};
