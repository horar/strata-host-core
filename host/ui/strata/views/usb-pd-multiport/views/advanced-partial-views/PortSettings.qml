import QtQuick 2.9
import QtQuick.Layouts 1.3
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id: root

    property bool assuredPortPowerEnabled: true

    Item {
        id: controlMargins
        anchors {
            fill: parent
            margins: 15
        }

        Text{
            id: assuredPortText
            text: "Assure Port power:"
            anchors {
                top:parent.top
                left: parent.left
                leftMargin: 45
            }
        }

        SGSwitch {
            id: assuredPortSwitch
            anchors {
                left: assuredPortText.right
                leftMargin: 10
                verticalCenter: assuredPortText.verticalCenter
            }
            enabled: assuredPortPowerEnabled
            checkedLabel: "On"
            uncheckedLabel: "Off"
            switchHeight: 20
            switchWidth: 46

            checked: platformInterface.assured_power_port.enabled
            onToggled: platformInterface.set_assured_power_port.update(checked, portNumber)  //we're only allowing port 1 to be assured

            Component.onCompleted: {
                assuredPortSwitch.checked =  false
            }
        }

        SGComboBox {

            property variant maxPowerOptions
            property int maxPower: platformInterface.request_usb_power_notification.maximum_power

            onMaxPowerChanged:{
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    if (maxPower >= 100){
                        maxPowerOptions = ["15","27", "36", "45","60","100"];
                    }
                    else if (maxPower >=60){
                        maxPowerOptions = ["15","27", "36", "45","60"];
                    }
                    else if (maxPower >=45){
                        maxPowerOptions = ["15","27", "36", "45"];
                    }
                    else if (maxPower >=36){
                        maxPowerOptions = ["15","27", "36"];
                    }
                    else if (maxPower >=27){
                        maxPowerOptions = ["15","27"];
                    }
                    else if (maxPower >=15){
                        maxPowerOptions = ["15"];
                    }
                    else{
                        maxPowerOptions = [];
                    }
                }
            }

            id: maxPowerOutput
            label: "Max Power Output:"
            model: maxPowerOptions
            enabled: !assuredPortSwitch.checked
            textColor: !assuredPortSwitch.checked ? "black" : "grey"
            comboBoxHeight: 25
            comboBoxWidth: 60
            anchors {
                left: parent.left
                leftMargin: 48
                top: assuredPortSwitch.bottom
                topMargin: 10
            }

            //when changing the value
            onActivated: {
                console.log("setting max power to ",parseInt(maxPowerOutput.comboBox.currentText));
                platformInterface.set_usb_pd_maximum_power.update(portNumber,parseInt(maxPowerOutput.comboBox.currentText))
            }

            //notification of a change from elsewhere
            //NB this info comes from the periodic power notification, not from the usb_pd_maximum_power notificaiton
            property var currentMaximumPower: platformInterface.usb_pd_maximum_power.commanded_max_power
            onCurrentMaximumPowerChanged: {
                if (platformInterface.usb_pd_maximum_power.port === portNumber){
                    maxPowerOutput.currentIndex = maxPowerOutput.comboBox.find( parseInt (platformInterface.usb_pd_maximum_power.commanded_max_power))
                }

            }
        }



        SGSlider {
            id: currentLimit
            label: "Current limit:"
            value: platformInterface.request_over_current_protection_notification.current_limit
            labelTopAligned: true
            startLabel: "0A"
            endLabel: "100A"
            anchors {
                left: parent.left
                leftMargin: 86
                top: maxPowerOutput.bottom
                topMargin: 10
                right: currentLimitInput.left
                rightMargin: 10
            }

            onMoved: platformInterface.set_over_current_protection.update(portNumber, value)

        }

        SGSubmitInfoBox {
            id: currentLimitInput
            showButton: false
            infoBoxWidth: 30
            anchors {
                verticalCenter: currentLimit.verticalCenter
                verticalCenterOffset: -7
                right: currentLimitInputUnits.left
                rightMargin: 5
            }

            value: platformInterface.request_over_current_protection_notification.current_limit.toFixed(0)
            onApplied: platformInterface.set_over_current_protection.update(portNumber, intValue)

        }

        Text{
            id: currentLimitInputUnits
            text: "A"
            anchors {
                right: parent.right
                verticalCenter: currentLimitInput.verticalCenter
            }
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
            text: "<b>Cable Compensation:</b>"
            font {
                pixelSize: 16
            }
            anchors {
                top: div1.bottom
                topMargin: 15
            }
        }

        SGSlider {
            id: increment
            label: "For every increment of:"
            value:platformInterface.set_cable_loss_compensation.output_current
            from:0
            to:3
            labelTopAligned: true
            startLabel: "0A"
            endLabel: "3A"
            anchors {
                left: parent.left
                leftMargin: 25
                top: cableCompensation.bottom
                topMargin: 10
                right: incrementInput.left
                rightMargin: 10
            }
            onMoved:{
                console.log("sending values from increment slider:",portNumber, increment.value, platformInterface.set_cable_loss_compensation.bias_voltage);
                platformInterface.set_cable_compensation.update(portNumber,
                                                                     value,
                                                                     platformInterface.set_cable_loss_compensation.bias_voltage)
            }

        }

        SGSubmitInfoBox {
            id: incrementInput
            showButton: false
            infoBoxWidth: 30
            anchors {
                verticalCenter: increment.verticalCenter
                verticalCenterOffset: -7
                right: incrementInputUnits.left
                rightMargin: 5
            }

            value: platformInterface.get_cable_loss_compensation.output_current.toFixed(0)
            onApplied: platformInterface.set_cable_loss_compensation.update(portNumber,
                           intValue,
                           platformInterface.get_cable_loss_compensation.bias_voltage)

        }

        Text{
            id: incrementInputUnits
            text: "A"
            anchors {
                right: parent.right
                verticalCenter: incrementInput.verticalCenter
            }
        }

        SGSlider {
            id: bias
            label: "Bias output by:"
            value:platformInterface.set_cable_loss_compensation.bias_voltage
            from:0
            to:2
            labelTopAligned: true
            startLabel: "0mV"
            endLabel: "2mV"
            anchors {
                left: parent.left
                leftMargin: 75
                top: increment.bottom
                topMargin: 10
                right: biasInput.left
                rightMargin: 10
            }
            onMoved: {
                platformInterface.set_cable_compensation.update(portNumber,
                                                                     platformInterface.set_cable_loss_compensation.output_current,
                                                                     value)
            }

        }

        SGSubmitInfoBox {
            id: biasInput
            showButton: false
            infoBoxWidth: 30
            anchors {
                verticalCenter: bias.verticalCenter
                verticalCenterOffset: -7
                right: biasInputUnits.left
                rightMargin: 5
            }

            value: platformInterface.get_cable_loss_compensation.bias_voltage.toFixed(0)
            onApplied: platformInterface.set_cable_loss_compensation.update(portNumber,
                                                                            platformInterface.get_cable_loss_compensation.output_current,
                                                                            intValue)
        }

        Text{
            id: biasInputUnits
            text: "mV"
            anchors {
                right: parent.right
                verticalCenter: biasInput.verticalCenter
            }
        }


        SGDivider {
            id: div2
            height: 1
            anchors {
                top: bias.bottom
                topMargin: 15
            }
        }

        Text {
            id: advertisedVoltages
            text: "<b>Advertised Voltages:</b>"
            font {
                pixelSize: 16
            }
            anchors {
                top: div2.bottom
                topMargin: 15
            }
        }

        SGSegmentedButtonStrip {
            id: faultProtectionButtonStrip
            anchors {
                left: advertisedVoltages.right
                leftMargin: 10
                verticalCenter: advertisedVoltages.verticalCenter
            }
            textColor: "#666"
            activeTextColor: "white"
            radius: 4
            buttonHeight: 25
            hoverEnabled: false

            property var sourceCapabilities: platformInterface.usb_pd_advertised_voltages_notification.settings

            onSourceCapabilitiesChanged:{

                //the strip's first child is the Grid layout. The children of that layout are the buttons in
                //question. This makes accessing the buttons a little bit cumbersome since they're loaded dynamically.
                if (platformInterface.usb_pd_advertised_voltages_notification.port === portNumber){
                    //console.log("updating advertised voltages for port ",portNumber)
                    //disable all the possibilities
                    faultProtectionButtonStrip.buttonList[0].children[6].enabled = false;
                    faultProtectionButtonStrip.buttonList[0].children[5].enabled = false;
                    faultProtectionButtonStrip.buttonList[0].children[4].enabled = false;
                    faultProtectionButtonStrip.buttonList[0].children[3].enabled = false;
                    faultProtectionButtonStrip.buttonList[0].children[2].enabled = false;
                    faultProtectionButtonStrip.buttonList[0].children[1].enabled = false;
                    faultProtectionButtonStrip.buttonList[0].children[0].enabled = false;

                    var numberOfSettings = platformInterface.usb_pd_advertised_voltages_notification.number_of_settings;
                    if (numberOfSettings >= 7){
                        faultProtectionButtonStrip.buttonList[0].children[6].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[6].text = platformInterface.usb_pd_advertised_voltages_notification.settings[6].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[6].text += "V, ";
                        faultProtectionButtonStrip.buttonList[0].children[6].text += platformInterface.usb_pd_advertised_voltages_notification.settings[6].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[6].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[6].text = "NA";
                    }

                    if (numberOfSettings >= 6){
                        faultProtectionButtonStrip.buttonList[0].children[5].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[5].text = platformInterface.usb_pd_advertised_voltages_notification.settings[5].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[5].text += "V, ";
                        faultProtectionButtonStrip.buttonList[0].children[5].text += platformInterface.usb_pd_advertised_voltages_notification.settings[5].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[5].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[5].text = "NA";
                    }

                    if (numberOfSettings >= 5){
                        faultProtectionButtonStrip.buttonList[0].children[4].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[4].text = platformInterface.usb_pd_advertised_voltages_notification.settings[4].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[4].text += "V, ";
                        faultProtectionButtonStrip.buttonList[0].children[4].text += platformInterface.usb_pd_advertised_voltages_notification.settings[4].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[4].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[4].text = "NA";
                    }

                    if (numberOfSettings >= 4){
                        faultProtectionButtonStrip.buttonList[0].children[3].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[3].text = platformInterface.usb_pd_advertised_voltages_notification.settings[3].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[3].text += "V, ";
                        faultProtectionButtonStrip.buttonList[0].children[3].text += platformInterface.usb_pd_advertised_voltages_notification.settings[3].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[3].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[3].text = "NA";
                    }

                    if (numberOfSettings >= 3){
                        faultProtectionButtonStrip.buttonList[0].children[2].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[2].text = platformInterface.usb_pd_advertised_voltages_notification.settings[2].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[2].text += "V, ";
                        faultProtectionButtonStrip.buttonList[0].children[2].text += platformInterface.usb_pd_advertised_voltages_notification.settings[2].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[2].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[2].text = "NA";
                    }

                    if (numberOfSettings >= 2){
                        faultProtectionButtonStrip.buttonList[0].children[1].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[1].text = platformInterface.usb_pd_advertised_voltages_notification.settings[1].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[1].text += "V, ";
                        faultProtectionButtonStrip.buttonList[0].children[1].text += platformInterface.usb_pd_advertised_voltages_notification.settings[1].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[1].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[1].text = "NA";
                    }

                    if (numberOfSettings >= 1){
                        faultProtectionButtonStrip.buttonList[0].children[0].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[0].text = platformInterface.usb_pd_advertised_voltages_notification.settings[0].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[0].text += "V, ";
                        faultProtectionButtonStrip.buttonList[0].children[0].text += platformInterface.usb_pd_advertised_voltages_notification.settings[0].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[0].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[1].text = "NA";
                    }

                }
            }

            segmentedButtons: GridLayout {
                id:advertisedVoltageGridLayout
                columnSpacing: 2

                SGSegmentedButton{
                    id: setting1
                    //text: qsTr("5V, 3A")
                    checkable: false
                }

                SGSegmentedButton{
                    id: setting2
                    //text: qsTr("7V, 3A")
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting3
                    //text: qsTr("8V, 3A")
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting4
                    //text: qsTr("9V, 3A")
                    //enabled: false
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting5
                    //text: qsTr("12V, 3A")
                    //enabled: false
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting6
                    //text: qsTr("15V, 3A")
                    //enabled: false
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting7
                    //text: qsTr("20V, 3A")
                    //enabled: false
                    checkable: false
                }
            }
        }
    }
}
