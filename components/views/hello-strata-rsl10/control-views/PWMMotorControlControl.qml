import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.sgwidgets 1.0

CustomControl {
    id: root
    title: qsTr("PWM Motor Control")

    // UI state
    property real duty: platformInterface.pwm_mot_ui_duty
    property real freq: platformInterface.pwm_mot_ui_freq
    property string control: platformInterface.pwm_mot_ui_control
    property bool enable: platformInterface.pwm_mot_ui_enable

    Component.onCompleted: {
        if (hideHeader) {
            Help.registerTarget(pwmsliderLabel, "This slider will set the duty cycle of the PWM signal going to the motor to vary the speed.", 0, "helloStrata_PWMMotorControl_Help")
            Help.registerTarget(comboboxLabel, "This combobox will set the rotation direction or brake the motor.", 1, "helloStrata_PWMMotorControl_Help")
            Help.registerTarget(toggleswitchLabel, "This switch will turn the motor on and off.", 2, "helloStrata_PWMMotorControl_Help")
            Help.registerTarget(frequencyLabel, "This text box sets PWM frequency of the motor drive. The valid frequency range is from 1 to 152Hz and the value is coerced based on the CAT9532’s frequency prescaler.", 3, "helloStrata_PWMMotorControl_Help")
        }
    }

    onDutyChanged: {
        pwmslider.value = duty
    }

    onFreqChanged: {
        freqbox.text = freq.toString()
    }

    onControlChanged: {
        combobox.currentIndex = combobox.model.indexOf(control)
    }

    onEnableChanged: {
        toggleswitch.checked = enable
    }

    contentItem: ColumnLayout {
        id: content
        anchors.centerIn: parent

        spacing: 10 * factor
        SGAlignedLabel {
            id: pwmsliderLabel
            target: pwmslider
            text:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
            fontSizeMultiplier: factor
            CustomSlider {
                id: pwmslider
                width: content.parent.width
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
                    platformInterface.pwm_mot_ui_duty = value
                    if(toggleswitch.checked)
                        platformInterface.set_motor_control.update(true,combobox.currentText,value/100,parseInt(freqbox.text))
                    else
                        platformInterface.set_motor_control.update(false,combobox.currentText,value/100,parseInt(freqbox.text))
                }
            }
        }

        RowLayout {
            spacing: defaultPadding * factor
            SGAlignedLabel {
                id: comboboxLabel
                target: combobox
                text: "<b>" + qsTr("Motor Control") + "</b>"
                fontSizeMultiplier: factor
                SGComboBox {
                    id: combobox
                    height: 30 * factor
                    model: [qsTr("Forward"), qsTr("Brake"), qsTr("Reverse")]
                    fontSizeMultiplier: factor
                    onActivated: {
                        platformInterface.pwm_mot_ui_control = model[index]
                        if(toggleswitch.checked)
                            platformInterface.set_motor_control.update(true,model[index],pwmslider.value/100,parseInt(freqbox.text))
                        else
                            platformInterface.set_motor_control.update(false,model[index],pwmslider.value/100,parseInt(freqbox.text))
                    }
                    KeyNavigation.tab: freqbox
                }
            }

            SGAlignedLabel {
                id: toggleswitchLabel
                target: toggleswitch
                text: "<b>" + qsTr("Motor Enable") + "</b>"
                fontSizeMultiplier: factor
                SGSwitch {
                    id: toggleswitch
                    height: 30 * factor
                    anchors.bottom: parent.bottom
                    checkedLabel: qsTr("On")
                    uncheckedLabel: qsTr("Off")
                    fontSizeMultiplier: factor
                    onClicked: {
                        platformInterface.pwm_mot_ui_enable = checked
                        if(checked)
                            platformInterface.set_motor_control.update(true,combobox.currentText,pwmslider.value/100,parseInt(freqbox.text))
                        else {
                            platformInterface.set_motor_control.update(false,combobox.currentText,pwmslider.value/100,parseInt(freqbox.text))
                        }
                    }

                }
            }

            SGAlignedLabel {
                id: frequencyLabel
                target: freqbox
                text: "<b>" + qsTr("Frequency") + "</b>"
                fontSizeMultiplier: factor

                SGSubmitInfoBox {
                    id: freqbox
                    height: 30 * factor
                    width: 80 * factor
                    anchors.bottom: parent.bottom
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
                        if (theLastValueIs !== text ) {
                            platformInterface.pwm_mot_ui_freq = Number(text)
                            if(toggleswitch.checked)
                                platformInterface.set_motor_control.update(true,combobox.currentText,pwmslider.value/100,Number(text))
                            else
                                platformInterface.set_motor_control.update(false,combobox.currentText,pwmslider.value/100,Number(text))
                            theLastValueIs = text
                        }
                    }
                }
                KeyNavigation.tab: combobox
            }


        }
    }
}
