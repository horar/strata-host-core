import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

TextField {
    id: messageBar
    width: parent.width
    height: 30

    property alias message: messageBar.text
    property alias backgroundColor: background.color

    color: "#eee"
    text: ""
    readOnly: true
    horizontalAlignment: TextInput.AlignHCenter
    background: Rectangle {
        id: background
        anchors.fill: parent
        color: "#b55400"
    }
}
