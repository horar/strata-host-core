import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import Qt.labs.platform 1.1 as QtLabsPlatform

SGWidgets.SGMainWindow {
    id: root

    visible: true
    height: 600
    width: 800
    minimumHeight: 600
    minimumWidth: 800

    title: qsTr("Serial Console Interface")

    property variant settingsDialog: null

    QtLabsPlatform.MenuBar {
        QtLabsPlatform.Menu {
            title: "File"

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
}
