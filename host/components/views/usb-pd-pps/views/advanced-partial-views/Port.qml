import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
//import "../../sgwidgets"
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as SGWidgets09

Item {
    id: root

    property bool debugLayout: true
    property int portNumber: 1
    property alias portConnected: portInfo.portConnected
    property alias portColor: portInfo.portColor
    property bool showGraphs: true

    width: parent.width
    height: portSettings.height + portGraphs.height


    PortInfo {
        id: portInfo
        anchors {
            left: parent.left
            top: root.top
            topMargin: 110
        }
        advertisedVoltage:{
            if (platformInterface.usb_power_notification.port === portNumber){
                return platformInterface.usb_power_notification.negotiated_voltage
            }
            else{
                return portInfo.advertisedVoltage;
            }
        }
        pdContract:{
            if (platformInterface.usb_power_notification.port === portNumber){
               return (platformInterface.usb_power_notification.negotiated_current * platformInterface.usb_power_notification.negotiated_voltage);
            }
            else{
                return portInfo.pdContract;
            }
        }
        inputPower:{
            if (platformInterface.usb_power_notification.port === portNumber){
                return (platformInterface.usb_power_notification.input_voltage * platformInterface.usb_power_notification.input_current).toFixed(2);
            }
            else{
                return portInfo.inputPower;
            }
        }
        outputPower:{
            if (platformInterface.usb_power_notification.port === portNumber){
                return (platformInterface.usb_power_notification.output_voltage * platformInterface.usb_power_notification.output_current).toFixed(2);
            }
            else{
                return portInfo.outputPower;
            }
        }
        outputVoltage:{
            if (platformInterface.usb_power_notification.port === portNumber){
                return (platformInterface.usb_power_notification.output_voltage).toFixed(2);
            }
            else{
                return portInfo.outputVoltage;
            }
        }
        portTemperature:{
            if (platformInterface.usb_power_notification.port === portNumber){
                return (platformInterface.usb_power_notification.temperature).toFixed(1);
            }
            else{
                return portInfo.portTemperature;
            }
        }
//        efficency: {
//            var theInputPower = platformInterface.usb_power_notification.input_voltage * platformInterface.usb_power_notification.input_current;
//            var theOutputPower = platformInterface.usb_power_notification.output_voltage * platformInterface.usb_power_notification.output_current;

//            if (platformInterface.usb_power_notification.port === portNumber){
//                if (theInputPower == 0){    //division by 0 would normally give "nan"
//                    return "—"
//                }
//                else{
//                    //return Math.round((theOutputPower/theInputPower)*100)/100
//                    return "—"
//                }
//            }
//            else{
//                return portInfo.efficency;
//            }
//        }
    }







    PortSettings {
        id: portSettings
        anchors {
            left: portInfo.right
            top: root.top
            right: root.right
        }
        height: 225

        SGWidgets09.SGLayoutDivider {
            position: "left"
        }
    }

    Row {
        id: portGraphs
        anchors {
            top: portSettings.bottom
            topMargin: 5
            left: root.left
            right: root.right
        }
        height:250

        SGWidgets09.SGGraphTimed {
            id: graph1
            title: "Voltage Bus"
            visible: true
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
            }
            width: portGraphs.width /  4
            yAxisTitle: "V"
            xAxisTitle: "Seconds"
            minYValue: 0                    // Default: 0
            maxYValue: 23                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.usb_power_notification.output_voltage
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGWidgets09.SGGraphTimed {
            id: graph2
            title: "Current Out"
            visible: true
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph1.right
            }
            width: portGraphs.width /  4
            yAxisTitle: "A"
            xAxisTitle: "Seconds"

            minYValue: 0                    // Default: 0
            maxYValue: 5                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.usb_power_notification.output_current
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGWidgets09.SGGraphTimed {
            id: graph3
            title: "Voltage In"
            visible: true
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph2.right
            }
            width: portGraphs.width /  4
            yAxisTitle: "V"
            xAxisTitle: "Seconds"

            minYValue: 0                    // Default: 0
            maxYValue: 32                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.usb_power_notification.input_current
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGWidgets09.SGGraphTimed {
            id: graph4
            title: "Power Out"
            visible: true
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph3.right
            }
            width: portGraphs.width /  4
            yAxisTitle: "W"
            xAxisTitle: "Seconds"
            minYValue: 0                    // Default: 0
            maxYValue: 60                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.usb_power_notification.output_voltage *
                            platformInterface.usb_power_notification.output_current;
                }
            }

            inputData: stream          // Set the graph's data source here
        }




    }

}
