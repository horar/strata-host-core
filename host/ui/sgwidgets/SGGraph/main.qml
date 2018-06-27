import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGGraph Example")

    SGGraph {
        // ChartView needs to be run in a QApplication, not the default QGuiApplication
        // https://stackoverflow.com/questions/34099236/qtquick-chartview-qml-object-seg-faults-causes-qml-engine-segfault-during-load
        id: graph

        anchors {
            fill: parent                // Set custom anchors for responsive sizing
        }

        inputData: graphData.stream          // Set the graph's data source here

        // Optional graph settings:
        title: "Graph"                  // Default: empty
        xAxisTitle: "Seconds"           // Default: empty
        yAxisTitle: "why axis"          // Default: empty
        textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this property
        dataLineColor: "white"          // Default: #000000 (black)
        axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
        gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
        underDataColor: "transparent"   // Default: Qt.rgba(.5, .5, .5, .3) (transparent gray)
        backgroundColor: "black"        // Default: #ffffff (white)
        minYValue: 0                    // Default: 0
        maxYValue: 20                   // Default: 10
        minXValue: 0                    // Default: 0
        maxXValue: 5                    // Default: 10
        showXGrids: false               // Default: false
        showYGrids: true                // Default: false
        showOptions: true               // Default: false
    }

    // Sends demo data stream with adjustible timing interval output
    Timer {
        id: graphData
        property real stream
        property real count: 0
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream = Math.sin(count/500)*3+10;
        }
    }
}
