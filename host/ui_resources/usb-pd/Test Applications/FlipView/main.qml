import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Flipable {
        id: flipable
        width: 240
        height: 240
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    
        property bool flipped: false
    
        front: Rectangle{
            id: rectangle
            width: 240
            height: 240
            border.color: "black"
            color: "red"
            anchors.centerIn: parent

            //Image { source: "front.png"; anchors.centerIn: parent }
            Button{
                x: 32
                y: 128
                width: 176
                height: 64
                text: "front"
                opacity: 1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 72

            }
            }

        back: Rectangle{
            width: 240
            height: 240
            border.color: "red"
            color: "yellow"
            anchors.centerIn: parent

            Image { source: "back.png"; anchors.centerIn: parent }
            }
    
        transform: Rotation {
            id: rotation
            origin.x: flipable.width/2
            origin.y: flipable.height/2
            axis.x: 0; axis.y: -1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
            angle: 0    // the default angle
        }
    
        states: State {
            name: "back"
            PropertyChanges { target: rotation; angle: 180 }
            when: flipable.flipped
        }
    
        transitions: Transition {
            NumberAnimation { target: rotation; property: "angle"; duration: 2000 }
        }

        MouseArea {
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.fill: parent
            onClicked: flipable.flipped = !flipable.flipped
        }
    }
}
