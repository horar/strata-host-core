import QtQuick 2.12
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.12

Item {
    id: root
    anchors.fill:parent

    property alias content: text.text
    property alias message: statusBar.message

    Rectangle {
        id: background
        width: parent.width
        height: parent.height
        color: "#393e46"
        StatusBar {
            id: statusBar
            anchors.top:parent.top
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
