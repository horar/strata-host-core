import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Item {
    ListModel {
        id: assemblyModel
        ListElement {
            image_name: "assembly_drawing.png"
        }
    }

    // LOGO
    Rectangle {
        id: headerLogo
        anchors { top: parent.top }
        width: parent.width; height: 40
        color: "#235A92"
    }
    Image {
        anchors { top: parent.top; right: parent.right }
        height: 40
        fillMode: Image.PreserveAspectFit
        source: "onsemi_logo.png"
    }

    Rectangle {
        anchors { top: headerLogo.bottom }
        width: mainWindow.width; height: mainWindow.height - tabBar.height - headerLogo.height
        //border.width: 2; border.color: "red"  // DEBUG

        ListView {
            id: assemblyList
            width: mainWindow.width; height: parent.height

            snapMode: ListView.SnapOneItem
            model: assemblyModel
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
                    source: image_name
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.debug("image_name=" + image_name);
                        assemblyList.currentIndex = index
                    }
                }
            }
        } // end ListView
    }
}
