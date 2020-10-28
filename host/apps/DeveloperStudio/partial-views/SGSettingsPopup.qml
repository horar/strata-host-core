import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0

SGStrataPopup {
    id: root
    modal: true
    visible: true
    headerText: "General Settings"
    closePolicy: Popup.CloseOnEscape
    focus: true
    horizontalPadding: 20
    bottomPadding: 20
    width: 400
    height: 300
    x: container.width/2 - root.width/2
    y: container.parent.windowHeight/2 - root.height/2

    onClosed: {
        parent.active = false
    }

    contentItem:  ColumnLayout {
        id: column

        ColumnLayout {
            Layout.alignment: Qt.AlignLeft

            SGText {
                text: "Platform View Settings"
                fontSizeMultiplier: 1.3
            }

            SGCheckBox{
                id: autoOpen
                text: "Open platform view automatically"
                checked: userSettings.autoOpenView
                leftPadding: 0

                onCheckedChanged: {
                    userSettings.autoOpenView = checked
                    userSettings.saveSettings()
                }
            }

            SGCheckBox {
                id: switchTo
                text: "Switch to active tab"
                checked: userSettings.switchToActive
                leftPadding: 0

                onCheckedChanged: {
                    userSettings.switchToActive = checked
                    userSettings.saveSettings()
                }
            }
        }

        ColumnLayout{
            Layout.alignment: Qt.AlignLeft

            SGText {
                text: "Firmware Settings"
                fontSizeMultiplier: 1.3
            }

            SGCheckBox {
                id: firmwareUpdates
                text: "Notify me when firmware version updates"
                checked: userSettings.notifyOnFirmwareUpdate
                leftPadding: 0

                onCheckedChanged: {
                    userSettings.notifyOnFirmwareUpdate = checked
                    userSettings.saveSettings()
                }
            }

            SGCheckBox {
                text: "Preload firmware versions"
                leftPadding: 0
                enabled: false
            }
        }
    }
}
