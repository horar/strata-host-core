import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import "platform-settings"
import "../"
import "qrc:/js/navigation_control.js" as NavigationControl

Rectangle {
    id: platformSettings
    color: "#ddd"
    anchors {
        fill: parent
    }

    ColumnLayout {
        id: mainColumn
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 30

        SoftwareManagement {
            id: softwareManagement
        }

        FirmwareManagement {
            id: firmwareManagement
        }

        SGCheckBox {
            id: notifyCheck
            text: "Notify me when newer versions of firmware or control views are available"
            Layout.alignment: Qt.AlignLeft
            leftPadding: 0
            checked: NavigationControl.userSettings.notifyOnFirmwareUpdate

            onCheckedChanged: {
                NavigationControl.userSettings.notifyOnFirmwareUpdate = notifyCheck.checked
                NavigationControl.userSettings.saveSettings()
            }
        }

        Item {
            // fills extra space
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    SGConfirmationPopup {
        id: warningPop
        cancelButtonText: "Cancel"
        acceptButtonText: "OK"
        titleText: "Warning"
        popupText: "Older firmware versions may be incompatible with the<br>installed software version. Are you sure you want to continue?"

        property Item callback: null

        onPopupClosed: {
            if (closeReason === warningPop.acceptCloseReason) {
                warningPop.callback.callback()
            }
        }
    }
}
