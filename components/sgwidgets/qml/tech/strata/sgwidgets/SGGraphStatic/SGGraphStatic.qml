/*
 * Copyright (c) 2018-2022 onsemi.
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

    property alias series1: dataLine1
    property alias series2: dataLine2

    property int textSize: 14
    property alias dataLine1Color: dataLine1.color
    property alias dataLine2Color: dataLine2.color
    property color axesColor: Qt.rgba(.2, .2, .2, 1)
    property color gridLineColor: Qt.rgba(.8, .8, .8, 1)
    property color textColor: Qt.rgba(0, 0, 0, 1)
    property real minYValue: 0
    property real maxYValue: 10
    property real minXValue: 0
    property real maxXValue: 10
    property string xAxisTitle: ""
    property string yAxisTitle: ""
    property bool showXGrids: false
    property bool showYGrids: false

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
        labelFormat: "%.1f"
        labelsFont.pixelSize: rootChart.textSize*.8
        labelsColor: textColor
    }


    LineSeries {
        // Data line
        id: dataLine1
        name: "Line 1"
        color: Qt.rgba(0, 0, 0, 1)
        width: 2
        axisX: valueAxisX
        axisY: valueAxisY
    }

    LineSeries {
        // Data line
        id: dataLine2
        name: "Line 2"
        color: Qt.rgba(0, 0, 0, 1)
        width: 2
        axisX: valueAxisX
        axisY: valueAxisY
    }

    MouseArea {
        anchors{
            fill: rootChart
        }
        property point clickPos: "0,0"
        preventStealing: true

        onWheel: {
            var scale = Math.pow(1.5, wheel.angleDelta.y * 0.001)

            var scaledChartWidth = (valueAxisX.max - valueAxisX.min) / scale
            var scaledChartHeight = (valueAxisY.max - valueAxisY.min) / scale

            var chartCenter = Qt.point((valueAxisX.min + valueAxisX.max) / 2, (valueAxisY.min + valueAxisY.max) / 2)
            var chartWheelPosition = rootChart.mapToValue(Qt.point(wheel.x, wheel.y))
            var chartOffset = Qt.point((chartCenter.x - chartWheelPosition.x) * (1 - scale), (chartCenter.y - chartWheelPosition.y) * (1 - scale))

            valueAxisX.min = (chartCenter.x - (scaledChartWidth / 2)) + chartOffset.x
            valueAxisX.max = (chartCenter.x + (scaledChartWidth / 2)) + chartOffset.x
            valueAxisY.min = (chartCenter.y - (scaledChartHeight / 2)) + chartOffset.y
            valueAxisY.max = (chartCenter.y + (scaledChartHeight / 2)) + chartOffset.y

            resetChart.visible = true
        }

        onPressed: {
            clickPos = Qt.point(mouse.x, mouse.y)
        }

        onPositionChanged: {
            resetChart.visible = true
            rootChart.scrollLeft(mouse.x - clickPos.x)
            rootChart.scrollUp(mouse.y - clickPos.y)
            clickPos = Qt.point(mouse.x, mouse.y)
        }
    }

    Button {
        id: resetChart
        visible: false
        anchors {
            right: rootChart.right
            top: rootChart.top
            margins: 12
        }
        text: "Reset Chart"
        onClicked: {
            valueAxisX.min = Qt.binding(function(){ return minXValue })
            valueAxisX.max = Qt.binding(function(){ return maxXValue })
            valueAxisY.min = Qt.binding(function(){ return minYValue })
            valueAxisY.max = Qt.binding(function(){ return maxYValue })
            visible = false
        }
        width: 90
        height: 20
    }
}
