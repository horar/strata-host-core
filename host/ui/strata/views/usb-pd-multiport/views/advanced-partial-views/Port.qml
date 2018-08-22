import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id: root

    property bool debugLayout: true
    property int portNumber: 1
    property alias portConnected: portInfo.portConnected
    property alias portColor: portInfo.portColor
    property bool showGraphs: false

    width: parent.width
    height: graphSelector.nothingChecked ? portSettings.height : portSettings.height + portGraphs.height

    PortInfo {
        id: portInfo
        anchors {
            left: parent.left
            top: root.top
            bottom: graphSelector.top
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
            if (platformInterface.request_usb_power_notification.port === portNumber){
               return Math.round(platformInterface.request_usb_power_notification.maximum_power *100)/100
            }
            else{
                return portInfo.maxPower;
            }
        }
        inputPower:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return Math.round(platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current *100)/100
            }
            else{
                return portInfo.inputPower;
            }
        }
        outputPower:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return Math.round(platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current *100)/100
            }
            else{
                return portInfo.outputPower;
            }
        }
        outputVoltage:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return Math.round(platformInterface.request_usb_power_notification.output_voltage *100)/100
            }
            else{
                return portInfo.outputVoltage;
            }
        }
        portTemperature:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return platformInterface.request_usb_power_notification.temperature
            }
            else{
                return portInfo.portTemperature;
            }
        }
        efficency: {
            var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current;
            var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current;

            if (platformInterface.request_usb_power_notification.port === portNumber){
                if (theInputPower == 0){    //division by 0 would normally give "nan"
                    return "—"
                }
                else{
                    //return Math.round((theOutputPower/theInputPower)*100)/100
                    return "—"
                }
            }
            else{
                return portInfo.efficency;
            }
        }
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

        SGGraph {
            id: graph1
            title: "Voltage Out"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "V"
            xAxisTitle: "Seconds"
            minYValue: 0                    // Default: 0
            maxYValue: 22                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream
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

        SGGraph {
            id: graph2
            title: "Current Out"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph1.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "A"
            xAxisTitle: "Seconds"

            minYValue: 0                    // Default: 0
            maxYValue: 6                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream
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

        SGGraph {
            id: graph3
            title: "Current In"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph2.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "A"
            xAxisTitle: "Seconds"

            minYValue: 0                    // Default: 0
            maxYValue: 6                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream
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

        SGGraph {
            id: graph4
            title: "Power Out"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph3.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "W"
            xAxisTitle: "Seconds"
            minYValue: 0                    // Default: 0
            maxYValue: 110                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream
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

        SGGraph {
            id: graph5
            title: "Power In"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph4.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "W"
            xAxisTitle: "Seconds"
            minYValue: 0                    // Default: 0
            maxYValue: 110                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream
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

        SGGraph {
            id: graph6
            title: "Efficiency"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                //                left: graph4.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "Percent"
            xAxisTitle: "Seconds"

            minYValue: 0                    // Default: 0
            maxYValue: 100                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream
            property real count: 0
            property real interval: 10 // 10 Hz?
            property real inputPower: 0
            property real outputPower: 0

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.request_usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    inputPower = platformInterface.request_usb_power_notification.input_voltage *
                            platformInterface.request_usb_power_notification.input_current;
                    outputPower = platformInterface.request_usb_power_notification.output_voltage *
                            platformInterface.request_usb_power_notification.output_current;
                    //console.log("inputPower=",inputPower," outputPower=",outputPower,(outputPower/inputPower)*100);
                    if (inputPower == 0)
                        stream = 0;
                    else{
                        stream = (outputPower/inputPower)*100;
                    }
                }
            }

            inputData: stream          // Set the graph's data source here
        }
    }
}
