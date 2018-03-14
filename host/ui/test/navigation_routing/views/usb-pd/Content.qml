import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
Rectangle {

    id: content
    anchors { fill: parent}

    property string control_name:  "USB-PD"

    StackLayout{

        anchors {
           top: content.top
           bottom: bar.top
           centerIn: content
        }
        height: parent.height - bar.height

        id: view
        currentIndex: bar.currentIndex

        Rectangle {
            anchors {fill : parent}
            color: "red"
            Text{
                anchors { centerIn: parent}
                text: "Block Diagram"
            }
        }

        Rectangle {
            anchors {fill : parent}
            color: "blue"
            Text{
                anchors { centerIn: parent}
                text: "Assembly"
            }
        }

        Rectangle {
            anchors {fill : parent}
            color: "teal"
            Text{
                anchors { centerIn: parent}
                text: "Schematic"
            }
        }

        Rectangle {
            anchors {fill : parent}
            color: "grey"
            Text{
                anchors { centerIn: parent}
                text: "Layout"
            }
        }

        Rectangle {
            anchors {fill : parent}
            color: "magenta"
            Text{
                anchors { centerIn: parent}
                text: "Test Report"
            }
        }
   }
    TabBar{
        id: bar
        anchors { bottom: content.bottom }
        width: parent.width
        TabButton{
            text: control_name + "-" + "Block Diagram"
        }
        TabButton {
            text: control_name + "-" + "Assembly"
        }
        TabButton {
            text: control_name + "-" +"Schematic"
        }
        TabButton {
            text: control_name + "-" + "Layout"
        }
        TabButton {
            text: control_name + "-" + "Test Report"
        }
    }





}
