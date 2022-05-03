/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.theme 1.0
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

FocusScope {
    id: root
    clip: true
    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth

    property color textColor: "black"
    property color invalidTextColor: TangoTheme.palette.error
    property real fontSizeMultiplier: 1.0
    property color boxBorderColor: "#CCCCCC"
    property real boxBorderWidth: 1
    property bool contextMenuEnabled: false

    property alias text: infoText.text
    property alias horizontalAlignment: infoText.horizontalAlignment
    property alias placeholderText: placeholder.text
    property alias readOnly: infoText.readOnly
    property alias boxColor: box.color
    property alias unit: unit.text
    property alias textPadding: infoText.padding
    property alias validator: infoText.validator
    property alias acceptableInput: infoText.acceptableInput
    property alias boxFont: infoText.font
    property alias unitFont: unit.font
    property alias unitHorizontalAlignment: unit.horizontalAlignment
    property alias unitOverrideWidth: unit.overrideWidth
    property alias boxObject: box
    property alias infoTextObject: infoText
    property alias mouseAreaObject: mouseArea
    property alias placeholderObject: placeholder
    property alias unitObject: unit

    signal accepted(string text)
    signal editingFinished(string text)

    RowLayout {
        id: row
        anchors {
            fill: parent
        }

        Rectangle {
            id: box
            Layout.preferredHeight: 26 * fontSizeMultiplier
            Layout.fillHeight: true
            Layout.preferredWidth: Math.max(unit.Layout.preferredWidth, 10)
            Layout.fillWidth: true
            color: infoText.readOnly ? "#F2F2F2" : "white"
            radius: 2
            border {
                color: root.boxBorderColor
                width: root.boxBorderWidth
            }
            clip: true

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
                    pixelSize: SGSettings.fontPixelSize * fontSizeMultiplier
                }
                text: ""
                selectByMouse: true
                readOnly: true
                color: text == "" || acceptableInput ? root.textColor : root.invalidTextColor
                horizontalAlignment: Text.AlignRight
                KeyNavigation.tab: root.KeyNavigation.tab
                KeyNavigation.backtab: root.KeyNavigation.backtab
                KeyNavigation.priority: root.KeyNavigation.priority
                focus: true
                onAccepted: root.accepted(infoText.text)
                onEditingFinished: root.editingFinished(infoText.text)
                persistentSelection: root.contextMenuEnabled

                onActiveFocusChanged: {
                    if ((root.contextMenuEnabled === true) && (activeFocus === false) && (contextMenuPopup.visible === false)) {
                        infoText.deselect()
                    }
                }

                SGContextMenuEditActions {
                    id: contextMenuPopup
                    textEditor: infoText
                }

                MouseArea {
                    id: mouseArea
                    anchors {
                        fill: infoText
                    }
                    cursorShape: Qt.IBeamCursor
                    acceptedButtons: root.contextMenuEnabled ? Qt.RightButton : Qt.NoButton

                    onReleased: {
                        if (containsMouse) {
                            contextMenuPopup.popup(null)
                        }
                    }

                    onClicked: {
                        infoText.forceActiveFocus()
                    }
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
            Layout.fillWidth: unit.overrideWidth === -1
            Layout.preferredWidth: unit.overrideWidth === -1 ? contentWidth : unit.overrideWidth
            Layout.maximumWidth: Layout.preferredWidth
            property real overrideWidth: -1
        }
    }

    function selectAll() {
        infoText.selectAll()
    }
}
