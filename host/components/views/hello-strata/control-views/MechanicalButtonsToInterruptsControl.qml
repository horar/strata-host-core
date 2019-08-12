import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

CustomControl {
    id: root
    title: qsTr("Mechanical Buttons to Interrupts")

    property real lightSizeValue: 25*factor

    // notification
    property var sw1: platformInterface.mechanical_buttons_noti_sw1
    property var sw2: platformInterface.mechanical_buttons_noti_sw2
    property var sw3: platformInterface.mechanical_buttons_noti_sw3
    property var sw4: platformInterface.mechanical_buttons_noti_sw4

    Component.onCompleted: {
        if (hideHeader) {
            Help.registerTarget(buttons, "The status of the buttons on the board will show here. GUI interrupt indicators for SW1 and SW2 are off when applicable button is pressed on PCB while SW3 and SW4 are on.", 0, "helloStrata_ButtonsInterrupts_Help")
        }
    }

    onSw1Changed: {
        led1.status = sw1.value ? SGStatusLight.Green : SGStatusLight.Off
    }

    onSw2Changed: {
        led2.status = sw2.value ? SGStatusLight.Green : SGStatusLight.Off
    }

    onSw3Changed: {
        led3.status = sw3.value ? SGStatusLight.Green : SGStatusLight.Off
    }

    onSw4Changed: {
        led4.status = sw4.value ? SGStatusLight.Green : SGStatusLight.Off
    }

    contentItem: ColumnLayout {
        id: content
        anchors.centerIn: parent
        spacing: defaultMargin * factor
        RowLayout {
            id: buttons
            Layout.alignment: Qt.AlignHCenter
            spacing: defaultMargin * factor
            SGAlignedLabel {
                target: led1
                text: "<b>" + qsTr("SW1") + "</b>"
                fontSizeMultiplier: factor
                alignment: SGAlignedLabel.SideTopCenter
                SGStatusLight {
                    id: led1
                    width: lightSizeValue * factor
                }
            }
            SGAlignedLabel {
                target: led2
                text: "<b>" + qsTr("SW2") + "</b>"
                fontSizeMultiplier: factor
                alignment: SGAlignedLabel.SideTopCenter
                SGStatusLight {
                    id: led2
                    width: lightSizeValue * factor
                }
            }
            SGAlignedLabel {
                target: led3
                text: "<b>" + qsTr("SW3") + "</b>"
                fontSizeMultiplier: factor
                alignment: SGAlignedLabel.SideTopCenter
                SGStatusLight {
                    id: led3
                    width: lightSizeValue * factor
                }
            }
            SGAlignedLabel {
                target: led4
                text: "<b>" + qsTr("SW4") + "</b>"
                fontSizeMultiplier: factor
                alignment: SGAlignedLabel.SideTopCenter
                SGStatusLight {
                    id: led4
                    width: lightSizeValue * factor
                }
            }
        }
        Image {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: (lightSizeValue * 4 + defaultMargin * 3) * factor
            Layout.maximumHeight: (lightSizeValue + 12) * factor
            fillMode: Image.PreserveAspectFit
            source: "Images/helpImage_interrupt.png"
        }
    }
}
