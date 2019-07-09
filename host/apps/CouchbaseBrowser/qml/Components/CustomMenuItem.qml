import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3


Rectangle {
    id: root
    color: "transparent"

    signal buttonPress()

    property alias filename: icon.source
    property alias label: iconLabel.text

    property bool disable: false

    MouseArea {
        id: customButton
        anchors.fill: parent
        hoverEnabled: true
        onContainsMouseChanged: {
            root.color = (containsMouse) ? "#b55400" : "transparent"
        }
        onClicked: {
            buttonPress()
        }
    }
    Label {
        id: iconLabel
        text: "<b>Open</b>"
        color: "#eeeeee"
        anchors {
            top: root.bottom
            horizontalCenter: root.horizontalCenter
        }
    }
    Image {
        id: icon
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
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
