import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import tech.strata.sgwidgets 1.0

Popup {
    id: comboBoxPopup
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

    property string parentProperty
    property var model: ["Qt.Horizontal", "Qt.Vertical"]
    property alias label: label.text
    onClosed: menuLoader.active = false

    ColumnLayout {
        anchors.fill: parent
        Text {
            id: label
            text: "Please toggle the switch:"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        SGComboBox {
            id: comboBox
            Layout.alignment: Qt.AlignHCenter
            model: comboBoxPopup.model
        }


        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: okButton
                text: "OK"
                onClicked: {
                    comboBoxPopup.close()
                    visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, parentProperty, comboBox.currentText)
                }
            }

            Button {
                text: "Cancel"
                onClicked: {
                    comboBoxPopup.close()
                }
            }
        }
    }
}
