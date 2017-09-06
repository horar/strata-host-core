import QtQuick 2.7
import QtCharts 2.2

ChartView {
    id: container

    x: 0; y: 0
    implicitWidth: 600; implicitHeight: 400

    property alias title: chartTitle.name

    // warning zone image`
    Rectangle {
        anchors{ top : parent.top
            topMargin: parent.height/5 }

        x: container.plotArea.x; y: container.plotArea.y + 20
        width: container.plotArea.width; height: (container.plotArea.height)/2
        opacity: 0.20
        color: "red"
    }

    SplineSeries {
        id: chartTitle

        name: "Line Graph Chart"

        XYPoint { x: 0; y: 0 }
        XYPoint { x: 1.1; y: 2.1 }
        XYPoint { x: 1.9; y: 3.3 }
        XYPoint { x: 2.1; y: 2.1 }
        XYPoint { x: 2.9; y: 4.9 }
        XYPoint { x: 3.4; y: 3.0 }
        XYPoint { x: 4.1; y: 3.3 }
    }
}
