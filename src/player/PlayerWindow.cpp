#include "PlayerWindow.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QCloseEvent>
#include <QCoreApplication>
#include <QUrl>
#include <QFileInfo>

PlayerWindow::PlayerWindow(const QString &filePath, QWidget *parent)
    : QWidget(parent)
{
    setWindowTitle("MP3 Alarm Player");
    setFixedSize(360, 160);

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
        QProgressBar {
            border: 1px solid #444;
            border-radius: 4px;
            background-color: #2a2a2a;
            height: 8px;
            text-align: center;
        }
        QProgressBar::chunk {
            background-color: #4caf50;
            border-radius: 4px;
        }
    )");

    m_titleLabel = new QLabel(QFileInfo(filePath).fileName(), this);
    m_titleLabel->setAlignment(Qt::AlignCenter);
    m_titleLabel->setStyleSheet("font-size: 16px; font-weight: bold;");

    m_progressBar = new QProgressBar(this);
    m_progressBar->setTextVisible(false);

    m_timeLabel = new QLabel("00:00 / 00:00", this);
    m_timeLabel->setAlignment(Qt::AlignCenter);

    m_pauseButton = new QPushButton("Пауза", this);
    auto *stopButton = new QPushButton("Стоп", this);

    auto *buttonRow = new QHBoxLayout();
    buttonRow->addWidget(m_pauseButton);
    buttonRow->addWidget(stopButton);

    auto *layout = new QVBoxLayout(this);
    layout->addWidget(m_titleLabel);
    layout->addWidget(m_progressBar);
    layout->addWidget(m_timeLabel);
    layout->addLayout(buttonRow);

    m_player = new QMediaPlayer(this);
    m_audioOutput = new QAudioOutput(this);
    m_player->setAudioOutput(m_audioOutput);
    m_player->setSource(QUrl::fromLocalFile(filePath));

    connect(m_player, &QMediaPlayer::positionChanged, this, &PlayerWindow::onPositionChanged);
    connect(m_player, &QMediaPlayer::durationChanged, this, &PlayerWindow::onDurationChanged);
    connect(m_pauseButton, &QPushButton::clicked, this, &PlayerWindow::togglePause);

    connect(stopButton, &QPushButton::clicked, this, [this]() {
        m_userStopped = true;
        close();
    });

    connect(m_player, &QMediaPlayer::mediaStatusChanged, this,
        [this](QMediaPlayer::MediaStatus status) {
            if (status == QMediaPlayer::EndOfMedia) {
                m_finished = true;
                close();
            }
        });

    m_player->play();
}

void PlayerWindow::onPositionChanged(qint64 position)
{
    m_progressBar->setValue(static_cast<int>(position));
    m_timeLabel->setText(formatTime(position) + " / " + formatTime(m_player->duration()));
}

void PlayerWindow::onDurationChanged(qint64 duration)
{
    m_progressBar->setRange(0, static_cast<int>(duration));
}

void PlayerWindow::togglePause()
{
    if (m_player->playbackState() == QMediaPlayer::PlayingState) {
        m_player->pause();
        m_pauseButton->setText("Продолжить");
    } else {
        m_player->play();
        m_pauseButton->setText("Пауза");
    }
}

QString PlayerWindow::formatTime(qint64 ms) const
{
    qint64 totalSeconds = ms / 1000;
    qint64 minutes = totalSeconds / 60;
    qint64 seconds = totalSeconds % 60;
    return QString("%1:%2")
        .arg(minutes, 2, 10, QChar('0'))
        .arg(seconds, 2, 10, QChar('0'));
}

void PlayerWindow::closeEvent(QCloseEvent *event)
{
    if (!m_finished && !m_userStopped) {
        event->ignore();
        return;
    }
    event->accept();
    QCoreApplication::exit(m_userStopped ? 2 : 0);
}
