import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item{
    id:mainmenu
    anchors.fill: parent

    RowLayout{
        id:rowright
        width: parent.width
        height:parent.height/2.5

        //        anchors.top: title.bottom
        Rectangle{
            Layout.preferredWidth:parent.width/1.5
            Layout.preferredHeight: parent.height-100

            Rectangle{
                id:rec1
                anchors.fill:parent
                color: "transparent"

                RowLayout {
                    anchors.fill:parent

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        ColumnLayout{
                            id : a
                            anchors.fill: parent

                            SGLabelledInfoBox {
                                id: labelledInfoBox1
                                infoBoxWidth: 100
                                label: "INPUT VOLTAGE"
                                info: yourSpeedValue + " Vrms"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledInfoBox {
                                id: labelledInfoBox2
                                infoBoxWidth: 110
                                label: "INPUT CURRENT"
                                info: "2.00 Arms"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledInfoBox {
                                id: labelledInfoBox3
                                infoBoxWidth: 120
                                label: "OUTPUT VOLTAGE"
                                info: "12.02 V"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                        }
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        ColumnLayout{
                            id : b
                            anchors.fill: parent

                            SGLabelledInfoBox {
                                id: labelledInfoBox4
                                infoBoxWidth: 150
                                label: "INPUT (ACTIVE) POWER"
                                info: "120 W"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledInfoBox {
                                id: labelledInfoBox5
                                infoBoxWidth: 120
                                label: "REACTIVE POWER"
                                info: "10 VAR"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledInfoBox {
                                id: labelledInfoBox6
                                infoBoxWidth: 120
                                label: "OUTPUT CURRENT"
                                info: "8.50 A"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                        }

                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        ColumnLayout{
                            id : c
                            anchors.fill: parent

                            SGLabelledInfoBox {
                                id: labelledInfoBox7
                                infoBoxWidth: 120
                                label: "APPARENT POWER"
                                info: "120 VA"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledInfoBox {
                                id: labelledInfoBox8
                                infoBoxWidth: 100
                                label: "POWER FACTOR"
                                info: "0.90"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledInfoBox {
                                id: labelledInfoBox9
                                infoBoxWidth: 110
                                label: "OUTPUT POWER"
                                info: "100 W"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                        }

                    }
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        ColumnLayout{
                            id : d
                            anchors.fill: parent

                            SGLabelledInfoBox {
                                id: labelledInfoBox10
                                infoBoxWidth: 110
                                label: "LINE FREQUENCY"
                                info: "50 Hz"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledInfoBox {
                                id: labelledInfoBox11
                                infoBoxWidth: 100
                                label: "LOSS (Pin-Pout)"
                                info: "20 W"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledInfoBox {
                                id: labelledInfoBox12
                                infoBoxWidth: 100
                                label: "<b>EFFICIENCY</b>"
                                info: "95 %"
                                labelLeft: false

                                Layout.alignment: Qt.AlignCenter
                            }
                        }
                    }
                } //end of rowlayout
            }


        }
        Rectangle{
            //            Layout.preferredHeight: parent.height-100
            //            Layout.preferredWidth: parent.width - 50
            color: "red"//"transparent"
            Layout.rightMargin: 10
            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle{
                anchors.fill:parent
                anchors.centerIn: parent

                SGGraphTimed {
                    id: graph
                    anchors {
                        fill: parent             // Set custom anchors for responsive sizing
                    }
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
                    minXValue: -5                   // Default: 0
                    maxXValue: 0                    // Default: 5
                    showXGrids: false               // Default: false
                    showYGrids: true                // Default: false
                    xAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                    yAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                    throttlePlotting: true          // Default: true - Restricts plotting to every 100ms or more to save resources, false plots on every inputData change (NOT RECOMMENDED)
                    repeatOldData: visible          // Default: visible - If no new data has been sent after 200ms, graph will plot a new point at the current time with the last input value

                    //                    inputData: yourUpdatingData  // Set the graph's data source here
                }
            }
        }
    }

    Rectangle{
        id:rec2
        width: parent.width
        height: parent.height/2
        anchors.top: rowright.bottom
        color: "transparent"

        ColumnLayout{
            anchors.fill: parent

            Rectangle{
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: parent.height/10
                color: "transparent"
                Layout.leftMargin: 50

                SGSegmentedButtonStrip {
                    id: segmentedButtons

                    segmentedButtons: GridLayout {
                        columnSpacing: 5

                        SGSegmentedButton{
                            id:voutgraph
                            text: qsTr("Vout")
                            checked: true  // Sets default checked button when exclusive
                            onClicked: {
                                graph1.opacity = 1.0
                                graph1.enabled = true
                                graph2.opacity = 0.5
                                graph2.enabled = false
                                graph3.opacity = 0.5
                                graph3.enabled = false
                                graph4.opacity = 0.5
                                graph4.enabled = false
                                graph5.opacity = 0.5
                                graph5.enabled = false
                                graph6.opacity = 0.5
                                graph6.enabled = false
                            }
                        }

                        SGSegmentedButton{
                            id:ioutgraph
                            text: qsTr("Iout")
                            checked: false  // Sets default checked button when exclusive
                            onClicked: {
                                graph1.opacity = 0.5
                                graph1.enabled = false
                                graph2.opacity = 1.0
                                graph2.enabled = true
                                graph3.opacity = 0.5
                                graph3.enabled = false
                                graph4.opacity = 0.5
                                graph4.enabled = false
                                graph5.opacity = 0.5
                                graph5.enabled = false
                                graph6.opacity = 0.5
                                graph6.enabled = false

                            }
                        }

                        SGSegmentedButton{
                            id:poutgraph
                            text: qsTr("Pout")
                            checked: false  // Sets default checked button when exclusive
                            onClicked: {
                                graph1.opacity = 0.5
                                graph1.enabled = false
                                graph2.opacity = 0.5
                                graph2.enabled = false
                                graph3.opacity = 1.0
                                graph3.enabled = true
                                graph4.opacity = 0.5
                                graph4.enabled = false
                                graph5.opacity = 0.5
                                graph5.enabled = false
                                graph6.opacity = 0.5
                                graph6.enabled = false
                            }
                        }

                        SGSegmentedButton{
                            id:pingraph
                            text: qsTr("Pin")
                            checked: false  // Sets default checked button when exclusive
                            onClicked: {
                                graph1.opacity = 0.5
                                graph1.enabled = false
                                graph2.opacity = 0.5
                                graph2.enabled = false
                                graph3.opacity = 0.5
                                graph3.enabled = false
                                graph4.opacity = 1.0
                                graph4.enabled = true
                                graph5.opacity = 0.5
                                graph5.enabled = false
                                graph6.opacity = 0.5
                                graph6.enabled = false
                            }
                        }

                        SGSegmentedButton{
                            id:iingraph
                            text: qsTr("Iin")
                            checked: false  // Sets default checked button when exclusive
                            onClicked: {
                                graph1.opacity = 0.5
                                graph1.enabled = false
                                graph2.opacity = 0.5
                                graph2.enabled = false
                                graph3.opacity = 0.5
                                graph3.enabled = false
                                graph4.opacity = 0.5
                                graph4.enabled = false
                                graph5.opacity = 1.0
                                graph5.enabled = true
                                graph6.opacity = 0.5
                                graph6.enabled = false
                            }
                        }

                        SGSegmentedButton{
                            id:pfgraph
                            text: qsTr("PF")
                            checked: false  // Sets default checked button when exclusive
                            onClicked: {
                                graph1.opacity = 0.5
                                graph1.enabled = false
                                graph2.opacity = 0.5
                                graph2.enabled = false
                                graph3.opacity = 0.5
                                graph3.enabled = false
                                graph4.opacity = 0.5
                                graph4.enabled = false
                                graph5.opacity = 0.5
                                graph5.enabled = false
                                graph6.opacity = 1.0
                                graph6.enabled = true
                            }
                        }
                    }
                }
            }

            Rectangle{
                Layout.preferredWidth:parent.width - 40
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                color: "transparent"

                RowLayout{
                    anchors.fill: parent

                    SGGraphTimed {
                        id: graph1
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        opacity: 0.5
                        enabled: false
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
                        minXValue: -5                   // Default: 0
                        maxXValue: 0                    // Default: 5
                        showXGrids: false               // Default: false
                        showYGrids: true                // Default: false
                        xAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                        yAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                        throttlePlotting: true          // Default: true - Restricts plotting to every 100ms or more to save resources, false plots on every inputData change (NOT RECOMMENDED)
                        repeatOldData: visible          // Default: visible - If no new data has been sent after 200ms, graph will plot a new point at the current

                        //                        inputData: yourUpdatingData  // Set the graph's data source here

                    }

                    SGGraphTimed {
                        id: graph2
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        opacity: 0.5
                        enabled: false
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
                        minXValue: -5                   // Default: 0
                        maxXValue: 0                    // Default: 5
                        showXGrids: false               // Default: false
                        showYGrids: true                // Default: false
                        xAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                        yAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                        throttlePlotting: true          // Default: true - Restricts plotting to every 100ms or more to save resources, false plots on every inputData change (NOT RECOMMENDED)
                        repeatOldData: visible          // Default: visible - If no new data has been sent after 200ms, graph will plot a new point at the current

                        //                        inputData: yourUpdatingData  // Set the graph's data source here
                    }

                    SGGraphTimed {
                        id: graph3
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        opacity: 0.5
                        enabled: false
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
                        minXValue: -5                   // Default: 0
                        maxXValue: 0                    // Default: 5
                        showXGrids: false               // Default: false
                        showYGrids: true                // Default: false
                        xAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                        yAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                        throttlePlotting: true          // Default: true - Restricts plotting to every 100ms or more to save resources, false plots on every inputData change (NOT RECOMMENDED)
                        repeatOldData: visible          // Default: visible - If no new data has been sent after 200ms, graph will plot a new point at the current

                        //                        inputData: yourUpdatingData  // Set the graph's data source here
                    }

                    SGGraphTimed {
                        id: graph4
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        opacity: 0.5
                        enabled: false
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
                        minXValue: -5                   // Default: 0
                        maxXValue: 0                    // Default: 5
                        showXGrids: false               // Default: false
                        showYGrids: true                // Default: false
                        xAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                        yAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                        throttlePlotting: true          // Default: true - Restricts plotting to every 100ms or more to save resources, false plots on every inputData change (NOT RECOMMENDED)
                        repeatOldData: visible          // Default: visible - If no new data has been sent after 200ms, graph will plot a new point at the current

                        //                        inputData: yourUpdatingData  // Set the graph's data source here
                    }

                    SGGraphTimed {
                        id: graph5
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        opacity: 0.5
                        enabled: false
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
                        minXValue: -5                   // Default: 0
                        maxXValue: 0                    // Default: 5
                        showXGrids: false               // Default: false
                        showYGrids: true                // Default: false
                        xAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                        yAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                        throttlePlotting: true          // Default: true - Restricts plotting to every 100ms or more to save resources, false plots on every inputData change (NOT RECOMMENDED)
                        repeatOldData: visible          // Default: visible - If no new data has been sent after 200ms, graph will plot a new point at the current

                        //                        inputData: yourUpdatingData  // Set the graph's data source here
                    }

                    SGGraphTimed {
                        id: graph6
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        opacity: 0.5
                        enabled: false
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
                        minXValue: -5                   // Default: 0
                        maxXValue: 0                    // Default: 5
                        showXGrids: false               // Default: false
                        showYGrids: true                // Default: false
                        xAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                        yAxisTickCount: 10              // Default: tickCount automatically calculated with built in applyNiceNumbers() if not specified here
                        throttlePlotting: true          // Default: true - Restricts plotting to every 100ms or more to save resources, false plots on every inputData change (NOT RECOMMENDED)
                        repeatOldData: visible          // Default: visible - If no new data has been sent after 200ms, graph will plot a new point at the current

                        //                        inputData: yourUpdatingData  // Set the graph's data source here
                    }
                }
            }
        }
    }
}
