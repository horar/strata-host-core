import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0

Item {
    id: root
    width: contentColumn.width
    height: contentColumn.height

    Column {
        id: contentColumn
        spacing: 10

        Row {
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
                        let curve = basicGraph.createCurve("graphCurve" + basicGraph.count())
                        curve.color = Qt.rgba(Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, 1) // random color
                        curve.autoUpdate = false // turn autoUpdate off temporarily so that update() is not called with for every appended point
                        for (let i = 0; i <= 1000; i++) {
                            curve.append(i/1000, Math.random())
                        }
                        curve.autoUpdate = true
                        curve.update()
                    }
                }

                Button {
                    text: "Remove first curve from graph"
                    onClicked: {
                        basicGraph.removeCurve(0);
                    }
                }

                Button {
                    text: "Iterate and log points in first curve"
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
                        timedGraphAxis.curve(0).append((currentTime - startTime)/1000, root.yourDataValueHere())
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
                    interval: 16
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
                        timedGraphPoints.curve(0).shiftPoints((currentTime - lastTime)/1000)
                        timedGraphPoints.curve(0).append(0, root.yourDataValueHere())
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
            SGWidgets.SGGraph {
                id: coloredGraph
                width: 400
                height: 150
                title: "Graph with Customized Colors"
                xMin: 1
                xMax: 100
                yMin: 0
                yMax: 1
                xTitle: "X Axis"
                yTitle: "Y Axis"
                backgroundColor: "pink"
                foregroundColor: "steelblue"
            }
        }

        Row {
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
}
