import QtQuick 2.0
import QtCharts 2.1
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
    property bool hardwareStatus : {
// if user wants to reset the axis
//        if(count == 100) {
//            lineSeries1.clear();
//            count = 0;
//            axisX.max = 10;
//        }

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
// if user wants to have a rolling display
//            if(count >= 100) {
//                      axisX.max += .1;
//                      axisX.min += .1;
//                  }
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

    }

    onVisibleChanged: if (visible) {
                          console.log("sohuld start the timer");
                          whenOpen= true;
                      }
                      else {
                          whenOpen = false;
                          if(count!=0) {
//                            lineSeries1.clear();
                            (chartType === "outputVoltageCurrent")?lineSeries2.clear()&lineSeries1.clear():lineSeries1.clear();
                            count = 0;
                            axisX.max=10;
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
}

