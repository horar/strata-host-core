import QtQuick 2.7
import QtCharts 2.2
import QtQuick.Controls 1.4

ChartView {
    id: container
    x: 0; y: 0

    property alias variable1Name: variable1.name
    property alias variable2Name: variable2.name
    property alias variable1Color: variable1.color
    property alias variable2Color: variable2.color
    property  bool secondValueVisible: false
    property bool efficencyLable: false

    // warning zone image
    Rectangle {
        anchors{ top : parent.top
            topMargin: parent.height/3.9 }

        x: container.plotArea.x; y: container.plotArea.y + 20
        width: container.plotArea.width; height: (container.plotArea.height)/2
        opacity: 0.20
        color: "red"
    }
    Label {
        id: labelAxisx
        width: 50; height: 50
    }
//    Label {
//        width: 100; height: 50
//        text: "Efficency: 95% "
//        visible: efficencyLable
//        anchors { bottom: container.bottom; left: container.left }
//    }

    ValueAxis {
        id: axisY1
        min: 0
        max: 7
    }

    ValueAxis {
        id: axisY2
        min: -5
        max: 7
    }
    ValueAxis {
        id: axisX
        min: 0
        max: 10
    }
    SplineSeries {
        id: variable1
        color: "blue"
        axisY: axisY1
        axisX: axisX
        XYPoint { x: 0; y: 0 }
        XYPoint { x: 1.1; y: 2.1 }
        XYPoint { x: 1.9; y: 3.3 }
        XYPoint { x: 2.1; y: 2.1 }
        XYPoint { x: 2.9; y: 4.9 }
        XYPoint { x: 3.4; y: 3.0 }
        XYPoint { x: 4.1; y: 3.3 }
        XYPoint { x: 5.1; y: 4.0 }
        XYPoint { x: 6.9; y: 4.3 }
        XYPoint { x: 7.9; y: 6.3 }
        XYPoint { x: 10.0; y: 7.0 }

    }
    SplineSeries {
        id: variable2
        color:"red"
        visible: secondValueVisible
        axisYRight: axisY2
        XYPoint { x: 0; y: 0 }
        XYPoint { x: 1; y: 1 }
        XYPoint { x: 2; y: 2 }
        XYPoint { x: 2.5; y: 2.8 }
        XYPoint { x: 3; y: 3 }
        XYPoint { x: 3.5; y: 3.5}
        XYPoint { x: 4.1; y: 4 }
        XYPoint { x: 5.1; y: 5 }
        XYPoint { x: 6.1; y: 6 }
        XYPoint { x: 7.9; y: 4.2 }
        XYPoint { x: 10.0; y: 5.2 }
    }
}
