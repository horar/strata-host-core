import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import Qt.labs.platform 1.1 as QtLabsPlatform

SGWidgets.SGMainWindow {
    id: root
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600

    visible: true
    title: qsTr("Logging Configuration Utility")

    QtLabsPlatform.MenuBar{
        QtLabsPlatform.Menu{
            title: "File"
            QtLabsPlatform.MenuItem{
            text: qsTr("&Exit")
            shortcut: "Ctrl+Q"
            onTriggered:
                root.close()
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

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(root, "qrc:/LcuAboutWindow.qml")
    }

}
