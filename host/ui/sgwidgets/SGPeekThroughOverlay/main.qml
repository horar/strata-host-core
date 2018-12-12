import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3

Window {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("")
    property variant clickPos: "1,1" // @disable-check M311 // Ignore 'use string' (M311) QtCreator warning


    Rectangle {
        color: "tomato"
        anchors {
            centerIn: parent
        }
        opacity: 0.75
        width: 300
        height: width

    }

    Rectangle {
        id: myBox
        color: "tomato"
        x: root.width/2 - myBox.width/2
        y: root.height/2 - myBox.height/2
        width: 200
        height: width

        MouseArea {
            anchors {
                fill: parent
            }
            onPressed: {
                root.clickPos = Qt.point(mouse.x,mouse.y)
            }
            onPositionChanged: {
                var delta = Qt.point(mouse.x-root.clickPos.x, mouse.y-root.clickPos.y)
                myBox.x += delta.x;
                myBox.y += delta.y;
            }
        }

        Text {
            id: text
            anchors {
                centerIn: myBox
            }
            text: "Drag Me Around"
        }

        Button {
            id: showOverlay
            text: "Show Overlay"
            onClicked: {
                poopup.visible = !poopup.visible
                poopup2.visible = false
            }
            anchors {
                top: text.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Rectangle {
        id: myBox2
        color: "cyan"
        x: 50
        y: 50
        width: 100
        height: width

        Button {
            id: showOverlay1
            text: "Overlay"
            onClicked: {
                poopup2.visible = !poopup2.visible
                poopup.visible = false
            }
            anchors {
                centerIn: parent
            }
        }
    }


    SGPeekThroughOverlay {
        id: poopup
        property alias target: myBox
        onClicked: visible = false
    }

    SGPeekThroughOverlay {
        id: poopup2
        property alias target: myBox2
        onClicked: visible = false
    }
}
