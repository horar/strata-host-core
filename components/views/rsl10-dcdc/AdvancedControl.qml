import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.strata.sgwidgets 0.9
import tech.strata.sgwidgets 1.0 as Widget10
import "qrc:/js/navigation_control.js" as NavigationControl
import "sgwidgets/"
import "qrc:/js/help_layout_manager.js" as Help


Item {
    anchors.fill: parent
    property string vinlable: ""
    property bool hideEcoSwitch: false
    property string warningVin: multiplePlatform.warningHVVinLable

    // property that reads the initial notification
    property var temp_calc: platformInterface.status_temperature_sensor.temperature
    property var vin_calc: platformInterface.status_voltage_current.vin/1000
    property var iin_calc: platformInterface.status_voltage_current.iin
    property var vout_calc: platformInterface.status_voltage_current.vout/1000
    property var iout_calc: platformInterface.status_voltage_current.iout

    property var pin_calc: vin_calc * iin_calc * 1000
    property var pout_calc: vout_calc * iout_calc * 1000
    property var effi_calc: ((pout_calc * 100) / pin_calc).toFixed(3)




    property string read_enable_state: platformInterface.initial_status.enable_status
    onRead_enable_stateChanged: {
        if(read_enable_state === "on") {
            platformInterface.enabled = true
            platformInterface.pause_periodic = false
        }
        else  {
            platformInterface.enabled = false
            platformInterface.pause_periodic = true
        }
    }



    FontLoader {
        id: icons
        source: "sgwidgets/fonts/sgicons.ttf"
    }

    Component.onCompleted:  {
        //multiplePlatform.check_class_id()
        //platformInterface.read_initial_status.update()
        Help.registerTarget(navTabs, "These tabs switch between Basic, Advanced, Real-time trend analysis, Load Transient and Core Control views.", 0, "advanceHelp")
        Help.registerTarget(powerInputGauge, "This gauge shows the Input Power.", 1, "advanceHelp")
        Help.registerTarget(powerDissipatedGauge, "This gauge shows the power dissipated by the DC-DC. This is calculated with Pout - Pin.", 2, "advanceHelp")
        Help.registerTarget(tempGauge, "This gauge shows the temperature of the board.", 3, "advanceHelp")
        Help.registerTarget(powerOutputGauge, "This gauge shows the Output Power.", 4, "advanceHelp")
        Help.registerTarget(ledLight, "The LED will light up green when input voltage is ready and greater than" + " "+ multiplePlatform.minVin +"V.It will light up red when under"+ " "+ warningVin + "to warn the user that input voltage is not high enough.", 12, "advanceHelp")
        Help.registerTarget(inputCurrent, "Input current is shown here.", 14, "advanceHelp")
        Help.registerTarget(inputVoltage, "Input voltage is shown here.", 13, "advanceHelp")
        Help.registerTarget(outputCurrent, "Output current is shown here.", 16, "advanceHelp")
        Help.registerTarget(outputVoltage, "Output voltage is shown here.", 15, "advanceHelp")
        Help.registerTarget(vinGraph, "Input Voltage is plotted in real time", 6, "advanceHelp")
        Help.registerTarget(iinGraph, "Input Current is plotted in real time", 7, "advanceHelp")
        Help.registerTarget(voutGraph, "Output Voltage is plotted in real time", 10, "advanceHelp")
        Help.registerTarget(ioutGraph, "Output Current is plotted in real time", 11, "advanceHelp")
        Help.registerTarget(pdissGraph, "Power Dissipated is plotted in real time", 8, "advanceHelp")
        Help.registerTarget(poutGraph, "Output Power is plotted in real time", 9, "advanceHelp")
        Help.registerTarget(efficiencyGraph, "Efficiency (η) is plotted in real time", 5, "advanceHelp")
        Help.registerTarget(capacityBar1, "A linear capacity graphing in real time", 17, "advanceHelp")
    }

    Rectangle{
        anchors.fill: parent
        width : parent.width
        height: parent.height

        Rectangle {
            id: pageLable
            width: parent.width/2
            height: parent.height/ 12
            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: pageText
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }

                text:  "<b>"+ multiplePlatform.opn +"<b>"

                font.pixelSize: (parent.width + parent.height)/ 15
                color: "green"
            }
            Text {
                id: pageText2
                anchors {
                    top: pageText.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                text: multiplePlatform.title
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "blue"

            }
        }

        Rectangle {
            id: controlSection1
            width: parent.width
            height: parent.height - 100
            anchors{
                top: pageLable.bottom
                topMargin: 70
            }
            Rectangle {
                id: topControl
                anchors {
                    left: controlSection1.left
                    top: controlSection1.top
                }
                width: parent.width
                height: controlSection1.height/3

                SGCircularGauge {
                    id: powerInputGauge
                    anchors {
                        top: parent.top
                        left: parent.left
                        leftMargin: 20
                    }

                    width: parent.width/7.5
                    height: parent.height
                    gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    minimumValue: 0
                    maximumValue: multiplePlatform.poutScale
                    tickmarkStepSize: multiplePlatform.poutStep
                    outerColor: "#999"
                    unitLabel: if(multiplePlatform.pdiss === "mW") {"mW"}
                               else{"W"}
                    gaugeTitle: "Input Power"
                    value: if(multiplePlatform.pdiss === "mW") {pin_calc/1000}
                           else{(pin_calc/1000000).toFixed(3)}
                    Behavior on value { NumberAnimation { duration: 300 } }
                }

                SGCircularGauge {
                    id: powerDissipatedGauge
                    anchors {
                        left: powerInputGauge.right
                        leftMargin: 20
                        top: parent.top
                    }

                    width: parent.width/7.5
                    height: parent.height
                    gaugeFrontColor1: Qt.rgba(0,1,.25,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    minimumValue: 0
                    maximumValue: multiplePlatform.pdissScale
                    tickmarkStepSize: multiplePlatform.pdissStep
                    outerColor: "#999"
                    gaugeTitle: "Power Dissipated"
                    unitLabel: if(multiplePlatform.pdiss === "mW") {"mW"}
                               else{"W"}
                    value: if(pin_calc > pout_calc)
                           {if(multiplePlatform.pdiss === "W") {((pin_calc - pout_calc)/1000000).toFixed(0)}
                               else{((pin_calc - pout_calc)/1000).toFixed(0)}}
                           else{0}


                    Behavior on value { NumberAnimation { duration: 300 } }
                }

                SGCircularGauge {
                    id: tempGauge
                    anchors {
                        left: powerDissipatedGauge.right
                        leftMargin: 20
                        top: parent.top
                    }

                    width: parent.width/7.5
                    height: parent.height
                    gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    minimumValue: -55
                    maximumValue: 125
                    tickmarkStepSize: 20
                    outerColor: "#999"
                    unitLabel: "°C"
                    gaugeTitle: "Board" + "\n" +"Temperature"
                    value: temp_calc
                    Behavior on value { NumberAnimation { duration: 300 } }
                }

                SGCircularGauge {
                    id: powerOutputGauge
                    anchors {
                        left: tempGauge.right
                        leftMargin: 20
                        top: parent.top
                    }

                    width: parent.width/7.5
                    height: parent.height
                    gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    minimumValue: 0
                    maximumValue: multiplePlatform.poutScale
                    tickmarkStepSize: multiplePlatform.poutStep
                    outerColor: "#999"
                    unitLabel: if(multiplePlatform.pdiss === "mW") {"mW"}
                               else{"W"}
                    gaugeTitle: "Output Power"
                    value: if(multiplePlatform.pdiss === "W") {(pout_calc/1000000).toFixed(0)}
                           else{(pout_calc/1000).toFixed(0)}
                    Behavior on value { NumberAnimation { duration: 300 } }
                }

                GraphConverter{
                    id: efficiencyGraph
                    width: parent.width/2.5
                    height: parent.height
                    anchors {
                        left: powerOutputGauge.right
                        leftMargin: 20
                        top: parent.top
                        topMargin: 5
                        right:parent.right
                        rightMargin: 5
                    }
                    autoAdjustMaxMin: false
                    //repeatOldData: visible
                    dataLineColor: "purple"
                    textColor: "black"
                    axesColor: "black"
                    gridLineColor: "lightgrey"
                    underDataColor: "transparent"
                    backgroundColor: "white"
                    xAxisTickCount: 11
                    yAxisTickCount: 11
                    throttlePlotting: true
                    pointCount: if (platformInterface.systemMode === false) {1} else {50}
                    title: "<b>Efficiency</b>"
                    yAxisTitle: "<b>η [%]</b>"
                    xAxisTitle: "<b>10 µs / div<b>"
                    inputData: effi_calc
                    maxYValue: 100
                    minYValue: 0
                    showYGrids: true
                    showXGrids: true
                    minXValue: 0
                    maxXValue:5
                    reverseDirection: true


                }
            } // end of left control

            Rectangle {
                width: parent.width
                height: parent.height/1.7
                color: "transparent"

                anchors {
                    top : topControl.bottom
                    topMargin: 0
                }

                Rectangle {
                    id: dataContainer
                    color: "transparent"
                    border.color: "transparent"
                    border.width: 5
                    radius: 10
                    width: parent.width
                    height: parent.height

                    anchors {
                        top: parent.top
                        topMargin : 0
                        left: parent.left
                        leftMargin : 50
                    }

                    GraphConverter{
                        id: vinGraph
                        width: parent.width/6
                        height: parent.height/1.5
                        anchors {
                            left: parent.left
                            leftMargin: -50
                            top: parent.top
                            topMargin: 20
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
                        xAxisTitle: "<b>100 µs / div<b>"
                        yAxisTitle: "Input Voltage (V)"
                        inputData: vin_calc
                        maxYValue: multiplePlatform.vinScale
                        showYGrids: true
                        showXGrids: true
                        minXValue: 0
                        maxXValue: 5
                        reverseDirection: true
                    }

                    SGStatusLight {
                        id: ledLight
                        // Optional Configuration:
                        label: "VIN Ready < "+ multiplePlatform.minVin +"V"
                        anchors {
                            top : vinGraph.bottom
                            topMargin : 5
                            horizontalCenter: vinGraph.horizontalCenter
                            horizontalCenterOffset:  0
                        }

                        lightSize: (vinGraph.width + vinGraph.height)/20
                        fontSize:  (vinGraph.width + vinGraph.height)/40


                        property string vinMonitor: {platformInterface.status_voltage_current.vin}
                        onVinMonitorChanged:  {
                            if(multiplePlatform.minVin > vin_calc) {
                                ledLight.status = "red"
                                vinlable = "under"
                                ledLight.label = "VIN NOT Ready < "+ multiplePlatform.minVin +"V"
                            }
                            else if(multiplePlatform.nominalVin < vin_calc) {
                                ledLight.status = "red"
                                vinlable = "under"
                                ledLight.label = "VIN NOT Ready > "+ multiplePlatform.nominalVin +"V"
                            }
                            else {
                                ledLight.status = "green"
                                vinlable = "over"
                                ledLight.label = "VIN Ready"
                            }
                        }
                    }


                    SGLabelledInfoBox {
                        id: inputVoltage
                        label: "Vin"
                        info: {
                            if(multiplePlatform.showDecimal === true) {vin_calc.toFixed(3)}
                            else {vin_calc.toFixed(0)}
                        }

                        infoBoxColor: if (multiplePlatform.nominalVin < vin_calc) {"red"}
                                      else{"lightblue"}
                        infoBoxBorderColor: "grey"
                        infoBoxBorderWidth: 3

                        unit: "V"
                        infoBoxWidth: vinGraph.width/2
                        infoBoxHeight : vinGraph.height/10
                        fontSize :  (vinGraph.width + vinGraph.height)/37
                        unitSize: (vinGraph.width + vinGraph.height)/35
                        anchors {
                            top : ledLight.bottom
                            topMargin : 17
                            horizontalCenter: vinGraph.horizontalCenter
                            horizontalCenterOffset:  10
                        }
                    }

                    GraphConverter{
                        id: iinGraph
                        width: parent.width/6
                        height: parent.height/1.5
                        anchors {
                            left: vinGraph.right
                            leftMargin: 0
                            top: parent.top
                            topMargin: 20
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
                        xAxisTitle: "<b>100 µs / div<b>"
                        yAxisTitle: if(multiplePlatform.current === "mA") {"Input Current (mA)"}
                                    else{"Input Current (A)"}
                        inputData: {
                            if(multiplePlatform.current === "A") {(iin_calc/1000).toFixed(3)}
                            else {iin_calc.toFixed(0)}
                        }
                        maxYValue: if(multiplePlatform.current === "mA") {multiplePlatform.iinScale * 1000}
                                   else{multiplePlatform.iinScale}
                        showYGrids: true
                        showXGrids: true
                        minXValue: 0
                        maxXValue: 5
                        reverseDirection: true
                    }


                    SGLabelledInfoBox {
                        id: inputCurrent
                        label: "Iin"
                        info: {
                            if(multiplePlatform.current === "A") {(iin_calc/1000).toFixed(3)}
                            else {iin_calc.toFixed(0)}
                        }

                        infoBoxColor: "lightgreen"
                        infoBoxBorderColor: "grey"
                        infoBoxBorderWidth: 3

                        unit: if(multiplePlatform.current === "mA") {"mA"}
                              else{"A"}
                        infoBoxWidth: iinGraph.width/2
                        infoBoxHeight : iinGraph.height/10
                        fontSize :  (iinGraph.width + iinGraph.height)/37
                        unitSize: (iinGraph.width + iinGraph.height)/35
                        anchors {
                            top : iinGraph.bottom
                            topMargin : 45
                            horizontalCenter: iinGraph.horizontalCenter
                            horizontalCenterOffset:  10
                        }
                    }

                    SGCapacityBar {
                        id: capacityBar1
                        label: "Load Capacity:"
                        maximumValue: multiplePlatform.poutScale
                        labelLeft: false
                        showThreshold: true
                        barWidth: parent.width/4
                        thresholdExceeded: true
                        anchors {
                            top : iinGraph.bottom
                            topMargin : 20
                            horizontalCenter: parent.horizontalCenter
                        }
                        gaugeElements: Row {
                            id: container1
                            property real totalValue: childrenRect.width // Necessary for over threshold detection signal shown below
                            SGCapacityBarElement{
                                color: "#7bdeff"
                                value: if(multiplePlatform.pdiss === "mW") {pout_calc/1000}
                                       else{(pout_calc/1000).toFixed(3)}
                            }

                            SGCapacityBarElement{
                                color: "orange"
                                value: if(pin_calc > pout_calc)
                                       {if(multiplePlatform.pdiss === "W") {((pin_calc - pout_calc)/1000000).toFixed(0)}
                                           else{((pin_calc - pout_calc)/1000).toFixed(0)}}
                                       else{0}
                            }
                        }
                    }

                    GraphConverter{
                        id: pdissGraph
                        width: parent.width/6
                        height: parent.height/1.5
                        anchors {
                            left: iinGraph.right
                            leftMargin: 0
                            top: parent.top
                            topMargin: 20
                        }
                        showOptions: false
                        autoAdjustMaxMin: false
                        //repeatOldData: visible
                        dataLineColor: "orange"
                        textColor: "black"
                        axesColor: "black"
                        gridLineColor: "lightgrey"
                        underDataColor: "transparent"
                        backgroundColor: "white"
                        xAxisTickCount: 6
                        yAxisTickCount: 11
                        throttlePlotting: true
                        pointCount: 30
                        xAxisTitle: "<b>100 µs / div<b>"
                        yAxisTitle: if(multiplePlatform.pdiss === "mW") {"Power Dissipated (mW)"}
                                    else{"Power Dissipated (W)"}
                        inputData: if(pin_calc > pout_calc)
                                   {if(multiplePlatform.pdiss === "W") {((pin_calc - pout_calc)/1000000).toFixed(0)}
                                       else{((pin_calc - pout_calc)/1000).toFixed(0)}}
                                   else{0}
                        maxYValue: multiplePlatform.pdissScale
                        showYGrids: true
                        showXGrids: true
                        minXValue: 0
                        maxXValue: 5
                        reverseDirection: true
                    }

                    GraphConverter{
                        id: poutGraph
                        width: parent.width/6
                        height: parent.height/1.5
                        anchors {
                            left: pdissGraph.right
                            leftMargin: 0
                            top: parent.top
                            topMargin: 20
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
                        xAxisTitle: "<b>100 µs / div<b>"
                        yAxisTitle: if(multiplePlatform.pdiss === "mW") {"Output Power (mW)"}
                                    else{"Output Power (W)"}
                        inputData: if(multiplePlatform.pdiss === "W") {(pout_calc/1000000).toFixed(0)}
                                   else{(pout_calc/1000).toFixed(0)}
                        maxYValue: multiplePlatform.poutScale
                        showYGrids: true
                        showXGrids: true
                        minXValue: 0
                        maxXValue: 5
                        reverseDirection: true
                    }

                    GraphConverter{
                        id: voutGraph
                        width: parent.width/6
                        height: parent.height/1.5
                        anchors {
                            left: poutGraph.right
                            leftMargin: 0
                            top: parent.top
                            topMargin: 20
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
                        xAxisTitle: "<b>100 µs / div<b>"
                        yAxisTitle: "Output Voltage (V)"
                        inputData: {vout_calc}
                        maxYValue: multiplePlatform.voutScale
                        showYGrids: true
                        showXGrids: true
                        minXValue: 0
                        maxXValue: 5
                        reverseDirection: true
                    }

                    SGLabelledInfoBox {
                        id: outputVoltage
                        label: "Vout"
                        info: {
                            if(multiplePlatform.showDecimal === true) {vout_calc.toFixed(3)}
                            else {vout_calc.toFixed(0)}
                        }

                        infoBoxColor: "lightblue"
                        infoBoxBorderColor: "grey"
                        infoBoxBorderWidth: 3

                        unit: "V"
                        infoBoxWidth: voutGraph.width/2
                        infoBoxHeight : voutGraph.height/10
                        fontSize :  (voutGraph.width + voutGraph.height)/37
                        unitSize: (voutGraph.width + voutGraph.height)/35
                        anchors {
                            top : voutGraph.bottom
                            topMargin : 50
                            horizontalCenter: voutGraph.horizontalCenter
                            horizontalCenterOffset:  10
                        }
                    }

                    GraphConverter{
                        id: ioutGraph
                        width: parent.width/6
                        height: parent.height/1.5
                        anchors {
                            left: voutGraph.right
                            leftMargin: 0
                            top: parent.top
                            topMargin: 20
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
                        xAxisTitle: "<b>100 µs / div<b>"
                        yAxisTitle: if(multiplePlatform.current === "mA") {"Output Current (mA)"}
                                    else{"Output Current (A)"}
                        inputData: if(multiplePlatform.current === "mA") {iout_calc}
                                   else{(iout_calc/1000).toFixed(3)}
                        maxYValue: if(multiplePlatform.current === "mA") {multiplePlatform.ioutScale * 1000}
                                   else{multiplePlatform.ioutScale}
                        showYGrids: true
                        showXGrids: true
                        minXValue: 0
                        maxXValue: 5
                        reverseDirection: true

                    }


                    SGLabelledInfoBox {
                        id: outputCurrent
                        label: "Iout"
                        info: {
                            if(multiplePlatform.current === "A") {(iout_calc/1000).toFixed(3)}
                            else {iout_calc.toFixed(0)}
                        }

                        infoBoxColor: "lightgreen"
                        infoBoxBorderColor: "grey"
                        infoBoxBorderWidth: 3

                        unit: if(multiplePlatform.current === "mA") {"mA"}
                              else{"A"}
                        infoBoxWidth: ioutGraph.width/2
                        infoBoxHeight : ioutGraph.height/10
                        fontSize :  (ioutGraph.width + ioutGraph.height)/37
                        unitSize: (ioutGraph.width + ioutGraph.height)/35
                        anchors {
                            top : ioutGraph.bottom
                            topMargin : 50
                            horizontalCenter: ioutGraph.horizontalCenter
                            horizontalCenterOffset:  10
                        }
                    }
                }
            }
        }
    }
}
