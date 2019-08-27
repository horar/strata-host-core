import QtQuick 2.9
import QtQuick.Controls 2.3
import "qrc:/views/efficiency-simulator/sgwidgets/"
import "component_source.js" as ComponentSource

Item {
    id: root

    signal update()  // Selected mosfets in comboboxes aren't set until very late in loading, so update is signaled when this happens, otherwise many of the properties below are undefined

    property alias highSideMosfet: highMosfet.selectedMosfet
    property int highMosfetIndex: 0
    property alias lowSideMosfet: lowMosfet.selectedMosfet
    property alias driver: driverParams.selectedDriver
    property bool ready: false

    property real inputvoltage: bcpInputVoltage.floatValue
    property real outputvoltage: bcpOutputVoltage.floatValue
    property real switchingfrequency: bcpSwitchingFrequency.floatValue * 1000
    property real dutycycle: bcpDutyCycle.floatValue
    property real currentripple: bcpCurrentRipple.floatValue
    property real voltageripple: bcpVoltageRipple.floatValue * 0.001
    property real maximumoutputcurrent: bcpMaxCurrent.floatValue

    property real drivervoltage: driverVDR.floatValue
    property real sourcingresistance: driverParams.selectedDriver.SourcingResistance
    property real sinkingresistance: driverParams.selectedDriver.SinkingResistance
    property real dRVH: driverParams.selectedDriver.RiseDelayTime * 1E-09
    property real dRVI: driverParams.selectedDriver.FallDelayTime * 1E-09
    property real quiescentcurrent: driverParams.selectedDriver.QuiescentCurrent * 0.001

    property real rDSon_HS: highMosfet.selectedMosfet.RDSon45 * 0.001
    property real qGTOT_HS: highMosfet.selectedMosfet.Qg45 * 1E-09
    property real coss_HS: highMosfet.selectedMosfet.Coss * 1E-12
    property real qGD_HS: highMosfet.selectedMosfet.Qgd * 1E-09
    property real qGS_HS: highMosfet.selectedMosfet.Qgs * 1E-09
    property real vth_HS: highMosfet.selectedMosfet.Vth
    property real gfs_HS: highMosfet.selectedMosfet.Transconductance
    property real rgin_HS: highMosfet.selectedMosfet.InternalRgin
    property real rJA_HS: highMosfet.selectedMosfet.ThermalResistance
    property real rDSontemperaturecoefficent_HS: highMosfet.selectedMosfet.RDSonTemperatureCoefficient * 0.01
    property real rgex_HS: highExternalGateResistance.floatValue
    property int numberofFET_HS: highNumberOfMosfet.currentValue

    property real eSR_Coutput: outputLCESRCoutput.floatValue * 0.001
    property real coutput: outputCapActual.floatValue * 1E-06
    property real windingresistance: outputLCWindingResistance.floatValue * 0.001
    property real inductance: outputLCInductActual.floatValue * 1E-06

    property real rDSon_LS: lowMosfet.selectedMosfet.RDSon45 * 0.001
    property real qGTOT_LS: lowMosfet.selectedMosfet.Qg45 * 1E-09
    property real coss_LS: lowMosfet.selectedMosfet.Coss * 1E-12
    property real qRR_LS: lowMosfet.selectedMosfet.measuredQrr * 1E-09
    property real qRRmeasurementcurrent_LS: lowMosfet.selectedMosfet.measuredQrr  /////POSSIBLY WRONG in their code, shifted all other values down
    property real vSD_LS: lowMosfet.selectedMosfet.SDDiodeForwardVoltage
    property real rJA_LS: lowMosfet.selectedMosfet.ThermalResistance
    property real rDSontemperaturecoefficent_LS: lowMosfet.selectedMosfet.RDSonTemperatureCoefficient * 0.01
    property real rgex_LS: lowExternalGateResistance.floatValue
    property int numberofFET_LS: lowNumberOfMosfet.currentValue

    property real qTOT_justified_HS: (highMosfet.selectedMosfet.Qg10 + (drivervoltage - 4.5) * (highMosfet.selectedMosfet.IDMax - highMosfet.selectedMosfet.Qg10) / 5.5) / 1000000000
    property real qTOT_justified_LS: (lowMosfet.selectedMosfet.Qg10 + (drivervoltage - 4.5) * (lowMosfet.selectedMosfet.IDMax - lowMosfet.selectedMosfet.Qg10) / 5.5) / 1000000000
    property real rDSon_justified_HS: (highMosfet.selectedMosfet.RDSon45 + (drivervoltage - 4.5) * (highMosfet.selectedMosfet.measuredQrr - highMosfet.selectedMosfet.RDSon45) / 7.5) / 1000 / numberofFET_HS
    property real rDSon_justified_LS: (lowMosfet.selectedMosfet.RDSon45 + (drivervoltage - 4.5) * (lowMosfet.selectedMosfet.measuredQrr - lowMosfet.selectedMosfet.RDSon45) / 7.5) / 1000 / numberofFET_LS

    SGTitleBar {
        id: topTitle
        title: mosfetSelectHigh.currentText + " x " + highNumberOfMosfet.currentText + " + " + mosfetSelectLow.currentText + " x " + lowNumberOfMosfet.currentText + " @ " + bcpSwitchingFrequency.value + "kHz; Vin=" + bcpInputVoltage.value + "V; Vout=" + bcpOutputVoltage.value + "V; Driver=" + driverSelect.currentText + "(" + driverVDR.value + "V)"
        horizontalAlignment: Text.AlignHCenter
        border { width: 1 }
        pixelSize: 20
        bold: true
        height: 40
    }

    ScrollView {
        id: scroll
        anchors {
            top: topTitle.bottom
            left: root.left
            right: root.right
            bottom: root.bottom
        }
        contentWidth: container.width
        contentHeight: container.height
        clip: true


        Rectangle {
            id: container
            width: 1200
            height: 20 + Math.max(leftColumn.height, middleColumn.height, rightColumn.height)

            Column {
                id: leftColumn
                anchors {
                    top: container.top
                    left: container.left
                }
                width: container.width/3
                spacing: 20

                Column {
                    id: buckCircuitParams
                    anchors {
                        left: leftColumn.left
                        leftMargin: 10
                        right: leftColumn.right
                        rightMargin: 10
                    }
                    height: childrenRect.height
                    spacing: 2

                    Rectangle {
                        id: leftTopMargin
                        height: 10
                        width: buckCircuitParams.width
                    }

                    SGTitleBar {
                        id: bcpTitle
                        title: "<b>Buck Circuit Parameters</b>"
                    }

                    SGSubmitInfoBox {
                        id: bcpInputVoltage
                        label: "Input Voltage"
                        value: "12"
                        overrideLabelWidth: 170
                        unit: "V"
                        onApplied: root.dataUpdate()
                    }

                    SGSubmitInfoBox {
                        id: bcpOutputVoltage
                        label: "Output Voltage"
                        value: "1.2"
                        overrideLabelWidth: bcpInputVoltage.overrideLabelWidth
                        unit: "V"
                        onApplied: root.dataUpdate()
                    }

                    SGSubmitInfoBox {
                        id: bcpSwitchingFrequency
                        label: "Switching Frequency"
                        value: "500"
                        overrideLabelWidth: bcpInputVoltage.overrideLabelWidth
                        unit: "kHz"
                        onApplied: root.dataUpdate()
                    }

                    SGSubmitInfoBox {
                        id: bcpDutyCycle
                        label: "Duty Cycle"
                        value: "" + (parseFloat(bcpOutputVoltage.value) / parseFloat(bcpInputVoltage.value)).toFixed(2)
                        overrideLabelWidth: bcpInputVoltage.overrideLabelWidth
                        readOnly: true
                        onApplied: root.dataUpdate()
                    }

                    SGSubmitInfoBox {
                        id: bcpPeriodTs
                        label: "Period Ts (s)"
                        value: "" + 1/parseFloat(bcpSwitchingFrequency.value)/1000 * 1000000
                        overrideLabelWidth: bcpInputVoltage.overrideLabelWidth
                        unit: "us"
                        readOnly: true
                    }

                    SGSubmitInfoBox {
                        id: bcpCurrentRipple
                        label: "Current Ripple Peak-to-Avg"
                        value: "" + parseFloat(bcpDutyCycle.value) * parseFloat(bcpPeriodTs.value) * 0.000001 * (parseFloat(bcpInputVoltage.value)-parseFloat(bcpOutputVoltage.value)) / parseFloat(outputLCInductActual.value) / 2 * 1000000
                        overrideLabelWidth: bcpInputVoltage.overrideLabelWidth
                        unit: "A"
                        readOnly: true
                    }

                    SGSubmitInfoBox {
                        id: bcpVoltageRipple
                        label: "Voltage Ripple"
                        value: "" + (0.5 * parseFloat(bcpCurrentRipple.value) * 0.5 * parseFloat(bcpPeriodTs.value) * 0.000001 / parseFloat(outputCapActual.value) * 1000000 * 1000 + parseFloat(bcpCurrentRipple.value) * parseFloat(outputLCESRCoutput.value)).toFixed(3)
                        overrideLabelWidth: bcpInputVoltage.overrideLabelWidth
                        unit: "mV"
                        readOnly: true
                    }

                    SGSubmitInfoBox {
                        id: bcpMaxCurrent
                        label: "Maximum Output Current"
                        value: "30"
                        overrideLabelWidth: bcpInputVoltage.overrideLabelWidth
                        unit: "A"
                        onApplied: root.dataUpdate()
                    }

                    SGSubmitInfoBox {
                        id: bcpCurrentRippleRatio
                        label: "Current Ripple Ratio"
                        value: "" + (parseFloat(bcpCurrentRipple.value)/parseFloat(bcpMaxCurrent.value)*100).toFixed(3)
                        overrideLabelWidth: bcpInputVoltage.overrideLabelWidth
                        unit: "%"
                        readOnly: true
                    }

                    SGSubmitInfoBox {
                        id: bcpVoltageRippleRatio
                        label: "Voltage Ripple Ratio"
                        value: "" + (parseFloat(bcpVoltageRipple.value)/1000/parseFloat(bcpOutputVoltage.value)*100).toFixed(3)
                        overrideLabelWidth: bcpInputVoltage.overrideLabelWidth
                        unit: "%"
                        readOnly: true
                    }
                }
            }

            Column {
                id: middleColumn
                anchors {
                    top: container.top
                    right: rightColumn.left
                    left: leftColumn.right
                }
                spacing: 20

                Column {
                    id: highMosfet
                    spacing: 2
                    anchors {
                        left: middleColumn.left
                        leftMargin: 10
                        right: middleColumn.right
                        rightMargin: 10
                    }

                    property var selectedMosfet: ({})

                    ListModel {
                        id: componentIds
                        Component.onCompleted: {
                            ComponentSource.loadComponentIdsIntoModel("MOSFET", componentIds)
                            mosfetSelectHigh.currentIndex=highMosfetIndex
                            mosfetSelectLow.currentIndex=0
                            root.ready = true
                            root.dataUpdate()
                        }
                    }

                    Rectangle {
                        id: middleTopMargin
                        height: 10
                        width: highMosfet.width
                    }

                    Rectangle {
                        id: highMosfetTitle
                        width: highMosfet.width
                        height: 30
                        color: "#ddd"
                        border {
                            color: "#bbb"
                            width: 0
                        }

                        SGComboBox {
                            id: mosfetSelectHigh
                            anchors {
                                verticalCenter: highMosfetTitle.verticalCenter
                                verticalCenterOffset: 1
                            }
                            model: componentIds
                            textRole: "component_id"
                            overrideLabelWidth: 210
                            label: "<b>High-Side MOSFET</b>"
                            onCurrentTextChanged: {
                                highMosfet.selectedMosfet = ComponentSource.getComponent(currentText)
                                root.dataUpdate()
                            }
                            comboBoxWidth: 150
                            comboBoxHeight: 25
                        }
                    }

                    Rectangle {
                        id: highDetailsTitle
                        width: parent.width
                        height: 20
                        color: "#ddd"

                        Text {
                            id: highDetailsText
                            text: highDetails.open ? "Hide Details" : "Show Details"
                            elide: Text.ElideRight
                            color: highDetails.open ? "#000" : "#666"
                            anchors {
                                verticalCenter: highDetailsTitle.verticalCenter
                                horizontalCenter: highDetailsTitle.horizontalCenter
                            }
                        }

                        MouseArea {
                            anchors { fill: highDetailsTitle }
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                highDetails.openClose()
                            }
                        }
                    }

                    SGSubmitInfoBox {
                        id: highExternalGateResistance
                        label: "Rgex"
                        value: "0"
                        overrideLabelWidth: mosfetSelectHigh.overrideLabelWidth
                        unit: "Ω"
                        onApplied: root.dataUpdate()
                    }

                    SGComboBox {
                        id: highNumberOfMosfet
                        label: "Number of HS MOSFET"
                        model: [1, 2]
                        overrideLabelWidth: mosfetSelectHigh.overrideLabelWidth
                        comboBoxHeight: 25
                        comboBoxWidth: 60

                        property int currentValue: parseInt(currentText)

                        onCurrentTextChanged: {
                            currentValue = parseInt(currentText)
                            root.dataUpdate()
                        }
                    }

                    SGMinimizeContainer {
                        id: highDetails
                        contents: Column {
                            spacing: 2

                            SGColumnDivider { }

                            SGSubmitInfoBox {
                                id: highRDSon45
                                label: "RDS(on)"
                                value: highMosfet.selectedMosfet.RDSon45
                                overrideLabelWidth: mosfetSelectHigh.overrideLabelWidth
                                readOnly: true
                                unit: "mΩ"
                            }

                            SGSubmitInfoBox {
                                id: highQg45
                                label: "QG(TOT)"
                                value: highMosfet.selectedMosfet.Qg45
                                overrideLabelWidth: mosfetSelectHigh.overrideLabelWidth
                                readOnly: true
                                unit: "nC"
                            }

                            SGSubmitInfoBox {
                                id: highCoss
                                label: "Coss"
                                value: highMosfet.selectedMosfet.Coss
                                overrideLabelWidth: mosfetSelectHigh.overrideLabelWidth
                                readOnly: true
                                unit: "pf"
                            }

                            SGSubmitInfoBox {
                                id: highQGD
                                label: "QGD"
                                value: highMosfet.selectedMosfet.Qgd
                                overrideLabelWidth: mosfetSelectHigh.overrideLabelWidth
                                readOnly: true
                                unit: "nC"
                            }

                            SGSubmitInfoBox {
                                id: highQGS
                                label: "QGS"
                                value: highMosfet.selectedMosfet.Qgs
                                overrideLabelWidth: mosfetSelectHigh.overrideLabelWidth
                                readOnly: true
                                unit: "nC"
                            }

                            SGSubmitInfoBox {
                                id: highVth
                                label: "VGS(TH)"
                                value: highMosfet.selectedMosfet.Vth
                                overrideLabelWidth: mosfetSelectHigh.overrideLabelWidth
                                readOnly: true
                                unit: "V"
                            }

                            SGSubmitInfoBox {
                                id: highTransconductance
                                label: "gFS"
                                value: highMosfet.selectedMosfet.Transconductance
                                overrideLabelWidth: mosfetSelectHigh.overrideLabelWidth
                                readOnly: true
                                unit: "S"
                            }

                            SGSubmitInfoBox {
                                id: highInternalRgin
                                label: "RG"
                                value: highMosfet.selectedMosfet.InternalRgin
                                overrideLabelWidth: mosfetSelectHigh.overrideLabelWidth
                                readOnly: true
                                unit: "Ω"
                            }

                            SGSubmitInfoBox {
                                id: highThermalResistance
                                label: "RѲJA"
                                value: highMosfet.selectedMosfet.ThermalResistance
                                overrideLabelWidth: mosfetSelectHigh.overrideLabelWidth
                                readOnly: true
                                unit: "°C/W"
                            }

                            SGSubmitInfoBox {
                                id: highRDSonTemperatureCoefficient
                                label: "RDS(on) Temperature Coefficient"
                                value: highMosfet.selectedMosfet.RDSonTemperatureCoefficient
                                overrideLabelWidth: mosfetSelectHigh.overrideLabelWidth
                                readOnly: true
                                unit: "%/°C"
                            }
                        }
                    }
                }

                Column {
                    id: lowMosfet
                    spacing: 2
                    anchors {
                        left: middleColumn.left
                        leftMargin: 10
                        right: middleColumn.right
                        rightMargin: 10
                    }

                    property var selectedMosfet: ({})

                    Rectangle {
                        id: lowMosfetTitle
                        width: lowMosfet.width
                        height: 30
                        color: "#ddd"
                        border {
                            color: "#bbb"
                            width: 0
                        }

                        SGComboBox {
                            id: mosfetSelectLow
                            anchors {
                                verticalCenter: lowMosfetTitle.verticalCenter
                                verticalCenterOffset: 1
                            }
                            model: componentIds
                            textRole: "component_id"
                            overrideLabelWidth: 210
                            label: "<b>Low-Side MOSFET</b>"
                            onCurrentTextChanged: {
                                lowMosfet.selectedMosfet = ComponentSource.getComponent(currentText)
                                root.dataUpdate()
                            }
                            comboBoxWidth: 150
                            comboBoxHeight: 25
                        }
                    }

                    Rectangle {
                        id: lowDetailsTitle
                        width: parent.width
                        height: 20
                        color: "#ddd"

                        Text {
                            id: lowDetailsText
                            text: lowDetails.open ? "Hide Details" : "Show Details"
                            elide: Text.ElideRight
                            color: lowDetails.open ? "#000" : "#666"
                            anchors {
                                verticalCenter: lowDetailsTitle.verticalCenter
                                horizontalCenter: lowDetailsTitle.horizontalCenter
                            }
                        }

                        MouseArea {
                            anchors { fill: lowDetailsTitle }
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                lowDetails.openClose()
                            }
                        }
                    }

                    SGSubmitInfoBox {
                        id: lowExternalGateResistance
                        label: "Rgex"
                        value: "0"
                        overrideLabelWidth: mosfetSelectLow.overrideLabelWidth
                        unit: "Ω"
                        onApplied: root.dataUpdate()
                    }

                    SGComboBox {
                        id: lowNumberOfMosfet
                        label: "Number of HS MOSFET"
                        model: [1, 2]
                        overrideLabelWidth: mosfetSelectLow.overrideLabelWidth
                        comboBoxHeight: 25
                        comboBoxWidth: 60

                        property int currentValue: parseInt(currentText)

                        onCurrentTextChanged: {
                            currentValue = parseInt(currentText)
                            root.dataUpdate()
                        }
                    }

                    SGMinimizeContainer {
                        id: lowDetails
                        contents: Column {
                            spacing: 2

                            SGColumnDivider { }

                            SGSubmitInfoBox {
                                id: lowRDSon45
                                label: "RDS(on)"
                                value: lowMosfet.selectedMosfet.RDSon45
                                overrideLabelWidth: mosfetSelectLow.overrideLabelWidth
                                readOnly: true
                                unit: "mΩ"
                            }

                            SGSubmitInfoBox {
                                id: lowQg45
                                label: "QG(TOT)"
                                value: lowMosfet.selectedMosfet.Qg45
                                overrideLabelWidth: mosfetSelectLow.overrideLabelWidth
                                readOnly: true
                                unit: "nC"
                            }

                            SGSubmitInfoBox {
                                id: lowCoss
                                label: "Coss"
                                value: lowMosfet.selectedMosfet.Coss
                                overrideLabelWidth: mosfetSelectLow.overrideLabelWidth
                                readOnly: true
                                unit: "pf"
                            }

                            SGSubmitInfoBox {
                                id: lowmeasuredQrr
                                label: "QRR"
                                value: lowMosfet.selectedMosfet.measuredQrr
                                overrideLabelWidth: mosfetSelectLow.overrideLabelWidth
                                readOnly: true
                                unit: "nC"
                            }

                            SGSubmitInfoBox {
                                id: lowSDDiodeForwardVoltage
                                label: "VSD"
                                value: lowMosfet.selectedMosfet.SDDiodeForwardVoltage
                                overrideLabelWidth: mosfetSelectLow.overrideLabelWidth
                                readOnly: true
                                unit: "V"
                            }

                            SGSubmitInfoBox {
                                id: lowThermalResistance
                                label: "RѲJA"
                                value: lowMosfet.selectedMosfet.ThermalResistance
                                overrideLabelWidth: mosfetSelectLow.overrideLabelWidth
                                readOnly: true
                                unit: "°C/W"
                            }

                            SGSubmitInfoBox {
                                id: lowRDSonTemperatureCoefficient
                                label: "RDSon Temperature Coefficient"
                                value: lowMosfet.selectedMosfet.RDSonTemperatureCoefficient
                                overrideLabelWidth: mosfetSelectLow.overrideLabelWidth
                                readOnly: true
                                unit: "%/°C"
                            }
                        }
                    }
                }


                Column {
                    id: driverParams
                    spacing: 2
                    anchors {
                        left: middleColumn.left
                        leftMargin: 10
                        right: middleColumn.right
                        rightMargin: 10
                    }

                    property var selectedDriver: ({})

                    ListModel {
                        id: driverIds
                        Component.onCompleted: {
                            ComponentSource.loadComponentIdsIntoModel("driver", driverIds)
                            driverSelect.currentIndex=0
                        }
                    }

                    Rectangle {
                        id: driverTitle
                        width: driverParams.width
                        height: 30
                        color: "#ddd"
                        border {
                            color: "#bbb"
                            width: 0
                        }

                        SGComboBox {
                            id: driverSelect
                            anchors {
                                verticalCenter: driverTitle.verticalCenter
                                verticalCenterOffset: 1
                            }
                            model: driverIds
                            textRole: "component_id"
                            overrideLabelWidth: mosfetSelectLow.overrideLabelWidth
                            label: "<b>Driver</b>"
                            onCurrentTextChanged: {
                                driverParams.selectedDriver = ComponentSource.getComponent(currentText)
                                root.dataUpdate()
                            }
                            comboBoxWidth: 150
                            comboBoxHeight: 25
                        }
                    }

                    Rectangle {
                        id: driverDetailsTitle
                        width: parent.width
                        height: 20
                        color: "#ddd"

                        Text {
                            id: driverDetailsText
                            text: driverDetails.open ? "Hide Details" : "Show Details"
                            elide: Text.ElideRight
                            color: driverDetails.open ? "#000" : "#666"
                            anchors {
                                verticalCenter: driverDetailsTitle.verticalCenter
                                horizontalCenter: driverDetailsTitle.horizontalCenter
                            }
                        }

                        MouseArea {
                            anchors { fill: driverDetailsTitle }
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                driverDetails.openClose()
                            }
                        }
                    }

                    SGSubmitInfoBox {
                        id: driverVDR
                        label: "Vcc"
                        value: "5.0"
                        overrideLabelWidth: driverSelect.overrideLabelWidth
                        unit: "V"
                        onApplied: root.dataUpdate()
                    }

                    SGMinimizeContainer {
                        id: driverDetails
                        contents: Column {
                            spacing: 2

                            SGColumnDivider { }

                            SGSubmitInfoBox {
                                id: driverSourcingResistance
                                label: "Sourcing Resistance @ HS"
                                value: driverParams.selectedDriver.SourcingResistance
                                overrideLabelWidth: driverSelect.overrideLabelWidth
                                readOnly: true
                                unit: "Ω"
                            }

                            SGSubmitInfoBox {
                                id: driverSinkingResistance
                                label: "Sinking Resistance @ HS"
                                value: driverParams.selectedDriver.SinkingResistance
                                overrideLabelWidth: driverSelect.overrideLabelWidth
                                readOnly: true
                                unit: "Ω"
                            }

                            SGSubmitInfoBox {
                                id: driverRiseDelayTime
                                label: "tpdHDRVH"
                                value: driverParams.selectedDriver.RiseDelayTime
                                overrideLabelWidth: driverSelect.overrideLabelWidth
                                readOnly: true
                                unit: "ns"
                            }

                            SGSubmitInfoBox {
                                id: driverFallDelayTime
                                label: "tpdLDRVH"
                                value: driverParams.selectedDriver.FallDelayTime
                                overrideLabelWidth: driverSelect.overrideLabelWidth
                                readOnly: true
                                unit: "ns"
                            }

                            SGSubmitInfoBox {
                                id: driverQuiescentCurrent
                                label: "Quiescent Current"
                                value: driverParams.selectedDriver.QuiescentCurrent
                                overrideLabelWidth: driverSelect.overrideLabelWidth
                                readOnly: true
                                unit: "mA"
                            }

                            SGSubmitInfoBox {
                                id: driverMaximDriverVoltage
                                label: "MAX-Vcc"
                                value: driverParams.selectedDriver.MaximDriverVoltage
                                overrideLabelWidth: driverSelect.overrideLabelWidth
                                readOnly: true
                                unit: "V"
                            }
                        }
                    }
                }
            }

            Column {
                id: rightColumn
                anchors {
                    top: container.top
                    right: container.right
                }
                width: container.width/3
                spacing: 20

                Column {
                    id: outputLC
                    spacing: 2
                    anchors {
                        left: rightColumn.left
                        leftMargin: 10
                        right: rightColumn.right
                        rightMargin: 10
                    }

                    Rectangle {
                        id: rightTopMargin
                        height: 10
                        width: driverParams.width
                    }

                    SGTitleBar {
                        id: outputLCTitle
                        title: "<b>Output L-C</b>"
                    }

                    Rectangle {
                        id: rightColMargin1
                        height: 5
                        width: outputLC.width
                    }

                    Text {
                        text: "Capacitor"
                    }

                    SGSubmitInfoBox {
                        id: outputLCESRCoutput
                        label: "ESR_Coutput"
                        value: "5"
                        overrideLabelWidth: 150
                        unit: "mΩ"
                        onApplied: root.dataUpdate()
                    }

                    SGSubmitInfoBox {
                        id: outputCapActual
                        label: "Capacitor Actual Value"
                        value: "88"
                        overrideLabelWidth: outputLCESRCoutput.overrideLabelWidth
                        unit: "uf"
                        onApplied: root.dataUpdate()
                    }

                    SGColumnDivider { }

                    Text {
                        text: "Inductor"
                    }

                    SGSubmitInfoBox {
                        id: outputLCCoreLoss
                        label: "Core Loss"
                        value: "50"
                        overrideLabelWidth: outputLCESRCoutput.overrideLabelWidth
                        unit: "mW"
                        onApplied: root.dataUpdate()
                    }

                    SGSubmitInfoBox {
                        id: outputLCWindingResistance
                        label: "WindingResistance"
                        value: "1.5"
                        overrideLabelWidth: outputLCESRCoutput.overrideLabelWidth
                        unit: "mΩ"
                        onApplied: root.dataUpdate()
                    }

                    SGSubmitInfoBox {
                        id: outputLCInductActual
                        label: "Inductor Actual Value"
                        value: "1.00"
                        overrideLabelWidth: outputLCESRCoutput.overrideLabelWidth
                        unit: "uH"
                        onApplied: root.dataUpdate()
                    }

                    SGColumnDivider { }

                    Text {
                        text: "PCB Resistance"
                    }

                    SGSubmitInfoBox {
                        id: outputLCRPCB
                        label: "R-PCB"
                        value: "1"
                        overrideLabelWidth: outputLCESRCoutput.overrideLabelWidth
                        unit: "mΩ"
                        onApplied: root.dataUpdate()
                    }
                }
            }
        }
    }

    function dataUpdate() {
        if (root.ready) {
            root.update()
        }
    }
}
