import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

CustomControl {
    id: root
    title: qsTr("PWM to Filter")

    // UI state & notification
    property string rc_mode: platformInterface.pwm_fil_ui_rc_mode
    property real duty: platformInterface.pwm_fil_ui_duty
    property real freq: platformInterface.pwm_fil_ui_freq


    Component.onCompleted: {
        if (hideHeader) {
            Help.registerTarget(sgsliderLabel, "This slider will set the duty cycle of the PWM signal going to the filters.", 0, "helloStrata_PWMToFilters_Help")
            Help.registerTarget(freqboxLabel, "The entry box sets the frequency. A frequency larger than 100kHz is recommended. Hit 'enter' or 'tab' to set the register.", 1, "helloStrata_PWMToFilters_Help")
            Help.registerTarget(rcswLabel, "This switch will switch the units on the gauge between volts and bits of the ADC reading.", 2, "helloStrata_PWMToFilters_Help")
        }
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

    onRc_modeChanged: {
        rcsw.checked = rc_mode === "volts"
    }

    onDutyChanged: {
        sgslider.value = duty
    }

    onFreqChanged: {
        freqbox.text = freq.toString()
    }


    property var rc_out_volts: platformInterface.pwm_filter_analog_value.rc_out_volts
    onRc_out_voltsChanged: {
        //        if (rcsw.checked) {
        //            rcVoltsGauge.value = rc_out
        //        }
        //        else {
        //            rcBitsGauge.value = rc_out
        //        }
        rcVoltsGauge.value = rc_out_volts

    }

    property var rc_out_bits: platformInterface.pwm_filter_analog_value.rc_out_bits

    onRc_out_bitsChanged: {
        rc_out_bits.value = rc_out_bits
    }



    Rectangle {
        id: muxPopUp
        width: parent.width
        height: parent.height
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
                z:5
                id: myText
                anchors.fill:parent
                font.family: "Helvetica"
                font.pixelSize: muxPopUp.width/8
                text:  qsTr("Click To Enable")
                color: "white"
            }
        }
    }


    contentItem: RowLayout {
        id: content
        anchors.fill: parent

        spacing: 5 * factor

        GridLayout {
            rows: 2
            columns: 2
            rowSpacing: 10 * factor
            columnSpacing: 10 * factor
            SGAlignedLabel {
                id: sgsliderLabel
                Layout.columnSpan: 2

                target: sgslider
                text:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
                fontSizeMultiplier: factor
                SGSlider {
                    id: sgslider
                    width: (content.parent.maximumWidth - 5 * factor) * 0.5

                    textColor: "black"
                    stepSize: 1
                    from: 0
                    to: 100
                    startLabel: "0"
                    endLabel: "100 %"
                    fontSizeMultiplier: factor

                    onUserSet: {
                        platformInterface.pwm_fil_ui_duty = value
                        platformInterface.pwm_fil_set_duty_freq.update(value/100,root.freq)
                    }
                }
            }

            SGAlignedLabel {
                id: freqboxLabel
                target: freqbox
                text: "<b>" + qsTr("PWM Frequency") + "</b>"
                fontSizeMultiplier: factor
                SGInfoBox {
                    id: freqbox
                    height: 30 * factor
                    width: 110 * factor

                    readOnly: false
                    textColor: "black"
                    unit: "kHz"
                    text: root.freq.toString()
                    fontSizeMultiplier: factor
                    placeholderText: "100 - 1000"

                    validator: DoubleValidator {
                        bottom: 100
                        top: 1000
                    }

                    onEditingFinished: {
                        if (acceptableInput) {
                            platformInterface.pwm_fil_ui_freq = Number(text)
                            platformInterface.pwm_fil_set_duty_freq.update(root.duty/100,Number(text))
                        }
                    }

                    KeyNavigation.tab: root
                }
            }

            SGAlignedLabel {
                id: rcswLabel
                target: rcsw
                text: "<b>Volts/Bits</b>"
                fontSizeMultiplier: factor
                SGSwitch {
                    id: rcsw
                    height: 30 * factor

                    fontSizeMultiplier: factor
                    checkedLabel: "Volts"
                    uncheckedLabel: "Bits"

                    onClicked: {
                        //                        platformInterface.pwm_fil_ui_rc_mode = checked ? "volts" : "bits"
                        platformInterface.pwm_fil_set_rc_out_mode.update(checked ?  "volts": "bits" )
                    }
                }
            }
        }

        Item {
            id: rcGauge
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumHeight: 60
            Layout.minimumWidth: 60
            Layout.maximumHeight: width

            SGCircularGauge {
                id: rcVoltsGauge
                anchors.fill: parent

                visible: rcsw.checked
                unitText: "V"
                unitTextFontSizeMultiplier: factor  + 1
                value: 1
                tickmarkStepSize: 0.5
                tickmarkDecimalPlaces: 2
                minimumValue: 0
                maximumValue: 3.3
            }
            SGCircularGauge {
                id: rcBitsGauge
                anchors.fill: parent

                visible: !rcsw.checked
                unitText: "Bits"
                unitTextFontSizeMultiplier: factor + 1
                value: 0
                tickmarkStepSize: 512
                minimumValue: 0
                maximumValue: 4096



            }
        }
    }
}
