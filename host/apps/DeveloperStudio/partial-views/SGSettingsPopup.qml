import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
SGStrataPopup {
    id: root
    modal: true
    visible: false
    headerText: "General Settings"
    closePolicy: Popup.CloseOnEscape
    focus: true
    horizontalPadding: 20
    bottomPadding: 20

    height: parent.height/2
    width: parent.width/2
    x: parent.width/2 - root.width/2
    y: parent.height/2 - root.height/2

    onClosed: {
        const settings = {
            autoOpenView: autoOpen.checked,
            switchToActive: switchTo.checked,
            notifyOnFirmwareUpdate: firmwareUpdates.checked,
            index: NavigationControl.userSettings.index
        }
        NavigationControl.userSettings.writeFile("settings.json", settings)
        NavigationControl.userSettings.autoOpenView = settings.autoOpenView
        NavigationControl.userSettings.switchToActive = settings.switchToActive
        NavigationControl.userSettings.notifyOnFirmwareUpdate = settings.notifyOnFirmwareUpdate
        NavigationControl.userSettings.index = settings.index
    }

    ColumnLayout {
        id: column
        ColumnLayout {
            Layout.alignment: Qt.AlignLeft
            SGText {
                text: "Platform View Settings"
                fontSizeMultiplier: 1.3
            }
            SGCheckBox{
                id: autoOpen
                text: "open platform view automatically"
                checked: NavigationControl.userSettings.autoOpenView
                leftPadding: 0
            }
            SGCheckBox {
                id: switchTo
                text: "Switch to active tab"
                checked: NavigationControl.userSettings.switchToActive
                leftPadding: 0


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
                checked: NavigationControl.userSettings.notifyOnFirmwareUpdate
                leftPadding: 0
            }
            SGCheckBox {
                text: "Preload firmware versions"
                leftPadding: 0
                enabled: false
            }
        }
    }
}
