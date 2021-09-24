/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtCharts 2.2
import QtQuick.Controls 2.12

ChartView {
    id: rootChart
    title: ""
    titleColor: textColor
    titleFont.pixelSize: textSize
    legend { visible:false }
    antialiasing: true
    backgroundColor: "white"
    backgroundRoundness: 0
    anchors {
        margins: -12
    }

    implicitWidth: 300
    implicitHeight: 300

    margins {
        top: 5
        left: 5
        right: 5
        bottom: 5
    }

    property alias series: dataLine
    property alias repeatOldData: repeatTimer.running
    property alias xAxisTickCount: valueAxisX.tickCount
    property alias yAxisTickCount: valueAxisY.tickCount

    property int textSize: 14
    property color dataLineColor: Qt.rgba(0, 0, 0, 1)
    property color underDataColor: Qt.rgba(.5, .5, .5, .3)
    property color axesColor: Qt.rgba(.2, .2, .2, 1)
    property color gridLineColor: Qt.rgba(.8, .8, .8, 1)
    property color textColor: Qt.rgba(0, 0, 0, 1)
    property real minYValue: 0
    property real maxYValue: 10
    property real minXValue: 0
    property real maxXValue: 5
    property string xAxisTitle: ""
    property string yAxisTitle: ""
    property bool showXGrids: false
    property bool showYGrids: false

    property bool reverseDirection: false
    property bool showOptions: false
    property bool throttlePlotting: true
    property bool autoAdjustMaxMin: false
    property int pointCount: 50

    property real inputData: 0
    property real lastInputTime: Date.now()
    property real lastPlottedTime: Date.now()
    property real lastRedrawTime: Date.now()

    onVisibleChanged: {
        dataLine.clear()
    }

    // Define x-axis to be used with the series instead of default one
    ValueAxis {
        id: valueAxisX
        titleText: "<span style='color:"+textColor+"'>"+xAxisTitle+"</span>"
        titleFont.pixelSize: rootChart.textSize*.8
        min: minXValue
        max: maxXValue
        color: axesColor
        gridVisible: showXGrids
        gridLineColor: rootChart.gridLineColor
//        tickCount: 11  //  applyNiceNumbers() takes care of this based on range
        labelFormat: "%.1f"
        labelsFont.pixelSize: rootChart.textSize*.8
        labelsColor: textColor
    }

    ValueAxis {
        id: valueAxisY
        titleText: "<span style='color:"+textColor+"'>"+yAxisTitle+"</span>"
        titleFont.pixelSize: rootChart.textSize*.8
        min: minYValue
        max: maxYValue
        color: axesColor
        gridVisible: showYGrids
        gridLineColor: rootChart.gridLineColor
//        tickCount: 6  //  applyNiceNumbers() takes care of this based on range
        labelFormat: "%.0f"
        labelsFont.pixelSize: rootChart.textSize*.8
        labelsColor: textColor
    }

    AreaSeries {
        // Fill under the data line
        axisX: valueAxisX
        axisY: valueAxisY
        color: underDataColor
        borderColor: "transparent"
        borderWidth: 0
        upperSeries: dataLine
    }

    LineSeries {
        // Data line
        id: dataLine
        color: dataLineColor
        width: 2
    }

    Button {
        id: optionToggle
        visible: rootChart.showOptions
        anchors {
            right: rootChart.right
            top: rootChart.top
            margins: 12
        }
        checkable: true
        checked: false
        text: "Options"
        onClicked: {
            options.visible = !options.visible
        }
    }

    Item {
        id: options
        visible: false
        anchors {
            top: rootChart.top
            left: rootChart.left
            margins: 12
        }
    }

    // If repeatOldData is true, plot the last data point again if a new point hasn't been plotted in 200ms
    Timer {
        id: repeatTimer
        interval: 1000*((maxXValue - minXValue)/(pointCount*2))
        running: rootChart.visible
        repeat: true
        onTriggered: {
            if (timeSinceLastPlot() > interval) {
                appendData(timeSinceLastPlot() / 1000)
            }
        }
    }

    onInputDataChanged: {
        if (rootChart.visible) {
            var timeDiffSeconds = timeSinceLastPlot() / 1000
            if ( !throttlePlotting ){  // Unthrottled plots every point, NOT RECOMMENDED
                appendData(timeDiffSeconds)
            } else if (timeDiffSeconds >= (maxXValue - minXValue)/pointCount) { // When throttled, plots a point every (1/pointCount) of the min/max X time interval
                appendData(timeDiffSeconds)
            }
        }
    }

    Component.onCompleted: {
        // Automatically determine ticks if not specified by user
        if (!valueAxisX.tickCount){
            valueAxisX.applyNiceNumbers();
        }
        if (!valueAxisY.tickCount){
            valueAxisY.applyNiceNumbers();
        }
    }

    function appendData(timeDiffSeconds) {
        trimData()
//        console.log(dataLine.count)

        if (reverseDirection) {
            for (var i = 0; i<dataLine.count; i++) {
                var point = dataLine.at(i)
                replacePoint(point, point.x+timeDiffSeconds)
            }
            lastPlottedTime = Date.now()
            dataLine.append(rootChart.minXValue, inputData)
        } else {
            for (var i = 0; i<dataLine.count; i++) {
                var point = dataLine.at(i)
                replacePoint(point, point.x-timeDiffSeconds)
            }
            lastPlottedTime = Date.now()
            dataLine.append(rootChart.maxXValue, inputData)
        }

        if (autoAdjustMaxMin) {
            if (inputData < minYValue) {
                minYValue = inputData
                if (!valueAxisY.tickCount){
                    valueAxisY.applyNiceNumbers();
                }
            } else if (inputData > maxYValue) {
                maxYValue = inputData
                if (!valueAxisY.tickCount){
                    valueAxisY.applyNiceNumbers();
                }
            }
        }
    }

    function replacePoint(point, newX) {
        dataLine.replace(point.x, point.y, newX, point.y)
    }

    // Remove points that are outside of view to save resources
    function trimData() {
        if (reverseDirection) {
            if (dataLine.at(0).x > rootChart.maxXValue) {
                dataLine.remove(0)
                trimData() // Recurse to remove other points that may remain due to inconsistent timing
            }
        } else {
            if (dataLine.at(0).x < rootChart.minXValue) {
                dataLine.remove(0)
                trimData() // Recurse to remove other points that may remain due to inconsistent timing
            }
        }
        return
    }

    function timeSinceLastPlot(){
        return Date.now() - lastPlottedTime
    }

    function reset(){
        dataLine.clear()
    }
}
