import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0


import QtQuick.Window 2.10
import QtCharts 2.2

ChartView {
    id:chartView
    //title: "PORT 1: VOLTAGE AND CURRENT"
    titleColor: "#D8D8D8"//Qt.rgba(.5,.5,.5,1)
    titleFont.pointSize:11
    legend.visible:false
    antialiasing: true
    backgroundColor: "black"
    backgroundRoundness: 0
    margins{top:0; left:0; right:0; bottom:0}



    // Define x-axis to be used with the series instead of default one
    ValueAxis {
        id: valueAxisX
        min: 2000
        max: 2011
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
        max: 10
        tickCount: 6
        labelFormat: "%.0f"
        labelsFont.family: "helvetica"
        labelsFont.pointSize:8
        labelsColor: Qt.rgba(.5,.5,.5,1)
        //lineVisible: false
        gridLineColor: Qt.rgba(.5,.5,.5,.3)
        //shadesVisible: true
        //shadesColor:Qt.rgba(1,153/255,0,.3)
    }

    AreaSeries {
        //name: "Port 1 voltage"
        axisX: valueAxisX
        axisY: valueAxisY
        color: Qt.rgba(1,153/255,0,.3)//Qt.rgba(.5,.5,.5,.3)     //fill/brush color
        borderWidth: .5                  //borderColor is determined by the line series!
        upperSeries: upperLineSeries
    }



    LineSeries {
        id:upperLineSeries
        color:Qt.rgba(.9,.9,.9,1)
        XYPoint { x: 2000; y: 1 }
        XYPoint { x: 2001; y: 4 }
        XYPoint { x: 2002; y: 3 }
        XYPoint { x: 2003; y: 5 }
        XYPoint { x: 2004; y: 7 }
        XYPoint { x: 2005; y: 8 }
        XYPoint { x: 2006; y: 9 }
        XYPoint { x: 2007; y: 6 }
        XYPoint { x: 2008; y: 7 }
        XYPoint { x: 2009; y: 3 }
        XYPoint { x: 2010; y: 2 }
        XYPoint { x: 2011; y: 1 }
    }
}
