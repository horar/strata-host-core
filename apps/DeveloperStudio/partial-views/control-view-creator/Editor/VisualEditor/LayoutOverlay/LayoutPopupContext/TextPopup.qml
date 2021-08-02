import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

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

    onVisibleChanged: {
        if (visible) {
            textField.selectAll()
            textField.forceActiveFocus()
        }
    }

    DoubleValidator {
        id: doubleValidator
    }

    IntValidator {
        id: intValidator
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

        TextField {
            id: textField
            implicitWidth: 400
            onAccepted: {
                okButton.clicked()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: okButton
                text: "OK"
                enabled: {
                    if (mustNotBeEmpty) {
                        return textField.text !== ""
                    } else {
                        return true
                    }
                }
                onClicked: {
                    if (isString) {
                        let newString = textPopup.text
                        newString = newString.replace(/[\""]/g, '\\"') // escape any quotes in the string to avoid string errors
                        visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, sourceProperty , '"' + newString + '"')
                    } else {
                        visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, sourceProperty , textPopup.text)
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
