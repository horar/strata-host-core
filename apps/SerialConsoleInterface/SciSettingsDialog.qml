/*
 * Copyright (c) 2018-2021 onsemi.
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

SGWidgets.SGDialog {
    id: dialog

    title: "Settings"
    headerIcon: "qrc:/sgimages/tools.svg"
    modal: true

    property variant rootItem
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
                text: "Log level:"
                Layout.alignment: Qt.AlignRight
            }

            SGWidgets.SGLogLevelSelector {
                Layout.alignment: Qt.AlignLeft
            }

            SGWidgets.SGText {
                text: "Reset Settings"
                fontSizeMultiplier: 1.1
                font.bold: true
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignLeft
            }

            Column {
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignRight

                SGWidgets.SGText {
                    anchors.right: parent.right
                    text: "Restore all settings to their default values"
                }

                SGWidgets.SGButton {
                    anchors.right: parent.right
                    text: "Reset Settings"
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
            }

            Column {
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignRight

                SGWidgets.SGText {
                    anchors.right: parent.right
                    text: "Restore default window size"
                }

                SGWidgets.SGButton {
                    anchors.right: parent.right
                    text: "Reset Window Size"
                    onClicked: rootItem.resetWindowSize()
                }
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
                text: "Close"
                onClicked: dialog.accept()
            }
        }
    }
}
