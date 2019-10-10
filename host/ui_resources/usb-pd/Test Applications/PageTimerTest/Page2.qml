import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: page2

    Text {
        id: text1
        x: 0
        y: 0
        width: 298
        height: 101
        text: "page 2"
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter:parent.verticalCenter
        font.pixelSize: 72

    }

    BusyIndicator {
        id: busyIndicator
        x: 290
        y: 300
        anchors.horizontalCenter: parent.horizontalCenter
    }

}
