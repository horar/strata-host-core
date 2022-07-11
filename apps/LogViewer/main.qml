/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.sgwidgets.debug 1.0 as SGDebugWidgets
import Qt.labs.platform 1.0 as QtLabsPlatform
import QtQuick.Controls 2.12
import QtQml 2.12

SGWidgets.SGMainWindow {
    id: root
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600

    property int statusBarHeight: logViewerMain.statusBarHeight
    property var recentFiles: logViewerMain.recentFiles

    visible: true
    title: qsTr("Log Viewer")

    Shortcut {
        sequence: StandardKey.Open
        onActivated: logViewerMain.getFilePath()
    }

    QtLabsPlatform.MenuBar {
        QtLabsPlatform.Menu {
            title: qsTr("&File")

            QtLabsPlatform.MenuItem {
                text: qsTr("&Open...")
                shortcut: StandardKey.Open
                onTriggered: {
                    logViewerMain.getFilePath()
                }
            }

            QtLabsPlatform.Menu {
                id: recentFilesSubMenu
                title: qsTr("&Recent Files")
                enabled: recentFilesInstantiator.count > 0

                Instantiator {
                    id: recentFilesInstantiator
                    model: recentFiles
                    delegate: QtLabsPlatform.MenuItem {
                        text: qsTr("&%1: %2").arg(index + 1).arg(recentFiles[index])
                        onTriggered: logViewerMain.loadFiles(["file:" + recentFiles[index]])
                    }

                    onObjectAdded: recentFilesSubMenu.insertItem(index, object)
                    onObjectRemoved: recentFilesSubMenu.removeItem(object)
                }

                QtLabsPlatform.MenuSeparator {}

                QtLabsPlatform.MenuItem {
                    text: qsTr("&Clear Recent")
                    onTriggered: {
                        logViewerMain.clearRecentFiles()
                    }
                }
            }

            QtLabsPlatform.MenuItem {
                text: qsTr("&Close All Files")
                onTriggered: {
                    logViewerMain.closeAllFiles()
                }
            }

            QtLabsPlatform.MenuItem {
                text: qsTr("&Settings")
                onTriggered:  {
                    showSettingsDialog()
                }
            }

            QtLabsPlatform.MenuSeparator {}

            QtLabsPlatform.MenuItem {
                text: qsTr("&Exit")
                shortcut: "Ctrl+Q"
                onTriggered: {
                    root.close()
                }
            }
        }

        QtLabsPlatform.Menu {
            title: "Help"
            QtLabsPlatform.MenuItem {
                text: qsTr("&About")
                onTriggered:  {
                    showAboutWindow()
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#eeeeee"
    }

    Popup {
        id: popup

        parent: Overlay.overlay
        anchors.centerIn: parent
        padding: 16

        Column {
            SGWidgets.SGText {
                text: qsTr("Files are loading...")
                fontSizeMultiplier: 2.0
            }
        }
    }

    Timer {
        id: loadingTimer
        interval: 500
        onTriggered: {
            for (var i = 1; i < Qt.application.arguments.length; i++) {
                logViewerMain.loadFiles(["file:" + Qt.application.arguments[i]])
            }
            popup.close()
        }
    }

    LogViewerMain {
        id: logViewerMain
        anchors{
            fill: parent
            leftMargin: 5
            rightMargin: 5
            topMargin: 5
            bottomMargin: statusBarHeight + 5
        }

        focus: true
        Component.onCompleted: {
            if (Qt.application.arguments.length > 1) {
                popup.open()
                loadingTimer.start()
            }
        }
    }

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(root, "qrc:/LogViewerAboutWindow.qml")
    }

    function showSettingsDialog() {
        var dialog = SGWidgets.SGDialogJS.createDialog(
                    root,
                    "qrc:/LogViewerSettingsDialog.qml"
                    )
        dialog.accepted.connect(function() {
            dialog.destroy()
        })
        dialog.open()
    }

    SGDebugWidgets.SGQmlDebug {
        id: qmlDebug
        anchors {
            bottomMargin: 60
            rightMargin: 170
            right: parent.right
            bottom: parent.bottom
        }

        signalTarget: logModel
    }
}
