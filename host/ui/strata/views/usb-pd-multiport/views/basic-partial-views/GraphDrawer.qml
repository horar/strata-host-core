import QtQuick 2.9
import QtQuick.Controls 2.2
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id:root

    property real slideDuration: 200
    property real menuWidth: 450
    property real hintWidth: 0 //20
    property alias state: menuContainer.state
    property int portNumber: 1

    anchors {
        fill: parent
    }

    Rectangle {
        id: menuContainer
        width: root.menuWidth
        height: root.height
        x: root.width-hintWidth
        z: 3
        color: "#282a2b"

        MouseArea {
            // This blocks all mouseEvents from propagating through the menu to stuff below
            anchors { fill: parent }
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: false
        }

        Column  {
            id: menuItems
            width: parent.width
            anchors { verticalCenter: menuContainer.verticalCenter }
            visible: false
        }

        Text {
            id: hintIcon
            text: "\ue811"
            color: "#ddd"
            font {
                pixelSize: 25
                family: sgicons.name
            }
            anchors {
                verticalCenter: menuContainer.verticalCenter
                left: menuContainer.left
            }
            Behavior on opacity { NumberAnimation { duration: root.slideDuration } }
        }

        MouseArea{
            id: menuHover
            anchors {
                fill:parent
            }
            hoverEnabled: true
            onEntered: {
                menuContainer.state = "open"
            }
        }

        states: [
            State {
                name: "open"
            },
            State {
                name: "closed"
            }
        ]

        transitions: [ Transition {
                from: "*"
                to: "open"
                NumberAnimation {
                    target: menuContainer
                    property: "x"
                    duration: root.slideDuration
                    from: menuContainer.x
                    to: root.width - root.menuWidth
                }
                NumberAnimation {
                    target: hintIcon
                    property: "opacity"
                    duration: root.slideDuration
                    from: 1
                    to: 0
                }
                NumberAnimation {
                    target: modalArea
                    property: "opacity"
                    duration: root.slideDuration
                    from: 0
                    to: 0.2
                }
                onRunningChanged: {
                    if (!running){
                        menuHover.visible = false
                        remainderHover.visible = true
                    } else {
                        menuItems.visible = true
                    }
                }
            },
            Transition {
                from: "open"
                to: "closed"
                NumberAnimation {
                    target: menuContainer
                    property: "x"
                    duration: root.slideDuration
                    to: root.width - root.hintWidth
                    from: menuContainer.x
                }
                NumberAnimation {
                    target: hintIcon
                    property: "opacity"
                    duration: root.slideDuration
                    from: 0
                    to: 1
                }
                NumberAnimation {
                    target: modalArea
                    property: "opacity"
                    duration: root.slideDuration
                    from: 0.2
                    to: 0
                }
                onRunningChanged: {
                    if (!running){
                        menuHover.visible = true
                        remainderHover.visible = false
                        menuItems.visible = false
                    }
                }
            }
        ]

        SGGraph{
            id:voltageGraph
            anchors.left: menuContainer.left
            anchors.right:menuContainer.right
            anchors.top: menuContainer.top
            height: 275

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

            // Optional graph settings:
            title: "Port "+portNumber+ " Voltage" // Default: empty
            xAxisTitle: "Seconds"           // Default: empty
            yAxisTitle: "V"                 // Default: empty
            textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this property
            dataLineColor: "white"          // Default: #000000 (black)
            axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
            gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
            underDataColor: "transparent"   // Default: Qt.rgba(.5, .5, .5, .3) (transparent gray)
            backgroundColor: "black"        // Default: #ffffff (white)
            minYValue: 0                    // Default: 0
            maxYValue: 25                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10
            showXGrids: false               // Default: false
            showYGrids: true                // Default: false
            showOptions: true               // Default: false - shows an options button to toggle centered
            throttlePlotting: true          // Default: true - Plots new data no more than every 100ms to save CPU & memory resources, otherwise points plotted on every inputData change
            repeatOldData: false            // Default: visible - If no new data has been sent after 200ms, graph will plot a new point at the current time with the last input value
                                                            //  by default matches visibility of graph, so it doesn't waste CPU in the background.
        }


        SGGraph{
            id:powerGraph
            anchors.left: menuContainer.left
            anchors.right:menuContainer.right
            anchors.top: voltageGraph.bottom
            height: 275

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

            // Optional graph settings:
            title: "Port "+portNumber+ " Power" // Default: empty
            xAxisTitle: "Seconds"           // Default: empty
            yAxisTitle: "W"                 // Default: empty
            textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this property
            dataLineColor: "white"          // Default: #000000 (black)
            axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
            gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
            underDataColor: "transparent"   // Default: Qt.rgba(.5, .5, .5, .3) (transparent gray)
            backgroundColor: "black"        // Default: #ffffff (white)
            minYValue: 0                    // Default: 0
            maxYValue: 120                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10
            showXGrids: false               // Default: false
            showYGrids: true                // Default: false
            showOptions: true               // Default: false - shows an options button to toggle centered
            throttlePlotting: true          // Default: true - Plots new data no more than every 100ms to save CPU & memory resources, otherwise points plotted on every inputData change
            repeatOldData: false            // Default: visible - If no new data has been sent after 200ms, graph will plot a new point at the current time with the last input value
                                                            //  by default matches visibility of graph, so it doesn't waste CPU in the background.
        }
        SGGraph{
            id:temperatureGraph
            anchors.left: menuContainer.left
            anchors.right:menuContainer.right
            anchors.top: powerGraph.bottom
            height: 275

            property real stream
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("temp=",platformInterface.request_usb_power_notification.temperature);
                    count += interval;
                    stream = platformInterface.request_usb_power_notification.temperature;
                }
            }

            inputData: stream          // Set the graph's data source here

            // Optional graph settings:
            title: "Port "+portNumber+ " Temperature" // Default: empty
            xAxisTitle: "Seconds"           // Default: empty
            yAxisTitle: "°C"                 // Default: empty
            textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this property
            dataLineColor: "white"          // Default: #000000 (black)
            axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
            gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
            underDataColor: "transparent"   // Default: Qt.rgba(.5, .5, .5, .3) (transparent gray)
            backgroundColor: "black"        // Default: #ffffff (white)
            minYValue: 0                    // Default: 0
            maxYValue: 120                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                   // Default: 10
            showXGrids: false               // Default: false
            showYGrids: true                // Default: false
            showOptions: true               // Default: false - shows an options button to toggle centered
            throttlePlotting: true          // Default: true - Plots new data no more than every 100ms to save CPU & memory resources, otherwise points plotted on every inputData change
            repeatOldData: false            // Default: visible - If no new data has been sent after 200ms, graph will plot a new point at the current time with the last input value
                                                            //  by default matches visibility of graph, so it doesn't waste CPU in the background.


        }

//        Text {
//            text: "<b>Graphs Here</b>"
//            font {
//                pixelSize: 50
//            }
//            color: "#fff"
//            anchors {
//                centerIn: parent
//            }
//        }
    }

    MouseArea{
        id: remainderHover
        anchors {
            left: root.left
            top: root.top
            bottom: root.bottom
            right: menuContainer.left
        }
        //hoverEnabled: true
        visible: false
        onClicked: {
            menuContainer.state = "closed"
            //drawerMenuItems.closer()
        }
    }

    Rectangle {
        id: modalArea
        color: "#000"
        opacity: 0
        z: 1
        anchors {
            fill: remainderHover
        }
    }

    FontLoader {
        id: sgicons
        source: "../../sgwidgets/fonts/sgicons.ttf"
    }
}
