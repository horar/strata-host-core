import QtQuick 2.9
import QtQuick.Controls 2.3
import "qrc:/views/efficiency-simulator/sgwidgets/"

Item {
    id: root
    property alias series1: graph.series1
    property alias series2: graph.series2
    property alias dataLine1Color: graph.dataLine1Color
    property alias dataLine2Color: graph.dataLine2Color

    SGStaticGraph {
        id: graph
        anchors {
            left: root.left
            right: buckCircuitImage.left
            top: root.top
            bottom: root.bottom
        }

        title: "Efficiency"
        xAxisTitle: "Load Current"
        yAxisTitle: "Efficiency"
        textColor: "#000000"            // Default: #000000 (black) - Must use hex colors for this property
        minYValue: 50
        maxYValue: 100
        minXValue: 0
        maxXValue: 30
        showXGrids: true
        showYGrids: true
    }

    Rectangle {
        id: buckCircuitImage
        anchors {
            right: root.right
            verticalCenter: root.verticalCenter
        }
        width: 300
        height: childrenRect.height

        SGTitleBar {
            id: title
            title: "<b>Buck Converter Circuit</b>"
        }

        Image {
            anchors {
                top: title.bottom
            }

            sourceSize.width: buckCircuitImage.width
            source: "qrc:/views/efficiency-simulator/images/circuit.png"
        }
    }
}

