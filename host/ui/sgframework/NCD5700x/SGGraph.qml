import QtQuick 2.10
import QtCharts 2.2
import QtQuick.Controls 2.2

ChartView {
    id: rootChart
    title: ""
    titleColor: textColor
    titleFont.pointSize: textSize
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
    property bool rolling: false
    property real rollingRange
    property bool rollingCentered: false

    property real inputData
    property real dataTime: 0
    property real time: Date.now()


    // Define x-axis to be used with the series instead of default one
    ValueAxis {
        id: valueAxisX
        titleText: "<span style='color:"+textColor+"'>"+xAxisTitle+"</span>"
        titleFont.pointSize: rootChart.textSize*.8
        min: minXValue
        max: maxXValue
        color: axesColor
        gridVisible: showXGrids
        gridLineColor: rootChart.gridLineColor
//        tickCount: 11  //  applyNiceNumbers() takes care of this based on range
        labelFormat: "%.0f"
        labelsFont.pointSize: rootChart.textSize*.8
        labelsColor: textColor
    }

    ValueAxis {
        id: valueAxisY
        titleText: "<span style='color:"+textColor+"'>"+yAxisTitle+"</span>"
        titleFont.pointSize: rootChart.textSize*.8
        min: minYValue
        max: maxYValue
        color: axesColor
        gridVisible: showYGrids
        gridLineColor: rootChart.gridLineColor
//        tickCount: 6  //  applyNiceNumbers() takes care of this based on range
        labelFormat: "%.0f"
        labelsFont.pointSize: rootChart.textSize*.8
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
            id: rollingToggle
            checkable: true
            checked: rootChart.rolling
            text: rootChart.rolling ? "Rolling On" : "Rolling Off"
            onClicked: {
                rootChart.rolling = !rootChart.rolling
                if (!rootChart.rolling) { rootChart.rollingCentered = false; }
            }
        }

        Button {
            id: rollingCenteredToggle
            anchors {
                left: rollingToggle.right
            }
            checkable: true
            checked: rootChart.rollingCentered
            text: rootChart.rollingCentered ? "Centered On" : "Centered Off"
            onClicked: {
                rootChart.rollingCentered = !rootChart.rollingCentered
                if (rootChart.rollingCentered) { rootChart.rolling = true; }
            }
        }
    }

    onInputDataChanged: {
        //console.log(valueAxisX.max + "  " + valueAxisX.min + "  " + dataTime);
        if (!rolling){
            rootChart.dataTime += calculateDataInterval();
            dataLine.append(rootChart.dataTime, inputData);
            if (rootChart.dataTime >= maxXValue){
                rootChart.dataTime = minXValue;
                dataLine.clear();
                dataLine.append(rootChart.dataTime, inputData);
            }
        } else {
            rootChart.dataTime += calculateDataInterval();
            dataLine.append(rootChart.dataTime, inputData);
            if (rollingCentered){
                if (rootChart.dataTime >= maxXValue - (rollingRange/2)){
                    valueAxisX.max = rootChart.dataTime + rollingRange/2;
                    valueAxisX.min = valueAxisX.max - rollingRange;
                    if (dataLine.at(0).x < rootChart.dataTime - rollingRange/2) { dataLine.remove(0) } // Remove points that are outside of view
                }
            } else {
                if (rootChart.dataTime >= maxXValue){
                    valueAxisX.max = rootChart.dataTime;
                    valueAxisX.min = valueAxisX.max - rollingRange;
                    if (dataLine.at(0).x < rootChart.dataTime - rollingRange/2) { dataLine.remove(0) }
                }
            }
        }
    }

    onRollingChanged: {
        valueAxisX.min = minXValue;
        valueAxisX.max = maxXValue;
        valueAxisY.applyNiceNumbers();  // Automatically determine axis ticks
        valueAxisX.applyNiceNumbers();
        rootChart.rolling ? valueAxisX.labelFormat = "%.2f" : valueAxisX.labelFormat = "%.0f";
    }

    Component.onCompleted: {
        valueAxisY.applyNiceNumbers();  // Automatically determine axis ticks
        valueAxisX.applyNiceNumbers();
        rootChart.rollingRange = maxXValue - minXValue;
    }

    function calculateDataInterval(){
        var tick = Date.now();
        var seconds = (tick - time)/1000;
        time = tick;
        return seconds;
    }
}
