import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "qrc:/partial-views"
import "qrc:/js/navigation_control.js" as NavigationControl
import "../"
import "../status-bar/"
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

SGStrataPopup {
    id: platformPopup
    width: 450
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    headerText: "Update Available"
    modal: true
    padding: 0

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    onClosed: {
        NavigationControl.userSettings.notifyOnFirmwareUpdate = !checkBox.checked
        NavigationControl.userSettings.saveSettings()
    }

    ColumnLayout {
        width: parent.width
        spacing: 15

        SGText {
            Layout.topMargin: 15
            Layout.alignment: Qt.AlignHCenter
            fontSizeMultiplier: 1.15
            wrapMode: Text.Wrap
            text: {
                if (firmwareIsOutOfDate && controlViewIsOutOfDate) return "Newer versions of firmware and software are available for this plaform."
                else if (firmwareIsOutOfDate) return "A newer version of firmware is available for this plaform."
                else return "A newer version of software is available for this plaform."
            }
        }

        SGText {
            Layout.alignment: Qt.AlignHCenter
            fontSizeMultiplier: 1.15
            text: "Open settings to review?"
        }

        RowLayout {
            Layout.alignment: Qt.AlignCenter

            Button {
                text: "Yes"
                onClicked: {
                    platformPopup.close()
                    openSettings()
                }
            }

            Button {
                text: "No"
                onClicked: {
                    platformPopup.close()
                }
            }
        }

        SGCheckBox {
            id: checkBox
            Layout.bottomMargin: 15
            Layout.alignment: Qt.AlignCenter
            checked: false
            text: "Do not remind me"
        }
    }
}
