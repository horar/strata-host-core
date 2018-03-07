import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import tech.spyglass.ImplementationInterfaceBinding 1.0

import QtQuick.Window 2.10
import QtCharts 2.2

ChartView {
    id:chartView
    titleColor: "#D8D8D8"
    titleFont.pointSize:11
    legend.visible:false
    antialiasing: true
    backgroundColor: "black"
    backgroundRoundness: 0
    margins{top:0; left:0; right:0; bottom:0}

    property string chartType: ""
    property int portNumber:0
    property int count:0
    property int maxYValue: 10



    // Define x-axis to be used with the series instead of default one
    ValueAxis {
        id: valueAxisX
        min: 0
        max: 10
        tickCount: 3
        labelFormat: "%.0f"
        labelsFont.family: "helvetica"
        labelsFont.pointSize:8
        labelsColor: Qt.rgba(.5,.5,.5,1)
        //color:Qt.rgba(.5,.5,.5,.8)    //color of axis and tick marks
        gridVisible:false

    }

    ValueAxis {
        id: valueAxisY
        min: 0
        max: maxYValue
        tickCount: 6
        labelFormat: "%.0f"
        labelsFont.family: "helvetica"
        labelsFont.pointSize:8
        labelsColor: Qt.rgba(.5,.5,.5,1)
        //lineVisible: false
        gridLineColor: Qt.rgba(.5,.5,.5,.3)
        //shadesVisible: true
        //shadesColor:Qt.rgba(1,.6,0,.3)    //dark orange
    }

    AreaSeries {
        //name: "Port 1 voltage"
        axisX: valueAxisX
        axisY: valueAxisY
        color: Qt.rgba(.5,.5,.5,.3)     //fill/brush color
        borderWidth: .5                  //borderColor is determined by the line series!
        upperSeries: lineSeries1
    }



    LineSeries {
        id:lineSeries1
        color:Qt.rgba(.9,.9,.9,1)
    }

    LineSeries {
        id:portTargetVoltageLineSeries
        color:Qt.rgba(.9,.9,.9,1)
    }
    LineSeries {
        id:portTemperatureLineSeries
        color:Qt.rgba(.9,.9,.9,1)
    }
    LineSeries {
        id:portPowerLineSeries
        color:Qt.rgba(.9,.9,.9,1)
    }

    Connections {
        target: implementationInterfaceBinding

        onPortOutputVoltageChanged: {
            if( chartType === "Port Voltage" && portNumber == port ) {
                var parameterValue = value;
                portTargetVoltageLineSeries.append(count/10,parameterValue);
                count++;
                //console.log("voltage changed on port ", port, value)
            }
        }

        onPortTemperatureChanged: {
            if( chartType === "Port Temperature" && portNumber == port  ) {
                var parameterValue = value;
                portTemperatureLineSeries.append(count/10,parameterValue);
                count++;

            }

        }

        onPortPowerChanged: {
            if( chartType === "Port Power"  && portNumber == port ) {
                var parameterValue = value;
                portPowerLineSeries.append(count/10,parameterValue);
                count++;
            }
        }

//        onPortOutputVoltageChanged: {
//            if( chartType === "Output Voltage"  && portNumber == port ) {
//                parameterValue = value;
//                var lineSeries1.append(count/10,value);
//                //lineSeries1.name = "Output Voltage";
//                count++;
//            }
//        }

//        onPortInputVoltageChanged:{
//            if( chartType === "Input Power") {
//                parameterValue = value*parameterCurrentValue;
//                var lineSeries1.append(count/10,parameterValue);
//                //lineSeries1.name = "Input Power";
//                count++;


//            }
//        }

    }
}
