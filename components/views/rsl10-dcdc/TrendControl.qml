import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help
import "sgwidgets/"

Item{
    id:mainmenu
    width: parent.width
    height: parent.height

    // property that reads the initial notification
    property var vin_calc: platformInterface.status_voltage_current.vin/1000
    property var iin_calc: platformInterface.status_voltage_current.iin
    property var vout_calc: platformInterface.status_voltage_current.vout/1000
    property var iout_calc: platformInterface.status_voltage_current.iout

    property var pin_calc: vin_calc * iin_calc * 1000
    property var pout_calc: vout_calc * iout_calc * 1000
    property var effi_calc: ((pout_calc * 100) / pin_calc).toFixed(3)

    Rectangle{
        id:title
        width: parent.width/3
        height: parent.height/20
        anchors{
            top: parent.top
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
        color:"transparent"
        Text {
            text: "<b>Real-Time Trend Analysis<b>"
            font.pixelSize: (parent.width + parent.height)/ 15
            anchors.fill:parent
            color: "green"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    RowLayout{
        id:rowright
        width: parent.width
        height:parent.height/2.5
        anchors{
            top: title.bottom
        }

        Rectangle{
            Layout.preferredHeight: parent.height - 20
            Layout.fillWidth: true
            color: "transparent"
            Layout.rightMargin: 5

            Rectangle{
                anchors.fill:parent
                anchors.centerIn: parent

                GraphConverter {
                    id: graph0
                    anchors {
                        fill: parent
                    }
                    showOptions: false
                    autoAdjustMaxMin: false
                    //repeatOldData: visible
                    dataLineColor: "purple"
                    textColor: "black"
                    axesColor: "black"
                    gridLineColor: "lightgrey"
                    underDataColor: "transparent"
                    backgroundColor: "white"
                    xAxisTickCount: 51
                    yAxisTickCount: 11
                    throttlePlotting: true
                    pointCount: if (platformInterface.systemMode === false) {1} else {50}
                    title: "<b>Efficiency</b>"
                    yAxisTitle: "<b>η [%]</b>"
                    xAxisTitle: "<b>10 µs / div<b>"
                    inputData: effi_calc
                    minYValue: 0
                    maxYValue: 100
                    minXValue: 0
                    maxXValue: 5
                    reverseDirection: true
                    showYGrids: true
                    showXGrids: true
                }
            }
        }
    }

    Rectangle{
        id:root
        width: parent.width
        height: parent.height/2.2
        anchors.top: rowright.bottom
        color: "transparent"

        Widget09.SGSegmentedButtonStrip {
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
            activeColor: "green"
            radius: 20
            buttonHeight: 40
            exclusive: false
            buttonImplicitWidth: 150
            property int howManyChecked: 0

            segmentedButtons: GridLayout {
                columnSpacing: 2
                rowSpacing: 2

                Widget09.SGSegmentedButton{
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

                Widget09.SGSegmentedButton{
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

                Widget09.SGSegmentedButton{
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

                Widget09.SGSegmentedButton{
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

                Widget09.SGSegmentedButton{
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

                Widget09.SGSegmentedButton{
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
            height:parent.height/1.1

            GraphConverter {
                id: graph1
                title: "<b>Input Voltage</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                showOptions: false
                autoAdjustMaxMin: false
                //repeatOldData: visible
                dataLineColor: "blue"
                textColor: "black"
                axesColor: "black"
                gridLineColor: "lightgrey"
                underDataColor: "transparent"
                backgroundColor: "white"
                xAxisTickCount: 6
                yAxisTickCount: 11
                throttlePlotting: true
                pointCount: 30
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "Input Voltage (V)"
                xAxisTitle: "<b>100 µs / div</b>"
                inputData: vin_calc
                minYValue: 0
                maxYValue: multiplePlatform.vinScale
                minXValue: 0
                maxXValue: 5
                reverseDirection: true
                showYGrids: true
                showXGrids: true
            }

            GraphConverter {
                id: graph2
                title: "<b>Output Voltage</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                showOptions: false
                autoAdjustMaxMin: false
                //repeatOldData: visible
                dataLineColor: "blue"
                textColor: "black"
                axesColor: "black"
                gridLineColor: "lightgrey"
                underDataColor: "transparent"
                backgroundColor: "white"
                xAxisTickCount: 6
                yAxisTickCount: 11
                throttlePlotting: true
                pointCount: 30
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "Output Voltage (V)"
                xAxisTitle: "<b>100 µs / div</b>"
                inputData: vout_calc
                minYValue: 0
                maxYValue: multiplePlatform.voutScale
                minXValue: 0
                maxXValue: 5
                reverseDirection: true
                showYGrids: true
                showXGrids: true
            }

            GraphConverter {
                id: graph3
                title: "<b>Input Current</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                showOptions: false
                autoAdjustMaxMin: false
                //repeatOldData: visible
                dataLineColor: "green"
                textColor: "black"
                axesColor: "black"
                gridLineColor: "lightgrey"
                underDataColor: "transparent"
                backgroundColor: "white"
                xAxisTickCount: 6
                yAxisTickCount: 11
                throttlePlotting: true
                pointCount: 30
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: if(multiplePlatform.current === "mA") {"Input Current (mA)"}
                            else{"Input Current (A)"}
                xAxisTitle: "<b>100 µs / div</b>"
                inputData: if(multiplePlatform.current === "mA") {iin_calc}
                           else{(iin_calc/1000).toFixed(3)}
                minYValue: 0
                maxYValue: if(multiplePlatform.current === "mA") {multiplePlatform.iinScale * 1000}
                           else{multiplePlatform.iinScale}
                minXValue: 0
                maxXValue: 5
                reverseDirection: true
                showYGrids: true
                showXGrids: true
            }

            GraphConverter {
                id: graph4
                title: "<b>Output Current</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                showOptions: false
                autoAdjustMaxMin: false
                //repeatOldData: visible
                dataLineColor: "green"
                textColor: "black"
                axesColor: "black"
                gridLineColor: "lightgrey"
                underDataColor: "transparent"
                backgroundColor: "white"
                xAxisTickCount: 6
                yAxisTickCount: 11
                throttlePlotting: true
                pointCount: 30
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: if(multiplePlatform.current === "mA") {"Output Current (mA)"}
                            else{"Output Current (A)"}
                xAxisTitle: "<b>100 µs / div</b>"
                inputData: if(multiplePlatform.current === "mA") {iout_calc}
                           else{(iout_calc/1000).toFixed(3)}
                minYValue: 0
                maxYValue: if(multiplePlatform.current === "mA") {multiplePlatform.ioutScale * 1000}
                           else{multiplePlatform.ioutScale}
                minXValue: 0
                maxXValue: 5
                reverseDirection: true
                showYGrids: true
                showXGrids: true
            }

            GraphConverter {
                id: graph5
                title: "<b>Input Power</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                showOptions: false
                autoAdjustMaxMin: false
                //repeatOldData: visible
                dataLineColor: "#7bdeff"
                textColor: "black"
                axesColor: "black"
                gridLineColor: "lightgrey"
                underDataColor: "transparent"
                backgroundColor: "white"
                xAxisTickCount: 6
                yAxisTickCount: 11
                throttlePlotting: true
                pointCount: 30
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: if(multiplePlatform.pdiss === "mW") {"Input Power (mW)"}
                            else{"Input Power (W)"}
                xAxisTitle: "<b>100 µs / div</b>"
                inputData: if(multiplePlatform.pdiss === "mW") {pin_calc/1000}
                           else{(pin_calc/1000000).toFixed(3)}
                minYValue: 0
                maxYValue: multiplePlatform.poutScale
                minXValue: 0
                maxXValue: 5
                reverseDirection: true
                showYGrids: true
                showXGrids: true
            }

            GraphConverter {
                id: graph6
                title: "<b>Output Power</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                showOptions: false
                autoAdjustMaxMin: false
                //repeatOldData: visible
                dataLineColor: "#7bdeff"
                textColor: "black"
                axesColor: "black"
                gridLineColor: "lightgrey"
                underDataColor: "transparent"
                backgroundColor: "white"
                xAxisTickCount: 6
                yAxisTickCount: 11
                throttlePlotting: true
                pointCount: 30
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: if(multiplePlatform.pdiss === "mW") {"Output Power (mW)"}
                            else{"Output Power (W)"}
                xAxisTitle: "<b>100 µs / div</b>"
                inputData: if(multiplePlatform.pdiss === "W") {(pout_calc/1000000).toFixed(0)}
                           else{(pout_calc/1000).toFixed(0)}
                minYValue: 0
                maxYValue: multiplePlatform.poutScale
                minXValue: 0
                maxXValue: 5
                reverseDirection: true
                showYGrids: true
                showXGrids: true
            }
        }
    }

    Component.onCompleted:  {
        Help.registerTarget(navTabs, "These tabs switch between Basic, Advanced, Real-time trend analysis, Load Transient and Core Control views.", 0, "trendHelp")
        Help.registerTarget(portGraphs, "The graph is displayed in below when tab menu is selected. The graph is hidden when tab menu is diselected.", 2, "trendHelp")
        Help.registerTarget(graph0, "Efficiency Graph is showing here.", 1, "trendHelp")
     }
}
