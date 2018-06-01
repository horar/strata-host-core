import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGGraph Example")

    property real dAta

    SGGraph{
            // chartview needs to be run in a Qapplication, not the default qguiapplication
            // https://stackoverflow.com/questions/34099236/qtquick-chartview-qml-object-seg-faults-causes-qml-engine-segfault-during-load
            id: graph

            inputData: dAta

            // Optional graph settings:
            title: "Graph"                  // Default: empty
            xAxisTitle: "seconds"            // Default: empty
            yAxisTitle: "why axis"          // Default: empty
            textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this
            dataLineColor: "white"          // Default: #000000 (black)
            axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
            gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
            underDataColor: "transparent"   // Default: Qt.rgba(.5, .5, .5, .3) (transparent gray)
            backgroundColor: "black"        // Default: #ffffff (white)
            minYValue: 0                    // Default: 0
            maxYValue: 20                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 10                   // Default: 10
            showXGrids: false               // Default: false
            showYGrids: true                // Default: false
        }

    Timer {
        property real count: 0
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            count+= interval;
            dAta = Math.sin(count/500)*3+10;
        }
    }
}
