import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
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
}
