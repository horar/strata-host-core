import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGGraph Example")

    SGGraphStatic {
        // ChartView needs to be run in a QApplication, not the default QGuiApplication
        // https://stackoverflow.com/questions/34099236/qtquick-chartview-qml-object-seg-faults-causes-qml-engine-segfault-during-load
        id: graph

        anchors {
            fill: parent                // Set custom anchors for responsive sizing
        }

        // Optional graph settings:
        title: "Graph"                  // Default: empty
        xAxisTitle: "X axis"           // Default: empty
        yAxisTitle: "Why axis"          // Default: empty
        textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this property
        dataLine1Color: "white"          // Default: #000000 (black)
        dataLine2Color: "blue"          // Default: #000000 (black)
        axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
        gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
        backgroundColor: "black"        // Default: #ffffff (white)
        minYValue: 0                    // Default: 0
        maxYValue: 20                   // Default: 10
        minXValue: 0                    // Default: 0
        maxXValue: 20                    // Default: 10
        showXGrids: false               // Default: false
        showYGrids: true                // Default: false

        Component.onCompleted: {
            for (var i = 0; i < 100; i=(i+.1)){
                series1.append(i, Math.sin(i)+10)
            }
        }
    }
}
