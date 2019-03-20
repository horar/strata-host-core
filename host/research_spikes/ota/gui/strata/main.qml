import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import Qt.labs.settings 1.0


ApplicationWindow {
    id: appWindow

    width: 800
    minimumWidth: 640
    height: 600
    minimumHeight: 480
    visible: true

    title: qsTr("Strata Developer Studio - update RS")

    Settings {
        id: appSettings
        //        property string style: "Default"
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent

            Label {
                id: titleLabel
                text: qsTr("main window")
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            ToolButton {
                text: qsTr("\u2699")
                onClicked: appmMenu.open()

                Menu {
                    id: appmMenu

                    MenuItem {
                        text: qsTr("Settings...")
                        onTriggered: settingsDialog.open()
                    }
                    MenuItem {
                        text: qsTr("About...")
                        onTriggered: {}//aboutDialog.open()
                    }
                }
            }
        }

    }

    Dialog {
        id: settingsDialog

        x: Math.round((appWindow.width - width) / 2)
        y: Math.round(appWindow.height / 6)
        width: Math.round(Math.min(appWindow.width, appWindow.height) / 3 * 2)
        //        width: settingsColumn.implicitWidth
        modal: true
        focus: true
        title: qsTr("Settings")

        standardButtons: Dialog.Apply | Dialog.Cancel
        onApplied: {
            updateSettings.enabled = updatesCheckBox.checked
            updateSettings.periodIndex = periodBox.currentIndex
            updateSettings.actionIndex = actionBox.currentIndex

            settingsDialog.close()
        }

        onRejected: {
            updatesCheckBox.checked = updateSettings.enabled
            periodBox.currentIndex = updateSettings.periodIndex
            actionBox.currentIndex = updateSettings.actionIndex

            settingsDialog.close()
        }

        Settings {
            id: updateSettings

            category: "updates"
            property bool enabled: true
            property int periodIndex: 0
            property int actionIndex: 0

        }

        contentItem: ColumnLayout {
            id: settingsColumn

            GroupBox {
                id: groupBox
                Layout.fillWidth: true

                label: CheckBox {
                    id: updatesCheckBox
                    checked: true
                    text: qsTr("Automatic updates check")

                    Component.onCompleted: checked = updateSettings.enabled
                }
                ColumnLayout {
                    anchors.fill: parent
                    enabled: updatesCheckBox.checked

                    ComboBox {
                        id: periodBox
                        Layout.fillWidth: true
                        model: [
                            qsTr("Hourly"),
                            qsTr("Weekly"),
                            qsTr("Monthly")
                        ]

                        Component.onCompleted: currentIndex = updateSettings.periodIndex
                    }
                    ComboBox {
                        id: actionBox
                        Layout.fillWidth: true
                        model: [
                            qsTr("Update automatically"),
                            qsTr("Notify me about updates")
                        ]

                        Component.onCompleted: currentIndex = updateSettings.actionIndex
                    }
                }
            }
        }
    }

    MainWindow {
        anchors.fill: parent
    }
}
