import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

CustomControl {
    id: root
    title: qsTr("PWM Motor Control")

    // UI state
    property real duty: platformInterface.pwm_mot_ui_duty
    property string control: platformInterface.pwm_mot_ui_control
    property bool enable: platformInterface.pwm_mot_ui_enable

    Component.onCompleted: {
        if (hideHeader) {
            Help.registerTarget(pwmsliderLabel, "This slider will set the duty cycle of the PWM signal going to the motor to vary the speed.", 0, "helloStrata_PWMMotorControl_Help")
            Help.registerTarget(comboboxLabel, "This combobox will set the rotation direction or brake the motor.", 1, "helloStrata_PWMMotorControl_Help")
            Help.registerTarget(toggleswitchLabel, "This switch will turn the motor on and off.", 2, "helloStrata_PWMMotorControl_Help")
        }
    }

    onDutyChanged: {
        pwmslider.value = duty
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
            SGSlider {
                id: pwmslider
                width: content.parent.width

                textColor: "black"
                stepSize: 1
                from: 0
                to: 100
                startLabel: "0"
                endLabel: "100 %"
                fontSizeMultiplier: factor

                onUserSet: {
                    platformInterface.pwm_mot_ui_duty = value
                    platformInterface.pwm_mot_set_duty.update(value/100)
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
                        platformInterface.pwm_mot_set_control.update(model[index])
                    }
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
                        platformInterface.pwm_mot_enable.update(checked === true)
                    }
                }
            }
        }
    }
}
