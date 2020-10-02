import QtQuick 2.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

SGGraph {
    id: graphConverter

    property alias xAxisTitle: xTitle
    property alias yAxisTitle: yTitle
    property alias maxYValue: yMax
    property alias minYValue: yMin
    property alias maxXValue: xMax
    property alias minXValue: xMin
    property alias showYGrids: xGrid
    property alias showXGrids: yGrid
    property alias textColor: foregroundColor
    property alias gridLineColor: gridColor

    property bool autoAdjustMaxMin: false
    property real inputData
    property color dataLineColor: "black"

    // PROPERTIES THAT DO NOTHING - no equivalent in SGGraph 1.0
    property real xAxisTickCount: 0
    property real yAxisTickCount: 0
    property bool throttlePlotting
    property bool reverseDirection
    property color underDataColor
    property color axesColor
    property bool showOptions
    property bool repeatOldData
    property int pointCount /// not sure about this one
    ////

    panXEnabled: false
    panYEnabled: false
    zoomXEnabled: false
    zoomYEnabled: false
    autoUpdate: false

    Component.onCompleted: {
        if (autoAdjustMaxMin) {
            autoScaleXAxis()
            autoScaleYAxis()
        }

        let movingCurve = createCurve("movingCurve")
        movingCurve.color = dataLineColor
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
            curve.append(0, inputData)
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
