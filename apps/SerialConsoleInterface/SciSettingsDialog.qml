/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.sci 1.0 as Sci
import tech.strata.logconf 1.0 as LcuPlugin

SGWidgets.SGDialog {
    id: dialog

    title: "Settings"
    headerIcon: "qrc:/sgimages/tools.svg"
    modal: true

    property variant rootItem
    property int gridRowSpacing: 10
    property int gridColumnSpacing: 6

    GridLayout {
        columns: 3
        rows: 2
        rowSpacing: gridRowSpacing
        columnSpacing: gridColumnSpacing

        ColumnLayout {
            id: firstColumn
            spacing: gridColumnSpacing

            GridLayout {
                id: platformTabSettings
                columns: 2
                rowSpacing: gridRowSpacing
                columnSpacing: gridColumnSpacing

                SGWidgets.SGText {
                    text: "Platform Tab"
                    fontSizeMultiplier: 1.1
                    font.bold: true

                    Layout.columnSpan: 2
                    Layout.alignment: Qt.AlignLeft
                }

                SGWidgets.SGText {
                    text: "Commands in scrollback:"
                    Layout.alignment: Qt.AlignRight
                }

                Row {
                    SGWidgets.SGSpinBox {
                        id: maxCommandsInScrollbackEdit
                        from: 1
                        to: 100000
                        stepSize: 5000
                        editable: true
                        enabled: !Sci.Settings.commandsInScrollbackUnlimited
                        Layout.alignment: Qt.AlignRight

                        Binding {
                            target: maxCommandsInScrollbackEdit
                            property: "value"
                            value: Sci.Settings.maxCommandsInScrollback
                        }

                        onValueChanged: {
                            Sci.Settings.maxCommandsInScrollback = value
                        }
                    }

                    SGWidgets.SGCheckBox {
                        id: commandsInScrollbackUnlimitedCheckbox
                        text: "Unlimited"

                        Binding {
                            target: commandsInScrollbackUnlimitedCheckbox
                            property: "checked"
                            value: Sci.Settings.commandsInScrollbackUnlimited
                        }

                        onCheckedChanged : {
                            Sci.Settings.commandsInScrollbackUnlimited = checked
                        }
                    }
                }

                SGWidgets.SGText {
                    text: "Commands in history:"
                    Layout.alignment: Qt.AlignRight
                }

                SGWidgets.SGSpinBox {
                    id: maxCommandsInHistoryEdit

                    from: 1
                    to: 99
                    editable: true
                    Layout.alignment: Qt.AlignLeft

                    Binding {
                        target: maxCommandsInHistoryEdit
                        property: "value"
                        value: Sci.Settings.maxCommandsInHistory
                    }

                    onValueChanged: {
                        Sci.Settings.maxCommandsInHistory = value
                    }
                }

                SGWidgets.SGText {
                    text: "Environment"
                    fontSizeMultiplier: 1.1
                    font.bold: true
                    Layout.columnSpan: 2
                    Layout.alignment: Qt.AlignLeft
                }

                SGWidgets.SGText {
                    text: "Base font size:"
                    Layout.alignment: Qt.AlignRight
                }

                SGWidgets.SGSpinBox {
                    id: fontPixelSizeEdit
                    from: 8
                    to: 24
                    editable: true
                    Layout.alignment: Qt.AlignLeft

                    Binding {
                        target: fontPixelSizeEdit
                        property: "value"
                        value: SGWidgets.SGSettings.fontPixelSize
                    }

                    onValueChanged: {
                        SGWidgets.SGSettings.fontPixelSize = value
                    }
                }

                SGWidgets.SGText {
                    text: "General"
                    fontSizeMultiplier: 1.1
                    font.bold: true
                    Layout.columnSpan: 2
                    Layout.alignment: Qt.AlignLeft
                }

                SGWidgets.SGText {
                    text: "Commands collapsed at startup:"
                    Layout.alignment: Qt.AlignRight
                }

                SGWidgets.SGCheckBox {
                    id: commandsCollapsed
                    padding: 0
                    Layout.alignment: Qt.AlignLeft
                    text: " "

                    Binding {
                        target: commandsCollapsed
                        property: "checked"
                        value: Sci.Settings.commandsCondensedAtStartup
                    }

                    onCheckedChanged : {
                        Sci.Settings.commandsCondensedAtStartup = checked
                    }
                }

                SGWidgets.SGText {
                    text: "Release port of unrecognized device"
                    Layout.alignment: Qt.AlignRight
                }

                SGWidgets.SGCheckBox {
                    id: relesePortOption
                    padding: 0
                    Layout.alignment: Qt.AlignLeft
                    text: " "

                    Binding {
                        target: relesePortOption
                        property: "checked"
                        value: Sci.Settings.relasePortOfUnrecongizedDevice
                    }

                    onCheckedChanged : {
                        Sci.Settings.relasePortOfUnrecongizedDevice = checked
                    }
                }

                SGWidgets.SGText {
                    text: "Message queue send delay [ms]:"
                    Layout.alignment: Qt.AlignRight
                }

                SGWidgets.SGSpinBox {
                    id: messageQueueSendDelayEdit

                    from: 0
                    to: 2000
                    stepSize: 100
                    editable: true
                    Layout.alignment: Qt.AlignLeft

                    Binding {
                        target: messageQueueSendDelayEdit
                        property: "value"
                        value: Sci.Settings.messageQueueSendDelay
                    }

                    onValueChanged: {
                        Sci.Settings.messageQueueSendDelay = value
                    }
                }
            }

            SGWidgets.SGText {
                text: "Reset Settings"
                fontSizeMultiplier: 1.1
                font.bold: true
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignLeft
            }

            RowLayout {
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                spacing: gridRowSpacing

                SGWidgets.SGButton {
                    text: "Reset Settings"
                    hintText: "Restore all settings to their default values"
                    onClicked: {
                        SGWidgets.SGDialogJS.showConfirmationDialog(
                                    rootItem,
                                    "Reset settings to defaults",
                                    "Do you really want to reset all settings to their default values?",
                                    "Reset",
                                    function() {
                                        SGWidgets.SGSettings.resetToDefaultValues()
                                        Sci.Settings.resetToDefaultValues()
                                    },
                                    "Cancel",
                                    undefined,
                                    SGWidgets.SGMessageDialog.Warning
                                    )
                    }
                }

                SGWidgets.SGButton {
                    text: "Reset Window Size"
                    hintText: "Restore default window size"
                    onClicked: rootItem.resetWindowSize()
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignCenter
            width: 1
            height: firstColumn.height
            color: "black"
            opacity: 0.3
        }

        ColumnLayout {
            spacing: gridColumnSpacing
            Layout.alignment: Qt.AlignTop

            SGWidgets.SGText {
                text: "Logging Configuration"
                fontSizeMultiplier: 1.1
                font.bold: true
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignLeft
            }

            LcuPlugin.LogLevel {
                id: logLevel
                Layout.columnSpan: 2
                Layout.fillWidth: true
                fileName: ""
            }

            LcuPlugin.LogDetails {
                id: logDetails
                Layout.columnSpan: 2
                Layout.fillWidth: true
                fileName: ""
                lcuApp: false
            }
        }

        SGWidgets.SGButton {
            id: closeButton

            Layout.column: 1
            Layout.row: 1
            Layout.minimumHeight: logLevel.height
            Layout.maximumWidth: 1.5*height
            text: "Close"
            fontSizeMultiplier: 1.3
            background: Rectangle {
                anchors.fill: parent
                radius: 3
                color: parent.hovered ? headerBgColor : closeButton.implicitColor
            }
            onClicked: dialog.accept()
        }
    }
}
