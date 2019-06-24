import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 0.9

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root

    property real minimumHeight
    property real minimumWidth

    signal zoom

    property real defaultMargin: 20
    property real defaultPadding: 20
    property real factor: Math.min(root.height/minimumHeight,root.width/minimumWidth)

    // UI state
    property real freq: platformInterface.pwm_led_ui_freq
    property real duty: platformInterface.pwm_led_ui_duty
    property real volt: platformInterface.dac_led_ui_volt

    onFreqChanged: {
        freqBox.value = freq
    }

    onDutyChanged: {
        pwmSlider.value = duty*100
    }

    onVoltChanged: {
        dacSlider.value = volt
    }

    // hide in tab view
    property bool hideHeader: false
    onHideHeaderChanged: {
        if (hideHeader) {
            header.visible = false
            content.anchors.top = container.top
            container.border.width = 0
        }
        else {
            header.visible = true
            content.anchors.top = header.bottom
            container.border.width = 1
        }
    }

    Rectangle {
        id: container
        anchors.fill:parent
        border {
            width: 1
            color: "lightgrey"
        }

        Item {
            id: header
            anchors {
                top:parent.top
                left:parent.left
                right:parent.right
            }
            height: Math.max(name.height,btn.height)

            Text {
                id: name
                text: "<b>" + qsTr("DAC & PWM LED") + "</b>"
                font.pixelSize: 14*factor
                color:"black"
                anchors.left: parent.left
                padding: defaultPadding

                width: parent.width - btn.width - defaultPadding
                wrapMode: Text.WordWrap
            }

            Button {
                id: btn
                text: qsTr("Maximize")
                anchors {
                    top: parent.top
                    right: parent.right
                    margins: defaultMargin
                }

                height: btnText.contentHeight+6*factor
                width: btnText.contentWidth+20*factor

                contentItem: Text {
                    id: btnText
                    text: btn.text
                    font.pixelSize: 10*factor
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: zoom()
            }
        }

        Item {
            id: content
            anchors {
                top:header.bottom
                bottom: parent.bottom
                left:parent.left
                right:parent.right
            }

            Column {
                spacing: 10
                width: parent.width
                padding: defaultPadding

                SGSlider {
                    id: dacSlider
                    label:"<b>DAC</b>"
                    textColor: "black"
                    labelLeft: false
                    width: parent.width-2*defaultPadding
                    stepSize: 0.001
                    from: 0
                    to: 3.3
                    startLabel: "0"
                    endLabel: "3.3 V"
                    toolTipDecimalPlaces: 3
                    onValueChanged: {
                        if (platformInterface.dac_led_ui_volt !== value) {
                            platformInterface.dac_led_set_voltage.update(1)
                            platformInterface.dac_led_ui_volt = value
                        }
                    }
                }

                SGSlider {
                    id: pwmSlider
                    label:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
                    textColor: "black"
                    labelLeft: false
                    width: parent.width-2*defaultPadding
                    stepSize: 0.01
                    from: 0
                    to: 100
                    startLabel: "0"
                    endLabel: "100 %"
                    toolTipDecimalPlaces: 2
                    onValueChanged: {
                        if (platformInterface.pwm_led_ui_duty !== value/100) {
                            platformInterface.pwm_led_set_duty.update(value/100)
                            platformInterface.pwm_led_ui_duty = value/100
                        }
                    }
                }

                SGSubmitInfoBox {
                    id: freqBox
                    label: "<b>" + qsTr("PWM Frequency") + "</b>"
                    textColor: "black"
                    labelLeft: false
                    infoBoxWidth: 100
                    showButton: true
                    buttonText: qsTr("Apply")
                    unit: "kHz"
                    value: "1"
                    placeholderText: "0.0001 - 1000"
                    validator: DoubleValidator {
                        bottom: 0.0001
                        top: 1000
                    }
                    onValueChanged: {
                        if (platformInterface.pwm_led_ui_freq !== value)
                            platformInterface.pwm_led_ui_freq = value
                    }
                    onApplied: platformInterface.pwm_led_set_freq.update(value)
                }

                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
