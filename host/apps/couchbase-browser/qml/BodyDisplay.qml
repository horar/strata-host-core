import QtQuick 2.12
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.12
Item {
    id: root
    anchors.fill:parent
    property alias content: text.text
    property alias message: statusText.text

    Rectangle {
        id: background
        width: parent.width
        height: parent.height
        color: "#393e46"

        ScrollView {
            id: scroller
            anchors.fill: parent
            clip: true

            TextArea {
                id: text
                //anchors.fill: parent
                wrapMode: "Wrap"
                selectByMouse: true
                text: ""
                color: "#eeeeee"
            }
        }
        Rectangle {
            id: statusBar
            width: parent.width
            height: 25
            DropShadow {
                width: parent.width
                height: 3
                horizontalOffset: 5
                verticalOffset: -6
                radius: 8
                samples: 17
                source: statusBar
                color: "black"

            }
            anchors {
                bottom: parent.bottom
                left: parent.left
            }
            color: "#b55400"
            Text {
                id: statusText
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                padding: 3
                color: "#eee"
            }
        }
    }
}
