import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

Popup {
    id: textPopup
    padding: 10
    anchors {
        centerIn: Overlay.overlay
    }
    closePolicy: Popup.NoAutoClose
    modal: true

    background: Rectangle {
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 1
            verticalOffset: 3
            radius: 6.0
            samples: 12
            color: "#99000000"
        }
    }

    property alias doubleValidator: doubleValidator
    property alias intValidator: intValidator
    property alias regExpValidator: regExpValidator
    property alias text: textField.text
    property alias validator: textField.validator
    property alias label: label.text
    property string sourceProperty
    property bool isString: true

    DoubleValidator {
        id: doubleValidator
    }
    IntValidator {
        id: intValidator
    }
    RegExpValidator {
        id: regExpValidator
    }

    onVisibleChanged: {
        if (visible) {
            textField.selectAll()
            textField.forceActiveFocus()
        }
    }

    onClosed: menuLoader.active = false

    ColumnLayout {

        Text {
            id: label
            text: "Ensure all id's are unique, otherwise build will fail. Id's must start with lower case letter, and contain only letters, numbers and underscores."
            Layout.fillWidth: true
            Layout.maximumWidth: textField.implicitWidth
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        TextField {
            id: textField
            implicitWidth: 400
            validator: RegExpValidator {
                id: validatorValue
                regExp: /^[a-z_][a-zA-Z0-9_]*/
            }
            onAccepted: {
                if (text !=="") {
                    okButton.clicked()
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: okButton
                text: "OK"
                enabled: textField.text !== ""
                onClicked: {
                    textPopup.close()
                    if(isString) {
                        visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, sourceProperty , '"' + textPopup.text + '"')
                    }
                    else  {
                        visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, sourceProperty , textPopup.text)
                    }
                    visualEditor.functions.saveFile()
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
