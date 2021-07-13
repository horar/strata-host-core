import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: control

    implicitWidth: wrapper.width
    implicitHeight: wrapper.height

    property alias text: textItem.text
    property alias spacing: wrapper.spacing
    property color implicitIconColor: "black"
    property color alternativeIconColor: "white"
    property bool alternativeColorEnabled: false

    /* This is useful when you want to change text dynamically,
     * but dont want overall button width to be affected by text change.
     */
    property alias minimumWidthText: dummyText.text

    signal clicked()

    property alias iconColor: buttonItem.iconColor
    property alias iconSize: buttonItem.iconSize
    property alias icon: buttonItem.icon
    property alias hintText: buttonItem.hintText
    property alias highlightImplicitColor: buttonItem.implicitColor
    property alias hovered: buttonItem.hovered
    property alias backgroundOnlyOnHovered: buttonItem.backgroundOnlyOnHovered
    property alias iconMirror: buttonItem.iconMirror
    property alias padding: buttonItem.padding
    property alias checkable: buttonItem.checkable
    property alias checked: buttonItem.checked
    property alias pressed: buttonItem.pressed


    //cannot use TextMetrics as it provides wrong boundingRect.width for some font sizes (as of Qt 5.12.7)
    SGWidgets.SGText {
        id: dummyText
        visible: false
        font: textItem.font
    }

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

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            height: textItem.contentHeight
            width: Math.max(dummyText.contentWidth, textItem.contentWidth)

            SGWidgets.SGText {
                id: textItem
                anchors.horizontalCenter: parent.horizontalCenter
                alternativeColorEnabled: control.alternativeColorEnabled
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
