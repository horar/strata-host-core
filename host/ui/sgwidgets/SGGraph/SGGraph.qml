import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtCharts 2.2

ChartView {
    id: chartView
    title: ""
    titleColor: textColor
    titleFont.pointSize: textSize
    legend { visible:false }
    antialiasing: true
    backgroundColor: "white"
    backgroundRoundness: 0
    anchors {
        fill: parent
        margins: -12
    }
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

    property real inputData
    property real dataTime: 0
    property real time: Date.now()


    // Define x-axis to be used with the series instead of default one
    ValueAxis {
        id: valueAxisX
        titleText: "<span style='color:"+textColor+"'>"+xAxisTitle+"</span>"
        titleFont.pointSize: chartView.textSize*.8
        min: 0
        max: 10
        color: axesColor
        gridVisible: showXGrids
        gridLineColor: chartView.gridLineColor
//        tickCount: 11  //  applyNiceNumbers() takes care of this based on range
        labelFormat: "%.0f"
        labelsFont.pointSize: chartView.textSize*.8
        labelsColor: textColor
    }

    ValueAxis {
        id: valueAxisY
        titleText: "<span style='color:"+textColor+"'>"+yAxisTitle+"</span>"
        titleFont.pointSize: chartView.textSize*.8
        min: 0
        max: maxYValue
        color: axesColor
        gridVisible: showYGrids
        gridLineColor: chartView.gridLineColor
//        tickCount: 6  //  applyNiceNumbers() takes care of this based on range
        labelFormat: "%.0f"
        labelsFont.pointSize: chartView.textSize*.8
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
        Component.onCompleted: { color = dataLineColor } // Faller: there is a bug writing black to the color on loading, and it sets the default green color instead, so this is a workaround
    }


    onInputDataChanged: {
        chartView.dataTime += calculateDataInterval();
        dataLine.append(chartView.dataTime, inputData);
        console.log(dataTime);
        if (chartView.dataTime >= maxXValue){
            chartView.dataTime = minXValue;
            dataLine.clear();
            dataLine.append(chartView.dataTime, inputData);

        }
    }

    // Automatically determine axis ticks
    Component.onCompleted: {
        valueAxisY.applyNiceNumbers();
        valueAxisX.applyNiceNumbers();
    }

    function calculateDataInterval(){
        var tick = Date.now();
        var seconds = (tick - time)/1000;
        console.log(seconds);
        time = tick;
        return seconds;
    }
}
