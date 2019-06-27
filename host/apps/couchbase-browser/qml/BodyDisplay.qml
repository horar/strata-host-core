import QtQuick 2.12
import QtQuick.Controls 2.12
Item {
    id: root
    anchors.fill:parent
    property alias content: text.text

    Rectangle {
        id: background
        width: parent.width
        height: parent.height
        color: "white"

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
            }
        }
    }
}
