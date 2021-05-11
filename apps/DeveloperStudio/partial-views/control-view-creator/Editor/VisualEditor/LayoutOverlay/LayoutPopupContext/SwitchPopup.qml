import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import tech.strata.sgwidgets 1.0

Popup {
    id: switchPopup
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

    property string textFieldProperty
    onClosed: renameLoader.active = false

    ColumnLayout {
        anchors.fill: parent
        Text {
            id: label
            text: "Please toggle the switch:"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        SGSwitch {
            id: switchContainer
            checkedLabel: "true"                 // Default: "" (if not entered, label will not appear)
            uncheckedLabel: "false"              // Default: "" (if not entered, label will not appear)
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: okButton
                text: "OK"
                onClicked: {
                    switchPopup.close()
                    visualEditor.fileContents = visualEditor.functions.replaceObjectPropertyValueInString(layoutOverlayRoot.layoutInfo.uuid, textFieldProperty,switchContainer.checked)
                    console.log(layoutOverlayRoot.layoutInfo.uuid,textFieldProperty,switchContainer.checked)
                    visualEditor.functions.saveFile()
                }
            }

            Button {
                text: "Cancel"
                onClicked: {
                    switchPopup.close()
                }
            }
        }
    }
}
