import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

GridLayout {
    id: root

    ButtonGroup { buttons: root.children}
    Button {
        id: button1
        text: "test"
        checked: true
        onClicked: { checked = true }
        background: Rectangle{
            color: button1.checked ? "#999999" : "#cccccc"
            radius: 25
            implicitHeight: 50
            implicitWidth: 100

            Rectangle{
                height: parent.height
                width: parent.width/2
                anchors.right:parent.right
                color: parent.color
            }
        }
    }

    Button {
        id: buttonmid
        text: "test"
        onClicked: { checked = true }

        background: Rectangle{
            color: buttonmid.checked ? "#999999" : "#cccccc"
            radius: 0
            implicitHeight: 50
            implicitWidth: 100

//            Rectangle{
//                height: parent.height
//                width: parent.width
//                anchors.centerIn: parent
//                color: parent.color
//            }
        }
    }

    Button {
        id: button2
        text: "test"
        onClicked: { checked = true }

        background: Rectangle{
            color: button2.checked ? "#999999" : "#cccccc"
            radius: 25
            implicitHeight: 50
            implicitWidth: 100

            Rectangle{
                height: parent.height
                width: parent.width/2
                anchors.left: parent.left
                color: parent.color
            }
        }
    }
}
