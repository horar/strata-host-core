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
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0 as SGWidgets

GenericPopup {
    id: textPopup

    property alias doubleValidator: doubleValidator
    property alias intValidator: intValidator
    property alias regExpValidator: regExpValidator
    property alias text: textField.text
    property alias validator: textField.validator
    property alias label: label.text
    property string sourceProperty: "text"
    property bool isString: true
    property bool mustNotBeEmpty: false

    // Only used/modified when popup is "Set ID" (textPopup.sourceProperty == "id")
    // Used to disallow certain specific text inputs (duplicated object ID's)
    property var invalidInputs: []
    property bool validInput: true

    onVisibleChanged: {
        if (visible) {
            textField.selectAll()
            textField.forceActiveFocus()
        }
    }

    DoubleValidator {
        id: doubleValidator
        locale: "C"
    }

    IntValidator {
        id: intValidator
        locale: "C"
    }

    RegExpValidator {
        id: regExpValidator
        regExp: /^[a-z_][a-zA-Z0-9_]*/
    }

    ColumnLayout {

        Text {
            id: label
            text: "Enter the desired text."
            Layout.fillWidth: true
            Layout.maximumWidth: textField.implicitWidth
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        Text {
            id: invalidIdLabel
            text: "Error: ID '" + textField.text + "' is not unique."
            Layout.fillWidth: true
            Layout.maximumWidth: textField.implicitWidth
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: Theme.palette.error
            visible: !textPopup.validInput
        }

        TextField {
            id: textField
            implicitWidth: 400
            selectByMouse: true
            focus: true
            persistentSelection: true
            palette.highlight: Theme.palette.onsemiOrange

            onAccepted: {
                if (okButton.enabled) {
                    okButton.clicked()
                }
            }

            onTextChanged: {
                if (textPopup.sourceProperty == "id") {
                    textPopup.validInput = !textPopup.invalidInputs.includes(text)
                }
            }

            onActiveFocusChanged: {
                if ((activeFocus === false) && (contextMenuPopup.visible === false)) {
                    textField.deselect()
                }
            }

            SGWidgets.SGContextMenuEditActions {
                id: contextMenuPopup
                textEditor: textField
                copyEnabled: textField.echoMode !== TextField.Password
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.RightButton

                onReleased: {
                    if (containsMouse) {
                        contextMenuPopup.popup(null)
                    }
                }

                onClicked: {
                    textField.forceActiveFocus()
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: okButton
                text: "OK"
                enabled: {
                    if (validInput) {
                        if (mustNotBeEmpty) {
                            return textField.text !== ""
                        } else {
                            return true
                        }
                    } else {
                        return false
                    }
                }

                onClicked: {
                    if (isString) {
                        let newString = textPopup.text
                        newString = newString.replace(/[\""]/g, '\\"') // escape any quotes in the string to avoid string errors
                        visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, sourceProperty, '"' + newString + '"')
                    } else {
                        visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, sourceProperty, textPopup.text)
                    }
                    textPopup.close()
                }
            }

            Button {
                text: "Cancel"

                onClicked: {
                    textPopup.text = ""
                    textPopup.close()
                }
            }
        }
    }
}
