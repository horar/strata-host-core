import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3


Rectangle {
    id: root
    color: "transparent"
    property alias filename: icon.source
    property alias label: iconLabel.text
    signal buttonPress()
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
}
