import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "qrc:/partial-views"
import "qrc:/js/navigation_control.js" as NavigationControl
import "./"
import "../status-bar/"
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

SGStrataPopup {
    id: platformPopup
    width: 450
    height: 200
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    headerText: "Platform Notification"
    modal: true
    padding: 0

    glowColor: "#ccc"

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent


    onClosed: {
        NavigationControl.userSettings.notifyOnFirmwareUpdate = !checkBox.checked
        NavigationControl.userSettings.saveSettings()
    }

    DropShadow {
        width: platformPopup.width
        height: platformPopup.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: 30
        color: "#cc000000"
        source: platformPopup.background
        z: -1
        cached: true
    }

    Rectangle {
        id:platformItem
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            spacing: 5
            SGText {
                Layout.alignment: Qt.AlignHCenter
                fontSizeMultiplier: 1.15
                leftPadding: 5
                rightPadding: 5

                    text: {
                        if(firmwareIsOutOfDate && platformIsOutOfDate) return "Both the firmware and software for this platform are out of date."
                        else if(firmwareIsOutOfDate) return "The firmware for this platform is out of date."
                        else return "The software for this platform is out of date."
                    }
            }

            SGText {
                Layout.alignment: Qt.AlignHCenter
                fontSizeMultiplier: 1.15
                leftPadding: 5
                rightPadding: 5
                text: "Do you wish to update?"
            }

            RowLayout {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.fillHeight: true

                SGButton {
                    text: "Yes"
                    Layout.fillWidth: true
                    leftInset: 5
                    roundedBottom: true
                    roundedLeft: true
                    roundedRight: true
                    roundedTop: true
                    onClicked: {
                       platformPopup.close()
                       navigateToPlatform()
                    }
                }

                SGButton {
                    text: "No"
                    rightInset: 5
                    roundedBottom: true
                    roundedLeft: true
                    roundedRight: true
                    roundedTop: true
                    Layout.fillWidth: true
                    onClicked: {
                        platformPopup.close()
                    }
                }
            }

            SGCheckBox {
                id: checkBox
                Layout.alignment: Qt.AlignLeft
                checked: false
                text: "Do not remind me"
                topPadding: -10
            }
        }
    }
}
