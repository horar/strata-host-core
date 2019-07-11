import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item{
    id:mainmenu
    width: parent.width
    height: parent.height

    property var read_vin : platformInterface.input_notification.vin //"100 Vrms"

    onRead_vinChanged: {
        labelledInfoBox1.info = read_vin + "Vrms"
        graph1.inputData = read_vin

    }

    property var read_iin :  platformInterface.input_notification.iin //" 2.0 Arms"

    onRead_iinChanged: {
        labelledInfoBox2.info = read_iin + "Arms"
        graph3.inputData = read_iin
    }

    property var read_pin : platformInterface.input_notification.pin //" 120 W"

    onRead_pinChanged: {
        labelledInfoBox4.info = read_pin + "W"
        graph5.inputData = read_pin
    }

    property var read_vout : platformInterface.output_notification.vout //" 12.02V"

    onRead_voutChanged: {
        labelledInfoBox3.info = read_vout + "V"
        graph2.inputData = read_vout
    }

    property var read_iout: platformInterface.output_notification.iout //" 8.50A"

    onRead_ioutChanged: {
        labelledInfoBox6.info = read_iout + "A"
        graph4.inputData = read_iout
    }

    property var read_pout: platformInterface.output_notification.pout // " 120W"

    onRead_poutChanged: {
        labelledInfoBox5.info = read_pout + "VA"
        graph6.inputData = read_pout
    }

//    property  var graph_input_voltage_value: platformInterface.graph_notification.input_voltage
//    onGraph_input_voltage_valueChanged: {
//        console.log(
//                    "graph_input_voltage_value",graph_input_voltage_value)
//        graph1.inputData = graph_input_voltage_value

//    }

    Rectangle{
        id:title
        width: parent.width/3
        height: parent.height/20
        anchors{
            top: parent.top
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        //        color: "yellow"
        color:"transparent"
        Text {
            text: "ACF PSU"
            font.pixelSize: 25
            anchors.fill:parent
            color: "black"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    RowLayout{
        id:rowright
        width: parent.width
        height:parent.height/2.2
        anchors{
            top: title.bottom


        }


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

                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox1
                                infoBoxWidth: 100
                                label: "INPUT VOLTAGE"
                                //info:
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox2
                                infoBoxWidth: 110
                                label: "INPUT CURRENT"
                                info: "2.00 Arms"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
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

                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox4
                                infoBoxWidth: 150
                                label: "INPUT (ACTIVE) POWER"
                                info: "120 W"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox5
                                infoBoxWidth: 120
                                label: "REACTIVE POWER"
                                info: "10 VAR"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
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

                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox7
                                infoBoxWidth: 120
                                label: "APPARENT POWER"
                                info: "120 VA"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox8
                                infoBoxWidth: 100
                                label: "POWER FACTOR"
                                info: "0.90"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
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

                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox10
                                infoBoxWidth: 110
                                label: "LINE FREQUENCY"
                                info: "50 Hz"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox11
                                infoBoxWidth: 100
                                label: "LOSS (Pin-Pout)"
                                info: "20 W"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
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
            Layout.preferredHeight: parent.height - 80
            Layout.fillWidth: true
            color: "red"//"transparent"
            Layout.rightMargin: 5

            Rectangle{
                anchors.fill:parent
                anchors.centerIn: parent

                SGGraphTimed {
                    id: graph0
                    anchors {
                        fill: parent             // Set custom anchors for responsive sizing
                    }
                    title: "<b>Efficiency</b>"                  // Default: empty
                    yAxisTitle: "<b>η [%]</b>"
                    xAxisTitle: "<b>1 sec/div<b>"
                    minYValue: 0                    // Default: 0
                    maxYValue: 25                   // Default: 10
                    minXValue: 0                    // Default: 0
                    maxXValue: 5                    // Default: 10

                }
            }
        }
    }

    Rectangle{
        id:root
        width: parent.width
        height: parent.height/2
        anchors.top: rowright.bottom
        color: "transparent"

        SGSegmentedButtonStrip {
            id: graphSelector
            label: "<b>Show Graphs:</b>"
            labelLeft: false
            anchors {
                top: parent.top
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            textColor: "#666"
            activeTextColor: "white"
            radius: 4
            buttonHeight: 25
            exclusive: false
            buttonImplicitWidth: 50
            property int howManyChecked: 0

            segmentedButtons: GridLayout {
                columnSpacing: 2
                rowSpacing: 2

                SGSegmentedButton{
                    text: qsTr("Vin")
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
                    text: qsTr("Vout")
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
                    text: qsTr("Iout")
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
                    text: qsTr("Pout")
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
        Row {
            id: portGraphs
            anchors {
                top: graphSelector.bottom
                topMargin: 15
                left: parent.left
                right: parent.right
            }
            height:250

            SGGraphTimed {
                id: graph1
                title: "<b>Input Voltage</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "<b>[V]</b>"
                xAxisTitle: "<b>1 sec/div</b>"

                minYValue: 0                    // Default: 0
                maxYValue: 270                   // Default: 10
                minXValue: 0                    // Default: 0
                maxXValue: 5                    // Default: 10
                inputData: 0.0
            }

            SGGraphTimed {
                id: graph2
                title: "<b>Output Voltage</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "<b>[V]</b>"
                xAxisTitle: "<b>1 sec/div</b>"
                minYValue: 0                    // Default: 0
                maxYValue: 15                   // Default: 10
                minXValue: 0                    // Default: 0
                maxXValue: 5                    // Default: 10

            }

            SGGraphTimed {
                id: graph3
                title: "<b>Input Current</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "<b>[A]</b>"
                xAxisTitle: "<b>1 sec/div</b>"

                minYValue: 0                    // Default: 0
                maxYValue: 5                   // Default: 10
                minXValue: 0                    // Default: 0
                maxXValue: 5                    // Default: 10

            }

            SGGraphTimed {
                id: graph4
                title: "<b>Output Current</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "<b>[A]</b>"
                xAxisTitle: "<b>1 sec/div</b>"

                minYValue: 0                    // Default: 0
                maxYValue: 15                   // Default: 10
                minXValue: 0                    // Default: 0
                maxXValue: 5                    // Default: 10

            }

            SGGraphTimed {
                id: graph5
                title: "<b>Input Power</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "<b>[W]</b>"
                xAxisTitle: "<b>1 sec/div</b>"
                minYValue: 0                    // Default: 0
                maxYValue: 125                   // Default: 10
                minXValue: 0                    // Default: 0
                maxXValue: 5                    // Default: 10

            }

            SGGraphTimed {
                id: graph6
                title: "<b>Output Power</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "<b>[W]</b>"
                xAxisTitle: "<b>1 sec/div</b>"
                minYValue: 0                    // Default: 0
                maxYValue: 125                   // Default: 10
                minXValue: 0                    // Default: 0
                maxXValue: 5                    // Default: 10

            }
        }
    }
}
