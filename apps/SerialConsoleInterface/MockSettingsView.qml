import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.sci 1.0 as Sci

FocusScope {
    id: mockSettingsView

    onMockDeviceChanged: {
        if (mockDevice === null) {
            closeView()
        }
    }

    property variant mockDevice: model.platform.mockDevice
    property int baseSpacing: 10

    FocusScope {
        id: content
        anchors {
            fill: parent
            margins: baseSpacing
        }

        focus: true

        Column {
            anchors {
                left: parent.left
                right: parent.right
            }
            spacing: baseSpacing
            enabled: mockDevice !== null

            SGWidgets.SGText {
                text: "Mock Settings"
                fontSizeMultiplier: 2.0
                font.bold: true
            }

            SGWidgets.SGCheckBox {
                text: "Open Disabled"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Simulate faulty device that cannot be reopened")
                ToolTip.delay: 1000

                onCheckedChanged : {
                    mockDevice.openEnabled = !checked
                }

                Component.onCompleted: {
                    checked = (mockDevice !== null) ? !mockDevice.openEnabled : false
                }
            }

            SGWidgets.SGCheckBox {
                text: "Legacy Mode"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Simulate legacy functionality (no get_firmware_info)")
                ToolTip.delay: 1000

                onCheckedChanged : {
                    mockDevice.legacyMode = checked
                }

                Component.onCompleted: {
                    checked = (mockDevice !== null) ? mockDevice.legacyMode : true
                }
            }

            SGWidgets.SGCheckBox {
                id: responseDisabledCheckBox
                text: "Response Disabled"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Simulate faulty device that does not responds")
                ToolTip.delay: 1000

                onCheckedChanged : {
                    mockDevice.autoResponse = !checked
                }

                Component.onCompleted: {
                    checked = (mockDevice !== null) ? !mockDevice.autoResponse : false
                }
            }

            Rectangle {
                id: divider
                anchors {
                    topMargin: baseSpacing
                }

                width: parent.width
                height: 1
                color: "black"
                opacity: 0.4
            }

            SGWidgets.SGText {
                text: "Mock Response Configuration"
                fontSizeMultiplier: 2.0
                font.bold: true
            }

            Row {
                enabled: !responseDisabledCheckBox.checked

                TextArea {
                    id: mockCommandComboBoxLabel
                    implicitHeight: mockCommandComboBox.height
                    implicitWidth: 100
                    readOnly: true
                    horizontalAlignment: TextEdit.AlignLeft
                    verticalAlignment: TextEdit.AlignVCenter
                    font.pixelSize: SGWidgets.SGSettings.fontPixelSize * 1.2
                    text: "Command:"
                }

                SGWidgets.SGComboBox {
                    id: mockCommandComboBox
                    model: [
                        "Any Command",
                        "Get Firmware Info",
                        "Request Platform Id",
                        "Start Bootloader",
                        "Start Application",
                        "Flash Firmware",
                        "Flash Bootloader",
                        "Start Flash Firmware",
                        "Start Flash Bootloader",
                        "Set Assisted Platform id",
                        "Set Platform Id",
                        "Start Backup Firmware",
                        "Backup Firmware"
                    ]
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Command to be replied with a custom Response")
                    ToolTip.delay: 1000

                    onActivated: {
                        if (currentIndex !== -1) {
                            if (mockDevice.mockCommand !== currentIndex) {
                                mockDevice.mockCommand = currentIndex
                            }
                        }
                    }

                    Component.onCompleted: {
                        currentIndex = (mockDevice !== null) ? mockDevice.mockCommand : 0
                    }
                }
            }

            Row {
                enabled: !responseDisabledCheckBox.checked

                TextArea {
                    id: mockResponseComboBoxLabel
                    implicitHeight: mockResponseComboBox.height
                    implicitWidth: 100
                    readOnly: true
                    horizontalAlignment: TextEdit.AlignLeft
                    verticalAlignment: TextEdit.AlignVCenter
                    font.pixelSize: SGWidgets.SGSettings.fontPixelSize * 1.2
                    text: "Response:"
                }

                SGWidgets.SGComboBox {
                    id: mockResponseComboBox
                    model: [
                        "Normal",
                        "No Payload",
                        "No JSON",
                        "Nack",
                        "Invalid",
                        "Platform Config: Embedded App",
                        "Platform Config: Assisted App",
                        "Platform Config: Assisted No Board",
                        "Platform Config: Embedded Bootloader",
                        "Platform Config: Assisted Bootloader",
                        "Flash Firmware: Resend Chunk",
                        "Flash Firmware: Memory Error",
                        "Flash Firmware: Invalid Cmd Sequence",
                        "Flash Firmware: Invalid Value",
                        "Start Flash Firmware: Invalid"
                    ]
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Response to be sent for selected Command")
                    ToolTip.delay: 1000

                    onActivated: {
                        if (currentIndex !== -1) {
                            if (mockDevice.mockResponse !== currentIndex) {
                                mockDevice.mockResponse = currentIndex
                            }
                        }
                    }

                    Component.onCompleted: {
                        currentIndex = (mockDevice !== null) ? mockDevice.mockResponse : 0
                    }
                }
            }

            Row {
                enabled: !responseDisabledCheckBox.checked

                TextArea {
                    id: mockVersionComboBoxLabel
                    implicitHeight: mockVersionComboBox.height
                    implicitWidth: 100
                    readOnly: true
                    horizontalAlignment: TextEdit.AlignLeft
                    verticalAlignment: TextEdit.AlignVCenter
                    font.pixelSize: SGWidgets.SGSettings.fontPixelSize * 1.2
                    text: "Version:"
                }

                SGWidgets.SGComboBox {
                    id: mockVersionComboBox
                    model: [ "Version 1", "Version 2" ]
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Version of device which affects sent Response")
                    ToolTip.delay: 1000

                    onActivated: {
                        if (currentIndex !== -1) {
                            if (mockDevice.mockVersion !== currentIndex) {
                                mockDevice.mockVersion = currentIndex
                            }
                        }
                    }

                    Component.onCompleted: {
                        currentIndex = (mockDevice !== null) ? mockDevice.mockVersion : 0
                    }
                }
            }
        }

        SGWidgets.SGButton {
            anchors {
                left: parent.left
                bottom: parent.bottom
            }

            text: "Back"
            icon.source: "qrc:/sgimages/chevron-left.svg"
            onClicked: {
                closeView()
            }
        }
    }

    function closeView() {
        model.platform.scrollbackModel.clearAutoExportError()
        StackView.view.pop();
    }
}
