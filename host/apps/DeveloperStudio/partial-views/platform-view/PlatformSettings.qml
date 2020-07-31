import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12 // todo remove

import tech.strata.sgwidgets 1.0
import "PlatformSettings"
import "../status-bar"

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

        // Todo: to be implemented in CS-831, CS-832
//        SoftwareManagement { }

        FirmwareManagement { }

        // Todo: determine notification UX, to be implemented in CS-880 - re-use warningPop?
//        CheckBox {
//            id: reminderCheck
//            text: "Notify me when newer versions of firmware or controls are available"
//        }

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
