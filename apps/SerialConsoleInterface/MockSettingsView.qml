import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.sci 1.0 as Sci

FocusScope {
    id: mockSettingsView

    onMockDeviceChanged: {
        initValues()
    }

    onDeviceTypeChanged: {
        // force close the view in case the same deviceId is reused for non-mock device
        if (deviceType !== Sci.SciPlatform.MockDevice) {
            closeView()
        }
    }

    property variant mockDevice: model.platform.mockDevice
    property variant deviceType: model.platform.deviceType
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
            id: settingsWrapper
            anchors {
                left: parent.left
                right: parent.right
            }
            spacing: baseSpacing

            SGWidgets.SGText {
                text: "Mock Settings"
                fontSizeMultiplier: 2.0
                font.bold: true
            }

            SGWidgets.SGCheckBox {
                id: openEnabledCheckBox
                text: "Device will not reconnect after disconnection"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Simulate faulty device that cannot be reopened")
                ToolTip.delay: 1000

                onCheckedChanged : {
                    if (mockDevice === null) {
                        if (checked === false) {
                            if (sciModel.mockDevice.mockDeviceModel.reopenMockDevice(model.platform.deviceId) === false) {
                                checked = true
                            } else {
                                enabled = false
                            }
                        }
                    } else {
                        mockDevice.openEnabled = !checked
                    }
                }

                function init() {
                    if (mockDevice !== null) {
                        checked = !mockDevice.openEnabled
                        enabled = true;
                    } else {
                        if (sciModel.mockDevice.mockDeviceModel.canReopenMockDevice(model.platform.deviceId) === true) {
                            enabled = true;
                            openEnabledCheckBox.checked = true;
                        } else {
                            enabled = false;
                        }
                    }
                }
            }

            SGWidgets.SGCheckBox {
                id: legacyModeCheckBox
                text: "Legacy Mode"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Simulate legacy functionality (no get_firmware_info)")
                ToolTip.delay: 1000
                enabled: mockDevice !== null

                onCheckedChanged : {
                    mockDevice.legacyMode = checked
                }

                function init() {
                    checked = mockDevice.legacyMode
                }
            }

            SGWidgets.SGCheckBox {
                id: responseDisabledCheckBox
                text: "Device does not responds"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Simulate faulty device that does not responds")
                ToolTip.delay: 1000
                enabled: mockDevice !== null

                onCheckedChanged : {
                    mockDevice.autoResponse = !checked
                }

                function init() {
                    checked = !mockDevice.autoResponse
                }
            }
        }

        Rectangle {
            id: divider
            anchors {
                top: settingsWrapper.bottom
                topMargin: baseSpacing
            }

            width: parent.width
            height: 1
            color: "black"
            opacity: 0.4
        }

        Column {
            id: responseSettingsWrapper
            anchors {
                top: divider.bottom
                left: parent.left
                right: parent.right
            }
            spacing: baseSpacing
            enabled: mockDevice !== null

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
                    text: "Input Command:"
                }

                SGWidgets.SGComboBox {
                    id: mockCommandComboBox
                    model: sciModel.mockDevice.mockCommandModel
                    textRole: "name"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Command which is to be replied with a custom Response")
                    ToolTip.delay: 1000

                    onActivated: {
                        if (currentIndex !== -1) {
                            let command = model.data(currentIndex,"type")
                            if (mockDevice.mockCommand !== command) {
                                mockDevice.mockCommand = command
                            }
                        }
                    }

                    function init() {
                        currentIndex = model.find(mockDevice.mockCommand)
                    }
                }

                SGWidgets.SGText {
                    id: mockResponseComboBoxLabel
                    fontSizeMultiplier: 1.2
                    text: "Output Response:"
                }

                SGWidgets.SGComboBox {
                    id: mockResponseComboBox
                    model: sciModel.mockDevice.mockResponseModel
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

                    function init() {
                        currentIndex = model.find(mockDevice.mockResponse)
                    }
                }

                SGWidgets.SGText {
                    id: mockVersionComboBoxLabel
                    fontSizeMultiplier: 1.2
                    text: "Communication Protocol Version:"
                }

                SGWidgets.SGComboBox {
                    id: mockVersionComboBox
                    model: sciModel.mockDevice.mockVersionModel
                    textRole: "name"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Version of protocol used for communication")
                    ToolTip.delay: 1000

                    onActivated: {
                        if (currentIndex !== -1) {
                            let version = model.data(currentIndex,"type")
                            if (mockDevice.mockVersion !== version) {
                                mockDevice.mockVersion = version
                            }
                        }
                    }

                    function init() {
                        currentIndex = model.find(mockDevice.mockVersion)
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

    function initValues() {
        openEnabledCheckBox.init()
        if (mockDevice !== null) {
            legacyModeCheckBox.init()
            responseDisabledCheckBox.init()
            mockCommandComboBox.init()
            mockResponseComboBox.init()
            mockVersionComboBox.init()
        }
    }
}
