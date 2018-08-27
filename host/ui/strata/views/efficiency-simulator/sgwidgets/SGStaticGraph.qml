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
    property color dataLine1Color: Qt.rgba(0, 0, 0, 1)
    property color dataLine2Color: Qt.rgba(0, 0, 0, 1)
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
    property real scale: 1
    property real xWidth: maxXValue - minXValue
    property real yWidth: maxYValue - minYValue

    property real baseWidth
    property real baseHeight
    property real baseMinYValue
    property real baseMaxYValue
    property real baseMinXValue
    property real baseMaxXValue
    property real scrollTotal: 0

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
        name: "Circuit 1"
        color: dataLine1Color
        width: 2
        axisX: valueAxisX
        axisY: valueAxisY
    }

    LineSeries {
        // Data line
        name: "Circuit 2"
        id: dataLine2
        color: dataLine2Color
        width: 2
        axisX: valueAxisX
        axisY: valueAxisY
    }

    Component.onCompleted: {
        valueAxisY.applyNiceNumbers();  // Automatically determine axis ticks
        valueAxisX.applyNiceNumbers();
        baseWidth = xWidth
        baseHeight = yWidth
        baseMinXValue = minXValue
        baseMaxXValue = maxXValue
        baseMinYValue = minYValue
        baseMaxYValue = maxYValue
    }

    MouseArea {
        anchors{
            fill: rootChart
        }
        property variant clickPos: "1,1" // @disable-check M311 // Ignore 'use string' (M311) QtCreator warning

        onWheel: {
            scrollTotal -= wheel.angleDelta.y *0.001
            var scaleDiff = rootChart.scale
            rootChart.scale = Math.pow(1.5, scrollTotal)
            scaleDiff = rootChart.scale - scaleDiff

            if ( scaleDiff < 0 ) {
                rootChart.baseMinXValue -= ((wheel.x/width) - 0.5) * baseWidth * scaleDiff
                rootChart.baseMaxXValue -= ((wheel.x/width) - 0.5) * baseWidth * scaleDiff
                rootChart.baseMinYValue += ((wheel.y/height) - 0.5) * baseHeight * scaleDiff
                rootChart.baseMaxYValue += ((wheel.y/height) - 0.5) * baseHeight * scaleDiff
            }

            recalculate()
        }

        onPressed: {
            clickPos = Qt.point(mouse.x,mouse.y)
        }

        onPositionChanged: {
            var delta = Qt.point((mouse.x-clickPos.x)*(xWidth/width), (mouse.y-clickPos.y)*(yWidth/height))
            rootChart.baseMinXValue -= delta.x
            rootChart.baseMaxXValue -= delta.x
            rootChart.baseMinYValue += delta.y
            rootChart.baseMaxYValue += delta.y

            recalculate()

            clickPos = Qt.point(mouse.x,mouse.y)
        }
    }

    function recalculate() {
        rootChart.minXValue = baseMinXValue - ((rootChart.scale * baseWidth) - baseWidth) / 2
        rootChart.maxXValue = baseMaxXValue + ((rootChart.scale * baseWidth) - baseWidth) / 2
        rootChart.minYValue = baseMinYValue - ((rootChart.scale * baseHeight) - baseHeight) / 2
        rootChart.maxYValue = baseMaxYValue + ((rootChart.scale * baseHeight) - baseHeight) / 2
    }

    Button {
        id: resetZoom
        visible: rootChart.scrollTotal !== 0
        anchors {
            right: parent.right
            top: parent.top
            margins: 12
        }
        text: "Reset Zoom"
        onClicked: {
            zoomTimer.running = true
        }
        width: 90
        height: 20

        Timer {
            id: zoomTimer
            interval: 10
            running: false
            repeat: true
            property int count: 0
            property real scrollFrac
            onTriggered: {
                if (count < 25) {
                    scrollTotal -= scrollFrac
                    rootChart.scale = Math.pow(1.5, scrollTotal)
                    recalculate()
                    count++
                } else {
                    scrollTotal = 0
                    running = false
                }
            }
            onRunningChanged: {
                count = 0
                scrollFrac = scrollTotal / 25
            }
        }
    }
}
