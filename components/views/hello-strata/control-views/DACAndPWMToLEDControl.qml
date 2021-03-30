import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

CustomControl {
    id: root
    title: qsTr("DAC to LED and PWM to LED")
    // UI state
    property real freq: platformInterface.pwm_led_ui_freq
    property real duty: platformInterface.pwm_led_ui_duty
    property real volt: platformInterface.dac_led_ui_volt

    Component.onCompleted: {
        if (!hideHeader) {
            Help.registerTarget(root, "Each box represents the box on the silkscreen.\nExcept the \"DAC to LED\" and \"PWM to LED\" are combined.", 2, "helloStrataHelp")
        }
        else {
            Help.registerTarget(dacSliderLabel, "This will set the DAC output voltage to the LED. 2V is the maximum output.", 0, "helloStrata_DACPWMToLED_Help")
            Help.registerTarget(pwmSliderLabel, "This slider will set the duty cycle of the PWM signal going to the LED.", 1, "helloStrata_DACPWMToLED_Help")
            Help.registerTarget(freqBoxLabel, "The entry box sets the frequency. Click 'Enter' or 'Tab' to set the frequency.", 2, "helloStrata_DACPWMToLED_Help")
        }
    }

    onFreqChanged: {
        freqBox.text = freq.toString()
    }

    onDutyChanged: {
        pwmSlider.value = duty
    }

    onVoltChanged: {
        dacSlider.value = volt
    }

    property bool mux_high_state: platformInterface.dac_pwm
    onMux_high_stateChanged: {
        if(mux_high_state === true) {
            muxPopUp.visible = true
        }
        else muxPopUp.visible = false
    }

    contentItem:
        Rectangle{
        width: parent.width
        height: parent.height/1.6
        anchors.centerIn: parent
        Rectangle{
            id: dacSliderContainer
            width: parent.width
            height: parent.height/4
            color: "transparent"
            SGAlignedLabel {
                id: dacSliderLabel
                target: dacSlider
                text:"<b>DAC Output (V)</b>"
                fontSizeMultiplier: factor
                anchors.verticalCenter: parent.verticalCenter
                SGSlider {
                    id: dacSlider
                    width: (dacSliderContainer.width - inputBoxWidth)
                    inputBoxWidth: factor * 40
                    stepSize: 0.001
                    from: 0
                    to: 2
                    startLabel: "0"
                    endLabel: "2 V"
                    fontSizeMultiplier: factor

                    onUserSet: {
                        platformInterface.dac_led_ui_volt = value
                        platformInterface.dac_led_set_voltage.update(value)
                    }
                }
            }
        }

        Rectangle{
            width: parent.width
            height: parent.height/1.3
            anchors{
                top: dacSliderContainer.bottom
                topMargin: 10

            }
            color: "transparent"
            Rectangle {
                id: muxPopUp
                anchors.centerIn: parent.Center
                anchors.fill:parent
                color: "#a9a9a9"
                opacity: 0.8
                visible: false
                z: 3

                MouseArea{
                    anchors.fill: muxPopUp
                    onClicked: {
                        platformInterface.pwm_LED_filter = true
                        platformInterface.pwm_motor = true
                        platformInterface.dac_pwm = false
                        platformInterface.select_demux.update("led")
                    }
                }

                Rectangle {
                    width: myText.contentWidth
                    height: myText.contentHeight
                    z: 4
                    anchors.centerIn: parent
                    color: "transparent"

                    Text {
                        id: myText
                        z:5
                        anchors.fill:parent
                        font.family: "Helvetica"
                        font.pixelSize: {
                            console.log("p",muxPopUp.width)
                            if(muxPopUp.width < 420)
                                return muxPopUp.width/8
                            else return muxPopUp.width/17

                        }
                        text:  qsTr("Click to Enable")
                        color: "white"
                    }
                }
            }

            ColumnLayout{
                anchors.fill:parent
                Rectangle {
                    id: pwmSliderContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    color: "transparent"
                    SGAlignedLabel {
                        id: pwmSliderLabel
                        target: pwmSlider
                        text:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
                        fontSizeMultiplier: factor
                        anchors.verticalCenter: parent.verticalCenter

                        SGSlider {
                            id: pwmSlider
                            width: pwmSliderContainer.width - inputBoxWidth
                            inputBoxWidth: factor * 40
                            stepSize: 1
                            from: 0
                            to: 100
                            startLabel: "0"
                            endLabel: "100 %"
                            fontSizeMultiplier: factor

                            onUserSet: {
                                platformInterface.pwm_led_ui_duty = value
                                platformInterface.set_pwm_led.update(pwmSlider.value/100,freqBox.text)
                            }
                        }
                    }
                }


                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    Layout.alignment: Qt.AlignHCenter
                    SGAlignedLabel {
                        id: freqBoxLabel
                        target: freqBox
                        text: "<b>" + qsTr("PWM Frequency") + "</b>"
                        fontSizeMultiplier: factor
                        anchors.verticalCenter: parent.verticalCenter

                        SGInfoBox {
                            id: freqBox
                            height: 30 * factor
                            width: 130 * factor

                            readOnly: false
                            text: root.freq.toString()
                            unit: "kHz"
                            placeholderText: "0.001 - 1000"
                            fontSizeMultiplier: factor

                            validator: DoubleValidator {
                                bottom: 0.001
                                top: 1000
                            }

                            onEditingFinished: {
                                if (acceptableInput) {
                                    platformInterface.pwm_led_ui_freq = Number(text)
                                    platformInterface.set_pwm_led.update((pwmSlider.value)/100,Number(text))
                                }
                            }

                            KeyNavigation.tab: root
                        }
                    }
                }
            }
        }
    }
}
