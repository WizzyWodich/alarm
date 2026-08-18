#include <QApplication>
#include "PlayerWindow.h"
#include <iostream>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    if (argc < 2) {
        std::cerr << "Usage: mp3player <path_to_mp3>" << std::endl;
        return 1;
    }

    PlayerWindow window(argv[1]);
    window.show();

    return app.exec();
}
