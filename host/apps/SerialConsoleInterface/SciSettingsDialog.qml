import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.sci 1.0 as Sci

SGWidgets.SGDialog {
    id: dialog

    title: "Settings"
    headerIcon: "qrc:/sgimages/tools.svg"
    modal: true

    property int gridRowSpacing: 10
    property int gridColumnSpacaing: 6

    Column {

        SGWidgets.SGText {
            text: "Platform Tab"
            fontSizeMultiplier: 1.1
            font.bold: true

            width: platformTabSettings.width + 12
        }

        GridLayout {
            id: platformTabSettings
            anchors.right: parent.right
            columns: 2
            rowSpacing: gridRowSpacing
            columnSpacing: gridColumnSpacaing

            SGWidgets.SGText {
                text: "Commands in scrollback:"
                Layout.alignment: Qt.AlignRight
            }

            SGWidgets.SGSpinBox {
                id: maxCommandsInScrollbackEdit
                from: 20
                to: 450
                stepSize: 10
                editable: true
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

            SGWidgets.SGText {
                text: "Commands in history:"
                Layout.alignment: Qt.AlignRight
            }

            SGWidgets.SGSpinBox {
                id: maxCommandsInHistoryEdit
                from: 1
                to: 99
                editable: true
                Layout.alignment: Qt.AlignRight

                Binding {
                    target: maxCommandsInHistoryEdit
                    property: "value"
                    value: Sci.Settings.maxCommandsInHistory
                }

                onValueChanged: {
                    Sci.Settings.maxCommandsInHistory = value
                }
            }
        }

        Item {
            width: 1
            height: 2*gridRowSpacing
        }

        SGWidgets.SGText {
            text: "Environment"
            fontSizeMultiplier: 1.1
            font.bold: true
        }

        GridLayout {
            anchors.right: parent.right
            columns: 2
            rowSpacing: gridRowSpacing
            columnSpacing: gridColumnSpacaing

            SGWidgets.SGText {
                text: "Base font size:"
                Layout.alignment: Qt.AlignRight
            }

            SGWidgets.SGSpinBox {
                id: fontPixelSizeEdit
                from: 8
                to: 24
                editable: true
                Layout.alignment: Qt.AlignRight

                Binding {
                    target: fontPixelSizeEdit
                    property: "value"
                    value: SGWidgets.SGSettings.fontPixelSize
                }

                onValueChanged: {
                    SGWidgets.SGSettings.fontPixelSize = value
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
