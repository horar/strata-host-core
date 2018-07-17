import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "qrc:/sgwidgets"

Item {
    id: root

    property bool debugLayout: true
    property int portNumber: 1
    property alias portConnected: portInfo.portConnected
    property alias portColor: portInfo.portColor
    property bool showGraphs: false

    width: parent.width
    height: root.showGraphs ? portSettings.height + portGraphs.height : portSettings.height

    //TODO - Faller: when port is disconnected, close graphs

    PortInfo {
        id: portInfo
        anchors {
            left: parent.left
            top: root.top
            bottom: graphSelector.top
        }
    }

    SGSegmentedButtonStrip {
        id: graphSelector
        label: "<b>Show Graphs:</b>"
        labelLeft: false
        anchors {
            bottom: portSettings.bottom
            bottomMargin: 15
            horizontalCenter: portInfo.horizontalCenter
        }
        activeColorTop: "#666"
        activeColorBottom: "#666"
        inactiveColorTop: "#dddddd"
        inactiveColorBottom: "#dddddd"
        textColor: "#666"
        activeTextColor: "white"
        radius: 4
        buttonHeight: 25
        exclusive: false
        buttonImplicitWidth: 50
        enabled: root.portConnected

        segmentedButtons: GridLayout {
            columnSpacing: 2
            rowSpacing: 2

            SGSegmentedButton{
                text: qsTr("Vout")
                enabled: root.portConnected
            }

            SGSegmentedButton{
                text: qsTr("Iout")
                enabled: root.portConnected
            }

            SGSegmentedButton{
                text: qsTr("Iin")
                enabled: root.portConnected
            }

            SGSegmentedButton{
                text: qsTr("Pout")
                enabled: root.portConnected
           }

            SGSegmentedButton{
                text: qsTr("Pin")
                enabled: root.portConnected
            }

            SGSegmentedButton{
                text: qsTr("η")
                enabled: root.portConnected
            }
        }
    }


    PortSettings {
        id: portSettings
        anchors {
            left: portInfo.right
            top: portInfo.top
            right: root.right
        }
        height: 300

        SGLayoutDivider {
            position: "left"
        }
    }

    Item {
        id: portGraphs
        anchors {
            top: portSettings.bottom
            topMargin: 15
            left: root.left
            right: root.right
        }
        height:250

        SGGraph {
            id: graph1
            title: "Voltage Out"
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
            }
            width: height
            yAxisTitle: "Test"
            xAxisTitle: "Test"
        }

        SGGraph {
            id: graph2
            title: "Current Out"
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                left: graph1.right
            }
            width: height
            yAxisTitle: "Test"
            xAxisTitle: "Test"
        }

        SGGraph {
            id: graph3
            title: "Current In"
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                left: graph2.right
            }
            width: height
            yAxisTitle: "Test"
            xAxisTitle: "Test"
        }

        SGGraph {
            id: graph4
            title: "Power Out"
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                left: graph3.right
            }
            width: height
            yAxisTitle: "Test"
            xAxisTitle: "Test"
        }

        SGGraph {
            id: graph5
            title: "Power In"
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                left: graph4.right
            }
            width: height
            yAxisTitle: "Test"
            xAxisTitle: "Test"
        }
    }
}
