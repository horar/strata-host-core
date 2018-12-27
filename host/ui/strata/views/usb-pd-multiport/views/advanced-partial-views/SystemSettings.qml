import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id: root
    height: 350
    width: parent.width
    anchors {
        left: parent.left
    }

    Item {
        id: leftColumn
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/2

        Item {
            id: margins1
            anchors {
                fill: parent
                margins: 15
            }

            Text {
                id: powerManagement
                text: "<b>Power Management</b>"
                font {
                    pixelSize: 16
                }
            }

            Button{
                //a rectangle to cover the max power slider when it's disabled, so we can still show a
                //tooltip explaining *why* its disabled.
                id:toolTipMask
                //color:"transparent"
                //border.color:"red"
                hoverEnabled: true
                z:1
                visible:!maximumBoardPower.enabled
                background: Rectangle{
                    color:"transparent"
                }

                anchors {
                    top: powerManagement.bottom
                    topMargin: 15
                    left: margins1.left
                    leftMargin: 55
                    right: maximumBoardPowerUnits.left
                    rightMargin: 5
                    bottom:maximumBoardPower.bottom
                }

                ToolTip{
                    id:maxPowerToolTip
                    visible:toolTipMask.hovered
                    text:"System Power can not be changed when devices are connected"
                    delay:500
                    timeout:2000

                    background: Rectangle {
                        color: "#eee"
                        radius: 2
                    }
                }
            }

            SGSlider {

                property bool port1connected:false
                property bool port2connected:false
                property bool port3connected:false
                property bool port4connected:false
                property bool deviceConnected:false
                property var deviceIsConnected: platformInterface.usb_pd_port_connect.connection_state
                property var deviceIsDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

                onDeviceIsConnectedChanged: {

                    if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_1"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            port1connected = true;
                        }
                    }
                    else if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_2"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            port2connected = true;
                        }
                    }
                    else if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_3"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            port3connected = true;
                        }
                    }
                    else if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_4"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            port4connected = true;
                        }
                    }

                    //console.log("updating connection", port1connected, port2connected, port3connected, port4connected)
                    deviceConnected = port1connected || port2connected || port3connected || port4connected;

                }

                onDeviceIsDisconnectedChanged: {
                    if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_1"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            port1connected = false;
                        }
                    }
                    else if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_2"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            port2connected = false;
                        }
                    }
                    else if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_3"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            port3connected = false;
                        }
                    }
                    else if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_4"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            port4connected = false;
                        }
                    }
                    //console.log("updating connection", port1connected, port2connected, port3connected, port4connected)
                    deviceConnected = port1connected || port2connected || port3connected || port4connected;
                }

                property var currentMaxPower: platformInterface.maximum_board_power.watts

                id: maximumBoardPower
                label: "Maximum System Power:"
                enabled: !deviceConnected ? true : false  //slider enabled if nothing is plugged in
                anchors {
                    top: powerManagement.bottom
                    topMargin: 15
                    left: margins1.left
                    leftMargin: 55
                    right: maximumBoardPowerInput.left
                    rightMargin: 10
                }
                from: 30
                to: 200//platformInterface.ac_power_supply_connection.power
                startLabel: "30W"
                endLabel: "200W"//platformInterface.ac_power_supply_connection.power+"W"
                labelTopAligned: true
                value: currentMaxPower

                onMoved: {
                    //the control will be disabled if there are devices plugged in
                    platformInterface.set_maximum_board_power.update(value);
                }
            }

            SGSubmitInfoBox {
                id: maximumBoardPowerInput
                showButton: false
                infoBoxWidth: 35
                enabled: maximumBoardPower.enabled
                minimumValue: 30
                maximumValue: 200//platformInterface.ac_power_supply_connection.power
                anchors {
                    verticalCenter: maximumBoardPower.verticalCenter
                    verticalCenterOffset: -7
                    right: maximumBoardPowerUnits.left
                    rightMargin: 5
                }
                onApplied: {
                    platformInterface.set_maximum_board_power.update(maximumBoardPowerInput.intValue);
                    }
                value: Math.round(platformInterface.maximum_board_power.watts)
            }

            Text{
                id: maximumBoardPowerUnits
                text: "W"
                color: maximumBoardPower.enabled ? "black" : "grey"
                anchors {
                    right: parent.right
                    verticalCenter: maximumBoardPowerInput.verticalCenter
                }
            }

            Text{
                id: powerNegotiationTitleText
                text: "Power Negotiation:"
                anchors {
                    top: maximumBoardPower.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 92
                }
            }

            Text{
                id: powerNegotiationText
                text: "First come, first served"
                color:"dimgray"
                anchors {
                    top: maximumBoardPower.bottom
                    topMargin: 10
                    left: powerNegotiationTitleText.right
                    leftMargin: 10
                }
            }


            Button{
                //a rectangle to cover the max power popup when it's disabled, so we can still show a
                //tooltip explaining *why* its disabled.
                id:toolTipAssuredPowerMask
                hoverEnabled: true
                z:1
                visible:!maximumBoardPower.enabled
                background: Rectangle{
                    color:"transparent"
                }

                anchors {
                    left: assuredPortSwitch.left
                    top: assuredPortSwitch.top
                    bottom:assuredPortSwitch.bottom
                    right: assuredPortSwitch.right
                }

                ToolTip{
                    id:assuredPowerToolTip
                    visible:toolTipAssuredPowerMask.hovered
                    text:"Assured Power can not be changed when devices are connected"
                    delay:500
                    timeout:2000

                    background: Rectangle {
                        color: "#eee"
                        radius: 2
                    }
                }
            }

            Text{
                id: assuredPortText
                text: "Assure Port 1 power:"
                anchors {
                    top: powerNegotiationText.bottom
                    topMargin:15
                    left: margins1.left
                    leftMargin: 82
                }
            }

            SGSwitch {
                property bool port1connected:false
                property bool port2connected:false
                property bool port3connected:false
                property bool port4connected:false
                property bool deviceConnected:false
                property var deviceIsConnected: platformInterface.usb_pd_port_connect.connection_state
                property var deviceIsDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

                onDeviceIsConnectedChanged: {

                    if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_1"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            port1connected = true;
                        }
                    }
                    else if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_2"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            port2connected = true;
                        }
                    }
                    else if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_3"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            port3connected = true;
                        }
                    }
                    else if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_4"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            port4connected = true;
                        }
                    }

                    //console.log("updating connection", port1connected, port2connected, port3connected, port4connected)
                    deviceConnected = port1connected || port2connected || port3connected || port4connected;

                }

                onDeviceIsDisconnectedChanged: {
                    if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_1"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            port1connected = false;
                        }
                    }
                    else if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_2"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            port2connected = false;
                        }
                    }
                    else if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_3"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            port3connected = false;
                        }
                    }
                    else if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_4"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            port4connected = false;
                        }
                    }
                    //console.log("updating connection", port1connected, port2connected, port3connected, port4connected)
                    deviceConnected = port1connected || port2connected || port3connected || port4connected;
                }

                id: assuredPortSwitch
                enabled: !deviceConnected
                anchors {
                    left: assuredPortText.right
                    leftMargin: 10
                    verticalCenter: assuredPortText.verticalCenter
                }
                checkedLabel: "On"
                uncheckedLabel: "Off"
                switchHeight: 20
                switchWidth: 46

                checked: platformInterface.assured_power_port.enabled
                onToggled: platformInterface.set_assured_power_port.update(checked, 1)  //we're only allowing port 1 to be assured

            }

            SGComboBox {
                id: assuredMaxPowerOutput
                label: "Maximum Assured Power:"
                model: ["15","27", "36", "45","60","100"]
                comboBoxHeight: 25
                comboBoxWidth: 60
                enabled: (!assuredPortSwitch.checked && assuredPortSwitch.enabled)
                textColor: enabled ? "black" : "grey"
                anchors {

                    top: assuredPortText.top
                    topMargin: 30
                    left: margins1.left
                    leftMargin: 53
                }

                //when changing the value
                onActivated: {
                    console.log("setting max power to ",parseInt(assuredMaxPowerOutput.comboBox.currentText));
                    platformInterface.set_usb_pd_maximum_power.update(1,parseInt(assuredMaxPowerOutput.comboBox.currentText))
                }

                //notification of a change from elsewhere
                property var currentMaximumPower: platformInterface.usb_pd_maximum_power.commanded_max_power
                onCurrentMaximumPowerChanged: {
                    if (platformInterface.usb_pd_maximum_power.port === 1){
                        assuredMaxPowerOutput.currentIndex = assuredMaxPowerOutput.comboBox.find( parseInt (platformInterface.usb_pd_maximum_power.commanded_max_power))
                    }

                }


            }

            Text{
                id: assuredMaxPowerUnits
                text: "W"
                color: assuredMaxPowerOutput.enabled ? "black" : "grey"
                anchors {
                    left: assuredMaxPowerOutput.right
                    leftMargin: 5
                    verticalCenter: assuredMaxPowerOutput.verticalCenter
                }
            }



            SGSegmentedButtonStrip {
                id: sleepMode
                label: "Sleep Mode:"
                activeTextColor: "white"
                textColor: "#666"
                radius: 4
                buttonHeight: 25
                anchors {
                    top: assuredMaxPowerOutput.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 132
                }



                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    property var sleepMode: platformInterface.sleep_mode.mode

                    onSleepModeChanged:{
                        if (platformInterface.sleep_mode.mode === "off"){
                            manualSleepModeButton.checked = true;
                            automaticSleepModeButton.checked = false;
                        }
                        else if (platformInterface.sleep_mode.mode === "automatic"){
                            manualSleepModeButton.checked = false;
                            automaticSleepModeButton.checked = true;
                        }
                    }

                    SGSegmentedButton{
                        id:manualSleepModeButton
                        text: qsTr("Off")
                        checked: true  // Sets default checked button when exclusive

                        onClicked: {
                            platformInterface.set_sleep_mode.update("off");
                        }
                    }

                    SGSegmentedButton{
                        id:automaticSleepModeButton
                        text: qsTr("Automatic")
                        onClicked: {
                            platformInterface.set_sleep_mode.update("automatic");
                        }
                    }
                }
            }


            Text {
                id: faultHeader
                text: "<b>Faults</b>"
                font {
                    pixelSize: 16
                }
                anchors.top: sleepMode.bottom
                anchors.topMargin: 10
            }

            SGSegmentedButtonStrip {
                id: faultProtection
                anchors {
                    top: faultHeader.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 109
                }
                label: "Fault Protection:"
                textColor: "#666"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25

                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    SGSegmentedButton{
                        text: qsTr("Retry")
                        checked: platformInterface.usb_pd_protection_action.action === "retry"

                        onClicked: {
                            platformInterface.set_protection_action.update("retry");
                        }
                    }

                    SGSegmentedButton{
                        text: qsTr("None")
                        checked: platformInterface.usb_pd_protection_action.action === "nothing"

                        onClicked: {
                            platformInterface.set_protection_action.update("nothing");
                        }
                    }
                }
            }



            SGSlider {
                id: tempFault
                label: "Fault when temperature above:"
                anchors {
                    left: parent.left
                    leftMargin:20
                    top: faultProtection.bottom
                    topMargin: 10
                    right: tempFaultInput.left
                    rightMargin: 10
                }
                from: 0
                to: 135
                startLabel: "0°C"
                endLabel: "135°C"
                labelTopAligned: true
                value: platformInterface.set_maximum_temperature_notification.maximum_temperature
                onMoved: {
                    platformInterface.set_maximum_temperature.update(value);
                }
            }

            SGSubmitInfoBox {
                id: tempFaultInput
                showButton: false
                infoBoxWidth: 35
                minimumValue: 0
                maximumValue: 135
                anchors {
                    verticalCenter: tempFault.verticalCenter
                    verticalCenterOffset: -7
                    right: tempFaultUnits.left
                    rightMargin: 5
                }
                value: Math.round(platformInterface.set_maximum_temperature_notification.maximum_temperature)
                onApplied:{
                    //console.log("temp fault value onApplied");
                    var currentValue = parseFloat(value)
                    platformInterface.set_maximum_temperature.update(currentValue); // slider will be updated via notification
                }
            }

            Text{
                id: tempFaultUnits
                text: "°C"
                anchors {
                    right: parent.right
                    verticalCenter: tempFaultInput.verticalCenter
                }
            }
        }

        SGLayoutDivider {
            position: "right"
        }
    }

    Item {
        id: rightColumn
        anchors {
            left: leftColumn.right
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }


       Item {
            id: margins2
            anchors {
                fill: parent
                margins: 15
            }

            Text {
                id: tempFoldback
                text: "<b>Temperature Foldback</b>"
                font {
                    pixelSize: 16
                }
                anchors {
                    top: margins2.top
                    topMargin: 15
                }
            }

            Text{
                id: temperatureFoldbackStatus
                text: "Active:"
                anchors {
                    top: tempFoldback.bottom
                    topMargin:15
                    left: margins2.left
                    leftMargin: 120
                }
            }

            SGSwitch {
                id: tempFoldbackSwitch
                anchors {
                    left: temperatureFoldbackStatus.right
                    leftMargin: 10
                    verticalCenter: temperatureFoldbackStatus.verticalCenter
                }
                checkedLabel: "On"
                uncheckedLabel: "Off"
                switchHeight: 20
                switchWidth: 46
                checked: platformInterface.foldback_temperature_limiting_event.temperature_foldback_enabled
                onToggled:{
                    console.log("sending temp foldback update command from tempFoldbackSwitch");
                    platformInterface.set_temperature_foldback.update(tempFoldbackSwitch.checked,
                                                                                    platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature,
                                                                                    platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power);
                }
            }

            SGSlider {
                id: foldbackTemp
                label: "Limit above:"
                anchors {
                    left: parent.left
                    leftMargin: 87
                    top: temperatureFoldbackStatus.bottom
                    topMargin: 10
                    right: foldbackTempInput.left
                    rightMargin: 10
                }
                from: 0
                to: 100
                startLabel: "0°C"
                endLabel: "100°C"
                labelTopAligned: true
                value: platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature
                onMoved:{
                    console.log("sending temp foldback update command from foldbackTempSlider");
                    platformInterface.set_temperature_foldback.update(platformInterface.foldback_temperature_limiting_event.temperature_foldback_enabled,
                                                                                  foldbackTemp.value,
                                                                                  platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power)
                }

            }

            SGSubmitInfoBox {
                id: foldbackTempInput
                showButton: false
                infoBoxWidth: 35
                anchors {
                    verticalCenter: foldbackTemp.verticalCenter
                    verticalCenterOffset: -7
                    right: foldbackTempUnits.left
                    rightMargin: 5
                }
                value: Math.round(platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature)
                onApplied: platformInterface.set_temperature_foldback.update(platformInterface.foldback_temperature_limiting_event.temperature_foldback_enabled,
                                                                             parseFloat(value),
                                                                             platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power)
            }

            Text{
                id: foldbackTempUnits
                text: "°C"
                anchors {
                    right: parent.right
                    verticalCenter: foldbackTempInput.verticalCenter
                }
            }

            SGComboBox {
                id: limitOutput2
                label: "Reduce output power to:"
                model: ["10","15", "25", "45","75","90"]
                comboBoxHeight: 25
                comboBoxWidth: 60
                anchors {
                    left: parent.left
                    leftMargin: 10
                    top: foldbackTemp.bottom
                    topMargin: 10
                }
                //when the value is changed by the user
                onActivated: {
                    console.log("sending temp foldback update command from limitOutputComboBox");
                    platformInterface.set_temperature_foldback.update(platformInterface.foldback_temperature_limiting_event.temperature_foldback_enabled,
                                                                                 platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature,
                                                                                 limitOutput2.currentText)
                }

                property var currentFoldbackOuput: platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power

                onCurrentFoldbackOuputChanged: {
                    limitOutput2.currentIndex = limitOutput2.comboBox.find( parseInt (platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power))
                }
            }

            Text{
                id:percentLabel
                text:"%"
                anchors{
                    left:limitOutput2.right
                    leftMargin: 5
                    verticalCenter: limitOutput2.verticalCenter
                }
            }
        }
    }
}
