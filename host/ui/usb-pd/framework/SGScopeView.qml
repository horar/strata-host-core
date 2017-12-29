import QtQuick 2.0
import QtCharts 2.1
import QtQuick.Controls 1.4
import tech.spyglass.ImplementationInterfaceBinding 1.0

ChartView {
    id: chartView
    animationOptions: ChartView.NoAnimation
    theme: ChartView.ChartThemeLight
    property int count:0
    property string chartType: ""
    property int portNumber:0
    property bool whenOpen: false
    property var parameterValue: 1
    property var parameterCurrentValue: 0
    property var  efficencyValue: 0
    property bool efficencyVisible: false
    property real minLimit: 0
    property real maxLimit: 0.50

    property int plotWidth: 0
    property int plotHeight: 0
    property int plotX: 0
    property int plotY: 0
    property int setUpperRectheight: 0
    property int setLowerRectheight: 0
    property real currentHeight: 0
    property real percentageHeight: 0
    property real overallHeight: 0
    property bool portTempRedZone: false
    property bool inputPowerRedZone: false
    property bool currentYvalueOnGraphVisibility: false
    property string warningMessageOntheGraph: warningMessage.text

    property bool hardwareStatus : {
        // if user wants to shrink all the data in single chart after opening the graph
        if(chartView.count%100 == 0 && chartView.count!=0){
            axisX.max+=5;
        }
        if(chartView.parameterValue > axisY1.max) {
            axisY1.max = chartView.parameterValue+1;
        }

        implementationInterfaceBinding.platformState
    }
    onPlotAreaChanged:  {
        plotWidth = plotArea.width;
        plotHeight = plotArea.height;
        plotX = plotArea.x;
        plotY = plotArea.y;
        setUpperRectheight =  (1 - (minLimit/axisY1.max)) * plotHeight;
        setLowerRectheight = (maxLimit/axisY1.max) * plotHeight;

    }
    onVisibleChanged: {
        if(visible){
            whenOpen = true;
        }
        else {
            whenOpen = false;
            if(count != 0) {
                (chartType === "outputVoltageCurrent")?lineSeries2.clear()&lineSeries1.clear():lineSeries1.clear();
                count = 0;
                axisX.max= 10;
            }
        }
    }

    Label
    {
        id: warningMessage
        opacity: 0.0
        text: warningMessageOntheGraph
        font.bold: true
        font.pixelSize: 22
        color: "red"
        anchors.centerIn: parent

    }

    Connections {
        target: implementationInterfaceBinding

        onPortTargetVoltageChanged: {
            if( chartType === "Target Voltage" && whenOpen && portNumber == port ) {
                parameterValue = value;
                lineSeries1.append(count/10,parameterValue);
                count++;
            }
        }

        onPortTemperatureChanged: {
            if( chartType === "Port Temperature"&& whenOpen && portNumber == port  ) {
                parameterValue = value;
                lineSeries1.append(count/10,parameterValue);
                count++;
//                if(parameterValue <= currentHeight) {
//                    warningMessage.opacity = 1.0;
//                    warningMessageOntheGraph = "Temperature Too High";
//                    currentYvalueOnGraphVisibility = false;
//                }
//                else  {
//                    warningMessage.opacity = 0.0;
//                    currentYvalueOnGraphVisibility = true;
//                }

            }

        }

        onPortPowerChanged: {
            if( chartType === "Port Power"&& whenOpen  && portNumber == port ) {
                parameterValue = value;
                lineSeries1.append(count/10,parameterValue);
                count++;
            }
        }

        onPortOutputVoltageChanged: {
            if( chartType === "Output Voltage"&& whenOpen  && portNumber == port ) {
                parameterValue = value;
                lineSeries1.append(count/10,value);
                lineSeries1.name = "Output Voltage";
                count++;
            }
        }

        onPortInputVoltageChanged:{
            if( chartType === "Input Power"&& whenOpen) {
                parameterValue = value*parameterCurrentValue;
                lineSeries1.append(count/10,parameterValue);
                lineSeries1.name = "Input Power";
                count++;
//                if(parameterValue <= currentHeight) {
//                    warningMessage.opacity = 1.0;
//                    warningMessageOntheGraph = "Voltage Too Low";
//                    currentYvalueOnGraphVisibility = false;

//                }
//                else  {
//                    warningMessage.opacity = 0.0;
//                    currentYvalueOnGraphVisibility = true;
//                }

            }
        }

        onPortCurrentChanged: {
            parameterCurrentValue = value;
        }
        onPortEfficencyChanged: {
            if( chartType === "Input Power"&& whenOpen  && portNumber == port ) {
                efficencyValue = output_power/input_power;

            }
        }
    }

//    MouseArea {
//        anchors.fill: parent
//        onClicked: {
//            if(!selection)
//            {
//                selection = selectionComponent.createObject(parent, {"x": plotX, "y": plotY, "width": plotWidth , "height":setUpperRectheight})
//                selection = selectionComponent2.createObject(parent, {"x": plotX, "y": plotY + plotHeight - setLowerRectheight , "width": plotWidth , "height": setLowerRectheight});
//            }
//        }
//    }

//    Component {
//        id: selectionComponent

//        Rectangle {
//            id: selComp
//            opacity: 0.2
//            visible: portTempRedZone
//            Label {
//                id: currentYvalue
//                opacity: 1.0
//                text: currentHeight.toFixed(2)
//                font.bold: true
//                font.pixelSize: 22
//                color: "red"
//                anchors.centerIn: parent
//                visible: currentYvalueOnGraphVisibility


//            }
//            border {
//                width: 2
//                color: "red"
//            }
//            color: "red"
//            property int rulersSize: 20
//            MouseArea {     // drag mouse area
//                anchors.fill: parent
//                drag{
//                    target: parent
//                    minimumX: 0
//                    minimumY: 0
//                    maximumX: parent.parent.width - parent.width
//                    maximumY: parent.parent.height - parent.height
//                    smoothed: true
//                }

//                onDoubleClicked: {
//                    parent.destroy()        // destroy component
//                }
//            }

//            Rectangle {
//                width: rulersSize
//                height: rulersSize
//                radius: rulersSize
//                x: parent.x / 2
//                y: parent.y
//                opacity: 2
//                color: "red"
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.verticalCenter: parent.bottom

//                MouseArea {
//                    anchors.fill: parent
//                    drag{ target: parent; axis: Drag.YAxis }
//                    onMouseYChanged: {
//                        if(drag.active){
//                            selComp.height = selComp.height + mouseY;
//                            overallHeight = selComp.height/plotHeight;
//                            currentHeight = - ((axisY1.max * overallHeight) - (axisY1.max));
//                            currentYvalue.opacity = 1.0
//                            currentYvalueOnGraphVisibility = true;
//                            if(currentHeight > axisY1.max) {
//                                currentYvalue.opacity = 0.0;
//                                currentYvalueOnGraphVisibility = false;
//                                selComp.height = 0;
//                            }
//                            else if(currentHeight < axisY1.min) {
//                                selComp.height = plotHeight;
//                                currentHeight = 0.0;
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }

