import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

Window {
    id: root
    width: 800
    height: 300
    maximumWidth: width
    maximumHeight: height
    minimumWidth: width
    minimumHeight: height
    visible: false
    modality: Qt.WindowModal

    signal allow()
    signal deny()

    property alias messageToDisplay: message.text

    Rectangle {
        anchors.fill: parent
        color: "#222831"
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
            text: ""
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
            onClicked: allow()
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
