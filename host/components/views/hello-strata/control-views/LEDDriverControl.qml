import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

CustomControl {
    id: root
    title: qsTr("LED Driver")

    property real lightSizeValue: 25*factor
    property real comboBoxHeightValue: 25*factor
    property real comboBoxWidthValue: 58*factor
    property var buttonState: ["Off","On","B0","B1"]

    // UI state
    property int y1: platformInterface.led_driver_ui_y1
    property int y2: platformInterface.led_driver_ui_y2
    property int y3: platformInterface.led_driver_ui_y3
    property int y4: platformInterface.led_driver_ui_y4

    property int r1: platformInterface.led_driver_ui_r1
    property int r2: platformInterface.led_driver_ui_r2
    property int r3: platformInterface.led_driver_ui_r3
    property int r4: platformInterface.led_driver_ui_r4

    property int b1: platformInterface.led_driver_ui_b1
    property int b2: platformInterface.led_driver_ui_b2
    property int b3: platformInterface.led_driver_ui_b3
    property int b4: platformInterface.led_driver_ui_b4

    property int g1: platformInterface.led_driver_ui_g1
    property int g2: platformInterface.led_driver_ui_g2
    property int g3: platformInterface.led_driver_ui_g3
    property int g4: platformInterface.led_driver_ui_g4

    property real freq0: platformInterface.led_driver_ui_freq0
    property real duty0: platformInterface.led_driver_ui_duty0
    property real freq1: platformInterface.led_driver_ui_freq1
    property real duty1: platformInterface.led_driver_ui_duty1

    Component.onCompleted: {
        if (hideHeader) {
            Help.registerTarget(comboBoxGrid, "These comboBoxes change state their respective LEDs in the grid.", 0, "helloStrata_LEDDriver_Help")
            Help.registerTarget(blinkSetting, "These controls will set the Blink0 and Blink1 registers. Frequency and duty cycle can be set and hit 'enter' or 'tab' to set the register.", 1, "helloStrata_LEDDriver_Help")
            Help.registerTarget(resetbtn, "This will reset the registers in the part to its default state.", 2, "helloStrata_LEDDriver_Help")
        }
    }

    onY1Changed: comboBox1.currentIndex =y1
    onY2Changed: comboBox2.currentIndex =y2
    onY3Changed: comboBox3.currentIndex =y3
    onY4Changed: comboBox4.currentIndex =y4

    onR1Changed: comboBox5.currentIndex =r1
    onR2Changed: comboBox6.currentIndex =r2
    onR3Changed: comboBox7.currentIndex =r3
    onR4Changed: comboBox8.currentIndex =r4

    onB1Changed: comboBox9.currentIndex =b1
    onB2Changed: comboBox10.currentIndex =b2
    onB3Changed: comboBox11.currentIndex =b3
    onB4Changed: comboBox12.currentIndex =b4

    onG1Changed: comboBox13.currentIndex =g1
    onG2Changed: comboBox14.currentIndex =g2
    onG3Changed: comboBox15.currentIndex =g3
    onG4Changed: comboBox16.currentIndex =g4

    onFreq0Changed: freqbox0.text = freq0.toString()
    onDuty0Changed: dutybox0.text = duty0.toString()
    onFreq1Changed: freqbox1.text = freq1.toString()
    onDuty1Changed: dutybox1.text = duty1.toString()

    contentItem: GridLayout {
        id: content
        anchors.centerIn: parent
        rowSpacing: 10 * factor
        rows: 2
        columns: 2

        GridLayout {
            id: comboBoxGrid
            rowSpacing: 5*factor
            columnSpacing: 3*factor
            rows: 4
            columns: 4

            SGComboBox {
                id: comboBox1
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_y1 = currentIndex
                    platformInterface.set_led_driver.update(15,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox2
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_y2 = currentIndex
                    platformInterface.set_led_driver.update(14,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox3
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_y3 = currentIndex
                    platformInterface.set_led_driver.update(13,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox4
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_y4 = currentIndex
                    platformInterface.set_led_driver.update(12,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox5
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_r1 = currentIndex
                    platformInterface.set_led_driver.update(11,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox6
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_r2 = currentIndex
                    platformInterface.set_led_driver.update(10,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox7
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_r3 = currentIndex
                    platformInterface.set_led_driver.update(9,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox8
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_r4 = currentIndex
                    platformInterface.set_led_driver.update(8,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox9
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_b1 = currentIndex
                    platformInterface.set_led_driver.update(7,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox10
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_b2 = currentIndex
                    platformInterface.set_led_driver.update(6,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox11
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_b3 = currentIndex
                    platformInterface.set_led_driver.update(5,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox12
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_b4 = currentIndex
                    platformInterface.set_led_driver.update(4,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox13
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_g1 = currentIndex
                    platformInterface.set_led_driver.update(3,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox14
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_g2 = currentIndex
                    platformInterface.set_led_driver.update(2,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox15
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_g3 = currentIndex
                    platformInterface.set_led_driver.update(1,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox16
                Layout.preferredHeight: comboBoxHeightValue
                Layout.preferredWidth: comboBoxWidthValue
                fontSizeMultiplier: factor
                model: buttonState
                onActivated: {
                    platformInterface.led_driver_ui_g4 = currentIndex
                    platformInterface.set_led_driver.update(0,currentIndex)
                }
            }
        }

        GridLayout {
            id: ledGrid
            rowSpacing: 5*factor
            columnSpacing: 3*factor
            rows: 4
            columns: 4

            SGStatusLight {
                id: light1
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox1.currentIndex !== 0 ? SGStatusLight.Yellow : SGStatusLight.Off
            }

            SGStatusLight {
                id: light2
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox2.currentIndex !== 0 ? SGStatusLight.Yellow : SGStatusLight.Off
            }

            SGStatusLight {
                id: light3
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox3.currentIndex !== 0 ? SGStatusLight.Yellow : SGStatusLight.Off
            }

            SGStatusLight {
                id: light4
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox4.currentIndex !== 0 ? SGStatusLight.Yellow : SGStatusLight.Off
            }

            SGStatusLight {
                id: light5
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox5.currentIndex !== 0 ? SGStatusLight.Red : SGStatusLight.Off
            }

            SGStatusLight {
                id: light6
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox6.currentIndex !== 0 ? SGStatusLight.Red : SGStatusLight.Off
            }

            SGStatusLight {
                id: light7
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox7.currentIndex !== 0 ? SGStatusLight.Red : SGStatusLight.Off
            }

            SGStatusLight {
                id: light8
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox8.currentIndex !== 0 ? SGStatusLight.Red : SGStatusLight.Off
            }

            SGStatusLight {
                id: light9
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox9.currentIndex !== 0 ? SGStatusLight.Blue : SGStatusLight.Off
            }

            SGStatusLight {
                id: light10
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox10.currentIndex !== 0 ? SGStatusLight.Blue : SGStatusLight.Off
            }

            SGStatusLight {
                id: light11
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox11.currentIndex !== 0 ? SGStatusLight.Blue : SGStatusLight.Off
            }

            SGStatusLight {
                id: light12
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox12.currentIndex !== 0 ? SGStatusLight.Blue : SGStatusLight.Off
            }

            SGStatusLight {
                id: light13
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox13.currentIndex !== 0 ? SGStatusLight.Green : SGStatusLight.Off
            }

            SGStatusLight {
                id: light14
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox14.currentIndex !== 0 ? SGStatusLight.Green : SGStatusLight.Off
            }

            SGStatusLight {
                id: light15
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox15.currentIndex !== 0 ? SGStatusLight.Green : SGStatusLight.Off
            }

            SGStatusLight {
                id: light16
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox16.currentIndex !== 0 ? SGStatusLight.Green : SGStatusLight.Off
            }
        }

        GridLayout {
            id: blinkSetting
            Layout.alignment: Qt.AlignLeft
            columns: 3
            rows: 2
            columnSpacing: 7 * factor
            rowSpacing: 5 * factor
            Text {
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 5 * factor
                text: "<b>" + qsTr("Blink 0 (B0)") + "</b>"
                font.pixelSize: 12 * factor
            }

            SGAlignedLabel {
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                target: freqbox0
                text: "<b>" + qsTr("Frequency") + "</b>"
                fontSizeMultiplier: factor
                SGInfoBox {
                    id: freqbox0
                    readOnly: false
                    textColor: "black"
                    height: 30 * factor
                    width: 90 * factor
                    unit: "Hz"
                    placeholderText: "1 - 152"
                    validator: DoubleValidator {
                        bottom: 1
                        top: 152
                    }
                    fontSizeMultiplier: factor
                    onEditingFinished: {
                        if (acceptableInput) {
                            platformInterface.led_driver_ui_freq0 = Number(text)
                            platformInterface.set_led_driver_freq0.update(Number(text))
                        }
                    }
                    KeyNavigation.tab: root
                }
            }
            SGAlignedLabel {
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                target: dutybox0
                text: "<b>" + "PWM" + "</b>"
                fontSizeMultiplier: factor
                SGInfoBox {
                    id:dutybox0
                    readOnly: false
                    textColor: "black"
                    height: 30 * factor
                    width: 80 * factor
                    unit: "%"
                    placeholderText: "0 - 100"
                    validator: DoubleValidator {
                        bottom: 0
                        top: 100
                    }
                    fontSizeMultiplier: factor
                    onEditingFinished: {
                        if (acceptableInput) {
                            platformInterface.led_driver_ui_duty0 = Number(text)
                            platformInterface.set_led_driver_duty0.update(Number(text)/100)
                        }
                    }
                    KeyNavigation.tab: root
                }
            }

            Text {
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 5 * factor
                text: "<b>" + qsTr("Blink 1 (B1)") + "</b>"
                font.pixelSize: 12 * factor
            }

            SGAlignedLabel {
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                target: freqbox1
                text: "<b>" + qsTr("Frequency") + "</b>"
                fontSizeMultiplier: factor
                SGInfoBox {
                    id: freqbox1
                    readOnly: false
                    textColor: "black"
                    height: 30 * factor
                    width: 90 * factor
                    unit: "Hz"
                    placeholderText: "1 - 152"
                    validator: DoubleValidator {
                        bottom: 1
                        top: 152
                    }
                    fontSizeMultiplier: factor
                    onEditingFinished: {
                        if (acceptableInput) {
                            platformInterface.led_driver_ui_freq1 = Number(text)
                            platformInterface.set_led_driver_freq1.update(Number(text))
                        }
                    }
                    KeyNavigation.tab: root
                }
            }
            SGAlignedLabel {
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                target: dutybox1
                text: "<b>" + "PWM" + "</b>"
                fontSizeMultiplier: factor
                SGInfoBox {
                    id:dutybox1
                    readOnly: false
                    textColor: "black"
                    height: 30 * factor
                    width: 80 * factor
                    unit: "%"
                    placeholderText: "0 - 100"
                    validator: DoubleValidator {
                        bottom: 0
                        top: 100
                    }
                    fontSizeMultiplier: factor
                    onEditingFinished: {
                        if (acceptableInput) {
                            platformInterface.led_driver_ui_duty1 = Number(text)
                            platformInterface.set_led_driver_duty1.update(Number(text)/100)
                        }
                    }
                    KeyNavigation.tab: root
                }
            }

        }

        Button {
            id: resetbtn
            Layout.preferredHeight: 30 * factor
            Layout.preferredWidth: 80 * factor
            Layout.alignment: Qt.AlignCenter
            font.pixelSize: 12*factor
            text: qsTr("Reset")
            width: 75
            onClicked: platformInterface.clear_led_driver.update()
        }
    }
}
