import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

GridLayout {
    id: root

    ButtonGroup { buttons: root.children}
    Button {
        id: button1
        text: "AM"
        checked: true
        onClicked: { checked = true }
        background: Rectangle{
            gradient: Gradient {
                GradientStop { position: 0.0; color: button1.checked ? "#bbbbbb" : "#ffffff" }
                GradientStop { position: 1.0; color: button1.checked ? "#999999" : "#cccccc" }
            }
            radius: height/2
            implicitHeight: 35
            implicitWidth: 100

            Rectangle{
                height: parent.height
                width: parent.width/2
                anchors.right:parent.right
//                color: parent.color
                gradient: parent.gradient
            }
        }
    }

    Button {
        id: buttonmid
        text: "FM"
        onClicked: { checked = true }

        background: Rectangle{
            gradient: Gradient {
                GradientStop { position: 0.0; color: buttonmid.checked ? "#bbbbbb" : "#ffffff" }
                GradientStop { position: 1.0; color: buttonmid.checked ? "#999999" : "#cccccc" }
            }
            radius: 0
            implicitHeight: 35
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
        text: "SAT"
        onClicked: { checked = true }

        background: Rectangle{
            gradient: Gradient {
                GradientStop { position: 0.0; color: button2.checked ? "#bbbbbb" : "#ffffff" }
                GradientStop { position: 1.0; color: button2.checked ? "#999999" : "#cccccc" }
            }
            radius: height/2
            implicitHeight: 35
            implicitWidth: 100

            Rectangle{
                height: parent.height
                width: parent.width/2
                anchors.left: parent.left
                color: parent.color
                gradient: parent.gradient
            }
        }
    }
}
