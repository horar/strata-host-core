import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Popup {
    id: root
    width: 800
    height: 300
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    visible: false
    padding: 1
    closePolicy: Popup.CloseOnEscape
    modal: true

    property alias messageToDisplay: message.text

    signal allow()
    signal deny()

    Rectangle {
        id: container
        anchors.fill: parent

        color: "#222831"
        Text {
            id: message
            width: parent.width - 50
            height: 100
            anchors {
                top: parent.top
                topMargin: 50
                horizontalCenter: parent.horizontalCenter
            }

            maximumLineCount: 25
            horizontalAlignment: Text.AlignHCenter
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

            text: "Yes"
            onClicked: allow()
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
    DropShadow {
        anchors.fill: container
        source: container
        horizontalOffset: 7
        verticalOffset: 7
        spread: 0
        radius: 20
        samples: 41
        color: "#aa000000"
    }
}
