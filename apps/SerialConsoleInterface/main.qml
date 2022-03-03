/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQml 2.12
import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import Qt.labs.platform 1.1 as QtLabsPlatform

SGWidgets.SGMainWindow {
    id: root

    visible: true
    height: defaultWindowHeight
    width: defaultWindowWidth
    minimumHeight: 768
    minimumWidth: 1024

    title: qsTr("Serial Console Interface")

    property variant settingsDialog: null
    property variant connectMockDeviceDialog: null
    property int defaultWindowHeight: 768
    property int defaultWindowWidth: 1024

    function resetWindowSize() {
        root.height = defaultWindowHeight
        root.width = defaultWindowWidth
    }

    QtLabsPlatform.MenuBar {
        QtLabsPlatform.Menu {
            title: qsTr("&File")

            QtLabsPlatform.MenuItem {
                text: qsTr("&Settings")
                onTriggered:  {
                    showSettingsDialog()
                }
            }

            QtLabsPlatform.MenuSeparator {}

            QtLabsPlatform.MenuItem {
                text: qsTr("&Exit")
                onTriggered:  {
                    root.close()
                }
            }
        }

        QtLabsPlatform.Menu {
            title: qsTr("&Mock")

            QtLabsPlatform.MenuItem {
                text: qsTr("&Connect Device...")
                onTriggered:  {
                    showConnectMockDeviceDialog()
                }
            }

            QtLabsPlatform.Menu {
                id: disconnectDeviceSubMenu
                title: qsTr("&Disconnect Device")

                Instantiator {
                    id: disconnectDeviceInstantiator
                    model: sciModel.mockDeviceModel
                    delegate: QtLabsPlatform.MenuItem {
                        text: deviceName
                        onTriggered: {
                            sciModel.mockDeviceModel.disconnectMockDevice(deviceId)
                        }
                    }

                    onObjectAdded: disconnectDeviceSubMenu.insertItem(index, object)
                    onObjectRemoved: disconnectDeviceSubMenu.removeItem(object)
                }

                QtLabsPlatform.MenuSeparator {}

                QtLabsPlatform.MenuItem {
                    text: qsTr("Disconnect all")
                    enabled: disconnectDeviceInstantiator.count > 0
                    onTriggered:  {
                        sciModel.mockDeviceModel.disconnectAllMockDevices()
                    }
                }
            }
        }

        QtLabsPlatform.Menu {
            title: qsTr("&Help")
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

    SciMain {
        id: sciMain
        anchors.fill: parent
    }

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(root, "qrc:/SciAboutWindow.qml")
    }

    function showSettingsDialog() {
        if (settingsDialog !== null) {
            return
        }

        settingsDialog = SGWidgets.SGDialogJS.createDialog(
                    root,
                    "qrc:/SciSettingsDialog.qml",
                    {
                        "rootItem": root,
                    })
        settingsDialog.open()
    }

    function showConnectMockDeviceDialog() {
        if (connectMockDeviceDialog !== null) {
            return
        }

        connectMockDeviceDialog = SGWidgets.SGDialogJS.createDialog(root,"qrc:/SciConnectMockDeviceDialog.qml")
        connectMockDeviceDialog.open()
    }
}
