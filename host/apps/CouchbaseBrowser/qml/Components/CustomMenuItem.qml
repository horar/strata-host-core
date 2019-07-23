import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3


Item {
    id: root

    signal buttonPress()

    property alias filename: icon.source
    property alias label: iconLabel.text
    property bool disable: false

    implicitWidth: Math.max(iconContainer.width, iconLabel.contentWidth)

    Rectangle {
        id: iconContainer
        height: parent.height - iconLabel.height
        width: height
        color: "transparent"
        radius: 5
        anchors.horizontalCenter: parent.horizontalCenter
        Image {
            id: icon
            width: parent.width - 5
            height: parent.height - 5
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit

            MouseArea {
                id: customButton
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: {
                    iconContainer.color = (containsMouse) ? "#f7f7f7" : "transparent"
                }
                onClicked: {
                    buttonPress()
                }
            }
        }
    }

    Label {
        id: iconLabel
        text: "<b>Open</b>"
        color: "#eeeeee"
        anchors {
            top: iconContainer.bottom
            horizontalCenter: parent.horizontalCenter
        }
    }

    onDisableChanged: {
        if (disable) {
            opacity = 0.5
            enabled = false
        }
        else {
            opacity = 1
            enabled = true
        }
    }
}
