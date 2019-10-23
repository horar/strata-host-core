import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: control

    width: wrapper.width
    height: wrapper.height

    property alias text: textItem.text
    property alias spacing: wrapper.spacing

    property color implicitIconColor: "black"
    property color alternativeIconColor: "white"
    property bool alternativeColorEnabled: false

    signal clicked()

    property alias iconColor: buttonItem.iconColor
    property alias iconSize: buttonItem.iconSize
    property alias icon: buttonItem.icon
    property alias hintText: buttonItem.hintText
    property alias highlightImplicitColor: buttonItem.implicitColor
    property alias hovered: buttonItem.hovered
    property alias backgroundOnlyOnHovered: buttonItem.backgroundOnlyOnHovered
    property alias iconMirror: buttonItem.iconMirror

    Column {
        id: wrapper

        spacing: 4

        SGWidgets.SGButton {
            id: buttonItem
            anchors.horizontalCenter: parent.horizontalCenter

            padding: 2
            backgroundOnlyOnHovered: true
            scaleToFit: true
            iconColor: control.alternativeColorEnabled ? control.alternativeIconColor : control.implicitIconColor
            color: control.alternativeColorEnabled ? "#555555" : implicitColor
            onClicked: control.clicked()
        }

        SGWidgets.SGText {
            id: textItem
            anchors.horizontalCenter: parent.horizontalCenter
            alternativeColorEnabled: control.alternativeColorEnabled
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
