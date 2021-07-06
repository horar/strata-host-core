import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import "qrc:/partial-views/"
import "qrc:/partial-views/general/"

SGStrataPopup { // @disable-check M300 // Ignore false positive (M311) QtCreator warning
    id: root
    modal: true
    visible: true
    headerText: "Control View Creator Settings"
    closePolicy: Popup.CloseOnEscape
    focus: true
    width: 400
    anchors.centerIn: Overlay.overlay

    onClosed: {
        parent.active = false
    }

    contentItem: ColumnLayout {
        id: column
        width: parent.width - 40

        SGText {
            text: "Build Settings"
            fontSizeMultiplier: 1.3
        }

        Rectangle {
            // divider
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#666"
        }

        SGSettingsCheckbox { // @disable-check M300 // Ignore false positive (M311) QtCreator warning
            text: "Switch to \"View\" mode after running build"
            checked: cvcUserSettings.openViewOnBuild

            onCheckedChanged: {
                cvcUserSettings.openViewOnBuild = checked
                cvcUserSettings.saveSettings()
            }
        }

        SGSettingsCheckbox { // @disable-check M300 // Ignore false positive (M311) QtCreator warning
            text: "Refresh Visual Editor when external file changes are detected"
            checked: cvcUserSettings.reloadViewExternalChanges

            onCheckedChanged: {
                cvcUserSettings.reloadViewExternalChanges = checked
                cvcUserSettings.saveSettings()
            }
        }
    }
}
