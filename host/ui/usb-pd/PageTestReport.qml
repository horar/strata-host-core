import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

import tech.spyglass.Document 1.0
import tech.spyglass.DocumentManager 1.0

Item {
    // LOGO
    Rectangle {
        id: headerLogo
        anchors { top: parent.top }
        width: parent.width; height: 40
        color: "#235A92"

        // PROOF OF CONCEPT BANNER
        Rectangle {
            anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
            width: parent.width * 0.70; height: 30;
            color: "red"
            radius: 4
            Label {
                anchors { centerIn: parent }
                text: "SPYGLASS PROOF OF CONCEPT WITH LAB CLOUD"
                color: "white"
                font.bold: true
            }
        }
    }

    Image {
        anchors { top: parent.top; right: parent.right }
        height: 40
        fillMode: Image.PreserveAspectFit
        source: "./images/icons/onLogoGreenWithText.png"
    }

    Rectangle {
        anchors { top: headerLogo.bottom }
        width: mainWindow.width; height: mainWindow.height - tabBar.height - headerLogo.height
        //border.width: 2; border.color: "red"  // DEBUG

        ListView {
            id: reportList
            width: mainWindow.width; height: parent.height

            snapMode: ListView.SnapOneItem
            model: documentManager.testReportDocuments
            focus: true
            clip: true
            add: Transition { NumberAnimation { properties: "x,y"; from: 100; duration: 1000 } }

            delegate: Rectangle {
                width: mainWindow.width; height: mainWindow.height - headerLogo.height
                //border.width: 2; border.color: "green"  // DEBUG
                Image {
                    id: image
                    anchors.centerIn: parent
                    width: parent.width; height: parent.height
                    fillMode: Image.PreserveAspectFit
                    source: "data:image/png;base64," + model.data
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        reportList.currentIndex = index
                    }
                }
            }
        } // end ListView
    }
}
