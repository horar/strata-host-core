/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.sgwidgets.debug 1.0 as SGDebugWidgets
import Qt.labs.platform 1.0 as QtLabsPlatform

SGWidgets.SGMainWindow {
    id: root

    height: 600
    width: 800
    minimumHeight: 600
    minimumWidth: 800

    visible: true
    title: qsTr("Widget Gallery")

    QtLabsPlatform.MenuBar {
        QtLabsPlatform.Menu {
            title: "File"

            QtLabsPlatform.MenuItem {
                text: qsTr("&Settings")
                onTriggered:  {
                    showSettingsDialog()
                }
            }

            QtLabsPlatform.MenuItem {
                text: qsTr("&Exit")
                onTriggered:  {
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
        id: bg
        anchors.fill: parent
        color:"#eeeeee"
    }

    WgMain {
        anchors {
            fill: parent
        }
    }

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(root, "qrc:/WgAboutWindow.qml")
    }

    function showSettingsDialog() {
        var dialog = SGWidgets.SGDialogJS.createDialog(
                    root,
                    "qrc:/WgSettingsDialog.qml"
                    )
        dialog.accepted.connect(function() {
            dialog.destroy()
        })
        dialog.open()
    }

    SGDebugWidgets.SGQmlDebug {
        id: qmlDebug
        anchors {
            topMargin: 10
            rightMargin: 170
            right: parent.right
            top: parent.top
        }

            signalTarget: wgModel
    }
}
