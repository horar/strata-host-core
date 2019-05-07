import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    id: button

    property alias source: icon.source
    property color color: hasAlternativeColor ? alternativeIconColor : implicitIconColor
    property color implicitIconColor: "black"
    property color alternativeIconColor: "white"
    property bool hasAlternativeColor: false
    property int padding: 1
    property alias hintText: tooltip.text

    signal clicked()

    ToolTip {
        id: tooltip
        visible: text.length && pressable.containsMouse
        delay: 1000
        timeout: 4000
    }

    SgPressable {
        id: pressable
        anchors.fill: parent

        radius: 2
        hoverColor: button.color
        onClicked: {
            button.clicked()
        }

        SgIcon {
            id: icon
            width: button.width - 2*padding
            height: button.height - 2*padding
            anchors.centerIn: parent

            iconColor: button.color
        }
    }
}
