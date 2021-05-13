import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
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
    property int gridColumnSpacing: 6

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
                text: "Device will not reconnect after disconnection"
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
                text: "Device does not responds"
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

            GridLayout {
                id: mockResponseSettings
                columns: 2
                rowSpacing: baseSpacing
                columnSpacing: gridColumnSpacing
                enabled: !responseDisabledCheckBox.checked

                SGWidgets.SGText {
                    id: mockCommandComboBoxLabel
                    fontSizeMultiplier: 1.2
                    text: "Command:"
                }

                SGWidgets.SGComboBox {
                    id: mockCommandComboBox
                    model: sciModel.mockCommandModel
                    textRole: "name"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Command to be replied with a custom Response")
                    ToolTip.delay: 1000

                    onActivated: {
                        if (currentIndex !== -1) {
                            let command = model.data(currentIndex,"type")
                            if (mockDevice.mockCommand !== command) {
                                mockDevice.mockCommand = command
                            }
                        }
                    }

                    Component.onCompleted: {
                        currentIndex = (mockDevice !== null) ? model.find(mockDevice.mockCommand) : -1
                    }
                }

                SGWidgets.SGText {
                    id: mockResponseComboBoxLabel
                    fontSizeMultiplier: 1.2
                    text: "Response:"
                }

                SGWidgets.SGComboBox {
                    id: mockResponseComboBox
                    model: sciModel.mockResponseModel
                    textRole: "name"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Response to be sent for selected Command")
                    ToolTip.delay: 1000

                    onActivated: {
                        if (currentIndex !== -1) {
                            let response = model.data(currentIndex,"type")
                            if (mockDevice.mockResponse !== response) {
                                mockDevice.mockResponse = response
                            }
                        }
                    }

                    Component.onCompleted: {
                        currentIndex = (mockDevice !== null) ? model.find(mockDevice.mockResponse) : -1
                    }
                }

                SGWidgets.SGText {
                    id: mockVersionComboBoxLabel
                    fontSizeMultiplier: 1.2
                    text: "Version:"
                }

                SGWidgets.SGComboBox {
                    id: mockVersionComboBox
                    model: sciModel.mockVersionModel
                    textRole: "name"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Version of device which affects sent Response")
                    ToolTip.delay: 1000

                    onActivated: {
                        if (currentIndex !== -1) {
                            let version = model.data(currentIndex,"type")
                            if (mockDevice.mockVersion !== version) {
                                mockDevice.mockVersion = version
                            }
                        }
                    }

                    Component.onCompleted: {
                        currentIndex = (mockDevice !== null) ? model.find(mockDevice.mockVersion) : -1
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
