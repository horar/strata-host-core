import QtQuick 2.9
import QtQuick.Layouts 1.3
import "qrc:/views/usb-pd/sgwidgets"

Item {
    id: root

    Item {
        id: controlMargins
        anchors {
            fill: parent
            margins: 15
        }

        SGComboBox {
            id: maxPowerOutput
            label: "Max Power Output:"
            model: ["15","27", "36", "45","60","100"]
            anchors {
                left: parent.left
                leftMargin: 23
                top: parent.top
            }

            //when changing the value
            onActivated: {
                console.log("setting max power to ",maxPowerOutput.comboBox.currentText);
                platformInterface.set_usb_pd_maximum_power.update(portNumber,maxPowerOutput.comboBox.currentText)
            }

            //notification of a change from elsewhere
            property var currentMaximumPower: platformInterface.usb_pd_maximum_power.current_max_power
            onCurrentMaximumPowerChanged: {
                if (platformInterface.usb_pd_maximum_power.port === portNumber){
                    maxPowerOutput.currentIndex = maxPowerOutput.comboBox.find( parseInt (platformInterface.usb_pd_maximum_power.current_max_power))
                }

            }


        }


        SGSlider {
            id: currentLimit
            label: "Current limit:"
            from:0
            to:6
            startLabel:"0A"
            endLabel:"6A"
            value: platformInterface.request_over_current_protection_notification.current_limit
            anchors {
                left: parent.left
                leftMargin: 61
                top: maxPowerOutput.bottom
                topMargin: 10
                right: currentLimitInput.left
                rightMargin: 10
            }

            onSliderMoved: platformInterface.set_over_current_protection.update(portNumber, value)
            onValueChanged: platformInterface.set_over_current_protection.update(portNumber, value)

        }

        SGSubmitInfoBox {
            id: currentLimitInput
            showButton: false
            minimumValue: 0
            maximumValue: 6
            anchors {
                verticalCenter: currentLimit.verticalCenter
                right: parent.right
            }
            value: platformInterface.request_over_current_protection_notification.current_limit.toFixed(0)
            onApplied: platformInterface.set_over_current_protection.update(portNumber, value)
        }

        SGDivider {
            id: div1
            anchors {
                top: currentLimit.bottom
                topMargin: 15
            }
        }

        Text {
            id: cableCompensation
            text: "<b>Cable Compensation</b>"
            font {
                pixelSize: 16
            }
            anchors {
                top: div1.bottom
                topMargin: 10
            }
        }

        SGSlider {
            id: increment
            label: "For every increment of:"
            value:platformInterface.get_cable_loss_compensation.output_current
            from:1
            to:3
            startLabel:"1A"
            endLabel:"3A"
            toolTipDecimalPlaces: 2
            anchors {
                left: parent.left
                top: cableCompensation.bottom
                topMargin: 10
                right: incrementInput.left
                rightMargin: 10
            }
            onSliderMoved:{
                //console.log("sending values from increment slider:",portNumber, increment.value, platformInterface.get_cable_loss_compensation.bias_voltage);
                platformInterface.set_cable_loss_compensation.update(portNumber,
                                                                     increment.value,
                                                                     platformInterface.set_cable_loss_compensation.bias_voltage)
            }

        }

        SGSubmitInfoBox {
            id: incrementInput
            showButton: false
            anchors {
                verticalCenter: increment.verticalCenter
                right: parent.right
            }
            value: platformInterface.get_cable_loss_compensation.output_current.toFixed(2)
            onApplied: {
                platformInterface.set_cable_loss_compensation.update(portNumber,
                                                                     incrementInput.value,
                                                                     platformInterface.set_cable_loss_compensation.bias_voltage)
            }
        }

        SGSlider {
            id: bias
            label: "Bias output by:"
            value:platformInterface.get_cable_loss_compensation.bias_voltage
            from:0
            to:2
            startLabel:"0mV"
            endLabel:"2mV"
            toolTipDecimalPlaces: 2
            anchors {
                left: parent.left
                leftMargin: 50
                top: increment.bottom
                topMargin: 10
                right: biasInput.left
                rightMargin: 10
            }
            onSliderMoved: {
                platformInterface.set_cable_loss_compensation.update(portNumber,
                                                                     platformInterface.set_cable_loss_compensation.output_current,
                                                                     bias.value)
            }

        }

        SGSubmitInfoBox {
            id: biasInput
            showButton: false
            anchors {
                verticalCenter: bias.verticalCenter
                right: parent.right
            }
            value: platformInterface.get_cable_loss_compensation.bias_voltage.toFixed(2)
            onApplied: {
                platformInterface.set_cable_loss_compensation.update(portNumber,
                        platformInterface.set_cable_loss_compensation.output_current,
                        biasInput.value)
            }
        }



    }
}
