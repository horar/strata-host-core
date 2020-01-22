import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.fonts 1.0
import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0

RowLayout {
    id: root
    spacing: 10
    Layout.fillWidth: false
    Layout.fillHeight: false

    signal accepted(real value)
    signal editingFinished(string text)

    property alias text: infoText.text
    property alias textColor: infoText.textColor
    property alias textPadding: infoText.textPadding
    property alias invalidTextColor: infoText.invalidTextColor
    property alias boxColor: infoText.boxColor
    property alias boxBorderColor: infoText.boxBorderColor
    property alias boxBorderWidth:  infoText.boxBorderWidth
    property alias unit: infoText.unit
    property alias readOnly: infoText.readOnly
    property alias validator: infoText.validator
    property alias placeholderText: infoText.placeholderText
    property alias horizontalAlignment: infoText.horizontalAlignment
    property alias buttonText: applyButton.text
    property alias buttonImplicitWidth: applyButton.implicitWidth

    property real floatValue: { return parseFloat(infoText.text) }
    property int intValue: { return parseInt(infoText.text) }
    property real fontSizeMultiplier: 1.0
    property string appliedString
    property real infoBoxHeight: infoText.implicitHeight
    property real infoBoxWidth: infoText.implicitWidth

    SGInfoBox {
        id: infoText
        readOnly: false
        fontSizeMultiplier: root.fontSizeMultiplier
        Layout.fillWidth: false
        Layout.preferredWidth: root.infoBoxWidth
        Layout.fillHeight: false
        Layout.preferredHeight: root.infoBoxHeight
        KeyNavigation.tab: applyButton
        KeyNavigation.backtab: root.KeyNavigation.backtab

        onAccepted: root.accepted(infoText.text)
        onEditingFinished: root.editingFinished(infoText.text)
    }

    SGButton {
        id: applyButton
        visible: text !== ""
        text: ""
        fontSizeMultiplier: root.fontSizeMultiplier
        Layout.fillHeight: true
        hoverEnabled: true
        color: {
            if (hovered) {
                return "#B3B3B3"
            } else if (checked) {
                return "#808080"
            } else {
                return "#D9D9D9"
            }
        }
        KeyNavigation.backtab: infoText
        KeyNavigation.tab: root.KeyNavigation.tab

        MouseArea {
            hoverEnabled: true
            anchors.fill: parent
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                if (infoText.acceptableInput) {
                    infoText.accepted(infoText.text)
                }
            }
        }
    }

    function forceActiveFocus() {
        infoText.forceActiveFocus()
    }
}
