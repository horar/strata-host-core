import QtQuick 2.10
import QtCharts 2.2
import QtQuick.Controls 2.2

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
    property real maxXValue: 10.00
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
        labelFormat: "%.0f"
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
        useOpenGL: true
    }

    LineSeries {
        // Data line
        id: dataLine2
        name: "Line 2"
        color: Qt.rgba(0, 0, 0, 1)
        width: 2
        axisX: valueAxisX
        axisY: valueAxisY
        useOpenGL: true
    }

    MouseArea {
        anchors{
            fill: rootChart
        }
        property variant clickPos: "1,1"
        preventStealing: true

        onWheel: {
            var scale = Math.pow(1.5, wheel.angleDelta.y * .001)

            var chartCenter = Qt.point((valueAxisX.min + valueAxisX.max)/2, (valueAxisY.min + valueAxisY.max)/2)
            var pixelCenter = rootChart.mapToPosition(chartCenter)
            var offset = Qt.point((pixelCenter.x - wheel.x)*(1-scale), (pixelCenter.y - wheel.y)*(1-scale))

            var rect = Qt.rect(0, 0, rootChart.plotArea.width/scale, rootChart.plotArea.height)
            rect.x = pixelCenter.x-rect.width/2

            rootChart.zoomIn(rect)
            rootChart.scrollRight(offset.x)

            resetChart.visible = true
        }

        onPressed: {
            clickPos = Qt.point(mouse.x, mouse.y)
        }

        onPositionChanged: {
            resetChart.visible = true
            rootChart.scrollLeft(mouse.x-clickPos.x)
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
            rootChart.zoomReset()
            valueAxisX.min = Qt.binding(function(){return minXValue})
            valueAxisX.max = Qt.binding(function(){return maxXValue})
            valueAxisY.min = Qt.binding(function(){return minYValue})
            valueAxisY.max = Qt.binding(function(){return maxYValue})
            visible = false
        }
        width: 90
        height: 20
    }
}
