/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Item {
    id: root

    signal activated(int index)
    signal highlighted(int index)
    signal editTextChanged(string editText)

    function find(text) {
        return comboBox.find(text)
    }

    property alias currentIndex: comboBox.currentIndex
    property alias currentText: comboBox.currentText
    property alias model: comboBox.model
    property alias count: comboBox.count
    property alias acceptableInput: comboBox.acceptableInput
    property alias down: comboBox.down
    property alias editable: comboBox.editable
    property alias pressed: comboBox.pressed
    property alias textRole: comboBox.textRole
    property alias overrideLabelWidth: labelText.width
    property alias placeholderText: comboBox.placeholderText

    property string label: ""
    property bool labelLeft: true
    property color textColor: "black"
    property color indicatorColor: "#aaa"
    property color borderColor: "#aaa"
    property color boxColor: "white"
    property bool dividers: false
    property real comboBoxHeight: 32
    property real comboBoxWidth: 120
    property real popupHeight: 300
    property font font

    implicitHeight: labelLeft ? Math.max(labelText.height, comboBox.height) : labelText.height + comboBox.height + comboBox.anchors.topMargin
    implicitWidth: labelLeft ? labelText.width + comboBox.width + comboBox.anchors.leftMargin : Math.max(labelText.width, comboBox.width)

    Text {
        id: labelText
        text: root.label
        width: contentWidth
        height: root.label === "" ? 0 : root.labelLeft ? comboBox.height : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? (comboBox.height-contentHeight)/2 : 0
        bottomPadding: topPadding
        color: root.textColor
        horizontalAlignment: Text.AlignRight
    }

    ComboBox {
        id: comboBox

        onActivated: root.activated(index)
        onHighlighted: root.highlighted(index)
        onEditTextChanged: root.editTextChanged(editText)
        font: root.font
        enabled: root.enabled
        opacity: enabled ? 1 : 0.5

        model: ["First", "Second", "Third"]
        height: root.comboBoxHeight
        anchors {
            left: root.labelLeft ? labelText.right : root.left
            leftMargin: root.label === "" ? 0 : root.labelLeft ? 10 : 0
            top: root.labelLeft ? labelText.top : labelText.bottom
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
        }
        width: root.comboBoxWidth

        property string placeholderText

        indicator: Item {
                width: iconImage.width
                height: iconImage.height
                rotation: comboBox.popup.visible ? 180 : 0
                anchors {
                    verticalCenter: comboBox.verticalCenter
                    right: comboBox.right
                    rightMargin: comboBox.height/2 - width/2
                }

                Image {
                    id: iconImage
                    visible: false
                    fillMode: Image.PreserveAspectFit
                    source: "icons/angle-down-solid.svg"
                    sourceSize.height: 25
                }

                ColorOverlay {
                    id: overlay
                    anchors.fill: iconImage
                    source: iconImage
                    visible: true
                    color: comboBox.pressed ? colorMod(root.indicatorColor, .25) : root.indicatorColor
                }
            }

        contentItem: TextField {
            id: textField
            anchors {
                fill: parent
                rightMargin: comboBox.height
            }
            leftPadding: 10
            rightPadding: 0

            text: comboBox.editable ? comboBox.editText : comboBox.displayText
            enabled: comboBox.editable && comboBox.enabled
            autoScroll: comboBox.editable
            readOnly: comboBox.down
//            inputMethodHints: comboBox.inputMethodHints
//            validator: comboBox.validator
            placeholderText: comboBox.placeholderText

            font: comboBox.font
            color: root.textColor
            selectionColor: comboBox.palette.highlight
            selectedTextColor: comboBox.palette.highlightedText
            verticalAlignment: Text.AlignVCenter

            background: Rectangle {
                visible: comboBox.enabled && comboBox.editable && !comboBox.flat
                border.width: parent && parent.activeFocus && !parent.readOnly ? 2 : 1
                border.color: parent && parent.activeFocus && !parent.readOnly ? "#219647" : root.borderColor
                color: root.boxColor
            }
            onAccepted: parent.focus = false
            Keys.forwardTo: root
        }

        background: Rectangle {
            implicitWidth: root.comboBoxWidth
            height: root.comboBoxHeight
            border.color: comboBox.pressed ? colorMod(root.borderColor, .25) : root.borderColor
            border.width: comboBox.visualFocus ? 2 : 1
            radius: 2
            color: root.boxColor
        }

        popup: Popup {
            y: comboBox.height - 1
            width: comboBox.width
            implicitHeight: Math.min(contentItem.implicitHeight + ( 2 * padding ), root.popupHeight)
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: comboBox.popup.visible ? comboBox.delegateModel : null
                currentIndex: comboBox.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator {
                    active: true
                }
            }

            background: Rectangle {
                border.color: root.borderColor
                radius: 2
            }

            opacity: comboBox.delegateModel.count > 0 ? 1 : 0
        }

        delegate: ItemDelegate {
            id: delegate
            width: comboBox.width
            height: Math.max (root.comboBoxHeight, contentItem.implicitHeight + 10)  // Add/Subtract from this to modify list item heights in popup
            topPadding: 0
            bottomPadding: 0
            contentItem: Text {
                text: comboBox.textRole ? (Array.isArray(comboBox.model) ? modelData[comboBox.textRole] : model[comboBox.textRole]) : modelData
                color: root.textColor
                font: comboBox.font
//                elide: Text.ElideRight
                wrapMode: Text.Wrap
                verticalAlignment: Text.AlignVCenter
            }
            highlighted: comboBox.highlightedIndex === index

            background: Rectangle {
                id: delegateBackground
                implicitWidth: comboBox.width
                color: delegate.highlighted ? colorMod(root.boxColor, -0.05) : root.boxColor

                Rectangle {
                    id: delegateDivider
                    visible: root.dividers && index !== comboBox.count - 1
                    width: delegateBackground.width - 20
                    height: 1
                    color: colorMod(root.boxColor, -0.05)
                    anchors {
                        bottom: delegateBackground.bottom
                        horizontalCenter: delegateBackground.horizontalCenter
                    }
                }
            }
        }
    }

    // Add increment to color (within range of 0-1) add to lighten, subtract to darken
    function colorMod (color, increment) {
        return Qt.rgba(color.r + increment, color.g + increment, color.b + increment, 1 )
    }
}
