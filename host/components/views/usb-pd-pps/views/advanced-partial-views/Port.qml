import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
//import "../../sgwidgets"
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as SGWidgets09
//import tech.strata.sgwidgets 1.0 as SGWidgets10

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
            if (platformInterface.usb_power_notification.port == portNumber){
                return platformInterface.usb_power_notification.negotiated_voltage
            }
            else{
                return portInfo.advertisedVoltage;
            }
        }
        pdContract:{
            if (platformInterface.usb_power_notification.port == portNumber){
               return (platformInterface.usb_power_notification.negotiated_current * platformInterface.usb_power_notification.negotiated_voltage);
            }
            else{
                return portInfo.pdContract;
            }
        }
        inputPower:{
            if (platformInterface.usb_power_notification.port == portNumber){
                return (platformInterface.usb_power_notification.input_voltage * platformInterface.usb_power_notification.input_current).toFixed(2);
            }
            else{
                return portInfo.inputPower;
            }
        }
        outputPower:{
            if (platformInterface.usb_power_notification.port == portNumber){
                return (platformInterface.usb_power_notification.output_voltage * platformInterface.usb_power_notification.output_current).toFixed(2);
            }
            else{
                return portInfo.outputPower;
            }
        }
        outputVoltage:{
            if (platformInterface.usb_power_notification.port == portNumber){
                return (Math.trunc(platformInterface.usb_power_notification.output_voltage *100)/100);
            }
            else{
                return portInfo.outputVoltage;
            }
        }
        portTemperature:{
            if (platformInterface.usb_power_notification.port == portNumber){
                return (Math.trunc(platformInterface.usb_power_notification.temperature*100)/100);
            }
            else{
                return portInfo.portTemperature;
            }
        }

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

        SGGraph{
            id: graph1
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                bottomMargin: 5
            }
            width: portGraphs.width /  4

            title: "Bus Voltage"
            xTitle: "Seconds"
            yTitle: "V"
            yMin: 0
            yMax: 21
            xMin: -5
            xMax: 0
            panXEnabled: false
            panYEnabled: false
            zoomXEnabled: false
            zoomYEnabled: false
            autoUpdate: false
            foregroundColor: "black"
            backgroundColor: "white"


            Timer {
                id: graphTimerPoints
                interval: 60
                running: graph1.visible
                repeat: true

                property real lastTime

                onRunningChanged: {
                    if (running){
                        graph1.curve(0).clear()
                        lastTime = Date.now()
                    }
                }

                onTriggered: {
                    let currentTime = Date.now()
                    let curve = graph1.curve(0)
                    curve.shiftPoints(-(currentTime - lastTime)/1000, 0)
                    curve.append(0, platformInterface.usb_power_notification.output_voltage)
                    if (platformInterface.usb_power_notification.output_voltage > graph1.yMax){
                        graph1.yMax = Math.trunc(platformInterface.usb_power_notification.output_voltage +1)
                        console.log("resetting y max to", graph1.yMax)
                    }
                    removeOutOfViewPoints()
                    graph1.update()
                    lastTime = currentTime
                }

                function removeOutOfViewPoints() {
                    // recursively clean up points that have moved out of view
                    if (graph1.curve(0).at(0).x < graph1.xMin) {
                        graph1.curve(0).remove(0)
                        removeOutOfViewPoints()
                    }
                }
            }



            Component.onCompleted: {
                let movingCurve = createCurve("movingCurve")
                movingCurve.autoUpdate = false
            }
        }

        SGGraph{
            id: graph2
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                bottomMargin: 5
            }
            width: portGraphs.width /  4

            title: "Current Out"
            xTitle: "Seconds"
            yTitle: "A"
            yMin: 0
            yMax: 6
            xMin: -5
            xMax: 0
            panXEnabled: false
            panYEnabled: false
            zoomXEnabled: false
            zoomYEnabled: false
            autoUpdate: false
            foregroundColor: "black"
            backgroundColor: "white"


            Timer {
                id: graph2TimerPoints
                interval: 60
                running: graph2.visible
                repeat: true

                property real lastTime

                onRunningChanged: {
                    if (running){
                        graph2.curve(0).clear()
                        lastTime = Date.now()
                    }
                }

                onTriggered: {
                    let currentTime = Date.now()
                    let curve = graph2.curve(0)
                    curve.shiftPoints(-(currentTime - lastTime)/1000, 0)
                    curve.append(0, platformInterface.usb_power_notification.output_current)
                    //if the value exceeds the max y value of the graph, rescale
                    if (platformInterface.usb_power_notification.output_current > graph2.yMax){
                        graph2.yMax = Math.trunc(platformInterface.usb_power_notification.output_current +1)
                    }
                    removeOutOfViewPoints()
                    graph2.update()
                    lastTime = currentTime
                }

                function removeOutOfViewPoints() {
                    // recursively clean up points that have moved out of view
                    if (graph2.curve(0).at(0).x < graph2.xMin) {
                        graph2.curve(0).remove(0)
                        removeOutOfViewPoints()
                    }
                }
            }



            Component.onCompleted: {
                let movingCurve = createCurve("movingCurve")
                movingCurve.autoUpdate = false
            }
        }

        SGGraph{
            id: graph3
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                bottomMargin: 5
            }
            width: portGraphs.width /  4

            title: "Voltage In"
            xTitle: "Seconds"
            yTitle: "V"
            yMin: 0
            yMax: 32
            xMin: -5
            xMax: 0
            panXEnabled: false
            panYEnabled: false
            zoomXEnabled: false
            zoomYEnabled: false
            autoUpdate: false
            foregroundColor: "black"
            backgroundColor: "white"


            Timer {
                id: graph3TimerPoints
                interval: 60
                running: graph3.visible
                repeat: true

                property real lastTime

                onRunningChanged: {
                    if (running){
                        graph3.curve(0).clear()
                        lastTime = Date.now()
                    }
                }

                onTriggered: {
                    let currentTime = Date.now()
                    let curve = graph3.curve(0)
                    curve.shiftPoints(-(currentTime - lastTime)/1000, 0)
                    curve.append(0, platformInterface.usb_power_notification.input_voltage)
                    if (platformInterface.usb_power_notification.input_voltage > graph3.yMax){
                        graph3.yMax = Math.trunc(platformInterface.usb_power_notification.input_voltage +1)
                    }
                    removeOutOfViewPoints()
                    graph3.update()
                    lastTime = currentTime
                }

                function removeOutOfViewPoints() {
                    // recursively clean up points that have moved out of view
                    if (graph3.curve(0).at(0).x < graph3.xMin) {
                        graph3.curve(0).remove(0)
                        removeOutOfViewPoints()
                    }
                }
            }



            Component.onCompleted: {
                let movingCurve = createCurve("movingCurve")
                movingCurve.autoUpdate = false
            }
        }

        SGGraph{
            id: graph4
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                bottomMargin: 5
            }
            width: portGraphs.width /  4

            title: "Power Out"
            xTitle: "Seconds"
            yTitle: "W"
            yMin: 0
            yMax: 60
            xMin: -5
            xMax: 0
            panXEnabled: false
            panYEnabled: false
            zoomXEnabled: false
            zoomYEnabled: false
            autoUpdate: false
            foregroundColor: "black"
            backgroundColor: "white"


            Timer {
                id: graph4TimerPoints
                interval: 60
                running: graph3.visible
                repeat: true

                property real lastTime

                onRunningChanged: {
                    if (running){
                        graph4.curve(0).clear()
                        lastTime = Date.now()
                    }
                }

                onTriggered: {
                    let currentTime = Date.now()
                    let curve = graph4.curve(0)
                    var power = platformInterface.usb_power_notification.output_voltage *
                            platformInterface.usb_power_notification.output_current
                    curve.shiftPoints(-(currentTime - lastTime)/1000, 0)
                    curve.append(0, power)
                    if (power > graph4.yMax){
                        graph4.yMax = Math.trunc(power +1)
                    }
                    //console.log("appending new point:",platformInterface.usb_power_notification.input_voltage)
                    removeOutOfViewPoints()
                    graph4.update()
                    lastTime = currentTime
                }

                function removeOutOfViewPoints() {
                    // recursively clean up points that have moved out of view
                    if (graph4.curve(0).at(0).x < graph4.xMin) {
                        graph4.curve(0).remove(0)
                        removeOutOfViewPoints()
                    }
                }
            }



            Component.onCompleted: {
                let movingCurve = createCurve("movingCurve")
                movingCurve.autoUpdate = false
            }
        }


    }

}
