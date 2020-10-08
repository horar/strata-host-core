import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import "PlatformSettings"
import "../"
import "qrc:/js/navigation_control.js" as NavigationControl

Rectangle {
    id: platformSettings
    color: "#ddd"
    anchors {
        fill: parent
    }

    onDestroyed:{
        NavigationControl.userSettings.notifyOnFirmwareUpdate = notifyCheck.checked
        NavigationControl.userSettings.writeFile("settings.json");
    }

    property alias softwareManagement: softwareManagement

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

        // Todo: determine notification UX, to be implemented in CS-880 - re-use warningPop?
//        CheckBox {
//            id: reminderCheck
//            text: "Notify me when newer versions of firmware or controls are available"
//        }

        SGCheckBox {
            id: notifyCheck
            text: "Notify on firmware updates"
            checked: NavigationControl.userSettings.notifyOnFirmwareUpdate
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

        Connections {
            target: warningPop.acceptButton
            onClicked: {
                warningPop.callback.callback()
                warningPop.close()
            }
        }
    }
}
