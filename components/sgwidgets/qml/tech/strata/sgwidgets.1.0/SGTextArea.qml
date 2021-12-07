/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

FocusScope {
    id: control

    focus: true

    property alias text: edit.text
    property alias font: edit.font
    property alias placeholderText: placeholderTextItem.text
    property alias cursorPosition: edit.cursorPosition
    property int minimumLineCount: 3
    property int maximumLineCount: minimumLineCount
    property bool tabAllowed: false
    property alias readOnly: edit.readOnly
    property bool keepCursorAtEnd: false
    property bool isValid: true
    property bool contextMenuEnabled: false
    property alias palette: dummyControl.palette

    // This is to match look and feel of other controls
    Control {
        id: dummyControl
    }

    Rectangle {
        id: bg
        anchors.fill: parent

        color: dummyControl.palette.base
        border {
            width: control.activeFocus ? 2 : 1
            color: {
                if (control.activeFocus) {
                    return dummyControl.palette.highlight
                } else if (isValid) {
                    return dummyControl.palette.mid
                } else {
                    return TangoTheme.palette.error
                }
            }
        }
    }

    SGWidgets.SGContextMenuEditActions {
        id: contextMenuPopup
        textEditor: edit
    }

    Flickable {
        id: flick
        anchors {
            fill: parent
            topMargin: 3
            bottomMargin: 3
        }

        clip: true
        interactive: true
        contentHeight: edit.height
        contentWidth: edit.width
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
            width: 8
            visible: flick.height < flick.contentHeight
        }

        function ensureVisible(r) {
            if (contentX >= r.x) {
                contentX = r.x;
            } else if (contentX+width <= r.x+r.width) {
                contentX = r.x + r.width - width;
            } if (contentY >= r.y - edit.topPadding) {
                contentY = r.y - edit.topPadding;
            } else if (contentY + height <= r.y + r.height + edit.bottomPadding ) {
                contentY = r.y + r.height - height + edit.bottomPadding;
            }
        }

        MouseArea {
            width: flick.width
            height: flick.height

            cursorShape: Qt.IBeamCursor
            acceptedButtons: (contextMenuEnabled === true) ? (Qt.LeftButton | Qt.RightButton) : Qt.LeftButton
            onClicked: {
                edit.forceActiveFocus()
                edit.cursorPosition = edit.text.length
            }
            onReleased: {
                if ((contextMenuEnabled === true) && containsMouse && (mouse.button === Qt.RightButton)) {
                    contextMenuPopup.popup(null)
                }
            }
        }

        TextEdit {
            id: edit
            width: flick.width

            wrapMode: TextEdit.Wrap
            padding: 6 + 6
            color: dummyControl.palette.text
            selectionColor: dummyControl.palette.highlight
            selectedTextColor: dummyControl.palette.highlightedText
            font: dummyControl.font
            selectByMouse: true
            selectByKeyboard: true
            activeFocusOnTab: true
            persistentSelection: contextMenuEnabled
            focus: true

            Keys.onPressed: {
                if (event.key === Qt.Key_Tab) {
                    if (!tabAllowed) {
                        nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
                        event.accepted = true
                    }
                }
            }

            onTextChanged: {
                if (readOnly && keepCursorAtEnd) {
                    cursorPosition = text.length
                }
            }

            onCursorRectangleChanged: {
                flick.ensureVisible(cursorRectangle)
            }

            onActiveFocusChanged: {
                if ((contextMenuEnabled === true) && (activeFocus === false) && (contextMenuPopup.visible === false)) {
                    edit.deselect()
                }
            }

            Text {
                id: placeholderTextItem
                anchors {
                    fill: parent
                    margins: edit.padding
                }

                visible: edit.text.length === 0
                color: dummyControl.palette.text
                opacity: edit.enabled ? 0.5 : 1
                font: dummyControl.font
                elide: Text.ElideRight
            }
        }
    }
}
