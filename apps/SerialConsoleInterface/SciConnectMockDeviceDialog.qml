import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGDialog {
    id: dialog

    title: "Connect Mock Device"
    headerIcon: "qrc:/sgimages/tools.svg"
    modal: true

    property int gridRowSpacing: 10
    property int gridColumnSpacaing: 6

    Column {

        GridLayout {
            id: platformTabSettings
            anchors.right: parent.right
            columns: 2
            rowSpacing: gridRowSpacing
            columnSpacing: gridColumnSpacaing

            SGWidgets.SGText {
                text: "Properties"
                fontSizeMultiplier: 1.1
                font.bold: true

                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignLeft
            }

            SGWidgets.SGText {
                text: "Device Name:"
                Layout.alignment: Qt.AlignRight
            }

            SGWidgets.SGTextField {
                id: deviceName
                text: sciModel.mockDevice.mockDeviceModel.getLatestMockDeviceName();
                placeholderText: "Device Name..."
                Layout.alignment: Qt.AlignLeft
                contextMenuEnabled: true
                onTextChanged: {
                    if (deviceIdCheckbox.checked) {
                        updateDeviceId();
                    }
                }
            }

            SGWidgets.SGText {
                text: "Device Id:"
                Layout.alignment: Qt.AlignRight
            }

            Row {
                SGWidgets.SGTextField {
                    id: deviceId
                    placeholderText: "Device Id..."
                    Layout.alignment: Qt.AlignLeft
                    contextMenuEnabled: true
                    enabled: deviceIdCheckbox.checked === false
                }

                SGWidgets.SGCheckBox {
                    id: deviceIdCheckbox
                    text: "Auto-generated"
                    checked: true
                    onCheckedChanged: {
                        if (checked) {
                            updateDeviceId();
                        }
                    }
                }
            }

            SGWidgets.SGText {
                id: errorText
                text: ""
                color: "Red"

                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignLeft
            }
        }
    }

    footer: Item {
        implicitHeight: buttonRow.height + 10

        Row {
            id: buttonRow
            anchors.centerIn: parent
            spacing: 10

            SGWidgets.SGButton {
                text: "Cancel"
                onClicked: dialog.accept()
            }

            SGWidgets.SGButton {
                text: "Connect"
                enabled: (deviceName.text.length > 0) && (deviceId.text.length > 0)
                onClicked: {
                    if (sciModel.mockDevice.mockDeviceModel.connectMockDevice(deviceName.text, deviceId.text) === true) {
                        dialog.accept()
                    } else {
                        errorText.text = "Unable to connect this device, device already exists."
                    }
                }
            }
        }
    }

    function updateDeviceId() {
        deviceId.text = sciModel.mockDevice.mockDeviceModel.getMockDeviceId(deviceName.text);
    }

    onOpened: {
        deviceName.forceActiveFocus()
    }
}
