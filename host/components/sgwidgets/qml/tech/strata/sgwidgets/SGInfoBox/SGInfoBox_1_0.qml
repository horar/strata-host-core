import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.theme 1.0
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

RowLayout {
    id: root
    height: 26 * fontSizeMultiplier

    property color textColor: "black"
    property color invalidTextColor: "red"
    property real fontSizeMultiplier: 1.0
    property color boxBorderColor: "#CCCCCC"
    property real boxBorderWidth: 1

    property alias text: infoText.text
    property alias horizontalAlignment: infoText.horizontalAlignment
    property alias placeholderText: placeholder.text
    property alias readOnly: infoText.readOnly
    property alias boxColor: box.color
    property alias unit: unit.text
    property alias textPadding: infoText.padding
    property alias validator: infoText.validator
    property alias acceptableInput: infoText.acceptableInput

    signal accepted(string text)
    signal editingFinished(string text)

    Rectangle {
        id: box
        height: root.height
        color: infoText.readOnly ? "#F2F2F2" : "white"
        radius: 2
        border {
            color: root.boxBorderColor
            width: root.boxBorderWidth
        }
        clip: true
        implicitWidth: 100 * fontSizeMultiplier
        Layout.fillWidth: true

        TextInput {
            id: infoText
            padding: font.pixelSize * 0.5
            anchors {
                right: box.right
                verticalCenter: box.verticalCenter
                left: box.left
            }
            font {
                family: Fonts.inconsolata // Monospaced font for better text width uniformity
                pixelSize: Qt.application.font.pixelSize * fontSizeMultiplier
            }
            text: ""
            selectByMouse: true
            readOnly: true
            color: text == "" || acceptableInput ? root.textColor : root.invalidTextColor
            horizontalAlignment: Text.AlignRight

            onAccepted: root.accepted(infoText.text)
            onEditingFinished: root.editingFinished(infoText.text)

            MouseArea {
                anchors {
                    fill: infoText
                }
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.NoButton
            }

            Text {
                id: placeholder
                anchors {
                    right: infoText.right
                    verticalCenter: infoText.verticalCenter
                    left: infoText.left
                }
                padding: font.pixelSize * 0.5
                opacity: 0.5
                text: ""
                color: infoText.color
                visible: infoText.text === ""
                horizontalAlignment: infoText.horizontalAlignment
                elide: Text.ElideRight
                font: infoText.font
            }
        }
    }

    SGText {
        id: unit
        visible: text !== ""
        height: text === "" ? 0 : contentHeight
        fontSizeMultiplier: root.fontSizeMultiplier
        implicitColor: root.textColor
        Layout.minimumWidth: contentWidth
        Layout.maximumWidth: contentWidth
    }

    function forceActiveFocus() {
        infoText.forceActiveFocus()
    }
}
