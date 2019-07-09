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

        Rectangle {
            id: statusBar
            width: parent.width
            height: 25
            anchors {
                top: parent.top
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

        ScrollView {
            id: scroller
            anchors {
                top: statusBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            clip: true

            TextArea {
                id: text
                wrapMode: "Wrap"
                selectByMouse: true
                text: ""
                color: "#eeeeee"
                readOnly: true
            }
        }
    }
}
