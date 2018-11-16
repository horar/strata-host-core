QT += quick

CONFIG += c++1z
CONFIG += strict_c++

QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.13

# QMAKE_CXXFLAGS *= /std:c++17
# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp \
    PlatformController.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    PlatformController.h


INCLUDEPATH +=  $$PWD/../hcs2/connector/include\
                $$PWD/../hcs2/include\
                $$PWD/../hcs2/\
                $$PWD/../include/macos/libserial \
                $$PWD/../include/macos/libzmq \
                $$PWD/../../shared/rapidjson/include/ \
                $$PWD/../../shared/bootloader/include \
                $$PWD/../include/


# Solve Undefined symbols for architecture x86_64 on Mac
LIBS += -framework IOKit
LIBS += -framework Foundation

LIBS += -L"$$_PRO_FILE_PWD_/../Flasher/build/lib/" -lflasher
LIBS += -L"$$_PRO_FILE_PWD_/../Flasher/build/connector/lib/" -lconnector
                                                         #solves warning "Object file was built for newer OSX version than being linked"
LIBS += -L"$$_PRO_FILE_PWD_/../lib/macos/libzmq/" -lzmq -mmacosx-version-min=10.13
LIBS += -L"$$_PRO_FILE_PWD_/../lib/macos/libserial/" -lserialport

DISTFILES +=




