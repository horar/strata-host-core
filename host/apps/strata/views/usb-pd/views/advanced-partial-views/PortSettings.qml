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
                topMargin:25
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
            from:1
            to:6
            stepSize: 1
            startLabel:"1A"
            endLabel:"6A"
            labelTopAligned: true
            value: {
                if (platformInterface.output_current_exceeds_maximum.port === portNumber){
                    return platformInterface.output_current_exceeds_maximum.current_limit;
                }
                else{
                    return currentLimit.value;
                }

            }
            anchors {
                left: parent.left
                leftMargin: 61
                top: maxPowerOutput.bottom
                topMargin: 15
                right: currentLimitInput.left
                rightMargin: 10
            }

            onSliderMoved: platformInterface.set_over_current_protection.update(portNumber, value)
            onValueChanged: platformInterface.set_over_current_protection.update(portNumber, value)

        }

        SGSubmitInfoBox {
            id: currentLimitInput
            showButton: false
            minimumValue: 1
            maximumValue: 6
            anchors {
                verticalCenter: currentLimit.verticalCenter
                verticalCenterOffset: -7
                right: parent.right
            }
            value:{
               if (platformInterface.output_current_exceeds_maximum.port === portNumber){
                   return platformInterface.output_current_exceeds_maximum.current_limit.toFixed(0)
                }
                else{
                   return currentLimitInput.value;
                 }
            }
            onApplied: platformInterface.set_over_current_protection.update(portNumber, intValue)
        }


        Text {
            id: cableCompensation
            text: "Cable Compensation:"
            font {
                pixelSize: 13
            }
            anchors {
                top: currentLimit.bottom
                topMargin: 20
                left:parent.left
                leftMargin: 10
            }
        }



        SGSegmentedButtonStrip {
            id: cableCompensationButtonStrip
            anchors {
                left: cableCompensation.right
                leftMargin: 10
                verticalCenter: cableCompensation.verticalCenter
            }
            textColor: "#666"
            activeTextColor: "white"
            radius: 4
            buttonHeight: 25
            hoverEnabled: false

            property var cableLoss: platformInterface.get_cable_loss_compensation

            onCableLossChanged: {
                if (platformInterface.get_cable_loss_compensation.port === portNumber){
                    //console.log("cable compensation for port ",portNumber,"set to",platformInterface.get_cable_loss_compensation.bias_voltage*1000)
                    if (platformInterface.get_cable_loss_compensation.bias_voltage === 0){
                        cableCompensationButtonStrip.buttonList[0].children[0].enabled = true;
                    }
                    else if (platformInterface.get_cable_loss_compensation.bias_voltage * 1000 == 100){
                        cableCompensationButtonStrip.buttonList[0].children[2].enabled = true;
                    }
                    else if (platformInterface.get_cable_loss_compensation.bias_voltage * 1000 == 200){
                        cableCompensationButtonStrip.buttonList[0].children[2].enabled = true;
                    }
                }
            }

            segmentedButtons: GridLayout {
                id:cableCompensationGridLayout
                columnSpacing: 2

                SGSegmentedButton{
                    id: cableCompensationSetting1
                    text: qsTr("Off")
                    checkable: true

                    onClicked:{
                        platformInterface.set_cable_loss_compensation.update(portNumber,
                                               1,
                                               0);
                    }
                }

                SGSegmentedButton{
                    id: cableCompensationSetting2
                    text: qsTr("100 mV/A")
                    checkable: true

                    onClicked:{
                        platformInterface.set_cable_loss_compensation.update(portNumber,
                                               1,
                                               100/1000);
                    }
                }

                SGSegmentedButton{
                    id:cableCompensationSetting3
                    text: qsTr("200 mV/A")
                    checkable: true

                    onClicked:{
                        platformInterface.set_cable_loss_compensation.update(portNumber,
                                               1,
                                               200/1000);
                    }
                }
            }
        }

//        Text {
//            id: cableCompensation
//            text: "<b>Cable Compensation</b>"
//            font {
//                pixelSize: 16
//            }
//            anchors {
//                top: div1.bottom
//                topMargin: 10
//            }
//        }

//        SGSlider {
//            id: increment
//            label: "Rate of change:"
//            value:{
//                if (platformInterface.get_cable_loss_compensation.port === portNumber){
//                    return platformInterface.get_cable_loss_compensation.bias_voltage*1000;
//                }
//                else{
//                    return increment.value
//                }
//            }
//            from:.0
//            to:200
//            stepSize: 10
//            toolTipDecimalPlaces: 0
//            labelTopAligned: true
//            startLabel: "0mV/A"
//            endLabel: "200mV/A"
//            anchors {
//                left: parent.left
//                top: cableCompensation.bottom
//                topMargin: 10
//                right: incrementInput.left
//                rightMargin: 10
//            }
//            onSliderMoved:{
//                //console.log("sending values from increment slider:",portNumber, increment.value, platformInterface.get_cable_loss_compensation.bias_voltage);
//                platformInterface.set_cable_compensation.update(portNumber,
//                                       platformInterface.get_cable_loss_compensation.output_current,
//                                       value/1000)
//            }

//        }

//        SGSubmitInfoBox {
//            id: incrementInput
//            showButton: false
//            infoBoxWidth: 35
//            minimumValue: 0
//            maximumValue: 200
//            anchors {
//                verticalCenter: increment.verticalCenter
//                right: parent.right
//            }
//            value:{
//                if (platformInterface.get_cable_loss_compensation.port === portNumber){
//                    return (platformInterface.get_cable_loss_compensation.bias_voltage*1000)
//                }
//                else{
//                    return increment.value
//                }
//            }
//            onApplied:{
//                platformInterface.set_cable_compensation.update(portNumber,
//                           platformInterface.get_cable_loss_compensation.output_current,
//                           incrementInput.floatValue/1000)
//            }

//        }

//        SGSlider {
//            id: bias
//            label: "Per:"
//            value:{
//                if (platformInterface.get_cable_loss_compensation.port === portNumber){
//                    return platformInterface.get_cable_loss_compensation.output_current
//                }
//                else{
//                    return bias.value
//                }
//            }
//            from:.25
//            to:1
//            stepSize: .25
//            labelTopAligned: true
//            startLabel: "0.25A"
//            endLabel: "1A"
//            toolTipDecimalPlaces: 2
//            anchors {
//                left: parent.left
//                leftMargin: 50
//                top: increment.bottom
//                topMargin: 10
//                right: biasInput.left
//                rightMargin: 10
//            }
//            onSliderMoved: {
//                platformInterface.set_cable_compensation.update(portNumber,
//                                                                value,
//                                                                platformInterface.get_cable_loss_compensation.bias_voltage
//                                                                )
//            }

//        }

//        SGSubmitInfoBox {
//            id: biasInput
//            showButton: false
//            minimumValue: 0
//            maximumValue: 1
//            anchors {
//                verticalCenter: bias.verticalCenter
//                right: parent.right
//            }
//            value:{
//                if (platformInterface.get_cable_loss_compensation.port === portNumber){
//                    return platformInterface.get_cable_loss_compensation.output_current
//                }
//                else{
//                    return biasInput.value
//                }
//            }
//            onApplied: platformInterface.set_cable_compensation.update(portNumber,
//                          biasInput.floatValue,
//                          platformInterface.get_cable_loss_compensation.bias_voltage)
//        }



    }
}
