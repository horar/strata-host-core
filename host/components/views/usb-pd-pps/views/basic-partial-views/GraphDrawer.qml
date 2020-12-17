
import QtQuick 2.12
//import QtQuick.Window 2.12
import QtQuick.Controls 2.12

//import QtQuick 2.9
//import QtQuick.Controls 2.2
import "../../sgwidgets"
import tech.strata.sgwidgets 1.0 as SGWidgets10

Drawer {
    id:root
    height:parent.height
    width:450
    dragMargin:0
    edge:Qt.RightEdge

    property real slideDuration: 2000
    property real menuWidth: 450
    property real hintWidth: 0 //20
    property alias state: menuContainer.state
    property int portNumber: 1
    //property int graphHeight: 310
    property int graphHeight: root.height/3

    onAboutToShow:{
        openAnimation.start()
    }

    onAboutToHide:{
        closeAnimation.start()
    }

        ParallelAnimation {
            id: openAnimation
            running:false
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
        }

        ParallelAnimation{
            id:closeAnimation
            running:false
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

      Rectangle {
        id: menuContainer
        anchors.fill:parent
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




        SGWidgets10.SGGraph{
            id:voltageGraph
            anchors.left: menuContainer.left
            anchors.right:menuContainer.right
            anchors.top: menuContainer.top
            height: root.graphHeight

            title: " Bus Voltage"
            xTitle: "Seconds"
            yTitle: "V"
            yMin: 0
            yMax: 25
            xMin: -5
            xMax: 0
            panXEnabled: false
            panYEnabled: false
            zoomXEnabled: false
            zoomYEnabled: false
            autoUpdate: false
            foregroundColor: "white"
            backgroundColor: "black"


            Timer {
                id: graphTimerPoints
                interval: 60
                running: voltageGraph.visible
                repeat: true

                property real lastTime

                onRunningChanged: {
                    if (running){
                        voltageGraph.curve(0).clear()
                        lastTime = Date.now()
                    }
                }

                onTriggered: {
                    let currentTime = Date.now()
                    let curve = voltageGraph.curve(0)
                    curve.shiftPoints(-(currentTime - lastTime)/1000, 0)
                    curve.append(0, platformInterface.usb_power_notification.output_voltage)
                    removeOutOfViewPoints()
                    voltageGraph.update()
                    lastTime = currentTime
                }

                function removeOutOfViewPoints() {
                    // recursively clean up points that have moved out of view
                    if (voltageGraph.curve(0).at(0).x < voltageGraph.xMin) {
                        voltageGraph.curve(0).remove(0)
                        removeOutOfViewPoints()
                    }
                }
            }



            Component.onCompleted: {
                let movingCurve = createCurve("movingCurve")
                movingCurve.color = "white"
                movingCurve.autoUpdate = false
            }
        }

        SGWidgets10.SGGraph{
            id:powerGraph
            anchors.left: menuContainer.left
            anchors.right:menuContainer.right
            anchors.top: voltageGraph.bottom
            height: root.graphHeight

            // Optional graph settings:
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
            backgroundColor: "black"
            foregroundColor: "white"

            Timer {
                id: graphTimerPoints2
                interval: 60
                running: powerGraph.visible
                repeat: true

                property real lastTime

                onRunningChanged: {
                    if (running){
                        powerGraph.curve(0).clear()
                        lastTime = Date.now()
                    }
                }

                onTriggered: {
                    let currentTime = Date.now()
                    let curve = powerGraph.curve(0)
                    curve.shiftPoints(-(currentTime - lastTime)/1000, 0)
                    curve.append(0, platformInterface.usb_power_notification.output_current * platformInterface.usb_power_notification.output_voltage)
                    removeOutOfViewPoints()
                    powerGraph.update()
                    lastTime = currentTime
                }

                function removeOutOfViewPoints() {
                    // recursively clean up points that have moved out of view
                    if (powerGraph.curve(0).at(0).x < powerGraph.xMin) {
                        powerGraph.curve(0).remove(0)
                        removeOutOfViewPoints()
                    }
                }
            }


            Component.onCompleted: {
                let movingCurve = createCurve("movingCurve")
                movingCurve.color = "white"
                movingCurve.autoUpdate = false
            }
        }

        SGWidgets10.SGGraph{
            id:temperatureGraph
            anchors.left: menuContainer.left
            anchors.right:menuContainer.right
            anchors.top: powerGraph.bottom
            height: root.graphHeight

            // Optional graph settings:
            title: " Temperature"
            xTitle: "Seconds"
            yTitle: "°C"
            yMin: 0
            yMax: 100
            xMin: -5
            xMax: 0
            panXEnabled: false
            panYEnabled: false
            zoomXEnabled: false
            zoomYEnabled: false
            autoUpdate: false
            backgroundColor: "black"
            foregroundColor: "white"

            Timer {
                id: graphTimerPoints3
                interval: 60
                running: temperatureGraph.visible
                repeat: true

                property real lastTime

                onRunningChanged: {
                    if (running){
                        temperatureGraph.curve(0).clear()
                        lastTime = Date.now()
                    }
                }

                onTriggered: {
                    let currentTime = Date.now()
                    let curve = temperatureGraph.curve(0)
                    curve.shiftPoints(-(currentTime - lastTime)/1000, 0)
                    curve.append(0, platformInterface.usb_power_notification.temperature)
                    removeOutOfViewPoints()
                    temperatureGraph.update()
                    lastTime = currentTime
                }

                function removeOutOfViewPoints() {
                    // recursively clean up points that have moved out of view
                    if (temperatureGraph.curve(0).at(0).x < temperatureGraph.xMin) {
                        temperatureGraph.curve(0).remove(0)
                        removeOutOfViewPoints()
                    }
                }
            }



            Component.onCompleted: {
                let movingCurve = createCurve("movingCurve")
                movingCurve.color = "white"
                movingCurve.autoUpdate = false
            }
        }
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
