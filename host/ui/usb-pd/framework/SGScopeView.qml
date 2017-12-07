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
                // lineSeries2.visible = true;
                lineSeries1.append(count/10,value);
                lineSeries1.name = "Output Voltage";
                count++;
            }
        }

        onPortInputVoltageChanged:{
            if( chartType === "Input Power"&& whenOpen  && portNumber == port ) {
                parameterValue = value*parameterCurrentValue;
                // lineSeries2.visible = true;
                lineSeries1.append(count/10,parameterValue);
                lineSeries1.name = "Input Power";
                count++;
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

    onVisibleChanged: if (visible) {
                          console.log("should start the timer");
                          whenOpen= true;
                      }
                      else {
                          whenOpen = false;
                          if(count!=0) {
                              (chartType === "outputVoltageCurrent")?lineSeries2.clear()&lineSeries1.clear():lineSeries1.clear();
                              count = 0;
                              axisX.max=10;
                          }
                      }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if(!selection)
            {
                selection = selectionComponent.createObject(parent, {"x": 10, "y": 10, "width": parent.width - 60 , "height":parent.height / 3})
            }
        }
    }
    Component {
        id: selectionComponent

        Rectangle {
            id: selComp
            opacity: 0.2

            anchors { top : parent.top;
                topMargin: parent.height/4
                left: parent.left
                leftMargin: 59
                right: parent.right
                rightMargin: 51
            }

            border {
                width: 2
                color: "red"
            }
            color: "red"
            property int rulersSize: 20
            MouseArea {     // drag mouse area
                anchors.fill: parent
                drag{
                    target: parent
                    minimumX: 0
                    minimumY: 0
                    maximumX: parent.parent.width - parent.width
                    maximumY: parent.parent.height - parent.height
                    smoothed: true
                }

                onDoubleClicked: {
                    parent.destroy()        // destroy component
                }
            }

            Rectangle {
                width: rulersSize
                height: rulersSize
                radius: rulersSize
                x: parent.x / 2
                y: parent.y
                opacity: 2
                color: "red"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.bottom

                MouseArea {
                    anchors.fill: parent
                    drag{ target: parent; axis: Drag.YAxis }
                    onMouseYChanged: {
                        if(drag.active){
                            selComp.height = selComp.height + mouseY
                            if(selComp.height < 50)
                                selComp.height = 50
                        }
                    }
                }
            }
        }
    }

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

