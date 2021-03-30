import QtQuick 2.12
import tech.strata.prt 1.0 as PrtCommon
import tech.strata.sgwidgets 1.0 as SGWidgets
import Qt.labs.platform 1.1 as QtLabsPlatform


SGWidgets.SGMainWindow {
    id: root
    width: 1024
    height: 768
    minimumWidth: 1024
    minimumHeight: 768

    visible: true
    title: qsTr("Platform Registration Tool")

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
        anchors.fill: parent
        color: "#eeeeee"
    }


    PrtMain {
        anchors {
            fill: parent
            margins: 4
        }
    }

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(root, "qrc:/PrtAboutWindow.qml")
    }
}
