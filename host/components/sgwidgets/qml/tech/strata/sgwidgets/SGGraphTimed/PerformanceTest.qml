import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

//////// This is just for performance testing this SGGraphTimed, this file is not needed for any other projects

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGGraph Example")

    SGGraphTimed {
        id: graph
        width: parent.width/2
        height: parent.height/4
        inputData: graphData.stream
        minYValue: 0                    // Default: 0
        maxYValue: 20                   // Default: 10
        minXValue: 0                    // Default: 0
        maxXValue: 5                    // Default: 10
        showYGrids: true                // Default: false
    }
    SGGraphTimed {
        id: graph1
        anchors {
            top: graph.bottom
        }
        width: parent.width/2
        height: parent.height/4
        inputData: graphData1.stream          // Set the graph's data source here
        minYValue: 0                    // Default: 0
        maxYValue: 20                   // Default: 10
        minXValue: 0                    // Default: 0
        maxXValue: 5                    // Default: 10
        showYGrids: true                // Default: false
    }
    SGGraphTimed {
        id: graph2
        anchors {
            left: graph.right
        }
        width: parent.width/2
        height: parent.height/4
        inputData: graphData2.stream          // Set the graph's data source here
        minYValue: 0                    // Default: 0
        maxYValue: 20                   // Default: 10
        minXValue: 0                    // Default: 0
        maxXValue: 5                    // Default: 10
        showYGrids: true                // Default: false
    }
    SGGraphTimed {
        id: graph3
        anchors {
            top: graph.bottom
             left: graph.right
        }
        width: parent.width/2
        height: parent.height/4
        inputData: graphData3.stream          // Set the graph's data source here
        minYValue: 0                    // Default: 0
        maxYValue: 20                   // Default: 10
        minXValue: 0                    // Default: 0
        maxXValue: 5                    // Default: 10
        showYGrids: true                // Default: false
    }
    SGGraphTimed {
        // ChartView needs to be run in a QApplication, not the default QGuiApplication
        // https://stackoverflow.com/questions/34099236/qtquick-chartview-qml-object-seg-faults-causes-qml-engine-segfault-during-load
        id: graph4

        width: parent.width/2
        height: parent.height/4
        anchors {
            top: graph3.bottom
        }

        inputData: graphData.stream          // Set the graph's data source here

        // Optional graph settings:
        minYValue: 0                    // Default: 0
        maxYValue: 20                   // Default: 10
        minXValue: 0                    // Default: 0
        maxXValue: 5                    // Default: 10
        showYGrids: true                // Default: false
    }
    SGGraphTimed {
        id: graph5
        anchors {
            top: graph4.bottom
        }
        width: parent.width/2
        height: parent.height/4
        inputData: graphData1.stream          // Set the graph's data source here
        minYValue: 0                    // Default: 0
        maxYValue: 20                   // Default: 10
        minXValue: 0                    // Default: 0
        maxXValue: 5                    // Default: 10
        showYGrids: true                // Default: false
    }
    SGGraphTimed {
        id: graph6
        anchors {
            left: graph4.right
             top: graph3.bottom
        }
        width: parent.width/2
        height: parent.height/4
        inputData: graphData2.stream          // Set the graph's data source here
        minYValue: 0                    // Default: 0
        maxYValue: 20                   // Default: 10
        minXValue: 0                    // Default: 0
        maxXValue: 5                    // Default: 10
        showYGrids: true                // Default: false
    }
    SGGraphTimed {
        id: graph7
        anchors {
            top: graph4.bottom
            left: graph4.right
        }
        width: parent.width/2
        height: parent.height/4
        inputData: graphData3.stream          // Set the graph's data source here
        minYValue: 0                    // Default: 0
        maxYValue: 20                   // Default: 10
        minXValue: 0                    // Default: 0
        maxXValue: 5                    // Default: 10
        showYGrids: true                // Default: false
    }

    // Sends demo data stream with adjustible timing interval output
    Timer {
        id: graphData
        property real stream
        property real count: 0
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream = Math.sin(count/500)*3+10;
        }
    }
    Timer {
        id: graphData1
        property real stream
        property real count: 0
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream = Math.sin(count/400)*3+10;
        }
    }
    Timer {
        id: graphData2
        property real stream
        property real count: 0
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream = Math.sin(count/300)*3+10;
        }
    }
    Timer {
        id: graphData3
        property real stream
        property real count: 0
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream = Math.sin(count/200)*3+10;
        }
    }

    Button {
        onClicked: {
           graph1.visible = !graph1.visible
            graph2.visible = !graph2.visible
            graph3.visible = !graph3.visible
            graph.visible = !graph.visible
        }
    }
}
