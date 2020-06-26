import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0

Item {
    id: sgGraphExample
    width: contentColumn.width
    height: contentColumn.height

    Column {
        id: contentColumn
        spacing: 10

        Row {
            spacing: 5
            SGWidgets.SGGraph {
                id: basicGraph
                width: 400
                height: 300
                title: "Basic Graph - Pan/Zoom Enabled"
                xMin: 0
                xMax: 1
                yMin: 0
                yMax: 1
                xTitle: "X Axis"
                yTitle: "Y Axis"
            }

            Column {
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                spacing: 5

                Button {
                    text: "Add curve to graph and populate with points"
                    onClicked: {
                        let curve = basicGraph.createCurve("graphCurve" + basicGraph.count)
                        curve.color = sgGraphExample.randomColor()
                        let dataArray = []
                        for (let i = 0; i <= 1000; i++) {
                           dataArray.push({"x":i/1000, "y":sgGraphExample.yourDataValueHere()})
                        }
                        curve.appendList(dataArray)
                    }
                }

                Button {
                    text: "Remove first curve from graph"
                    enabled: basicGraph.count > 0
                    onClicked: {
                        basicGraph.removeCurve(0);
                    }
                }

                Button {
                    text: "Iterate and log points in first curve"
                    enabled: basicGraph.count > 0
                    onClicked: {
                        let curve = basicGraph.curve(0)
                        for (let i = 0; i < curve.count(); i++) {
                            console.log(curve.at(i))
                        }
                    }
                }
            }
        }

        Row {
            spacing: 5
            SGWidgets.SGGraph {
                // Note: Zoom/Pan mouse actions are disabled for this example since they will overwrite axis values and disable autoscaling
                id: autoScaleGraph
                width: 400
                height: 300
                title: "Basic Graph - AutoScale Example"
                panXEnabled: false
                panYEnabled: false
                zoomXEnabled: false
                zoomYEnabled: false
                xTitle: "X Axis"
                yTitle: "Y Axis"
            }

            Column {
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                spacing: 5

                Text {
                    width: 400
                    wrapMode: Text.Wrap
                    text: "Graphs will autoscale when min/max have not been initialized for an axis. autoScaleXAxis() and autoScaleYAxis() will clear previously set axis values and re-enable autoscaling."
                }

                Button {
                    text: "Add curve to graph, populate with points, and autoscale axes"
                    onClicked: {
                        let curve = autoScaleGraph.createCurve("graphCurve" + autoScaleGraph.count)
                        curve.color = sgGraphExample.randomColor()
                        let dataArray = []
                        for (let i = 0; i <= 1000; i++) {
                           dataArray.push({"x":i/1000, "y":sgGraphExample.yourDataValueHere()})
                        }
                        curve.appendList(dataArray)
                    }
                }

                Button {
                    text: "Set Axes Values"
                    onClicked: {
                        autoScaleGraph.xMax = 10
                        autoScaleGraph.xMin = 0
                        autoScaleGraph.yMin = 0
                        autoScaleGraph.yMax = 10
                    }
                }

                Button {
                    text: "Set Axes to AutoScale"
                    onClicked: {
                        autoScaleGraph.autoScaleXAxis()
                        autoScaleGraph.autoScaleYAxis()
                    }
                }
            }
        }

        Row {
            spacing: 5
            SGWidgets.SGGraph {
                id: timedGraphPoints
                width: 400
                height: 300
                title: "Timed Graph - Points Move"
                yMin: 0
                yMax: 1
                xMin: 5
                xMax: 0
                xTitle: "X Axis"
                yTitle: "Y Axis"
                panXEnabled: false
                panYEnabled: false
                zoomXEnabled: false
                zoomYEnabled: false
                autoUpdate: false

                Component.onCompleted: {
                    let movingCurve = createCurve("movingCurve")
                    movingCurve.color = "turquoise"
                    movingCurve.autoUpdate = false
                }

                Timer {
                    id: graphTimerPoints
                    interval: 60
                    running: false
                    repeat: true

                    property real lastTime

                    onRunningChanged: {
                        if (running){
                            timedGraphPoints.curve(0).clear()
                            lastTime = Date.now()
                        }
                    }

                    onTriggered: {
                        let currentTime = Date.now()
                        let curve = timedGraphPoints.curve(0)
                        curve.shiftPoints((currentTime - lastTime)/1000, 0)
                        curve.append(0, sgGraphExample.yourDataValueHere())
                        removeOutOfViewPoints()
                        timedGraphPoints.update()
                        lastTime = currentTime
                    }

                    function removeOutOfViewPoints() {
                        // recursively clean up points that have moved out of view
                        if (timedGraphPoints.curve(0).at(0).x > timedGraphPoints.xMin) {
                            timedGraphPoints.curve(0).remove(0)
                            removeOutOfViewPoints()
                        }
                    }
                }
            }

            Column {
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                spacing: 5

                Button {
                    text: "Start/stop timed graphing"
                    onClicked: {
                        graphTimerPoints.running = !graphTimerPoints.running
                    }
                }
            }
        }

        Row {
            spacing: 5
            SGWidgets.SGGraph {
                id: timedGraphAxis
                width: 400
                height: 300
                title: "Timed Graph - Axis Moves"
                yMin: 0
                yMax: 1
                xMin: -5
                xMax: 0
                xTitle: "X Axis"
                yTitle: "Y Axis"
                panXEnabled: false
                panYEnabled: false
                zoomXEnabled: false
                zoomYEnabled: false
                autoUpdate: false

                Component.onCompleted: {
                    let movingCurve = createCurve("movingCurve")
                    movingCurve.color = "lime"
                    movingCurve.autoUpdate = false
                }

                Timer {
                    id: graphTimerAxis
                    interval: 60
                    running: false
                    repeat: true

                    property real startTime
                    property real lastTime

                    onRunningChanged: {
                        if (running){
                            timedGraphAxis.curve(0).clear()
                            startTime = Date.now()
                            lastTime = startTime
                            timedGraphAxis.xMin = -5
                            timedGraphAxis.xMax = 0
                        }
                    }

                    onTriggered: {
                        let currentTime = Date.now()
                        timedGraphAxis.curve(0).append((currentTime - startTime)/1000, sgGraphExample.yourDataValueHere())
                        timedGraphAxis.shiftXAxis((currentTime - lastTime)/1000)
                        removeOutOfViewPoints()
                        timedGraphAxis.update()
                        lastTime = currentTime
                    }

                    function removeOutOfViewPoints() {
                        // recursively clean up points that have moved out of view
                        if (timedGraphAxis.curve(0).at(0).x < timedGraphAxis.xMin) {
                            timedGraphAxis.curve(0).remove(0)
                            removeOutOfViewPoints()
                        }
                    }
                }
            }

            Column {
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                spacing: 5

                Button {
                    text: "Start/stop timed graphing"
                    onClicked: {
                        graphTimerAxis.running = !graphTimerAxis.running
                    }
                }
            }
        }

        Row {
            spacing: 5
            SGWidgets.SGGraph {
                id: coloredGraph
                width: 400
                height: 300
                title: "Graph with Customized Colors and Title Scaling"
                xMin: 1
                xMax: 100
                yMin: 0
                yMax: 1
                xTitle: "X Axis"
                yTitle: "Y Axis"
                backgroundColor: "pink"
                foregroundColor: "steelblue"
                fontSizeMultiplier: fontSlider.value
            }

            Column {
                anchors {
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Modify title size:"
                    font.bold: true
                }

                Slider {
                    id: fontSlider
                    from: .5
                    to: 2
                    value: 1
                }
            }
        }

        Row {
            spacing: 5
            SGWidgets.SGGraph {
                // Note: Zoom/Pan mouse actions are disabled for log graph axes
                id: logGraph
                width: 400
                height: 150
                title: "Graph with Logarithmic Axes"
                xMin: 1
                xMax: 1000
                yMin: 1
                yMax: 1000
                xLogarithmic: true
                yLogarithmic: true
                xTitle: "X Axis"
                yTitle: "Y Axis"
            }
        }
    }

    function yourDataValueHere() {
        return Math.random()
    }

    function randomColor() {
        return Qt.rgba(Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, 1)
    }
}
