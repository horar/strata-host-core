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
    height: graphSelector.nothingChecked ? portSettings.height : portSettings.height + portGraphs.height

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
        textColor: "#666"
        activeTextColor: "white"
        radius: 4
        buttonHeight: 25
        exclusive: false
        buttonImplicitWidth: 50
        enabled: root.portConnected
        property int howManyChecked: 0

        segmentedButtons: GridLayout {
            columnSpacing: 2
            rowSpacing: 2

            SGSegmentedButton{
                text: qsTr("Vout")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph1.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph1.visible = false
                        graphSelector.howManyChecked--
                    }
                }
            }

            SGSegmentedButton{
                text: qsTr("Iout")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph2.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph2.visible = false
                        graphSelector.howManyChecked--
                    }
                }
            }

            SGSegmentedButton{
                text: qsTr("Iin")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph3.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph3.visible = false
                        graphSelector.howManyChecked--
                    }
                }
            }

            SGSegmentedButton{
                text: qsTr("Pout")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph4.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph4.visible = false
                        graphSelector.howManyChecked--
                    }
                }
           }

            SGSegmentedButton{
                text: qsTr("Pin")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph5.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph5.visible = false
                        graphSelector.howManyChecked--
                    }
                }
            }

            SGSegmentedButton{
                text: qsTr("η")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph6.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph6.visible = false
                        graphSelector.howManyChecked--
                    }
                }
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

    Row {
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
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "Test"
            xAxisTitle: "Test"
        }

        SGGraph {
            id: graph2
            title: "Current Out"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph1.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "Test"
            xAxisTitle: "Test"
        }

        SGGraph {
            id: graph3
            title: "Current In"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph2.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "Test"
            xAxisTitle: "Test"
        }

        SGGraph {
            id: graph4
            title: "Power Out"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph3.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "Test"
            xAxisTitle: "Test"
        }

        SGGraph {
            id: graph5
            title: "Power In"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph4.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "Test"
            xAxisTitle: "Test"
        }

        SGGraph {
            id: graph6
            title: "Efficiency"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                //                left: graph4.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "Test"
            xAxisTitle: "Test"
        }
    }
}
