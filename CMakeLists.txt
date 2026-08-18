cmake_minimum_required(VERSION 3.16)
project(MyAlarm LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Multimedia Widgets)

add_library(mp3alarm_core STATIC
    src/core/Alarm.cpp
    src/core/Scheduler.cpp
    src/core/ConfigLoader.cpp
)
target_include_directories(mp3alarm_core PUBLIC src)
target_link_libraries(mp3alarm_core PUBLIC Qt6::Core)

add_executable(Alarm src/main.cpp)
target_link_libraries(Alarm PRIVATE mp3alarm_core)

add_executable(mp3player
    src/player/main.cpp
    src/player/PlayerWindow.h
    src/player/PlayerWindow.cpp
)
target_link_libraries(mp3player PRIVATE Qt6::Core Qt6::Multimedia Qt6::Widgets)

add_executable(mp3alarm-gui
    src/gui/main.cpp
    src/gui/MainWindow.h
    src/gui/MainWindow.cpp
    src/gui/AlarmDialog.h
    src/gui/AlarmDialog.cpp
)
target_link_libraries(mp3alarm-gui PRIVATE mp3alarm_core Qt6::Widgets)

install(TARGETS Alarm mp3player mp3alarm-gui
    RUNTIME DESTINATION bin
)

if(WIN32)
    install(DIRECTORY "$<TARGET_FILE_DIR:Alarm>/"
        DESTINATION bin
        FILES_MATCHING
            PATTERN "*.dll"
            PATTERN "platforms/*"
            PATTERN "multimedia/*"
            PATTERN "styles/*"
    )
endif()

if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

if(WIN32)
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_PACKAGE_NAME "MP3 Alarm")
    set(CPACK_PACKAGE_VERSION "1.0.0")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "MP3Alarm")
    set(CPACK_NSIS_MODIFY_PATH OFF)

    set(CPACK_PACKAGE_EXECUTABLES "mp3alarm-gui" "MP3 Alarm")
    set(CPACK_CREATE_DESKTOP_LINKS "mp3alarm-gui")

    set(CPACK_NSIS_EXTRA_INSTALL_COMMANDS "
        ExecWait 'schtasks /Create /TN \\\"MP3AlarmCore\\\" /TR \\\"$INSTDIR\\\\bin\\\\Alarm.exe\\\" /SC ONLOGON /RL LIMITED /F'
    ")

    set(CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS "
        ExecWait 'schtasks /Delete /TN \\\"MP3AlarmCore\\\" /F'
    ")
endif()

include(CPack)