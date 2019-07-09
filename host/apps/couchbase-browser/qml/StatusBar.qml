import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Rectangle {
    id: background
    width: parent.width
    height: 30
    color: "#b55400"

    property alias message: messageBar.text

    TextArea {
        id: messageBar
        anchors.fill: parent
        horizontalAlignment: Qt.AlignCenter
        color: "#eee"
        text: ""
        readOnly: true
    }
}
