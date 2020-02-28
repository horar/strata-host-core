import QtQuick 2.12
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as SGWidgets09
Item {
    id: root

    Item {
        id: controlMargins
        anchors {
            fill: parent
            margins: 15
        }

        Text{
            id:maxPowerOutputText
            anchors.right: maxPowerOutput.left
            anchors.rightMargin: 5
            anchors.verticalCenter: maxPowerOutput.verticalCenter
            text:"Max Power Output:"
        }

        SGComboBox {
            id: maxPowerOutput
            model: ["16","30", "45", "60"]
            anchors {
                left: parent.left
                leftMargin: 140
                top: parent.top
                topMargin:75
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
                    maxPowerOutput.currentIndex = maxPowerOutput.find( (platformInterface.usb_pd_maximum_power.current_max_power).toFixed(1))
                }

            }

        }
        Text{
            id:maxPowerOutputUnitText
            anchors.left: maxPowerOutput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: maxPowerOutput.verticalCenter
            text:"W"
        }


        Text{
            id:currentLimitText
            anchors.right: currentLimit.left
            anchors.rightMargin: 5
            anchors.verticalCenter: currentLimit.verticalCenter
            anchors.verticalCenterOffset: -8
            text:"Current limit:"
            visible:false
        }

        SGSlider {
            id: currentLimit
            from:1
            to:6
            stepSize: 1
            fromText.text:"1A"
            toText.text:"6A"
            fillColor:"dimgrey"
            handleSize: 20
            inputBoxWidth:30
            visible:false
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
                leftMargin: 140
                top: maxPowerOutput.bottom
                topMargin: 15
                right: parent.right
                rightMargin: 10
            }

            onMoved: platformInterface.set_over_current_protection.update(portNumber, value)
            //onValueChanged: platformInterface.set_over_current_protection.update(portNumber, value)

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
                leftMargin: 5
            }
            visible:false
        }



        SGWidgets09.SGSegmentedButtonStrip {
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
            visible:false

//            property var cableLoss: platformInterface.get_cable_loss_compensation

//            onCableLossChanged: {
//                if (platformInterface.get_cable_loss_compensation.port === portNumber){
//                    console.log("cable compensation for port ",portNumber,"set to",platformInterface.get_cable_loss_compensation.bias_voltage*1000)
//                    if (platformInterface.get_cable_loss_compensation.bias_voltage === 0){
//                        cableCompensationButtonStrip.buttonList[0].children[0].checked = true;
//                    }
//                    else if (platformInterface.get_cable_loss_compensation.bias_voltage * 1000 == 100){
//                        cableCompensationButtonStrip.buttonList[0].children[2].checked = true;
//                    }
//                    else if (platformInterface.get_cable_loss_compensation.bias_voltage * 1000 == 200){
//                        cableCompensationButtonStrip.buttonList[0].children[2].checked = true;
//                    }
//                }
//            }

            segmentedButtons: GridLayout {
                id:cableCompensationGridLayout
                columnSpacing: 2

                SGWidgets09.SGSegmentedButton{
                    id: cableCompensationSetting1
                    text: qsTr("Off")
                    checkable: true

                    onClicked:{
                        platformInterface.set_cable_loss_compensation.update(portNumber,
                                               1,
                                               0);
                    }
                }

                SGWidgets09.SGSegmentedButton{
                    id: cableCompensationSetting2
                    text: qsTr("100 mv/A")
                    checkable: true

                    onClicked:{
                        platformInterface.set_cable_loss_compensation.update(portNumber,
                                               1,
                                               100/1000);
                    }
                }

                SGWidgets09.SGSegmentedButton{
                    id:cableCompensationSetting3
                    text: qsTr("200 mv/A")
                    checkable: true

                    onClicked:{
                        platformInterface.set_cable_loss_compensation.update(portNumber,
                                               1,
                                               200/1000);
                    }
                }
            }
        }



    }
}
