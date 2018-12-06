TEMPLATE = app
TARGET = Strata
win32:VERSION = 1.0.0.0 # major.minor.patch.build
else:VERSION = 1.0.0    # major.minor.patch

QT += quick qml webview webengine charts
CONFIG += c++1z strict_c++ resources_big
CONFIG += warn_on

# Application icon
win32: RC_ICONS = resources/icons/app/on.ico
macx: ICON = resources/icons/app/onLogoGreen.icns


# Minimum supported macOS version (Qt allows 10.11; but libzmq requires 10.13)
QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.13

macx {
    # Customized/parametrized Info.plist
    QMAKE_INFO_PLIST = resources/Info.plist.in

    # App ID
    QMAKE_TARGET_BUNDLE_PREFIX = com.onsemi.spyglass
}

DEFINES += QT_DEPRECATED_WARNINGS
DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES +=

# set root host build path
HOST_ROOT = ../../../host

# linux
unix : !macx : !win32 {
    message("Building on Linux")
    LIBS += -L$${HOST_ROOT}/ext_libs/libzmq/lib/linux/ -lzmq
    LIBS += -L$${HOST_ROOT}/build/libs/HostControllerClient/ -lHostControllerClient
    DEPENDPATH += $${HOST_ROOT}/ext_libs/libzmq/include
    INCLUDEPATH += $${HOST_ROOT}/libs/HostControllerClient/include/
    INCLUDEPATH += $${HOST_ROOT}/ext_libs/zmq/include
    INCLUDEPATH += $${HOST_ROOT}/ext_libs/libzmq/include
    INCLUDEPATH += $$PWD/PlatformInterface
}

# macOS (not iOS)
else : macx : !win32 {
    message("Building on macOS")
    LIBS += -L$${HOST_ROOT}/ext_libs/libzmq/lib/mac/ -lzmq
    LIBS += -L$${HOST_ROOT}/build/libs/HostControllerClient/ -lHostControllerClient
    DEPENDPATH += $${HOST_ROOT}/ext_libs/libzmq/include
    INCLUDEPATH += $${HOST_ROOT}/include/macos/libzmq
    INCLUDEPATH += $${HOST_ROOT}/libs/HostControllerClient/include/
    INCLUDEPATH += $${HOST_ROOT}/ext_libs/zmq/include
    INCLUDEPATH += $${HOST_ROOT}/ext_libs/libzmq/include
    INCLUDEPATH += $$PWD/PlatformInterface
    INCLUDEPATH += $$PWD/include

}

# windows
else : win32 {
    message("Building on Windows")
    LIBS += -L$$PWD/../../lib/windows/zeromq/ -llibzmq
    INCLUDEPATH += $${HOST_ROOT}/ext_libs/libzmq/include
    DEPENDPATH += $${HOST_ROOT}/ext_libs/libzmq/include
    INCLUDEPATH += $${HOST_ROOT}/lib/linux/include
    INCLUDEPATH += $${HOST_ROOT}/libs/HostControllerClient/include/
    INCLUDEPATH += $${HOST_ROOT}/ext_libs/zmq/include
    INCLUDEPATH += $${HOST_ROOT}/ext_libs/libzmq/include
    INCLUDEPATH += $$PWD/PlatformInterface/
    INCLUDEPATH += $$PWD/include
    DEPENDPATH += $${HOST_ROOT}/lib/linux/include
}
else: message("UNKNOWN machine type. Build configuration failed !!!!")

message("BUILD VARIABLES")
message(Host Root: $${HOST_ROOT});
message(Current Build Directory: $$PWD);
message(Include Path: $$INCLUDEPATH);
message(Depend Path: $$DEPENDPATH);
message("DONE");

HEADERS += PlatformInterface/core/CoreInterface.h \
    include/DocumentManager.h \
    $${HOST_ROOT}/libs/HostControllerClient/include/HostControllerClient.hpp \
    $${HOST_ROOT}/ext_libs/zmq/include/zhelpers.hpp \
    $${HOST_ROOT}/ext_libs/zmq/include/zmq.hpp \
    $${HOST_ROOT}/ext_libs/zmq/include/zmq_addon.hpp

SOURCES += main.cpp \
    PlatformInterface/core/CoreInterface.cpp \
    source/DocumentManager.cpp

RESOURCES += qml.qrc \
    views/SGPdfViewer/pdfjs.qrc
