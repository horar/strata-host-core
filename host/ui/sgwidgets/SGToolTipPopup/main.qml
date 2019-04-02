import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Rectangle {
        id: hoverContainer
        color: "tomato"
        height: 50
        width: hoverText.contentWidth + 40
        anchors { centerIn: parent }

        Text {
            id: hoverText
            text: qsTr("Hover Here")
            color: "white"
            anchors {  centerIn: parent }
        }

        MouseArea {
            id: hoverArea
            anchors { fill: parent }
            hoverEnabled: true
        }

        SGToolTipPopup {
            id: sgToolTipPopup

            showOn: hoverArea.containsMouse // Connect this to whatever boolean you want the tooltip to be shown when true
            anchors {
                bottom: hoverText.top
                horizontalCenter: hoverText.horizontalCenter
            }

            // Optional Configuration:
            radius: 5               // Default: 5 (0 for square)
            color: "#0ce"           // Default: "#00ccee"
            arrowOnTop: true         // Default: false (determines if arrow points up or down)
            horizontalAlignment: "center"     // Default: "center" (determines horizontal offset of arrow, other options are "left" and "right")

            // Content can contain any single object (which can have nested objects within it)
            content: Text {
                text: qsTr("This is a SGToolTipPopup")
                color: "white"
            }
        }
    }
}
