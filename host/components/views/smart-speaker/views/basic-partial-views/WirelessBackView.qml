import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id: root
    width: 200
    height:200
    color:"dimgray"
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
        id: fileButton
        text: "Current Network"
        onClicked: menu.open()

        anchors.top: networkName.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 40
                    color: fileButton.down ? "black" : "grey"
                    border.color: "black"
                    border.width: 0
                    radius: 10
                }
        Menu {
            id: menu
            y: networkButton.height

            MenuItem {
                text: "Network one"
            }
            MenuItem {
                text: "Network two"
            }
            MenuItem {
                text: "Network three"
            }

            onCurrentIndexChanged: {
                fileButton.text = menu.itemAt[currentIndex].text
            }
        }
    }

}
