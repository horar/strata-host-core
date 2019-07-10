import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: root
    anchors.fill:parent
    color: "#393e46"

    property alias content: textArea.text

    ScrollView {
        anchors.fill: parent
        clip: true
        TextArea {
            id: textArea
            wrapMode: "Wrap"
            selectByMouse: true
            text: ""
            color: "#eeeeee"
            readOnly: true
        }
    }
}
