import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import tech.strata.sgwidgets 1.0

Item {
    id: root

    property bool debugLayout: true
    property int portNumber: 1
    property alias portConnected: portInfo.portConnected
    property alias portColor: portInfo.portColor
    property bool showGraphs: false
    property alias enableAssuredPower: portSettings.assuredPortPowerEnabled

    width: parent.width
    height: {
        if (graphSelector.nothingChecked || !portConnected){
            portSettings.height;
        }
        else if (!graphSelector.nothingChecked && portConnected){
           portSettings.height + portGraphs.height;
        }

    }

    PortInfo {
        id: portInfo
        anchors {
            left: parent.left
            top: root.top
            bottom: graphSelector.top
        }

        property int theRunningTotal: 0
        property int theEfficiencyCount: 0
        property int theEfficiencyAverage: 0

        property var periodicValues: platformInterface.request_usb_power_notification

        onPeriodicValuesChanged: {
            var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current +2;//PTJ-1321 2 Watt compensation
            var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current;

            if (platformInterface.request_usb_power_notification.port === portNumber){
                //sum eight values of the efficency and average before displaying
                var theEfficiency = Math.round((theOutputPower/theInputPower) *100)
                portInfo.theRunningTotal += theEfficiency;
                //console.log("new efficiency value=",theEfficiency,"new total is",miniInfo1.theRunningTotal,miniInfo1.theEfficiencyCount);
                portInfo.theEfficiencyCount++;

                if (portInfo.theEfficiencyCount === 8){
                    portInfo.theEfficiencyAverage = portInfo.theRunningTotal/8;
                    portInfo.theEfficiencyCount = 0;
                    portInfo.theRunningTotal = 0

                    //console.log("publishing new efficency",miniInfo1.theEfficiencyAverage);
                    //return miniInfo1.theEfficiencyAverage
                }
            }

        }
        advertisedVoltage:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return platformInterface.request_usb_power_notification.negotiated_voltage
            }
            else{
                return portInfo.advertisedVoltage;
            }
        }
        maxPower:{
            //labeled "PD Contract" in the UI, this is the wattage agreed to by the platform and device
            if (platformInterface.request_usb_power_notification.port === portNumber){
                var voltage = platformInterface.request_usb_power_notification.negotiated_voltage;
                var current = platformInterface.request_usb_power_notification.negotiated_current;
                return Math.round(voltage*current *100)/100;
            }
            else{
                return portInfo.maxPower;
            }
        }
        inputPower:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return ((platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current)+2).toFixed(2); //PTJ-1321 adding 2 watts compensation
            }
            else{
                return portInfo.inputPower;
            }
        }
        outputPower:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return (platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current).toFixed(2);
            }
            else{
                return portInfo.outputPower;
            }
        }
        outputVoltage:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return (platformInterface.request_usb_power_notification.output_voltage).toFixed(2);
            }
            else{
                return portInfo.outputVoltage;
            }
        }
        portTemperature:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return (platformInterface.request_usb_power_notification.temperature).toFixed(1)
            }
            else{
                return portInfo.portTemperature;
            }
        }
        efficency: theEfficiencyAverage
    }

    SGSegmentedButtonStrip {
        id: graphSelector
        label: "<b>Show Graphs:</b>"
        labelLeft: false
        anchors {
            bottom: portSettings.bottom
            bottomMargin: 15
            horizontalCenter: portInfo.horizontalCenter
        }
        textColor: "#666"
        activeTextColor: "white"
        radius: 4
        buttonHeight: 25
        exclusive: false
        buttonImplicitWidth: 50
        enabled: root.portConnected
        property int howManyChecked: 0

        segmentedButtons: GridLayout {
            columnSpacing: 2
            rowSpacing: 2

            SGSegmentedButton{
                text: qsTr("Vout")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph1.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph1.visible = false
                        graphSelector.howManyChecked--
                    }
                }
            }

            SGSegmentedButton{
                text: qsTr("Iout")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph2.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph2.visible = false
                        graphSelector.howManyChecked--
                    }
                }
            }

            SGSegmentedButton{
                text: qsTr("Iin")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph3.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph3.visible = false
                        graphSelector.howManyChecked--
                    }
                }
            }

            SGSegmentedButton{
                text: qsTr("Pout")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph4.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph4.visible = false
                        graphSelector.howManyChecked--
                    }
                }
           }

            SGSegmentedButton{
                text: qsTr("Pin")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph5.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph5.visible = false
                        graphSelector.howManyChecked--
                    }
                }
            }

            SGSegmentedButton{
                text: qsTr("η")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph6.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph6.visible = false
                        graphSelector.howManyChecked--
                    }
                }
            }
        }
    }


    PortSettings {
        id: portSettings
        anchors {
            left: portInfo.right
            top: portInfo.top
            right: root.right
        }
        height: 300

        SGLayoutDivider {
            position: "left"
        }
    }

    Row {
        id: portGraphs
        anchors {
            top: portSettings.bottom
            topMargin: 15
            left: root.left
            right: root.right
        }
        height:250

        SGGraphTimed {
            id: graph1
            title: "Voltage Out"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                bottomMargin:0
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "V"
            xAxisTitle: "1 sec/div"
            minYValue: 0                    // Default: 0
            maxYValue: 25                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.request_usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.request_usb_power_notification.output_voltage
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGGraphTimed {
            id: graph2
            title: "Current Out"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                bottomMargin:0
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "A"
            xAxisTitle: "1 sec/div"

            minYValue: 0                    // Default: 0
            maxYValue: 5                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.request_usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.request_usb_power_notification.output_current
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGGraphTimed {
            id: graph3
            title: "Current In"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                bottomMargin:0
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "A"
            xAxisTitle: "1 sec/div"

            minYValue: 0                    // Default: 0
            maxYValue: 5                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.request_usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.request_usb_power_notification.input_current
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGGraphTimed {
            id: graph4
            title: "Power Out"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                bottomMargin:0
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "W"
            xAxisTitle: "1 sec/div"
            minYValue: 0                    // Default: 0
            maxYValue: 125                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.request_usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.request_usb_power_notification.output_voltage *
                            platformInterface.request_usb_power_notification.output_current;
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGGraphTimed {
            id: graph5
            title: "Power In"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                bottomMargin:0
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "W"
            xAxisTitle: "1 sec/div"
            minYValue: 0                    // Default: 0
            maxYValue: 125                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.request_usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.request_usb_power_notification.input_voltage *
                            platformInterface.request_usb_power_notification.input_current;
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGGraphTimed {
            id: graph6
            title: "Efficiency"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                bottomMargin:0
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "Percent"
            xAxisTitle: "1 sec/div"

            minYValue: 70                    // Default: 0
            maxYValue: 100                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property int theRunningTotal: 0
            property int theEfficiencyCount: 0
            property int theEfficiencyAverage: 0

            property var periodicValues: platformInterface.request_usb_power_notification.output_voltage

            onPeriodicValuesChanged: {
                var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current +2;//PTJ-1321 2 Watt compensation
                var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current;

                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //sum eight values of the efficency and average before displaying
                    var theEfficiency = Math.round((theOutputPower/theInputPower) *100)
                    graph6.theRunningTotal += theEfficiency;
                    //console.log("input=",theInputPower,"output=",theOutputPower,"efficiency=",theEfficiency);
                    //console.log("new efficiency value=",theEfficiency,"new total is",graph6.theRunningTotal,graph6.theEfficiencyCount);
                    graph6.theEfficiencyCount++;

                    if (graph6.theEfficiencyCount === 8){
                        graph6.theEfficiencyAverage = graph6.theRunningTotal/8;
                        graph6.theEfficiencyCount = 0;
                        graph6.theRunningTotal = 0

                        //console.log("publishing new efficency",graph6.theEfficiencyAverage);
                    }

                    if (theInputPower == 0)
                        stream = 0;
                    else{
                        stream = theEfficiencyAverage;
                    }
                }
            }

            inputData: stream          // Set the graph's data source here
        }
    }
}
