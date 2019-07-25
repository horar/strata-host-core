import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.fonts 1.0
import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0

RowLayout {
    id: root
    spacing: 10

    signal accepted(string text)
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

    SGInfoBox {
        id: infoText
        readOnly: false
        fontSizeMultiplier: root.fontSizeMultiplier
        Layout.fillWidth: true
        Layout.fillHeight: false
        Layout.preferredHeight: root.infoBoxHeight

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

        onClicked: {
            if (infoText.acceptableInput) {
                infoText.accepted(infoText.text)
            }
        }
    }

    function forceActiveFocus() {
        infoText.forceActiveFocus()
    }
}

