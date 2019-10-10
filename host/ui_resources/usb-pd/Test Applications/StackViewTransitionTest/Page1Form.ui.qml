import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: page1
    property alias button1: button1
    property alias rectangle: rectangle

    Rectangle {
        id: rectangle
        color: "#fd0202"
        anchors.fill: parent

        Button {
            id: button1
            x: 170
            y: 193
            width: 300
            height: 94
            text: qsTr("Pop me!")
            font.pointSize: 36
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: {
                StackView.pop()
            }
        }
    }
}
