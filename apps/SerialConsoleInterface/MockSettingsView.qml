/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.sci 1.0 as Sci

FocusScope {
    id: mockSettingsView

    property variant mockDevice: model.platform.mockDevice
    property variant deviceType: model.platform.deviceType
    property bool isValid: mockDevice.isValid
    property int baseSpacing: 10
    property int gridColumnSpacing: 6

    onDeviceTypeChanged: {
        // force close the view in case the same deviceId is reused for non-mock device
        if (deviceType !== Sci.SciPlatform.MockDevice) {
            closeView()
        }
    }

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

            GridLayout {
                id: mockSettings
                columns: 2
                rowSpacing: baseSpacing
                columnSpacing: gridColumnSpacing

                SGWidgets.SGCheckBox {
                    id: openEnabledCheckBox
                    text: "Device will not reconnect after disconnection"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Simulate faulty device that cannot be reopened")
                    ToolTip.delay: 1000
                    enabled: isValid

                    onCheckStateChanged: {
                        mockDevice.openEnabled = !checked
                    }

                    Binding {
                        target: openEnabledCheckBox
                        property: "checked"
                        value: !mockDevice.openEnabled
                    }
                }

                SGWidgets.SGButton {
                    text: "Reopen"
                    enabled: mockDevice.canReopenMockDevice
                    onClicked: {
                        mockDevice.reopenMockDevice()
                    }
                }

                SGWidgets.SGCheckBox {
                    id: responseDisabledCheckBox
                    text: "Device does not responds"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Simulate faulty device that does not responds")
                    ToolTip.delay: 1000
                    enabled: isValid
                    Layout.columnSpan: 2
                    Layout.alignment: Qt.AlignLeft

                    onCheckStateChanged: {
                        mockDevice.autoResponse = !checked
                    }

                    Binding {
                        target: responseDisabledCheckBox
                        property: "checked"
                        value: !mockDevice.autoResponse
                    }
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
            enabled: isValid

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
                    id: mockVersionComboBoxLabel
                    fontSizeMultiplier: 1.2
                    text: "Communication Protocol Version:"
                }

                SGWidgets.SGComboBox {
                    id: mockVersionComboBox
                    model: mockDevice.mockVersionModel
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

                    Binding {
                        target: mockVersionComboBox
                        property: "currentIndex"
                        value: mockDevice.mockVersionModel.find(mockDevice.mockVersion)
                    }
                }

                SGWidgets.SGText {
                    id: mockCommandComboBoxLabel
                    fontSizeMultiplier: 1.2
                    text: "Input Command:"
                }

                SGWidgets.SGComboBox {
                    id: mockCommandComboBox
                    model: mockDevice.mockCommandModel
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

                    Binding {
                        target: mockCommandComboBox
                        property: "currentIndex"
                        value: mockDevice.mockCommandModel.find(mockDevice.mockCommand)
                    }
                }

                SGWidgets.SGText {
                    id: mockResponseComboBoxLabel
                    fontSizeMultiplier: 1.2
                    text: "Output Response:"
                }

                SGWidgets.SGComboBox {
                    id: mockResponseComboBox
                    model: mockDevice.mockResponseModel
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

                    Binding {
                        target: mockResponseComboBox
                        property: "currentIndex"
                        value: mockDevice.mockResponseModel.find(mockDevice.mockResponse)
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
