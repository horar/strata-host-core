import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

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
            Help.registerTarget(root, "None", 0, "helloStrata_PWMMotorControl_Help")
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
            target: pwmslider
            text:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
            fontSizeMultiplier: factor
            SGSlider {
                id: pwmslider
                textColor: "black"
                stepSize: 1
                from: 0
                to: 100
                startLabel: "0"
                endLabel: "100 %"
                width: content.parent.width
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
                target: combobox
                text: "<b>" + qsTr("Motor Control") + "</b>"
                fontSizeMultiplier: factor
                SGComboBox {
                    id: combobox
                    model: [qsTr("Forward"), qsTr("Brake"), qsTr("Reverse")]
                    height: 30 * factor
                    fontSizeMultiplier: factor
                    onActivated: {
                        platformInterface.pwm_mot_ui_control = model[index]
                        platformInterface.pwm_mot_set_control.update(model[index])
                    }
                }
            }

            SGAlignedLabel {
                target: toggleswitch
                text: "<b>" + qsTr("Motor Enable") + "</b>"
                fontSizeMultiplier: factor
                SGSwitch {
                    id: toggleswitch
                    height: 30 * factor
                    checkedLabel: qsTr("On")
                    uncheckedLabel: qsTr("Off")
                    anchors.bottom: parent.bottom
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
