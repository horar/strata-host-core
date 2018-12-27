import QtQuick 2.9
import QtQuick.Window 2.10
import QtQuick.Controls 2.3
import "qrc:/help_layout_manager.js" as Help

/*
See help_layout_manager for API that is used in this file.
*/

Window {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("")
    property variant clickPos: "1,1" // @disable-check M311 // Ignore 'use string' (M311) QtCreator warning

    Component.onCompleted: {
        Help.registerWindow(root)
        Help.registerTarget(myBox, "this is the first box", 0, "basicViewHelp")
        Help.registerTarget(myBox2, "this is the second box", 1, "basicViewHelp")
    }

    onClosing: { // @disable-check M16  // Ignore "invalid property name" warning
        Help.reset("basicViewHelp")  // Necessary to remove dynamically created help views. If inside of a dynamically created object, use component.ondestruction instead
    }

    Rectangle {
        color: "tomato"
        anchors {
            centerIn: parent
        }
        opacity: 0.75
        width: 210
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
            text: "Start Help Tour"
            onClicked: {
                Help.startHelpTour("basicViewHelp")
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
        x: parent.width/6
        y: x
        width: 100
        height: width

        Text {
            id: box2text
            text: "Secondary Target Box"
            anchors {
                centerIn: parent
            }
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
