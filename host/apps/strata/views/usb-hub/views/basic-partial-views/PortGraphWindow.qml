import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Window 2.12
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id: root

    property string title: "<b>Port " + portNumber + "</b>"
    //property color overlaycolor: "tomato"

    //property alias portNumber: port.portNumber
    //property alias portConnected: port.portConnected

    property alias open: popoutWindow.visible
    property alias windowWidth: popoutWindow.width
    property alias windowHeight: popoutWindow.height
    property alias graph1: popoutWindow.graph1
    property alias graph2: popoutWindow.graph2
    property alias graph3: popoutWindow.graph3
    property alias graph4: popoutWindow.graph4
    property alias graph5: popoutWindow.graph5
    property alias graph6: popoutWindow.graph6

    property int howManyChecked: 0
    onHowManyCheckedChanged: {
        if (howManyChecked == 0){
            popoutWindow.close();
        }
        else{
            popoutWindow.width = 300 * howManyChecked;
        }
    }

    signal windowClosed

    Window {
        id: popoutWindow
        visible: false
        flags: Qt.Tool | Qt.BypassWindowManagerHint
        //height: root.height

        property alias graph1: portGraphs.portGraphsGraph1
        property alias graph2: portGraphs.portGraphsGraph2
        property alias graph3: portGraphs.portGraphsGraph3
        property alias graph4: portGraphs.portGraphsGraph4
        property alias graph5: portGraphs.portGraphsGraph5
        property alias graph6: portGraphs.portGraphsGraph6

        Rectangle {
            id: poppedWindow
            anchors {
                fill: parent
            }
            color: "white"
        }

        Row {
            id: portGraphs
            anchors {
                top: parent.top
                topMargin: 15
                left: parent.left
                right: parent.right
            }
            height:250

            property alias portGraphsGraph1: graph1
            property alias portGraphsGraph2: graph2
            property alias portGraphsGraph3: graph3
            property alias portGraphsGraph4: graph4
            property alias portGraphsGraph5: graph5
            property alias portGraphsGraph6: graph6

            SGGraph {
                id: graph1
                title: "Voltage Out"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, root.howManyChecked)
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

            SGGraph {
                id: graph2
                title: "Current Out"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, root.howManyChecked)
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

            SGGraph {
                id: graph3
                title: "Current In"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, root.howManyChecked)
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

            SGGraph {
                id: graph4
                title: "Power Out"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, root.howManyChecked)
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

            SGGraph {
                id: graph5
                title: "Power In"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, root.howManyChecked)
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

            SGGraph {
                id: graph6
                title: "Efficiency"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, root.howManyChecked)
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

        MouseArea {
            id: resize
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            width: 15
            height: 15
            enabled: true//popout.state === "popped"
            cursorShape: Qt.SizeFDiagCursor

            onPressed: {
                root.clickPos  = Qt.point(mouse.x,mouse.y)
            }

            onPositionChanged: {
                var delta = Qt.point(mouse.x-root.clickPos.x, mouse.y-root.clickPos.y)
                popoutWindow.width += delta.x;
                //popoutWindow.height += delta.y;
            }


//            Text {
//                id: resizeHint
//                text: "\u0023"
//                rotation: -45
//                opacity: 0.15
//                anchors {
//                    right: parent.right
//                    rightMargin: 4
//                    bottom: parent.bottom
//                }
//                font {
//                    pixelSize: 18
//                    family: sgicons.name
//                }
//            }
        }
        onClosing: {
            console.log("graph window closing");
            root.windowClosed();
            //add code here to turn off the buttons in the corresponding port

        }
    }   //Window

}
