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
    property alias running: redrawTimer.running
    property alias repeatOldData: repeatTimer.running

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

    property real inputData
    property real dataTime: 0
    property real graphTime: 0
    property real lastInputTime: Date.now()
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

    // If unthrottled, rolling graph redraws can bog down CPU when there are many data points are being plotted
    // Timer limits graph redraw to 10 times per second (rather than with every incoming data point)
    Timer {
        id: redrawTimer
        interval: 100
        running: rootChart.visible
        repeat: true
        onTriggered: {
            redrawGraph()
        }
    }

    // If repeatOldData is true, plot the last data point again if a new point hasn't been plotted in 200ms
    Timer {
        id: repeatTimer
        interval: 200
        running: rootChart.visible
        repeat: true
        onTriggered: {
            if (timeSinceLastPlot() > 200) {
                appendData()
            }
        }
    }

    onInputDataChanged: {
        if ( !throttlePlotting ){
            appendData()
        } else if (timeSinceLastPlot() >= 100) { // Under throttle condition: Won't plot unless it has been 100ms since last plot
            appendData()
        }
    }

    Component.onCompleted: {
        valueAxisY.applyNiceNumbers();  // Automatically determine axis ticks
        valueAxisX.applyNiceNumbers();
        rootChart.rollingWindow = maxXValue - minXValue;
    }

    function appendData() {
        rootChart.dataTime += timeSinceLastInputData();
        lastPlottedTime = Date.now()
        dataLine.append(rootChart.dataTime, inputData);
    }

    function redrawGraph() {
        rootChart.graphTime += timeSinceLastRedraw();
        if (centered){
            valueAxisX.max = rootChart.graphTime + rollingWindow/2;
        } else {
            valueAxisX.max = rootChart.graphTime
        }
        valueAxisX.min = valueAxisX.max - rollingWindow;
        trimData()
    }

    // Remove points that are outside of view to save memory
    function trimData() {
        if (dataLine.at(0).x < rootChart.dataTime - rollingWindow * 1.1) {
            dataLine.remove(0)
            trimData() // Recurse to remove other points that may remain due centered view change
        }
        return
    }

    function timeSinceLastInputData(){
        var seconds = (Date.now() - lastInputTime)/1000;
        lastInputTime = Date.now();
        return seconds;
    }

    function timeSinceLastPlot(){
        return Date.now() - lastPlottedTime;
    }

    function timeSinceLastRedraw(){
        var seconds = (Date.now() - lastRedrawTime) / 1000;
        lastRedrawTime = Date.now()
        return seconds;
    }
}
