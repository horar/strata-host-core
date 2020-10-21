import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.sgwidgets 1.0

CustomControl {
    id: root
    title: qsTr("I2C LED Driver")

    property real lightSizeValue: 25*factor
    property real comboBoxHeightValue: 25*factor
    property real comboBoxWidthValue: 55*factor
    property var buttonState: ["Off","On","B0"]

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
            Help.registerTarget(comboBoxGrid, "These comboboxes change the state of the respective LEDs in the grid.", 0, "helloStrata_LEDDriver_Help")
            Help.registerTarget(blinkSetting, "These controls will set the Blink0 register. Frequency and duty cycle can be set. Click 'Enter' or 'Tab' to set the register. The valid frequency range is from 1 to 152Hz and the value is coerced based on the CAT9532’s frequency prescaler.", 1, "helloStrata_LEDDriver_Help")
            Help.registerTarget(resetbtn, "This will reset the registers in the part to its default state. The GPIO that control the PWM Motor Control circuit will be reset but reconfigured to enable motor after reset.", 2, "helloStrata_LEDDriver_Help")
        }
    }

    onY1Changed: comboBox1.currentIndex =y1
    onY2Changed: comboBox2.currentIndex =y2
    onY3Changed: comboBox3.currentIndex =y3
    onY4Changed: comboBox4.currentIndex =y4

    onB1Changed: comboBox5.currentIndex =b1
    onB2Changed: comboBox6.currentIndex =b2
    onB3Changed: comboBox7.currentIndex =b3
    onB4Changed: comboBox8.currentIndex =b4

    onG1Changed: comboBox9.currentIndex =g1
    onG2Changed: comboBox10.currentIndex =g2
    onG3Changed: comboBox11.currentIndex =g3
    onG4Changed: comboBox12.currentIndex =g4

    onFreq0Changed: freqbox0.text = freq0.toString()
    onDuty0Changed: dutybox0.text = duty0.toString()

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
                    platformInterface.set_led_driver.update(11,currentIndex)
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
                    platformInterface.set_led_driver.update(10,currentIndex)
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
                    platformInterface.set_led_driver.update(9,currentIndex)
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
                    platformInterface.set_led_driver.update(8,currentIndex)
                }
            }

            SGComboBox {
                id: comboBox5
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
                id: comboBox6
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
                id: comboBox7
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
                id: comboBox8
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
                id: comboBox9
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
                id: comboBox10
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
                id: comboBox11
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
                id: comboBox12
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
                status: comboBox5.currentIndex !== 0 ? SGStatusLight.Blue : SGStatusLight.Off
            }

            SGStatusLight {
                id: light6
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox6.currentIndex !== 0 ? SGStatusLight.Blue : SGStatusLight.Off
            }

            SGStatusLight {
                id: light7
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox7.currentIndex !== 0 ? SGStatusLight.Blue : SGStatusLight.Off
            }

            SGStatusLight {
                id: light8
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox8.currentIndex !== 0 ? SGStatusLight.Blue : SGStatusLight.Off
            }

            SGStatusLight {
                id: light9
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox9.currentIndex !== 0 ? SGStatusLight.Green : SGStatusLight.Off
            }

            SGStatusLight {
                id: light10
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox10.currentIndex !== 0 ? SGStatusLight.Green : SGStatusLight.Off
            }

            SGStatusLight {
                id: light11
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox11.currentIndex !== 0 ? SGStatusLight.Green : SGStatusLight.Off
            }

            SGStatusLight {
                id: light12
                Layout.preferredHeight: lightSizeValue
                Layout.preferredWidth: lightSizeValue
                status: comboBox12.currentIndex !== 0 ? SGStatusLight.Green : SGStatusLight.Off
            }
        }

        GridLayout {
            id: blinkSetting
            Layout.alignment: Qt.AlignLeft

            columns: 3
            rows: 2
            columnSpacing: 5 * factor
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
                SGSubmitInfoBox {
                    id: freqbox0
                    height: 30 * factor
                    width: 80 * factor
                    textColor: "black"
                    unit: "Hz"
                    placeholderText: "1-152"
                    fontSizeMultiplier: factor

                    validator: DoubleValidator {
                        bottom: 1
                        top: 152
                    }

                    property var theLastValueIs: 0
                    onEditingFinished: {
                        if (theLastValueIs !== text) {
                            platformInterface.led_driver_ui_freq0 = Number(text)
                            platformInterface.set_led_driver_freq0.update(Number(text))
                            theLastValueIs = text
                        }
                    }

                    KeyNavigation.tab: root
                }
            }
            SGAlignedLabel {
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                target: dutybox0
                text: "<b>" + "Duty Cycle" + "</b>"
                fontSizeMultiplier: factor
                SGSubmitInfoBox {
                    id:dutybox0
                    height: 30 * factor
                    width: 75 * factor
                    textColor: "black"
                    unit: "%"
                    placeholderText: "0-99.6"
                    fontSizeMultiplier: factor
                    validator: DoubleValidator {
                        bottom: 0
                        top: 99.6
                    }

                    property var theLastValueIs: 0
                    onEditingFinished: {
                        if (theLastValueIs !== text) {
                            platformInterface.led_driver_ui_duty0 = Number(text)
                            platformInterface.set_led_driver_duty0.update(Number(text)/100)
                            theLastValueIs = text
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
            onClicked: platformInterface.clear_led_driver.update()
        }
    }
}