//    Component {
//        id: selectionComponent2
//        Rectangle {
//            id: selComp2
//            opacity: 0.2
//            visible: inputPowerRedZone
//            z:1

//            Label {
//                id: currentYvalueInInputPower
//                opacity: 1.0
//                text: currentHeight.toFixed(2)
//                font.bold: true
//                font.pixelSize: 22
//                color: "red"
//                z:2
//                anchors.centerIn: parent
//                visible: currentYvalueOnGraphVisibility
//            }

//            border {
//                width: 2
//                color: "red"
//            }
//            color: "red"
//            property int rulersSize: 20
//            MouseArea {     // drag mouse area
//                anchors.fill: parent
//                drag{
//                    target: parent
//                    minimumX: 0
//                    minimumY: 0
//                    maximumX: parent.parent.width - parent.width
//                    maximumY: parent.parent.height - parent.height
//                    smoothed: true
//                }

//                onDoubleClicked: {
//                    parent.destroy()        // destroy component
//                }
//            }

//            Rectangle {
//                id: draggableHolder
//                width: rulersSize
//                height: rulersSize
//                radius: rulersSize
//                x: parent.x/2
//                y: parent.y
//                opacity: 2
//                color: "red"
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.verticalCenter: parent.top
//                MouseArea {
//                    anchors.fill: parent
//                    drag{ target: parent; axis: Drag.YAxis }
//                    onMouseYChanged: {
//                        if(drag.active){
//                            selComp2.height = selComp2.height - mouseY
//                            selComp2.y = selComp2.y + mouseY
//                            overallHeight = selComp2.height/plotHeight;
//                            currentHeight = (axisY1.max * overallHeight);
//                            currentYvalueInInputPower.opacity = 1.0;
//                            currentYvalueOnGraphVisibility = true;

//                            if(currentHeight > axisY1.max) {
//                                selComp2.height = plotHeight;
//                                selComp2.y = plotY;
//                                currentYvalueInInputPower.opacity = 0.0;
//                                currentYvalueOnGraphVisibility = false;
//                            }
//                            else if(currentHeight < axisY1.min) {
//                                selComp2.height = 0;
//                                selComp2.y = plotY + plotHeight;
//                                currentYvalueInInputPower.opacity = 0.0;
//                                currentYvalueOnGraphVisibility = false;

//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }

    ValueAxis {
        id: axisY1
        min: 0
        max: 1
    }

    ValueAxis {
        id: axisX
        min: 0
        max: 10
        visible: true
    }

    LineSeries {
        id: lineSeries1
        name: chartView.chartType
        axisX: axisX
        axisY: axisY1
    }
    LineSeries {
        id: lineSeries2
        axisX: axisX
        axisY: axisY1
        visible: false
    }

    Label {
        id: efficencyLabel
        width: 100; height: 50
        text:  "Efficency: "+ Math.round(efficencyValue,2) + "%"
        visible: efficencyVisible
        z: 2
        anchors { bottom: chartView.bottom; left: chartView.left ; bottomMargin: -20}
    }
}

