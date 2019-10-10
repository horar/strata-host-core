import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: item1
    property int theNumber

    Text {
        id: text1
        x: 244
        y: 138
        width: 108
        height: 88
        text: qsTr("0")
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 72
    }

    Button {
        id: button
        x: 248
        y: 323
        text: qsTr("Increment")
        font.pointSize: 24
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Connections {
        target: button
        onClicked: text1.text = theNumber+1
    }
}
