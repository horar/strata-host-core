import QtQuick 2.9
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id: root
    width: parent.width

    Item{
        id: leftColumn
        anchors {
            left: root.left
            top: root.top
            right: rightColumn.left
            bottom: root.bottom
        }

        Item {
            id: margins
            anchors {
                fill: parent
                margins: 15
            }

            SGCapacityBar {
                id: capacityBar
                width: margins.width
                labelLeft: false
                barWidth: margins.width
                maximumValue: 200//platformInterface.ac_power_supply_connection.power
                //showThreshold: true
                //thresholdValue: (.9 * platformInterface.ac_power_supply_connection.power)

                gaugeElements: Row {
                    id: container
                    property real totalValue: childrenRect.width // Necessary for over threshold detection signal

                    SGCapacityBarElement{
                        id: port1BarElement
                        color: Qt.lighter(miniInfo1.portColor)
                        value: {
                            if (platformInterface.request_usb_power_notification.port === 1){
                                if (platformInterface.request_usb_power_notification.device !== "none")
                                    return (platformInterface.request_usb_power_notification.negotiated_voltage * platformInterface.request_usb_power_notification.negotiated_current)
                                  else
                                    return 0
                            }
                            else{
                               return port1BarElement.value;
                            }
                        }
                        secondaryValue:{
                            if (platformInterface.request_usb_power_notification.port === 1){
                                if (platformInterface.request_usb_power_notification.device !== "none"){
                                    var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                                    var correctedOutputCurrent= platformInterface.adjust_current ? outputCurrent * platformInterface.oldFirmwareScaleFactor : outputCurrent
                                    return (platformInterface.request_usb_power_notification.output_voltage *correctedOutputCurrent)
                                }
                                else{
                                    return 0
                                }
                            }
                            else{
                                return port1BarElement.secondaryValue;
                            }
                        }
                    }

                    SGCapacityBarElement{
                        id: port2BarElement
                        color: miniInfo2.portColor
                        value: {
                            if (platformInterface.request_usb_power_notification.port === 2){
                                //console.log("port two max power =",platformInterface.request_usb_power_notification.maximum_power)
                                if (platformInterface.request_usb_power_notification.device !== "none")
                                    return (platformInterface.request_usb_power_notification.negotiated_voltage * platformInterface.request_usb_power_notification.negotiated_current)
                                  else
                                    return 0
                            }
                            else{
                               return port2BarElement.value;
                            }
                        }
                        secondaryValue:{
                            if (platformInterface.request_usb_power_notification.port === 2){
                                if (platformInterface.request_usb_power_notification.device !== "none"){
                                    var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                                    var correctedOutputCurrent= platformInterface.adjust_current ? outputCurrent * platformInterface.oldFirmwareScaleFactor : outputCurrent
                                    return (platformInterface.request_usb_power_notification.output_voltage *correctedOutputCurrent)
                                }
                                else{
                                    return 0
                                }
                            }
                            else{
                                return port2BarElement.secondaryValue;
                            }
                        }
                    }

                    SGCapacityBarElement{
                        id: port3BarElement
                        color: miniInfo3.portColor
                        value: {
                            if (platformInterface.request_usb_power_notification.port === 3){
                                if (platformInterface.request_usb_power_notification.device !== "none")
                                    return (platformInterface.request_usb_power_notification.negotiated_voltage * platformInterface.request_usb_power_notification.negotiated_current)
                                  else
                                    return 0
                            }
                            else{
                               return port3BarElement.value;
                            }
                        }
                        secondaryValue:{
                            if (platformInterface.request_usb_power_notification.port === 3){
                                if (platformInterface.request_usb_power_notification.device !== "none"){
                                    var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                                    var correctedOutputCurrent= platformInterface.adjust_current ? outputCurrent * platformInterface.oldFirmwareScaleFactor : outputCurrent
                                    return (platformInterface.request_usb_power_notification.output_voltage *correctedOutputCurrent)
                                }
                                else{
                                    return 0
                                }
                            }
                            else{
                                return port3BarElement.secondaryValue;
                            }
                        }
                    }

                    SGCapacityBarElement{
                        id: port4BarElement
                        color: miniInfo4.portColor
                        value: {
                            if (platformInterface.request_usb_power_notification.port === 4){
                                if (platformInterface.request_usb_power_notification.device !== "none")
                                    return (platformInterface.request_usb_power_notification.negotiated_voltage * platformInterface.request_usb_power_notification.negotiated_current)
                                  else
                                    return 0
                            }
                            else{
                               return port4BarElement.value;
                            }
                        }
                        secondaryValue:{
                            if (platformInterface.request_usb_power_notification.port === 4){
                                if (platformInterface.request_usb_power_notification.device !== "none"){
                                    var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                                    var correctedOutputCurrent= platformInterface.adjust_current ? outputCurrent * platformInterface.oldFirmwareScaleFactor : outputCurrent
                                    return (platformInterface.request_usb_power_notification.output_voltage * correctedOutputCurrent)
                                }
                                else{
                                    return 0
                                }
                            }
                            else{
                                return port4BarElement.secondaryValue;
                            }
                        }
                    }
                }
            }

            PortInfoMini {
                id: miniInfo1
                portNum: 1
                anchors {
                    top: capacityBar.bottom
                    topMargin: 10
                    left: margins.left
                    bottom: margins.bottom
                }
                width: margins.width / 4 - 15
                portColor: "#4eafe0"

                property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state
                property int theRunningTotal: 0
                property int theEfficiencyCount: 0
                property int theEfficiencyAverage: 0

                property var periodicValues: platformInterface.request_usb_power_notification

                onPeriodicValuesChanged: {
                    var inputCurrent = platformInterface.request_usb_power_notification.input_current;
                    var correctedInputCurrent= platformInterface.adjust_current ? inputCurrent * platformInterface.oldFirmwareScaleFactor : inputCurrent
                    var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                    var correctedOutputCurrent= platformInterface.adjust_current ? outputCurrent * platformInterface.oldFirmwareScaleFactor : outputCurrent
                    var theInputPower = platformInterface.request_usb_power_notification.input_voltage * correctedInputCurrent +2;//PTJ-1321 2 Watt compensation
                    var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * correctedOutputCurrent;

                    if (platformInterface.request_usb_power_notification.port === 1){
                        //sum eight values of the efficency and average before displaying
                        var theEfficiency = Math.round((theOutputPower/theInputPower) *100)
                        miniInfo1.theRunningTotal += theEfficiency;
                        //console.log("new efficiency value=",theEfficiency,"new total is",miniInfo1.theRunningTotal,miniInfo1.theEfficiencyCount);
                        miniInfo1.theEfficiencyCount++;

                        if (miniInfo1.theEfficiencyCount == 8){
                            miniInfo1.theEfficiencyAverage = miniInfo1.theRunningTotal/8;
                            miniInfo1.theEfficiencyCount = 0;
                            miniInfo1.theRunningTotal = 0

                            //console.log("publishing new efficency",miniInfo1.theEfficiencyAverage);
                            //return miniInfo1.theEfficiencyAverage
                        }
                    }

                }

                onDeviceConnectedChanged: {
                    if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_1"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            miniInfo1.portConnected = true;
                        }
                    }
                }

                onDeviceDisconnectedChanged: {
                    if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_1"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            miniInfo1.portConnected = false;
                        }

                    }
                }

                negotiatedVoltage:{
                    if (platformInterface.request_usb_power_notification.port === 1){
                        return platformInterface.request_usb_power_notification.negotiated_voltage
                    }
                    else{
                        return miniInfo1.negotiatedVoltage;
                    }
                }
                maxPower:{
                    if (platformInterface.request_usb_power_notification.port === 1){
                        var voltage = platformInterface.request_usb_power_notification.negotiated_voltage;
                        var current = platformInterface.request_usb_power_notification.negotiated_current;
                        return Math.round(voltage*current *100)/100;
                    }
                    else if (!miniInfo1.portConnected){
                       return "—"  //show a dash on disconnect, so cached value won't show on connect
                     }
                    else{
                        return miniInfo1.maxPower;
                    }
                }
                inputPower: {
                    if (platformInterface.request_usb_power_notification.port === 1){
                        var inputCurrent = platformInterface.request_usb_power_notification.input_current;
                        var correctedInputCurrent= platformInterface.adjust_current ? inputCurrent * platformInterface.oldFirmwareScaleFactor : inputCurrent
                        return ((platformInterface.request_usb_power_notification.input_voltage * correctedInputCurrent)+2).toFixed(2); //PTJ-1321 adding 2 watts compensation
                    }
                    else{
                        return miniInfo1.inputPower;
                    }
                }
                outputVoltage:{
                    if (platformInterface.request_usb_power_notification.port === 1){
                        return (platformInterface.request_usb_power_notification.output_voltage).toFixed(2)
                    }
                    else{
                        return miniInfo1.outputVoltage;
                    }
                }
                portTemperature:{
                    if (platformInterface.request_usb_power_notification.port === 1){
                        return (platformInterface.request_usb_power_notification.temperature).toFixed(1);
                    }
                    else{
                        return miniInfo1.portTemperature;
                    }
                }
                outputPower: {
                    if (platformInterface.request_usb_power_notification.port === 1){
                        var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                        var correctedOutputCurrent= platformInterface.adjust_current ? outputCurrent * platformInterface.oldFirmwareScaleFactor : outputCurrent
                        return (platformInterface.request_usb_power_notification.output_voltage * correctedOutputCurrent).toFixed(2)
                    }
                    else{
                        return miniInfo1.outputPower;
                    }
                }
                portEfficency: {
                    return theEfficiencyAverage;
                }

            }

            PortInfoMini {
                id: miniInfo2
                portNum: 2
                anchors {
                    top: capacityBar.bottom
                    topMargin: 10
                    left: miniInfo1.right
                    leftMargin: 20
                    bottom: margins.bottom
                }
                width: margins.width / 4 - 15
                portColor: "#69db67"

                property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state
                property int theRunningTotal: 0
                property int theEfficiencyCount: 0
                property int theEfficiencyAverage: 0

                property var periodicValues: platformInterface.request_usb_power_notification

                onPeriodicValuesChanged: {
                    var inputCurrent = platformInterface.request_usb_power_notification.input_current;
                    var correctedInputCurrent= platformInterface.adjust_current ? inputCurrent * platformInterface.oldFirmwareScaleFactor : inputCurrent
                    var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                    var correctedOutputCurrent= platformInterface.adjust_current ? outputCurrent * platformInterface.oldFirmwareScaleFactor : outputCurrent
                    var theInputPower = platformInterface.request_usb_power_notification.input_voltage * correctedInputCurrent +2;//PTJ-1321 2 Watt compensation
                    var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * correctedOutputCurrent;

                    if (platformInterface.request_usb_power_notification.port === 2){
                        //sum eight values of the efficency and average before displaying
                        var theEfficiency = Math.round((theOutputPower/theInputPower) *100)
                        miniInfo2.theRunningTotal += theEfficiency;
                        //console.log("new efficiency value=",theEfficiency,"new total is",miniInfo1.theRunningTotal,miniInfo1.theEfficiencyCount);
                        miniInfo2.theEfficiencyCount++;

                        if (miniInfo2.theEfficiencyCount == 8){
                            miniInfo2.theEfficiencyAverage = miniInfo2.theRunningTotal/8;
                            miniInfo2.theEfficiencyCount = 0;
                            miniInfo2.theRunningTotal = 0
                        }
                    }

                }

                onDeviceConnectedChanged: {
                    if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_2"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            miniInfo2.portConnected = true;
                        }
                    }
                }

                onDeviceDisconnectedChanged: {
                    if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_2"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            miniInfo2.portConnected = false;
                        }

                    }
                }

                negotiatedVoltage:{
                    if (platformInterface.request_usb_power_notification.port === 2){
                        return platformInterface.request_usb_power_notification.negotiated_voltage
                    }
                    else{
                        return miniInfo2.negotiatedVoltage;
                    }
                }
                maxPower:{
                    if (platformInterface.request_usb_power_notification.port === 2){
                        var voltage = platformInterface.request_usb_power_notification.negotiated_voltage;
                        var current = platformInterface.request_usb_power_notification.negotiated_current;
                        return Math.round(voltage*current *100)/100;
                    }
                    else if (!miniInfo2.portConnected){
                       return "—"  //show a dash on disconnect, so cached value won't show on connect
                     }
                    else{
                        return miniInfo2.maxPower;
                    }
                }
                inputPower: {
                    if (platformInterface.request_usb_power_notification.port === 2){
                        var inputCurrent = platformInterface.request_usb_power_notification.input_current;
                        var correctedInputCurrent= platformInterface.adjust_current ? inputCurrent * platformInterface.oldFirmwareScaleFactor : inputCurrent
                        return ((platformInterface.request_usb_power_notification.input_voltage * correctedInputCurrent)+2).toFixed(2); //PTJ-1321 adding 2 watts compensation
                    }
                    else{
                        return miniInfo2.inputPower;
                    }
                }
                outputVoltage:{
                    if (platformInterface.request_usb_power_notification.port === 2){
                        return (platformInterface.request_usb_power_notification.output_voltage).toFixed(2)
                    }
                    else{
                        return miniInfo2.outputVoltage;
                    }
                }
                portTemperature:{
                    if (platformInterface.request_usb_power_notification.port === 2){
                        return Math.round(platformInterface.request_usb_power_notification.temperature * 10)/10;
                    }
                    else{
                        return miniInfo2.portTemperature;
                    }
                }
                outputPower: {
                    if (platformInterface.request_usb_power_notification.port === 2){
                        var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                        var correctedOutputCurrent= platformInterface.adjust_current ? outputCurrent * platformInterface.oldFirmwareScaleFactor : outputCurrent
                        return (platformInterface.request_usb_power_notification.output_voltage * correctedOutputCurrent).toFixed(2)
                    }
                    else{
                        return miniInfo2.outputPower;
                    }
                }
                portEfficency: theEfficiencyAverage
            }

            PortInfoMini {
                id: miniInfo3
                portNum: 3
                anchors {
                    top: capacityBar.bottom
                    topMargin: 10
                    left: miniInfo2.right
                    leftMargin: 20
                    bottom: margins.bottom
                }
                width: margins.width / 4 - 15
                portColor: "#e09a69"

                property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state
                property int theRunningTotal: 0
                property int theEfficiencyCount: 0
                property int theEfficiencyAverage: 0

                property var periodicValues: platformInterface.request_usb_power_notification

                onPeriodicValuesChanged: {
                    var inputCurrent = platformInterface.request_usb_power_notification.input_current;
                    var correctedInputCurrent= platformInterface.adjust_current ? inputCurrent * platformInterface.oldFirmwareScaleFactor : inputCurrent
                    var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                    var correctedOutputCurrent= platformInterface.adjust_current ? outputCurrent * platformInterface.oldFirmwareScaleFactor : outputCurrent
                    var theInputPower = platformInterface.request_usb_power_notification.input_voltage * correctedInputCurrent +2;//PTJ-1321 2 Watt compensation
                    var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * correctedOutputCurrent;

                    if (platformInterface.request_usb_power_notification.port === 3){
                        //sum eight values of the efficency and average before displaying
                        var theEfficiency = Math.round((theOutputPower/theInputPower) *100)
                        miniInfo3.theRunningTotal += theEfficiency;
                        miniInfo3.theEfficiencyCount++;

                        if (miniInfo3.theEfficiencyCount == 8){
                            miniInfo3.theEfficiencyAverage = miniInfo3.theRunningTotal/8;
                            miniInfo3.theEfficiencyCount = 0;
                            miniInfo3.theRunningTotal = 0
                        }
                    }

                }

                onDeviceConnectedChanged: {
                    if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_3"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            miniInfo3.portConnected = true;
                        }
                    }
                }

                onDeviceDisconnectedChanged: {
                    if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_3"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            miniInfo3.portConnected = false;
                        }

                    }
                }

                negotiatedVoltage:{
                    if (platformInterface.request_usb_power_notification.port === 3){
                        return platformInterface.request_usb_power_notification.negotiated_voltage
                    }
                    else{
                        return miniInfo3.negotiatedVoltage;
                    }
                }
                maxPower:{
                    if (platformInterface.request_usb_power_notification.port === 3){
                        var voltage = platformInterface.request_usb_power_notification.negotiated_voltage;
                        var current = platformInterface.request_usb_power_notification.negotiated_current;
                        return Math.round(voltage*current *100)/100;
                    }
                    else if (!miniInfo3.portConnected){
                       return "—"  //show a dash on disconnect, so cached value won't show on connect
                     }
                    else{
                        return miniInfo3.maxPower;
                    }
                }
                inputPower: {
                    if (platformInterface.request_usb_power_notification.port === 3){
                        var inputCurrent = platformInterface.request_usb_power_notification.input_current;
                        var correctedInputCurrent= platformInterface.adjust_current ? inputCurrent * platformInterface.oldFirmwareScaleFactor : inputCurrent
                        return ((platformInterface.request_usb_power_notification.input_voltage * correctedInputCurrent)+2).toFixed(2)  //PTJ-1321 adding 2 watts compensation
                    }
                    else{
                        return miniInfo3.inputPower;
                    }
                }
                outputVoltage:{
                    if (platformInterface.request_usb_power_notification.port === 3){
                        return (platformInterface.request_usb_power_notification.output_voltage).toFixed(2)
                    }
                    else{
                        return miniInfo3.outputVoltage;
                    }
                }
                portTemperature:{
                    if (platformInterface.request_usb_power_notification.port === 3){
                        return Math.round(platformInterface.request_usb_power_notification.temperature*10)/10;
                    }
                    else{
                        return miniInfo3.portTemperature;
                    }
                }
                outputPower: {
                    if (platformInterface.request_usb_power_notification.port === 3){
                        var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                        var correctedOutputCurrent= platformInterface.adjust_current ? outputCurrent * platformInterface.oldFirmwareScaleFactor : outputCurrent
                        return (platformInterface.request_usb_power_notification.output_voltage * correctedOutputCurrent).toFixed(2)
                    }
                    else{
                        return miniInfo3.outputPower;
                    }
                }
                portEfficency: theEfficiencyAverage
            }

            PortInfoMini {
                id: miniInfo4
                portNum: 4
                anchors {
                    top: capacityBar.bottom
                    topMargin: 10
                    left: miniInfo3.right
                    leftMargin: 20
                    bottom: margins.bottom
                }
                width: margins.width / 4 - 15
                portConnected: false
                portColor: "#2348cd"

                property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state
                property int theRunningTotal: 0
                property int theEfficiencyCount: 0
                property int theEfficiencyAverage: 0

                property var periodicValues: platformInterface.request_usb_power_notification

                onPeriodicValuesChanged: {
                    var inputCurrent = platformInterface.request_usb_power_notification.input_current;
                    var correctedInputCurrent= platformInterface.adjust_current ? inputCurrent * platformInterface.oldFirmwareScaleFactor : inputCurrent
                    var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                    var correctedOutputCurrent= platformInterface.adjust_current ? outputCurrent * platformInterface.oldFirmwareScaleFactor : outputCurrent
                    var theInputPower = platformInterface.request_usb_power_notification.input_voltage * correctedInputCurrent +2;//PTJ-1321 2 Watt compensation
                    var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * correctedOutputCurrent;

                    if (platformInterface.request_usb_power_notification.port === 4){
                        //sum eight values of the efficency and average before displaying
                        var theEfficiency = Math.round((theOutputPower/theInputPower) *100)
                        miniInfo4.theRunningTotal += theEfficiency;
                        miniInfo4.theEfficiencyCount++;

                        if (miniInfo4.theEfficiencyCount == 8){
                            miniInfo4.theEfficiencyAverage = miniInfo4.theRunningTotal/8;
                            miniInfo4.theEfficiencyCount = 0;
                            miniInfo4.theRunningTotal = 0
                        }
                    }
                }

                onDeviceConnectedChanged: {
                    if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_4"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            miniInfo4.portConnected = true;
                        }
                    }
                }

                onDeviceDisconnectedChanged: {
                    if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_4"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            miniInfo4.portConnected = false;
                        }

                    }
                }

                negotiatedVoltage:{
                    if (platformInterface.request_usb_power_notification.port === 4){
                        return platformInterface.request_usb_power_notification.negotiated_voltage
                    }
                    else{
                        return miniInfo4.negotiatedVoltage;
                    }
                }
                maxPower:{
                    if (platformInterface.request_usb_power_notification.port === 4){
                        var voltage = platformInterface.request_usb_power_notification.negotiated_voltage;
                        var current = platformInterface.request_usb_power_notification.negotiated_current;
                        return Math.round(voltage*current *100)/100;
                    }
                    else if (!miniInfo4.portConnected){
                       return "—"  //show a dash on disconnect, so cached value won't show on connect
                     }
                    else{
                        return miniInfo4.maxPower;
                    }
                }
                inputPower: {
                    if (platformInterface.request_usb_power_notification.port === 4){
                        var inputCurrent = platformInterface.request_usb_power_notification.input_current;
                        var correctedInputCurrent= platformInterface.adjust_current ? inputCurrent * platformInterface.oldFirmwareScaleFactor : inputCurrent
                        return ((platformInterface.request_usb_power_notification.input_voltage * correctedInputCurrent)+2).toFixed(2) ; //PTJ-1321 adding 2 watts compensation
                    }
                    else{
                        return miniInfo4.inputPower;
                    }
                }
                outputVoltage:{
                    if (platformInterface.request_usb_power_notification.port === 4){
                        return (platformInterface.request_usb_power_notification.output_voltage).toFixed(2)
                    }
                    else{
                        return miniInfo4.outputVoltage;
                    }
                }
                portTemperature:{
                    if (platformInterface.request_usb_power_notification.port === 4){
                        return Math.round(platformInterface.request_usb_power_notification.temperature*10)/10;
                    }
                    else{
                        return miniInfo4.portTemperature;
                    }
                }
                outputPower: {
                    if (platformInterface.request_usb_power_notification.port === 4){
                        var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                        var correctedOutputCurrent= platformInterface.adjust_current ? outputCurrent * platformInterface.oldFirmwareScaleFactor : outputCurrent
                        return (platformInterface.request_usb_power_notification.output_voltage * correctedOutputCurrent).toFixed(2);
                    }
                    else{
                        return miniInfo4.outputPower;
                    }
                }
                portEfficency: theEfficiencyAverage
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

        SGStatusListBox {
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
                    faultListModel.append({"type":"voltage", "port":"0", "status":stateMessage});

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
                if (platformInterface.over_temperature_notification.state === "above"){   //add temp  message to list
                    stateMessage = platformInterface.over_temperature_notification.port
                    stateMessage += " temperature is above ";
                    stateMessage += platformInterface.over_temperature_notification.maximum_temperature;
                    stateMessage += " °C";
                    faultListModel.append({"type":"temperature", "port":platformInterface.over_temperature_notification.port, "status":stateMessage});
                }
                else{                                       //remove temp message for the correct port from list
                    for(var i = 0; i < faultListModel.count; ++i){
                        var theItem = faultListModel.get(i);
                        if (theItem.type === "temperature" && theItem.port === platformInterface.over_temperature_notification.port){
                            faultListModel.remove(i);
                        }
                    }
                }
            }

            ListModel{
                id:faultListModel
            }
        }



        SGOutputLogBox {
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
                    faultHistory.input = stateMessage;

                }
                else{
//                    stateMessage = "Input voltage fault ended at ";
//                    stateMessage += platformInterface.input_under_voltage_notification.minimum_voltage;
//                    stateMessage += " V";
//                    faultHistory.input = stateMessage;
                }
            }

            onOverTempEventChanged: {
                console.log("over temp event received. state=",overTempEvent.state);
                if (overTempEvent.state === "above"){   //add temp  message to list
                    stateMessage = platformInterface.over_temperature_notification.port
                    stateMessage += " temperature is above ";
                    stateMessage += platformInterface.over_temperature_notification.maximum_temperature;
                    stateMessage += " °C";
                    faultHistory.input = stateMessage;
                    console.log("added over temp event to history")
                }
                else{
//                    stateMessage = platformInterface.over_temperature_notification.port
//                    stateMessage += " temperature went below ";
//                    stateMessage += platformInterface.over_temperature_notification.maximum_temperature;
//                    stateMessage += " °C";
//                    faultHistory.input = stateMessage;
                }


            }
        }
    }
}
