import QtQuick 2.12
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as SGWidgets09

Item {
    id: root
    height: 275
    width: parent.width
    anchors {
        left: parent.left
    }

    property bool faultProtectionIsOn : platformInterface.usb_pd_protection_action.action !== "nothing"
    property bool inputFoldbackOn : platformInterface.input_voltage_foldback.enabled
    property bool temperatureFoldbackOn: platformInterface.temperature_foldback.enabled

    Item {
        id: leftColumn
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/3

        Item {
            id: margins1
            anchors {
                fill: parent
                margins: 15
            }



            Text {
                id: faultText
                text: "<b>Faults</b>"
                font {
                    pixelSize: 16
                }
                anchors {
                    top: margins1.top
                    topMargin: 30
                }
            }

//            SGWidgets.SGButtonStrip {
//                id: buttonStrip2
//                model: ["One","Two","Three","Four"]
//                exclusive: false

//                onClicked: {
//                    console.info(Logger.wgCategory, "buttonStrip2", index)
//                }
//            }

            SGButtonStrip {
                id: faultProtection
                anchors {
                    top: faultText.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 85
                    right: margins1.right
                    rightMargin: 10
                }
                height:30
                //label: "Fault Protection:"
                //textColor: "#222"
                //activeTextColor: "white"
                //radius: 4
                //buttonHeight: 25
                //buttonImplicitWidth:0
                //hoverEnabled: false
                //exclusive: false
                model: ["Retry","None"]

                onClicked: {
                    console.log("button with index",index,"clicked")
                    if (index == 0)
                        platformInterface.set_protection_action.update("retry");
                    else if (index == 1)
                        platformInterface.set_protection_action.update("none")
                  }

                property var protectionAction: platformInterface.usb_pd_protection_action.action
                onProtectionActionChanged: {
                     if (protectionAction === "retry")
                         checkedIndices = 1
                     if (protectionAction === "none")
                         checkedIndices = 2
                }

//                segmentedButtons: GridLayout {
//                    columnSpacing: 2


//                    SGWidgets09.SGSegmentedButton{
//                        text: qsTr("Retry")
//                        property var protectionAction: platformInterface.usb_pd_protection_action.action

//                        checked: protectionAction === "retry"

//                        onClicked: {
//                            platformInterface.set_protection_action.update("retry");
//                        }
//                    }

//                    SGWidgets09.SGSegmentedButton{
//                        text: qsTr("None")

//                        property var protectionAction: platformInterface.usb_pd_protection_action.action

//                        checked: protectionAction === "nothing"

//                        onClicked: {
//                            platformInterface.set_protection_action.update("nothing");
//                        }
//                    }
//                }
            }


            Text{
                id:inputFaultLabel
                anchors.right: inputFault.left
                anchors.rightMargin: 5
                anchors.verticalCenter: inputFault.verticalCenter
                anchors.verticalCenterOffset: -8
                horizontalAlignment: Text.AlignRight
                text: "Fault when input below:"
                color: faultProtectionIsOn ? "black" : "grey"
            }

            SGSlider {
                id: inputFault
                anchors {
                    left: margins1.left
                    leftMargin: 190
                    top: faultProtection.bottom
                    topMargin: 15
                    right: margins1.right
                    rightMargin: 0
                }
                from: 5
                to: 20
                live:false
                fromText.fontSizeMultiplier:.75
                toText.fontSizeMultiplier: .75
                fromText.text: "5V"
                toText.text: "20V"
                handleSize:20
                fillColor:"dimgrey"
                enabled: faultProtectionIsOn
                value: platformInterface.input_under_voltage_notification.minimum_voltage
                onUserSet: {
                    platformInterface.set_minimum_input_voltage.update(value);
                }
            }

            Text{
                id:tempFaultLabel
                anchors.right: tempFault.left
                anchors.rightMargin: 5
                anchors.verticalCenter: tempFault.verticalCenter
                anchors.verticalCenterOffset: -8
                horizontalAlignment: Text.AlignRight
                text:"Fault when temperature above:"
                color: faultProtectionIsOn ? "black" : "grey"
            }

            SGSlider {
                id: tempFault
                anchors {
                    left: margins1.left
                    leftMargin: 190
                    top: inputFault.bottom
                    topMargin: 10
                    right: margins1.right
                    rightMargin: 0
                }
                from: 20
                to: 100
                stepSize:5
                fromText.text: "20 °C"
                toText.text: "100 °C"
                enabled: faultProtectionIsOn
                live: false
                fillColor:"dimgrey"
                handleSize:20
                fromText.fontSizeMultiplier:.75
                toText.fontSizeMultiplier: .75
                value: platformInterface.set_maximum_temperature_notification.maximum_temperature
                onUserSet: {
                    platformInterface.set_maximum_temperature.update(value);
                }
            }

            Text{
                id:hysteresisLabel
                anchors.right: hysteresisSlider.left
                anchors.rightMargin: 5
                anchors.verticalCenter: hysteresisSlider.verticalCenter
                anchors.verticalCenterOffset: -8
                horizontalAlignment: Text.AlignRight
                text:"Retry when temperature drops:"
                color: faultProtectionIsOn ? "black" : "grey"
            }

            SGSlider {
                id: hysteresisSlider
                anchors {
                    left: margins1.left
                    leftMargin: 190
                    top: tempFault.bottom
                    topMargin: 10
                    right: margins1.right
                    rightMargin: 0
                }
                from: 5
                to: 50
                stepSize:5
                fillColor:"dimgrey"
                handleSize:20
                fromText.fontSizeMultiplier:.75
                toText.fontSizeMultiplier: .75
                fromText.text: "5 °C"
                toText.text: "50 °C"
                enabled: faultProtectionIsOn

                property var theHysteresis: platformInterface.temperature_hysteresis.value
                onTheHysteresisChanged: {
                    console.log("new hysteresis value:", theHysteresis)
                }

                value:{
                    console.log("new hysteresis value2:", platformInterface.temperature_hysteresis.value)
                    return platformInterface.temperature_hysteresis.value
                }
                onUserSet: {
                    platformInterface.set_temperature_hysteresis.update(value);
                }
            }

        }

        SGWidgets09.SGLayoutDivider {
            position: "right"
        }
    }

    Item {
        id: middleColumn
        anchors {
            left: leftColumn.right
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/3


        Item {
            id: margins2
            anchors {
                fill: parent
                margins: 15
            }

            Text {
                id: inputFoldback
                text: "<b>Input Foldback</b>"
                font {
                    pixelSize: 16
                }
            }

            SGSwitch {
                id: inputFoldbackSwitch
                anchors {
                    right: parent.right
                    verticalCenter: inputFoldback.verticalCenter
                }
                height: 20
                width: 46
                grooveFillColor:"green"
                checked: platformInterface.input_voltage_foldback.enabled
                onToggled:{
                    //console.log("input foldback switch toggled to ",checked)
                    return platformInterface.set_input_voltage_foldback.update(checked, platformInterface.input_voltage_foldback.min_voltage,
                                platformInterface.input_voltage_foldback.power)
                }
            }

            Text{
                id:foldbackLimitLabel
                anchors.right: foldbackLimit.left
                anchors.rightMargin: 5
                anchors.verticalCenter: foldbackLimit.verticalCenter
                anchors.verticalCenterOffset: -8
                horizontalAlignment: Text.AlignRight
                text:"Limit below:"
                color: inputFoldbackOn ? "black" : "grey"
            }

            SGSlider {
                id: foldbackLimit
                value: platformInterface.input_voltage_foldback.min_voltage
                anchors {
                    left: parent.left
                    leftMargin: 135
                    top: inputFoldback.bottom
                    topMargin: 13
                    right: margins2.right
                    rightMargin: 0
                }
                from: 5
                to: 20
                fromText.fontSizeMultiplier:.75
                toText.fontSizeMultiplier: .75
                fromText.text: "5V"
                toText.text: "20V"
                handleSize:20
                fillColor:"dimgrey"
                enabled: inputFoldbackOn
                live:false
                //copy the current values for other stuff, and add the new slider value for the limit.
                onUserSet: platformInterface.set_input_voltage_foldback.update(platformInterface.input_voltage_foldback.enabled,
                                 value.toString(),
                                platformInterface.input_voltage_foldback.power)
            }


            Text{
                id:limitOutputLabel
                anchors.right: limitOutput.left
                anchors.rightMargin: 5
                anchors.verticalCenter: limitOutput.verticalCenter
                horizontalAlignment: Text.AlignRight
                text:"Limit output power to:"
                color: inputFoldbackOn ? "black" : "grey"
            }

            SGComboBox {
                id: limitOutput
                model: ["30","60"]
                anchors {
                    left: parent.left
                    leftMargin: 135
                    top: foldbackLimit.bottom
                    topMargin: 10
                }
                width: 70
                enabled: inputFoldbackOn
                textColor: enabled ? "black" : "grey"
                //when changing the value
                onActivated: {
                    console.log("setting input power foldback to ",limitOutput.currentText);
                    platformInterface.set_input_voltage_foldback.update(platformInterface.input_voltage_foldback.enabled,
                                                                        platformInterface.input_voltage_foldback.min_voltage,
                                                                                 limitOutput.currentText)
                }

                property var currentFoldbackOuput: platformInterface.input_voltage_foldback.power
                onCurrentFoldbackOuputChanged: {
                    var theFoldbackPower = Math.trunc(platformInterface.input_voltage_foldback.power);

                    //console.log("got a new min input power setting", theFoldbackPower);
                    limitOutput.currentIndex = limitOutput.find( theFoldbackPower);
                }
            }
            Text{
                id: foldbackTempUnits
                text: "W"
                anchors {
                    left: limitOutput.right
                    leftMargin: 5
                    verticalCenter: limitOutput.verticalCenter
                    verticalCenterOffset: 0
                }
                color: inputFoldbackOn ? "black" : "grey"
            }

            SGWidgets09.SGDivider {
                id: div1
                anchors {
                    top: limitOutput.bottom
                    topMargin: 15
                }
            }

            Text {
                id: tempFoldback
                text: "<b>Temperature Foldback</b>"
                font {
                    pixelSize: 16
                }
                anchors {
                    top: div1.bottom
                    topMargin: 15
                }
            }

            SGSwitch {
                id: tempFoldbackSwitch
                anchors {
                    right: parent.right
                    verticalCenter: tempFoldback.verticalCenter
                }
                height: 20
                width: 46
                grooveFillColor:"green"
                checked: platformInterface.temperature_foldback.enabled
                onToggled:{
                    //console.log("sending temp foldback update command from tempFoldbackSwitch");
                    platformInterface.set_temperature_foldback.update(tempFoldbackSwitch.checked,
                                      platformInterface.temperature_foldback.max_temperature,
                                       platformInterface.temperature_foldback.power);
                }
            }

            Text{
                id:foldbackTempLabel
                anchors.right: foldbackTemp.left
                anchors.rightMargin: 5
                anchors.verticalCenter: foldbackTemp.verticalCenter
                anchors.verticalCenterOffset: -8
                text:"Limit above:"
                color: temperatureFoldbackOn ? "black" : "grey"
            }

            SGSlider {
                id: foldbackTemp
                anchors {
                    left: parent.left
                    leftMargin: 135
                    top: tempFoldback.bottom
                    topMargin: 15
                    right: parent.right
                    rightMargin: 0
                }
                from: 20
                to: 100
                stepSize:5
                fromText.fontSizeMultiplier:.75
                toText.fontSizeMultiplier: .75
                fromText.text: "20°C"
                toText.text: "100°C"
                fillColor:"dimgrey"
                handleSize: 20
                enabled: temperatureFoldbackOn
                live:false
                value: platformInterface.temperature_foldback.max_temperature

                onUserSet:{
                    platformInterface.set_temperature_foldback.update(platformInterface.temperature_foldback.enabled,
                                                                                  foldbackTemp.value.toString(),
                                                                                  platformInterface.temperature_foldback.power)
                }

            }


            Text{
                id:limitOutput2Label
                anchors.right: limitOutput2.left
                anchors.rightMargin: 5
                anchors.verticalCenter: limitOutput2.verticalCenter
                text:"Limit output power to:"
                color: temperatureFoldbackOn ? "black" : "grey"
            }

            SGComboBox {
                id: limitOutput2
                model: [ "30","60"]
                anchors {
                    left: parent.left
                    leftMargin: 135
                    top: foldbackTemp.bottom
                    topMargin: 10
                }
                width: 70
                enabled: temperatureFoldbackOn
                textColor: enabled ? "black" : "grey"
                //when the value is changed by the user
                onActivated: {
                    //console.log("sending temp foldback update command from limitOutputComboBox");
                    platformInterface.set_temperature_foldback.update(platformInterface.temperature_foldback.enabled,
                                                                                 platformInterface.temperature_foldback.max_temperature,
                                                                                 limitOutput2.currentText)
                }

                property var currentFoldbackOuput: platformInterface.temperature_foldback.power

                onCurrentFoldbackOuputChanged: {
                    var theFoldbackPower = Math.trunc(platformInterface.temperature_foldback.power);
                    limitOutput2.currentIndex = limitOutput2.find(theFoldbackPower)
                }
            }

            Text{
                id: foldbackTempUnits2
                text: "W"
                anchors {
                    left: limitOutput2.right
                    leftMargin: 5
                    verticalCenter: limitOutput2.verticalCenter
                }
                color: temperatureFoldbackOn ? "black" : "grey"
            }
        }
}

    Item{
        id: rightColumn
        anchors {
            right: root.right
            top: root.top
            bottom: root.bottom
        }
        width: root.width/3

        SGStatusLogBox {
            id: currentFaults
            height: rightColumn.height/2
            width: rightColumn.width
            title: "Active Faults:"
            model: faultListModel

            property var underVoltageEvent: platformInterface.input_under_voltage_notification
            property var overTempEvent: platformInterface.over_temperature_notification
            property string stateMessage:""

            onUnderVoltageEventChanged: {
                if (underVoltageEvent.state === "below"){   //add input voltage message to list
                    stateMessage = "Input is below ";
                    stateMessage += platformInterface.input_under_voltage_notification.minimum_voltage;
                    stateMessage += " V";
                    //if there's already an input voltage fault in the list, remove it (there can only be one at a time)
                    for(var i = 0; i < faultListModel.count; ++i){
                        var theItem = faultListModel.get(i);
                        if (theItem.type === "voltage"){
                            faultListModel.remove(i);
                        }
                    }
                    //console.log("over voltage event:",stateMessage)
                    faultListModel.append({"type":"voltage", "portName":"0", "message":stateMessage});

                }
                else{                                       //remove input voltage message from list
                    for(var j = 0; j < faultListModel.count; ++j){
                        var theListItem = faultListModel.get(j);
                        if (theListItem.type === "voltage"){
                            faultListModel.remove(j);
                        }
                    }
                }
            }

            onOverTempEventChanged: {
                if (overTempEvent.state === "above"){   //add temp  message to list
                    stateMessage = "Temperature is above ";
                    stateMessage += platformInterface.over_temperature_notification.maximum_temperature;
                    stateMessage += " °C";
                    //if there's already a temperature fault in the list, remove it (there can only be one at a time)
                    for(var a = 0; a < faultListModel.count; ++a){
                        var theListItem = faultListModel.get(a);
                        if (theListItem.type === "temperature"){
                            console.log("removing old over-temp fault",a)
                            faultListModel.remove(a);
                        }
                    }
                    faultListModel.append({"type":"temperature", "message":stateMessage});
                }
                else{                                       //remove temp message for the correct port from list
                    for(var i = 0; i < faultListModel.count; ++i){
                        var theItem = faultListModel.get(i);
                        if (theItem.type === "temperature"){
                            faultListModel.remove(i);
                        }
                    }
                }
            }

            ListModel{
                id:faultListModel
            }
        }



        SGStatusLogBox {
            id: faultHistory
            height: rightColumn.height/2
            anchors {
                top: currentFaults.bottom
            }
            width: rightColumn.width
            title: "Fault History:"

            property var underVoltageEvent: platformInterface.input_under_voltage_notification
            property var overTempEvent: platformInterface.over_temperature_notification
            property string stateMessage:""

            onUnderVoltageEventChanged: {
                if (underVoltageEvent.state === "below"){   //add input voltage message to list
                    stateMessage = "Input is below ";
                    stateMessage += platformInterface.input_under_voltage_notification.minimum_voltage;
                    stateMessage += " V";
                    //console.log("adding message to fault history",stateMessage);
                    faultHistory.append(stateMessage);

                }
                else{
//                    stateMessage = "Input voltage fault ended at ";
//                    stateMessage += platformInterface.input_under_voltage_notification.minimum_voltage;
//                    stateMessage += " V";
//                    faultHistory.input = stateMessage;
                }
            }

            onOverTempEventChanged: {
                if (overTempEvent.state === "above"){   //add temp  message to list
                    stateMessage = "Temperature is above ";
                    stateMessage += platformInterface.over_temperature_notification.maximum_temperature;
                    stateMessage += " °C";
                    faultHistory.append(stateMessage);
                }
                else{
//                    stateMessage += "Temperature went below ";
//                    stateMessage += platformInterface.over_temperature_notification.maximum_temperature;
//                    stateMessage += " °C";
//                    faultHistory.input = stateMessage;
                }


            }
        }
    }
}
