import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

CustomControl {
    id: root
    title: qsTr("DAC to LED and PWM to LED")

    property alias dacSliderLabel: dacSliderLabel


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
            Help.registerTarget(freqBoxLabel, "The entry box sets the frequency. Hit 'enter' or 'tab' to set the register.", 2, "helloStrata_DACPWMToLED_Help")
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

    property bool mux_high_state: platformInterface.mux_high
    onMux_high_stateChanged: {
        if(mux_high_state === true) {
            muxPopUp.visible = true
        }
        else muxPopUp.visible = false
    }

    property bool pwm_LED_filter: platformInterface.pwm_LED_filter
    onPwm_LED_filterChanged: {
        if(pwm_LED_filter === false) {
            muxPopUp.visible = false
        }

    }




    Rectangle {
        id: muxPopUp
        anchors{


            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: 32
            // top: root.dacSliderLabel.bottom

        }
        width: parent.width- 20
        height: (pwmSliderLabel.height + freqBoxLabel.height) + 60
        color: "#a9a9a9"
        opacity: 0.8
        visible: false
        z: 3

        MouseArea{
            anchors.fill: muxPopUp
            onClicked: {
                muxPopUp.visible = false
                platformInterface.mux_high = false
                platformInterface.mux_low = true

                platformInterface.pwm_LED_filter = false
                platformInterface.select_demux.update("pwm_led_filter")
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
                font.pointSize: 45
                text:  qsTr("Click To Enable")
                color: "white"
            }
        }
    }


    contentItem: ColumnLayout {
        id: content

        anchors.centerIn: parent
        spacing: 10 * factor

        SGAlignedLabel {
            id: dacSliderLabel
            target: dacSlider
            text:"<b>DAC Output (V)</b>"
            fontSizeMultiplier: factor
            Layout.topMargin: -40


            SGSlider {
                id: dacSlider
                width: content.parent.width
                inputBoxWidth: 40 * factor

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
        SGAlignedLabel {

            id: pwmSliderLabel
            Layout.topMargin: 25
            target: pwmSlider
            text:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
            fontSizeMultiplier: factor
            SGSlider {
                id: pwmSlider
                width: content.parent.width
                inputBoxWidth: 40 * factor

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

        SGAlignedLabel {
            id: freqBoxLabel
            target: freqBox
            text: "<b>" + qsTr("PWM Frequency") + "</b>"
            fontSizeMultiplier: factor
            Layout.topMargin: 10
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
