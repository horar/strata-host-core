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
import tech.strata.logger 1.0

// This example describes describes how to use and customize
// Edit context menu GUI element that appears upon user interaction
// (right-click mouse operation) in the Strata GUI applications.
//
// This context menu is intended for editable text fields such as:
// TextField, TextInput, TextEdit, TextArea and offers basic Edit options:
//    Undo
//    Redo
//    Cut
//    Copy
//    Paste
//    Select All

Item {

    width: contentColumn.width
    height: editEnabledCheckBox.y + editEnabledCheckBox.height

    // This is to match look and feel of other controls
    Control {
        id: dummyControl
        enabled: editEnabledCheckBox.checked
    }

    Column {
        id: contentColumn
        spacing: 10
        enabled: editEnabledCheckBox.checked

        Column {
            SGWidgets.SGText {
                text: "Using existing SGTextField"
                fontSizeMultiplier: 1.3
            }
            // In case of using existing SGWidgets which support this functionality
            // (e.g. SGTextArea, SGTextEdit, SGTextField, SGTextInput, SGFileSelector, SGTextFieldEditor, ...)
            // it is necessary to define 'contextMenuEnabled: true' in these elements
            SGWidgets.SGTextField {
                contextMenuEnabled: true // will automatically enable the context menu with Edit options
            }
        }

        Column {
            SGWidgets.SGText {
                text: "Custom TextField"
                fontSizeMultiplier: 1.3
            }

            // In case of using custom text fields such as TextField, TextInput, TextEdit, TextArea
            // it is necessary to define the SGContextMenuEditActions which predefines the context menu
            SGWidgets.SGContextMenuEditActions {
                id: contextMenuPopupTextField
                textEditor: textField    // mandatory, should be id from one of [TextField, TextInput, TextEdit, TextArea]
                copyEnabled: true        // optional bool, in case it is necessary to disable copying (i.e. password fields)
            }

            TextField {
                id: textField
                placeholderText: "Input..."
                width: 200
                height: 40

                selectByMouse: true // necessary for selecting the text by mouse
                persistentSelection: true // stops the text fields from deselecting the text when losing focus, must be done manually

                // it is necessary to alter focus behavior of text fields
                // because when popup opens, they lose focus and deselect all text
                onActiveFocusChanged: {
                    // keep the standard deselect behavior on losing focus active as long as context menu is not visible
                    if ((activeFocus === false) && (contextMenuPopupTextField.visible === false)) {
                        textField.deselect()
                    }
                }

                // MouseArea opens the popup
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.IBeamCursor     // must be explicitly defined if MouseArea overlays text fields
                    acceptedButtons: Qt.RightButton // if reusing existing MouseArea, use Qt.LeftButton | Qt.RightButton

                    // user-friendly behavior is to set focus to the text field in the onClicked / onPressed
                    onClicked: {
                        textField.forceActiveFocus()
                    }

                    // Using onReleased provided best behavior during testing
                    onReleased: {
                        // add (mouse.button === Qt.RightButton) in case multiple buttons are used in the MouseArea
                        if (containsMouse) {
                            contextMenuPopupTextField.popup(null) // will create context menu at cursor position
                        }
                    }
                }
            }
        }


        Column {
            SGWidgets.SGText {
                text: "Custom TextInput"
                fontSizeMultiplier: 1.3
            }

            // In case of using custom text fields such as TextField, TextInput, TextEdit, TextArea
            // it is necessary to define the SGContextMenuEditActions which predefines the context menu
            SGWidgets.SGContextMenuEditActions {
                id: contextMenuPopupTextInput
                textEditor: textInput    // mandatory, should be id from one of [TextField, TextInput, TextEdit, TextArea]
                copyEnabled: true        // optional bool, in case it is necessary to disable copying (i.e. password fields)
            }

            Rectangle {
                width: 200
                height: 40

                color: dummyControl.palette.base
                border.width: textInput.activeFocus ? 2 : 1
                border.color: {
                    if (textInput.activeFocus) {
                        return dummyControl.palette.highlight
                    } else {
                        return dummyControl.palette.mid
                    }
                }

                TextInput {
                    id: textInput
                    padding: 6 + 6
                    color: dummyControl.palette.text
                    selectionColor: dummyControl.palette.highlight
                    selectedTextColor: dummyControl.palette.highlightedText
                    font: dummyControl.font
                    anchors.fill: parent

                    selectByMouse: true // necessary for selecting the text by mouse
                    persistentSelection: true // stops the text fields from deselecting the text when losing focus, must be done manually

                    // it is necessary to alter focus behavior of text fields
                    // because when popup opens, they lose focus and deselect all text
                    onActiveFocusChanged: {
                        // keep the standard deselect behavior on losing focus active as long as context menu is not visible
                        if ((activeFocus === false) && (contextMenuPopupTextInput.visible === false)) {
                            textInput.deselect()
                        }
                    }

                    Text {
                        id: placeholderTextInput
                        text: "Input..."
                        anchors {
                            fill: parent
                            margins: textInput.padding
                        }

                        visible: textInput.text.length === 0
                        color: dummyControl.palette.text
                        opacity: textInput.enabled ? 0.5 : 1
                        font: textInput.font
                        elide: Text.ElideRight
                    }

                    // MouseArea opens the popup
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor     // must be explicitly defined if MouseArea overlays text fields
                        acceptedButtons: Qt.RightButton // if reusing existing MouseArea, use Qt.LeftButton | Qt.RightButton

                        // user-friendly behavior is to set focus to the text field in the onClicked / onPressed
                        onClicked: {
                            textInput.forceActiveFocus()
                        }

                        // Using onReleased provided best behavior during testing
                        onReleased: {
                            // add (mouse.button === Qt.RightButton) in case multiple buttons are used in the MouseArea
                            if (containsMouse) {
                                contextMenuPopupTextInput.popup(null) // will create context menu at cursor position
                            }
                        }
                    }
                }
            }
        }

        Column {
            SGWidgets.SGText {
                text: "Custom TextArea"
                fontSizeMultiplier: 1.3
            }

            // In case of using custom text fields such as TextField, TextInput, TextEdit, TextArea
            // it is necessary to define the SGContextMenuEditActions which predefines the context menu
            SGWidgets.SGContextMenuEditActions {
                id: contextMenuPopupTextArea
                textEditor: textArea     // mandatory, should be id from one of [TextField, TextInput, TextEdit, TextArea]
                copyEnabled: true        // optional bool, in case it is necessary to disable copying (i.e. password fields)
            }

            TextArea {
                id: textArea
                placeholderText: "Input..."
                wrapMode: TextEdit.Wrap
                width: 200
                height: 100

                background: Rectangle {
                    anchors.fill: parent
                    color: dummyControl.palette.base
                    border.width: textArea.activeFocus ? 2 : 1
                    border.color: {
                        if (textArea.activeFocus) {
                            return dummyControl.palette.highlight
                        } else {
                            return dummyControl.palette.mid
                        }
                    }
                }

                selectByMouse: true // necessary for selecting the text by mouse
                persistentSelection: true // stops the text fields from deselecting the text when losing focus, must be done manually

                // it is necessary to alter focus behavior of text fields
                // because when popup opens, they lose focus and deselect all text
                onActiveFocusChanged: {
                    // keep the standard deselect behavior on losing focus active as long as context menu is not visible
                    if ((activeFocus === false) && (contextMenuPopupTextArea.visible === false)) {
                        textArea.deselect()
                    }
                }

                // MouseArea opens the popup
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.IBeamCursor     // must be explicitly defined if MouseArea overlays text fields
                    acceptedButtons: Qt.RightButton // if reusing existing MouseArea, use Qt.LeftButton | Qt.RightButton

                    // user-friendly behavior is to set focus to the text field in the onClicked / onPressed
                    onClicked: {
                        textArea.forceActiveFocus()
                    }

                    // Using onReleased provided best behavior during testing
                    onReleased: {
                        // add (mouse.button === Qt.RightButton) in case multiple buttons are used in the MouseArea
                        if (containsMouse) {
                            contextMenuPopupTextArea.popup(null) // will create context menu at cursor position
                        }
                    }
                }
            }
        }

        Column {
            SGWidgets.SGText {
                text: "Custom TextEdit"
                fontSizeMultiplier: 1.3
            }

            // In case of using custom text fields such as TextField, TextInput, TextEdit, TextArea
            // it is necessary to define the SGContextMenuEditActions which predefines the context menu
            SGWidgets.SGContextMenuEditActions {
                id: contextMenuPopupTextEdit
                textEditor: textEdit     // mandatory, should be id from one of [TextField, TextInput, TextEdit, TextArea]
                copyEnabled: true        // optional bool, in case it is necessary to disable copying (i.e. password fields)
            }

            Rectangle {
                width: 200
                height: 100

                color: dummyControl.palette.base
                border.width: textEdit.activeFocus ? 2 : 1
                border.color: {
                    if (textEdit.activeFocus) {
                        return dummyControl.palette.highlight
                    } else {
                        return dummyControl.palette.mid
                    }
                }

                TextEdit {
                    id: textEdit
                    wrapMode: TextEdit.Wrap
                    padding: 4 + 4
                    color: dummyControl.palette.text
                    selectionColor: dummyControl.palette.highlight
                    selectedTextColor: dummyControl.palette.highlightedText
                    font: dummyControl.font
                    anchors.fill: parent
                    clip: true

                    selectByMouse: true // necessary for selecting the text by mouse
                    persistentSelection: true // stops the text fields from deselecting the text when losing focus, must be done manually

                    // it is necessary to alter focus behavior of text fields
                    // because when popup opens, they lose focus and deselect all text
                    onActiveFocusChanged: {
                        // keep the standard deselect behavior on losing focus active as long as context menu is not visible
                        if ((activeFocus === false) && (contextMenuPopupTextEdit.visible === false)) {
                            textEdit.deselect()
                        }
                    }

                    Text {
                        id: placeholderTextEdit
                        text: "Input..."
                        anchors {
                            fill: parent
                            margins: textEdit.padding
                        }

                        visible: textEdit.text.length === 0
                        color: dummyControl.palette.text
                        opacity: textEdit.enabled ? 0.5 : 1
                        font: textEdit.font
                        elide: Text.ElideRight
                    }

                    // MouseArea opens the popup
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor     // must be explicitly defined if MouseArea overlays text fields
                        acceptedButtons: Qt.RightButton // if reusing existing MouseArea, use Qt.LeftButton | Qt.RightButton

                        // user-friendly behavior is to set focus to the text field in the onClicked / onPressed
                        onClicked: {
                            textEdit.forceActiveFocus()
                        }

                        // Using onReleased provided best behavior during testing
                        onReleased: {
                            // add (mouse.button === Qt.RightButton) in case multiple buttons are used in the MouseArea
                            if (containsMouse) {
                                contextMenuPopupTextEdit.popup(null) // will create context menu at cursor position
                            }
                        }
                    }
                }
            }
        }
    }

    SGWidgets.SGCheckBox {
        id: editEnabledCheckBox
        anchors {
            top: contentColumn.bottom
            topMargin: 20
        }

        text: "Everything enabled"
        checked: true
    }
}
