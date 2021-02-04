import QtQuick 2.12
import tech.strata.prt 1.0 as PrtCommon
import tech.strata.sgwidgets 1.0 as SGWidgets
import Qt.labs.platform 1.1 as QtLabsPlatform


SGWidgets.SGMainWindow {
    id: root
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600

    PrtCommon.PrtModel {
        id: prtModel
    }

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

    Rectangle {
        id: testServerWarningContainer
        color: "red"
        anchors {
            left: parent.left 
            right: undefined
            top: parent.top
            margins: 10
        }
        height: testServerWarning.height + 10
        width: parent.width/3.4
        radius: 5
        visible: prtModel.serverType.length > 0

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.centerIn: parent
            SGWidgets.SGIcon {
                source: "qrc:/sgimages/exclamation-circle.svg"
                height: 15
                width: height
                iconColor: "white"
            }

            Text {
                id: testServerWarning
                color: "white"
                font.bold: true
                text: " Non-production server in use. "
            }            
        }
    }

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(root, "qrc:/PrtAboutWindow.qml")
    }
}
