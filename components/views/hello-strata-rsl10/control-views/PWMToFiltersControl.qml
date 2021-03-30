import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import "qrc:/js/help_layout_manager.js" as Help

CustomControl {
    id: root
    title: qsTr("Filtered PWM To LED Current")

    // UI state & notification
    property real duty: platformInterface.pwm_fil_ui_duty

    Component.onCompleted: {
        if (!hideHeader) {
            Help.registerTarget(root, "Each box represents the box on the silkscreen.", 2, "helloStrataHelp")
        }
        else{
            Help.registerTarget(sgsliderLabel, "This slider will set the duty cycle of the PWM signal going to the filter.", 0, "helloStrata_PWMToFilters_Help")
            Help.registerTarget(rcswLabel, "This switch will switch the units on the gauge between volts and bits of the CS_FILT_ADC pin ADC reading.", 1, "helloStrata_PWMToFilters_Help")
            Help.registerTarget(rcVoltsBitsGauge, "This gauge will read voltage of CS_FILT_ADC pin in volts.", 2, "helloStrata_PWMToFilters_Help")
            Help.registerTarget(currentmAGauge, "This gauge will read output of current amplifier at CS_ADC pin in mA. ", 3, "helloStrata_PWMToFilters_Help")
        }
    }

    onDutyChanged: {
        sgslider.value = duty
    }

    property var rc_out_volts: platformInterface.filter.volts
    onRc_out_voltsChanged: {
        rcVoltsGauge.value = rc_out_volts
    }

    property var rc_out_bits: platformInterface.filter.bits
    onRc_out_bitsChanged: {
        rcBitsGauge.value = rc_out_bits
    }

    property var rc_out_miliamps: platformInterface.filter.miliamps
    onRc_out_miliampsChanged: {
        currentmAGauge.value = rc_out_miliamps
    }

    property string pwm_filter_switch: platformInterface.pwm_filter_mode
    onPwm_filter_switchChanged: {
        if(pwm_filter_switch != "") {
            if(pwm_filter_switch ===  "on") {
                rcsw.checked = true
            }
            else {
                rcsw.checked = false
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
            Layout.fillHeight: true
            Layout.fillWidth: true
            SGAlignedLabel {
                id: sgsliderLabel
                Layout.columnSpan: 2
                target: sgslider
                text:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
                fontSizeMultiplier: factor
                CustomSlider {
                    id: sgslider
                    width: (content.parent.maximumWidth - 5 * factor) * 0.5
                    textColor: "black"
                    stepSize: 1
                    from: 0
                    to: 100
                    live: false
                    fromText.text: "0 %"
                    toText.text: "100 %"
                    inputBox.validator: IntValidator { top: 100; bottom: 0 }
                    fontSizeMultiplier: factor
                    onUserSet: {
                        platformInterface.pwm_fil_ui_duty = value
                        platformInterface.pwm_fil_set_duty_freq.update(value/100,10)
                    }
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
                    checkedLabel: "Bits"
                    uncheckedLabel: "Volts"
                    onToggled: {
                        if(checked)
                            platformInterface.pwm_filter_mode = "on"
                        else platformInterface.pwm_filter_mode = "off"
                    }
                }
            }
        }


        ColumnLayout {
            id: rcGauge
            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle{
                id: rcVoltsBitsGauge
                Layout.fillHeight: true
                Layout.fillWidth: true
                //color: "red"
                SGCircularGauge {
                    id: rcVoltsGauge
                    anchors.fill: parent
                    visible: !rcsw.checked
                    unitText: "V"
                    unitTextFontSizeMultiplier: factor  + 2
                    value: 1
                    tickmarkStepSize: 0.2
                    tickmarkDecimalPlaces: 2
                    minimumValue: 0
                    maximumValue: 2
                }
                SGCircularGauge {
                    id: rcBitsGauge
                    anchors.fill: parent
                    visible: rcsw.checked
                    unitText: "Bits"
                    unitTextFontSizeMultiplier: factor + 2
                    value: 0
                    tickmarkStepSize: 512
                    minimumValue: 0
                    maximumValue: 4096
                }
            }

            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true
                // color: "green"

                SGCircularGauge {
                    id: currentmAGauge
                    anchors.fill: parent
                    unitText: "mA"
                    unitTextFontSizeMultiplier: factor  + 2
                    value: 7
                    tickmarkStepSize: 4
                    tickmarkDecimalPlaces: 1
                    minimumValue: 0
                    maximumValue: 20
                }
            }

        }
    }
}
