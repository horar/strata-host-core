import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")
    property int theNumber

    Button {
        id: button
        x: 258
        y: 339
        text: qsTr("Increment")
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 24
    }

    Text {
        id: text1
        x: 264
        y: 118
        width: 112
        height: 113
        text: qsTr("0")
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 72
    }

    Connections {
        target: button
        onClicked: text1.text = ++theNumber
    }

}
