import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import "../"

ColumnLayout {
    id: root
    width: parent.width

    SGText {
        text: "Build Settings"
        fontSizeMultiplier: 1.3
    }

    Rectangle {
        Layout.preferredHeight: 1
        Layout.fillWidth: true
        color: "#666"
    }

    SGControlViewCheckbox {
        id: openViewCheckbox

        text: "Open \"the View\" on build"
        checked: cvcUserSettings.openViewOnBuild

        onCheckedChanged: {
            cvcUserSettings.openViewOnBuild = checked
            cvcUserSettings.saveSettings()
        }
    }
}
