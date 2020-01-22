import QtQuick 2.12
import tech.strata.prt 1.0 as PrtCommon
import tech.strata.common 1.0 as Common
import tech.strata.sgwidgets 1.0 as SGWidgets
import Qt.labs.platform 1.1 as QtLabsPlatform

SGWidgets.SGMainWindow {
    id: root
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600

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


    PrtCommon.PrtModel {
        id: prtModel
    }

    Rectangle {
        anchors.fill: parent
        color: "#eeeeee"
    }

    Common.ProgramDeviceWizard {
        anchors {
            fill: parent
            margins: 4
        }
        boardManager: prtModel.boardManager
    }

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(root, "qrc:/PrtAboutWindow.qml")
    }
}
