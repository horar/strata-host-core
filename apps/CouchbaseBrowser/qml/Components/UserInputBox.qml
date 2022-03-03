/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

ColumnLayout {
    id: root
    z: 1

    spacing: 2

    property alias showButton: icon.visible
    property alias showLabel: label.visible
    property alias color: icon.iconColor
    property alias path: icon.source
    property alias placeholderText: inputField.placeholderText
    property alias label: label.text
    property alias userInput: inputField.text
    property color borderColor: "white"
    property bool isPassword: false
    property real iconSize: 0

    signal clicked()
    signal accepted()

    function clear(){
        inputField.text = ""
    }
    function isEmpty(){
        fieldBorder.border.color = (inputField.text === "") ? "red" : "transparent"
    }
    Label {
        id: label
        color: "#eee"
        visible: false
    }

    Rectangle {
        id: fieldBorder
        Layout.preferredHeight: row.height + 10
        Layout.preferredWidth: root.width

        border.width: 3
        border.color: "transparent"
        RowLayout {
            id:row
            width: parent.width
            anchors {
                verticalCenter: fieldBorder.verticalCenter
            }
            SGContextMenuEditActions {
                id: contextMenuPopup
                textEditor: inputField
                copyEnabled: isPassword === false
            }
            TextField {
                id: inputField
                Layout.fillWidth: true
                selectByMouse: true
                persistentSelection: true   // must deselect manually
                validator: RegExpValidator { regExp: /(^$|^(?!\s*$).+)/ }
                background: Item {}
                Component.onCompleted: {
                    inputField.echoMode = isPassword ? TextInput.Password : TextInput.Normal
                }
                onActiveFocusChanged: {
                    if ((activeFocus === false) && (contextMenuPopup.visible === false)) {
                        inputField.deselect()
                    }
                }
                onAccepted: root.accepted()

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.IBeamCursor
                    acceptedButtons: Qt.RightButton
                    onClicked: {
                        inputField.forceActiveFocus()
                    }
                    onReleased: {
                        if (containsMouse) {
                            contextMenuPopup.popup(null)
                        }
                    }
                }
            }
            SGIcon {
                id: icon
                Layout.preferredHeight: iconSize === 0 ? inputField.height - 5 : iconSize
                Layout.preferredWidth: iconSize === 0 ? Layout.preferredHeight : iconSize
                Layout.rightMargin: 5

                opacity: 0.5
                visible: false
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent

                    hoverEnabled: true
                    onEntered: icon.opacity = 1
                    onExited: icon.opacity = 0.5
                    onClicked: {
                        root.clicked()
                    }
                }
            }
        }
    }
}
