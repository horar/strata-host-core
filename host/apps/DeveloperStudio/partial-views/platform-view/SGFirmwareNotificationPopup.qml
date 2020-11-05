import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "qrc:/partial-views"
import "qrc:/js/navigation_control.js" as NavigationControl
import "./"
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0


Popup {
    id: firmwarePopup
    width: 450
    height: 200
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    modal: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    DropShadow {
        width: firmwarePopup.width
        height: firmwarePopup.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: 30
        color: "#cc000000"
        source: firmwarePopup.background
        z: -1
        cached: true
    }

    Rectangle {
        id:firmwareItem
        anchors.fill: parent
        color: "#ccc"


        ColumnLayout {
            anchors.fill: parent
            spacing: 5
            SGText {
                Layout.alignment: Qt.AlignHCenter
                fontSizeMultiplier: 1.15
                leftPadding: 5
                rightPadding: 5

                    text: {
                        if(firmwareIsOutOfDate && platformIsOutOfDate) return "Both firmware and software for this platform are out of date"
                        else if(firmwareIsOutOfDate) return "Firmware for this platform is out of date"
                        else return "Software for this platform is out of date"
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
                spacing: 20

                SGButton {
                    text: "Okay"
                    onClicked: {
                       platformStack.currentIndex = 2
                       firmwarePopup.close()
                    }
                }

                SGButton {
                    text: "Cancel"
                    onClicked: {
                        firmwarePopup.close()
                    }
                }
            }

            SGCheckBox {
                checked: false
                text: "Do not remind me"
                leftPadding: 10

                onCheckedChanged: {
                    NavigationControl.userSettings.notifyOnFirmwareUpdate = checked
                    NavigationControl.userSettings.saveSettings()
                }
            }
        }
    }
}
