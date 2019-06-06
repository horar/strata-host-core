import QtQuick 2.10
import QtQuick.Controls 2.2

Rectangle {
    id: back
    width: 200
    height:200
    color:"dimgrey"
    opacity:1
    radius: 10

    Text{
        id:networkName
        text:"available networks:"
        color:"white"
        font.pixelSize: 24
        anchors.top:parent.top
        anchors.topMargin:10
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Button {
        id: networkButton
        text: "Current Network"

        anchors.top: networkName.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 40
                    color: networkButton.down ? "black" : "grey"
                    border.color: "black"
                    border.width: 0
                    radius: 10
                }

        onClicked: menu.open()

        Menu {
            id: menu
            y: networkButton.height

            MenuItem {
                text: "Device one"
            }
            MenuItem {
                text: "Device two"
            }
            MenuItem {
                text: "Device three"
            }
        }
    }
}
