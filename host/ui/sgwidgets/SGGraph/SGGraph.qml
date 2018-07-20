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

    property alias series: dataLine

    property int textSize: 14
    property color dataLineColor: Qt.rgba(0, 0, 0, 1)
    property color underDataColor: Qt.rgba(.5, .5, .5, .3)
    property color axesColor: Qt.rgba(.2, .2, .2, 1)
    property color gridLineColor: Qt.rgba(.8, .8, .8, 1)
    property color textColor: Qt.rgba(0, 0, 0, 1)
    property int minYValue: 0
    property int maxYValue: 10
    property int minXValue: 0
    property int maxXValue: 10
    property string xAxisTitle: ""
    property string yAxisTitle: ""
    property bool showXGrids: false
    property bool showYGrids: false

    property bool showOptions: false
    property real rollingWindow
    property bool centered: false
    property bool throttlePlotting: true

    property bool repeatOldData: true
    property real inputData
    property real dataTime: 0
    property real time: Date.now()
    property real dataTimeInterval
    property real lastPlottedTime: Date.now()
    property real lastRedrawTime: Date.now()

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
            right: parent.right
            top: parent.top
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
            top: parent.top
            left: parent.left
            margins: 12
        }

        Button {
            id: centeredToggle
            anchors {
                left: parent.left
            }
            checkable: true
            checked: rootChart.centered
            text: rootChart.centered ? "Centered On" : "Centered Off"
            onClicked: {
                rootChart.centered = !rootChart.centered
            }
        }
    }

    onInputDataChanged: {
        if ( !throttlePlotting ){
            appendData()

            // If unthrottled and data points are coming in FAST (every <50ms) and dataLine has many to manage (300+), rolling graph redraws can bog down CPU
            // This timer limits how many times per second the graph is redrawn rather than with every incoming data point
            if (calculateTimeSinceLastRedraw() >= 0.1) {
                redrawGraph()
            }
        } else if (calculateTimeSinceLastPlot() >= 0.1){
            appendData()
            redrawGraph()
        }
    }

    Component.onCompleted: {
        valueAxisY.applyNiceNumbers();  // Automatically determine axis ticks
        valueAxisX.applyNiceNumbers();
        rootChart.rollingWindow = maxXValue - minXValue;
//        if ( repeatOldData ) {
//            graphRedrawTimer.running = true
//        }
    }

    function appendData() {
        rootChart.dataTime += calculateDataInterval();
        dataLine.append(rootChart.dataTime, inputData);
        lastPlottedTime = Date.now()
    }

    function redrawGraph() {
        console.log( dataLine.count )
        lastRedrawTime = Date.now()
        if (centered){
            if (rootChart.dataTime >= maxXValue - (rollingWindow/2)){
                valueAxisX.max = rootChart.dataTime + rollingWindow/2;
                valueAxisX.min = valueAxisX.max - rollingWindow;
                trimData()
            }
        } else {
            if (rootChart.dataTime >= maxXValue){
                valueAxisX.max = rootChart.dataTime;
                valueAxisX.min = valueAxisX.max - rollingWindow;
                trimData()
            }
        }
    }

    // Remove points that are outside of view to save memory
    function trimData() {
        if (dataLine.at(0).x < rootChart.dataTime - rollingWindow * 1.1) {
            dataLine.remove(0)
            trimData() // Recurse to remove other points that may remain due centered view change
        }
        return
    }

    function calculateDataInterval(){
        var seconds = (Date.now() - time)/1000;
        time = Date.now();
        return seconds;
    }

    function calculateTimeSinceLastPlot(){
        return (Date.now() - lastPlottedTime)/1000;
    }

    function calculateTimeSinceLastRedraw(){
        return (Date.now() - lastRedrawTime)/1000;
    }
}
