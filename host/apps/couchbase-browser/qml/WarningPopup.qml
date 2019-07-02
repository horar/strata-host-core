import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3

Popup {
    id: root
    width: 800
    height: 300
    visible: false
    padding: 0

    signal overwrite()
    signal deny()

    property alias messageToDisplay: message.text

    Rectangle {
        anchors.fill: parent
        color: "#393e46"
        border.color: "#b55400"
        Text {
            id: message
            maximumLineCount: 25
            width: parent.width - 50
            height: 100
            horizontalAlignment: Text.AlignHCenter
            anchors {
                top: parent.top
                topMargin: 50
                horizontalCenter: parent.horizontalCenter
            }
            color: "#eee"
            wrapMode: Text.Wrap
            font.pixelSize: 22
            text: "Warning! Starting replication will override all changes."
        }
        Button {
            id: yesButton
            width: 100
            height: 40
            anchors {
                centerIn: parent
                horizontalCenterOffset: -100
                verticalCenterOffset: 50
            }
            onClicked: overwrite()
            text: "Yes"
        }
        Button {
            id: noButton
            width: 100
            height: 40
            anchors {
                centerIn: parent
                horizontalCenterOffset: 100
                verticalCenterOffset: 50
            }
            text: "No"
            onClicked: deny()
        }
    }
}
