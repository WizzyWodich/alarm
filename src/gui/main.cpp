#include <QApplication>
#include "MainWindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QApplication::setOrganizationName("mp3alarm");
    QApplication::setApplicationName("mp3alarm");

    MainWindow window;
    window.show();

    return app.exec();
}