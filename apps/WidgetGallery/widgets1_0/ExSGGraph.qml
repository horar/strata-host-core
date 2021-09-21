/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0
import tech.strata.sgwidgets 0.9 as SGWidgets09

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
                xGrid: false
                yGrid: true
                gridColor: "red"
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
                xGrid: true
                yGrid: false
                gridColor: "green"
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
                id: yAxisGraph
                width: 400
                height: 300
                title: "Basic Graph - Multiple Y Axis Enabled With Ability To Change Color Of Y Axis And Add Legend"
                xMin: 0
                xMax: 1
                yMin: 0
                yMax: 5
                yRightMin: 0
                yRightMax: 10
                xTitle: "X Axis"
                yTitle: "Y Axis"
                yRightTitle: "Y1 Axis"
                xGrid: true
                yGrid: true
                gridColor: "green"
                yRightVisible: true
                legend: true  //enable to add legend
            }

            Column {
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                spacing: 5

                Button {
                    text: "Add curve to graph and populate with points for x and y left axis"
                    onClicked: {
                        let curve = yAxisGraph.createCurve("graphCurve" + yAxisGraph.count)
                        curve.color = sgGraphExample.randomColor()
                        //Set the color of yLeft Axis.
                        yAxisGraph.yLeftAxisColor = curve.color
                        let dataArray = []
                        for (let i = 0; i <= 1000; i++) {
                            dataArray.push({"x":i/1000, "y":sgGraphExample.yourDataValueHere()})
                        }
                        curve.appendList(dataArray)
                    }
                }

                Button {
                    text: "Add curve to graph and populate with points for x and y right axis"
                    onClicked: {
                        let curve = yAxisGraph.createCurve("graphCurve" + yAxisGraph.count)
                        curve.color = sgGraphExample.randomColor()
                        curve.yAxisLeft = false // YRight axis is enabled to plot the given curve. Default yAxisLeft = true
                        //Set the color of yRight Axis.
                        yAxisGraph.yRightAxisColor = curve.color
                        let dataArray = []
                        for (let i = 0; i <= 1000; i++) {
                            dataArray.push({"x":i/1000, "y":sgGraphExample.yourDataValueHere()})
                        }
                        curve.appendList(dataArray)
                    }
                }

                Button {
                    text: "Remove first curve from graph"
                    enabled: yAxisGraph.count > 0
                    onEnabledChanged: {
                        if(!enabled) {
                            yAxisGraph.yRightAxisColor = "black"
                            yAxisGraph.yLeftAxisColor = "black"
                        }
                    }
                    onClicked: {
                        yAxisGraph.removeCurve(0);
                    }
                }

                Button {
                    text: "Remove Legend"
                    enabled:  yAxisGraph.count > 0 && yAxisGraph.legend
                    onClicked: {
                        yAxisGraph.legend = false
                    }
                }
                Button {
                    text: "Add Legend"
                    enabled: yAxisGraph.count > 0 && (!yAxisGraph.legend)
                    onClicked: {
                        yAxisGraph.legend = true
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
                xGrid: true
                yGrid: true

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
                // Note: Zoom/Pan mouse actions are disabled for log graph axes
                id: gridLogGraph
                width: 400
                height: 300
                title: "Graph to Toggle major, minor grid and x/y Logarithmic"
                xMin: 1
                xMax: 50
                yMin: 1
                yMax: 50
                xTitle: "X Axis"
                yTitle: "Y Axis"
                gridColor: "black"
            }

            Column {
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                spacing: 5
                Button {
                    text: "Add Major Gridline"
                    onClicked: {
                        if(gridLogGraph.xMinorGrid && gridLogGraph.yMinorGrid) {
                            gridLogGraph.xMinorGrid = false
                            gridLogGraph.yMinorGrid = false
                        }
                        gridLogGraph.xGrid = true
                        gridLogGraph.yGrid = true
                    }

                }

                Button {
                    text: "Add Minor Gridline"
                    onClicked: {
                        gridLogGraph.xMinorGrid = true
                        gridLogGraph.yMinorGrid = true
                    }
                }

                Button {
                    text: "Clear Gridline"
                    onClicked: {
                        gridLogGraph.xGrid = false
                        gridLogGraph.yGrid = false
                        gridLogGraph.xMinorGrid = false
                        gridLogGraph.yMinorGrid = false
                    }
                }

                Button {
                    text: "Toggle X/Y Logarithmic Axes"
                    onClicked: {
                        if(gridLogGraph.xLogarithmic && gridLogGraph.yLogarithmic) {
                            gridLogGraph.xLogarithmic = false
                            gridLogGraph.yLogarithmic = false
                            text = "Toggle X/Y Logarithmic Axes"
                        }
                        else {
                            gridLogGraph.xLogarithmic = true
                            gridLogGraph.yLogarithmic = true
                            text = "Toggle X/Y Linear Axes"
                        }
                    }
                }



            }
        }

        Row {
            spacing: 5
            SGWidgets.SGGraph {
                id: styleGraph
                width: 400
                height: 300
                title: "Graph with style on data points"
                xMin: -1
                xMax: 3
                yMin: 0
                yMax: 1
                xTitle: "X Axis"
                yTitle: "Y Axis"

                Component.onCompleted: {
                    let curve = styleGraph.createCurve("graphCurve" + styleGraph.count)
                    curve.color = sgGraphExample.randomColor()

                    let dataArray = []
                    for (let i = 0; i <= 5; i++) {
                        dataArray.push({"x":i/5, "y":sgGraphExample.yourDataValueHere()})
                    }
                    curve.appendList(dataArray)
                    /*
                      To setSymbol() you need to pass in 4 arguments:
                      SetSymbol (
                                   Symbol Style (int),
                                   brush to fill the interior (string),
                                   outline pen(int),
                                   size(int)
                                )

                        --------------------------------------------------
                        Symbol Style: Assign a symbol.
                        Enum
                        ----------------------------------------------------
                        NoSymbol = -1,  //No Style. The symbol cannot be drawn.
                        Ellipse = 0,    //Ellipse or circle.
                        Rect = 1,       //Rectangle.
                        Diamond = 2,    // Diamond.
                        Triangle = 3,   //Triangle pointing upwards.
                        DTriangle = 4,  //Triangle pointing downwards.
                        UTriangle = 5,  //Triangle pointing upwards.
                        LTriangle = 6,  //Triangle pointing left.
                        RTriangle = 7,  //Triangle pointing right.
                        Cross = 8,      //Cross (+)
                        XCross 9,       //Diagonal cross (X)
                        HLine = 10,     //Horizontal line.
                        VLine = 11,     //Vertical line.
                        Star1 = 12,     //X combined with +.
                        Star2 = 13,     //Six-pointed star.
                        Hexagon = 14  //Hexagon.
                        ----------------------------------------------

                        ------------------------------------------------
                        Outline Pen: Draw lines and outlines of shapes
                        Enum
                        ------------------------------------------------
                        "NoPen"  = 0 ,
                        "SolidLine" 1 ,
                        "DashLine" =  2,
                        "DotLine" = 3 ,
                        "DashDotLine" = 4,
                        "DashDotLine" = 5,
                        "CustomDashLine" = 6
                         ------------------------------------------------
                    */
                    curve.setSymbol(2,"gray", 0 , 7)
                }
            }

            Column {
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                spacing: 5

                Button {
                    text: "Clear Symbol"
                    onClicked: {
                        styleGraph.curve(0).setSymbol(-1,"gray", 0 , 7)
                    }
                }
                Button {
                    text: "Random Symbol"
                    onClicked: {
                        styleGraph.curve(0).setSymbol(randomStyle(),"gray", 0 , 7)
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

        Row {
            spacing: 5
            SGWidgets.SGGraph {
                id: pointGraph
                width: 400
                height: 300
                title: "Graph with tooltip on data points"
                xMin: 0
                xMax: 10
                yMin: 0
                yMax: 10
                xTitle: "X Axis"
                yTitle: "Y Axis"

                Component.onCompleted: {
                    let curve = pointGraph.createCurve("graphCurve" + pointGraph.count)
                    curve.color = sgGraphExample.randomColor()

                    let dataArray = []
                    let i = 0
                    for (i = 0; i <= 10; i++) {
                        dataArray.push({"x":i, "y":sgGraphExample.yourDataValueHere()*10})
                    }
                    curve.appendList(dataArray)
                }

                function closestPointByXValue() {
                    // index and points array to store different curve points near the mouse
                    let index = 0
                    let curvePoints = []
                    let diff = Infinity // large default value
                    let closestIndex = 0
                    // loop over all curves to find the closest points to the mouse's X position, then find the curve closest to the mouse's Y position
                    for (let i = 0; i < pointGraph.count; i++) {
                        index = pointGraph.curve(i).closestXAxisPointIndex(closestValue.mouseValue.x)
                        if (index !== -1) {
                            // using the index, store that point in the curvePoints array
                            curvePoints[i] = pointGraph.curve(i).at(index)
                            let distance = Math.abs(closestValue.mouseValue.y - curvePoints[i].y)
                            // distance is used to determine which of all the curves is closest to the mouse
                            if (distance < diff) {
                                diff = distance
                                closestIndex = i
                            }
                        }
                    }
                    return curvePoints[closestIndex] // closest point by X, to the mouse
                }

                Item {
                    id: mouseCrosshair
                    x: pointGraph.mouseArea.mouseX
                    y: pointGraph.mouseArea.mouseY

                    property int scroll: pointGraph.mouseArea.wheelChoke
                    property var position: pointGraph.mouseArea.mousePosition
                    property point closestPoint: Qt.point(0,0)

                    onScrollChanged: {
                        closestValue.visible = false // while scrolling the tooltip is not visible
                    }

                    onPositionChanged: {
                        closestValue.visible = false // when shifting the graph the tooltip is not visible
                    }

                    onXChanged: {
                        closestPoint = pointGraph.closestPointByXValue()
                    }
                }

                // popup to display the point's coordinates and hovers over that location
                SGWidgets09.SGToolTipPopup {
                    id: closestValue
                    // x and y positions are limited to the size of pointGraph
                    x: determineX()
                    y: determineY()
                    color: "white"
                    showOn: pointGraph.mouseArea.containsMouse
                    enabled: false // disables internal mouse area
                    content: Text {
                        text: "(" + mouseCrosshair.closestPoint.x.toFixed(closestValue.decimalsX) + "," + mouseCrosshair.closestPoint.y.toFixed(closestValue.decimalsY) + ")"
                    }

                    property point mouseValue: pointGraph.mapToValue(Qt.point(mouseCrosshair.x, mouseCrosshair.y))
                    property int decimalsX: 1 // determines how many decimal points to show
                    property int decimalsY: 1
                    property point pos: pointGraph.mapToPosition(mouseCrosshair.closestPoint)

                    // determines the x position of the tooltip, will not extend beyond the xMin and xMax
                    // can comment the 'visible' property to see off screen point coordinates
                    function determineX() {
                        if (mouseCrosshair.closestPoint.x < pointGraph.xMin) {
                            let limit = Qt.point(pointGraph.xMin, mouseCrosshair.closestPoint.y)
                            visible = false // comment out to show tooltip at the edge of the screen
                            return pointGraph.mapToPosition(limit).x - width / 2 - 7
                        } else {
                            return pos.x - width / 2 - 7

                        }
                    }

                    // determines the y position of the tooltip, will not extend beyond the yMin and yMax
                    function determineY() {
                        if (mouseCrosshair.closestPoint.y > pointGraph.yMax) {
                            let limit = Qt.point(mouseCrosshair.closestPoint.x, pointGraph.yMax)
                            visible = false // comment out to show tooltip at the edge of the screen
                            return pointGraph.mapToPosition(limit).y - height
                        } else if (mouseCrosshair.closestPoint.y < pointGraph.yMin){
                            let limit = Qt.point(mouseCrosshair.closestPoint.x, pointGraph.yMin)
                            visible = false // comment out to show tooltip at the edge of the screen
                            return pointGraph.mapToPosition(limit).y - height
                        } else {
                            visible = true // comment out to show tooltip at the edge of the screen
                            return pos.y - height
                        }
                    }
                }
            }

            Column {
                spacing: 5
                anchors {
                    verticalCenter: parent.verticalCenter
                }

                // This button will remove the two sine waves and produce one curve with random points
                Button {
                    id: singleCurveButton
                    text: "Single Curve"
                    enabled: false

                    onClicked: {
                        pointGraph.yMin = 0
                        singleCurveButton.enabled = false
                        manyCurveButton.enabled = true
                        pointGraph.removeCurve("graphCurve0") // removes the two sine waves
                        pointGraph.removeCurve("graphCurve1")

                        let curve = pointGraph.createCurve("graphCurve" + pointGraph.count)
                        curve.color = sgGraphExample.randomColor()

                        let dataArray = []
                        for (let i = 0; i <= 10; i++) {
                            dataArray.push({"x":i, "y":sgGraphExample.yourDataValueHere()*10})
                        }
                        curve.appendList(dataArray)
                    }
                }

                // This button removes the single curve and creates two sine waves
                // Useful for testing tooltip with multiple curves
                Button {
                    id: manyCurveButton
                    text: "Multiple Curves"
                    enabled: true

                    onClicked: {
                        pointGraph.yMin = -10
                        singleCurveButton.enabled = true
                        manyCurveButton.enabled = false
                        pointGraph.removeCurve("graphCurve0") // remove the other curve

                        let curve = pointGraph.createCurve("graphCurve" + pointGraph.count)
                        curve.color = sgGraphExample.randomColor()

                        let dataArray = []
                        let i = 0
                        for (i = 0; i <= 100; i++) {
                            dataArray.push({"x":i/10, "y":sgGraphExample.multipleCurveValues(i/10)*10})
                        }
                        curve.appendList(dataArray)

                        curve = pointGraph.createCurve("graphCurve" + pointGraph.count)
                        curve.color = sgGraphExample.randomColor()

                        dataArray = []
                        for (i = 0; i <= 100; i++) {
                            dataArray.push({"x":i/10, "y":sgGraphExample.multipleCurveValues(i/10 - 10)*10})
                        }
                        curve.appendList(dataArray)
                    }
                }
            }
        }
    }

    function multipleCurveValues(value) {
        return Math.sin(value)
    }

    function yourDataValueHere() {
        return Math.random()
    }

    function randomColor() {
        return Qt.rgba(Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, 1)
    }
    function randomStyle() {
        return Math.random() * (14 - 0) + 0;
    }
}
