#-------------------------------------------------
#
# Project created by QtCreator 2018-06-20T01:22:14
#
#-------------------------------------------------

QT       += core gui concurrent

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = Flasher-GUI
TEMPLATE = app
CONFIG +=C++11
# The following define makes your compiler emit warnings if you use
# any feature of Qt which has been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
DEPENDPATH += $$PWD/../build


INCLUDEPATH +=  $$PWD/../include \
                $$PWD/../../hcs2/connector/include \
                $$PWD/../../hcs2/include \
                $$PWD/../../include/macos/libserial \
                $$PWD/../../include/macos/libzmq \
                $$PWD/../../../shared/rapidjson/include \
                $$PWD/../../../shared/bootloader/include
SOURCES += \
        main.cpp \
        mainwindow.cpp \
        ../src/Flasher.cpp

HEADERS += \
        mainwindow.h \
        ../include/Flasher.h

FORMS += \
        mainwindow.ui

# Solve Undefined symbols for architecture x86_64 on Mac
LIBS += -framework IOKit
LIBS += -framework Foundation

LIBS += -L"$$_PRO_FILE_PWD_/../build/lib/" -lflasher
LIBS += -L"$$_PRO_FILE_PWD_/../build/connector/lib/" -lconnector
LIBS += -L"$$_PRO_FILE_PWD_/../../lib/macos/libzmq/" -lzmq
LIBS += -L"$$_PRO_FILE_PWD_/../../lib/macos/libserial/" -lserialport
