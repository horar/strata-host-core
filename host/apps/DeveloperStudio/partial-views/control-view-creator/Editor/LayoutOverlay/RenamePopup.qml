import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

Popup {
    id: renamePopup
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

    property alias text: textField.text

    onVisibleChanged: {
        textField.selectAll()
        textField.forceActiveFocus()
    }

    ColumnLayout {

        Text {
            text: "Ensure all id's are unique, otherwise build may fail"
        }

        TextField {
            id: textField
            implicitWidth: 400
            validator: RegExpValidator {
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
                    renamePopup.close()
                    root.fileContents = root.replaceObjectPropertyValueInString(layoutOverlayRoot.layoutInfo.uuid, "id:",  renamePopup.text)
                    root.saveFile()
                }
            }

            Button {
                text: "Cancel"
                onClicked: {
                    renamePopup.text = ""
                    renamePopup.close()
                }
            }
        }
    }
}
