import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.strata.sgwidgets 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    height: 450
    width: parent.width
    anchors.left: parent.left
    property string vinlable: ""

    property var reset_indicator_status: platformInterface.power_cycle_status.reset
    onReset_indicator_statusChanged: {
        if(reset_indicator_status === "occurred"){
            platformInterface.reset_indicator = "red"
            platformInterface.reset_flag = true
        }
    }

    property string reset_led_status: platformInterface.reset_indicator
    onReset_led_statusChanged: {
        resetLed.status = platformInterface.reset_indicator
    }

    property var status_interrupt: platformInterface.status_interrupt.intb
    onStatus_interruptChanged:  {
        if(status_interrupt === "bad") {
            errorLed.status = "red"
            basicControl.warningVisible = true
        }
    }

    property var read_enable_state: platformInterface.initial_status_0.enable_status
    onRead_enable_stateChanged: {
        if(read_enable_state === "on") {
            platformInterface.enabled = true
            basicControl.warningVisible = false
        }
        else  {
            platformInterface.enabled = false
        }
    }

    property var read_vin: platformInterface.initial_status_0.vingood_status
    onRead_vinChanged: {
        if(read_vin === "good") {
            ledLight.status = "green"
            platformInterface.hide_enable = true
            vinlable = "over"
            ledLight.label = "VIN Ready \n ("+ vinlable + " 2.5V)"
        }
        else {
            ledLight.status = "red"
            platformInterface.hide_enable = false
            vinlable = "under"
            ledLight.label = "VIN Ready \n ("+ vinlable + " 2.25V)"

        }
    }

    function addToHistoryLog()
    {
        var errorArray = platformInterface.status_ack_register.events_detected
        for (var i in errorArray){
            faultHistoryModel.insert(0,{ status : errorArray[i] })
        }

    }

    property bool check_intd_state: platformInterface.intd_state
    onCheck_intd_stateChanged:  {
        if(check_intd_state == true) {
            errorLed.status = "green"
            basicControl.warningVisible = false
            faultModel.clear()
            addToHistoryLog()
        }
        else if(check_intd_state == false)   {
            if( errorLed.status === "green") {
                basicControl.warningVisible = false
            }
            else if ( errorLed.status === "red"){
                basicControl.warningVisible = true
            }
        }
    }


    property bool check_intd_initial_state:platformInterface.initial_status_0.intb_status
    onCheck_intd_initial_stateChanged: {
        if(check_intd_initial_state === "good"){
            platformInterface.intd_state = "green"
            basicControl.warningVisible = false
        }
        else {
            platformInterface.intd_state = "red"
            basicControl.warningVisible = true
        }
    }

    Component.onCompleted: {
        Help.registerTarget(tempGauge, "This gauge displays the board temperature next to the part in degrees Celsius. (make sure to change label on this to board temperature)", 0, "advance5AHelp")
        Help.registerTarget(efficiencyGauge, "This gauge displays the efficiency of the power conversion. This calculated through Pout/Pin.", 1, "advance5AHelp")
        Help.registerTarget(powerDissipatedGauge, "This gauge displays the total power loss in the converter from input to output. This is calculated through Pout - Pin.", 2, "advance5AHelp")
        Help.registerTarget(powerOutputGauge, "This gauge displays the output power of the converter", 3, "advance5AHelp")
        Help.registerTarget(resetLed, "The LED will come on if the part resets itself during an event (e.g. UVLO), telling the user the part has reset to its default state.", 4, "advance5AHelp")
        Help.registerTarget(resetButton, "The Force Reset button will reset the part's internal registers to their default values", 5, "advance5AHelp")
        Help.registerTarget(ledLight,"VIN Ready LED will turn green when input voltage is high enough to regulate (above 4.5V). Part cannot be enabled until input voltage is high enough. ", 6, "advance5AHelp")
        Help.registerTarget(errorLed, "Interrupt Error LED will be turned on when an interrupt has been triggered.", 7, "advance5AHelp")
        Help.registerTarget(interruptError, "When an interrupt is triggered, the message log will display the interrupts that occurred.", 8, "advance5AHelp")
        Help.registerTarget(faultHistory, "The fault History box will show all the previous faults generated. Every time a new fault occurs it will be displayed on the top of the list.", 9, "advance5AHelp")
        Help.registerTarget(inputVoltage, "Input voltage is shown here in Volts.", 10, "advance5AHelp")
        Help.registerTarget(inputCurrent, "Input current is shown here in A", 11, "advance5AHelp")
        Help.registerTarget(ouputCurrent, " Output current is shown here in A.", 12, "advance5AHelp")
        Help.registerTarget(outputVoltage, "Output voltage is shown here in Volts.", 13, "advance5AHelp")
    }

    Item {
        id: leftColumn
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        width: parent.width/1.7

        Item {
            id: margins1
            anchors {
                fill: parent
                margins: 15
            }
            Column {
                id : leftSetting
                anchors {
                    fill: parent
                }
                Rectangle {
                    id:gauges
                    width : parent.width
                    height: parent.height/1.5


                    SGCircularGauge {
                        id: tempGauge
                        anchors.top: parent.top
                        width: parent.width/4
                        height: parent.height
                        gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                        gaugeFrontColor2: Qt.rgba(1,0,0,1)
                        minimumValue: -55
                        maximumValue: 125
                        tickmarkStepSize: 20
                        outerColor: "#999"
                        unitLabel: "˚C"
                        //gaugeTitle : "Board" + "\n"+ "Temperature"

                        value: platformInterface.status_temperature_sensor.temperature
                        Behavior on value { NumberAnimation { duration: 300 } }
                    }
                    SGCircularGauge {
                        id: efficiencyGauge
                        anchors {
                            top: parent.top
                            left: tempGauge.right
                        }
                        width: parent.width/4
                        height: parent.height
                        gaugeFrontColor1: Qt.rgba(1,0,0,1)
                        gaugeFrontColor2: Qt.rgba(0,1,.25,1)
                        minimumValue: 0
                        maximumValue: 100
                        tickmarkStepSize: 10
                        outerColor: "#999"
                        unitLabel: "%"
                       // gaugeTitle: "Efficiency"
                        value: platformInterface.status_voltage_current.efficiency
                        Behavior on value { NumberAnimation { duration: 300 } }

                    }
                    SGCircularGauge {
                        id: powerDissipatedGauge
                        anchors {
                            top: parent.top
                            left: efficiencyGauge.right
                        }
                        width: parent.width/4
                        height: parent.height
                        gaugeFrontColor1: Qt.rgba(0,1,0,1)
                        gaugeFrontColor2: Qt.rgba(0,0,1,1)
                        minimumValue: 0
                        maximumValue: 5
                        tickmarkStepSize: 0.5
                        outerColor: "#999"
                        unitLabel: "W"
                       // gaugeTitle: "Power"+ "\n" + "Loss"
                       // decimal: 2
                        value: platformInterface.status_voltage_current.power_dissipated
                        Behavior on value { NumberAnimation { duration: 300 } }
                    }

                    SGCircularGauge {
                        id: powerOutputGauge
                        anchors {
                            top: parent.top
                            left: powerDissipatedGauge.right
                        }
                        width: parent.width/4
                        height: parent.height
                        gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                        gaugeFrontColor2: Qt.rgba(1,0,0,1)
                        minimumValue: 0
                        maximumValue:  20
                        tickmarkStepSize: 2
                        outerColor: "#999"
                        unitLabel: "W"
                        //gaugeTitle: "Output" +"\n"+" Power"
                       // decimal: 2
                        value: platformInterface.status_voltage_current.output_power
                        Behavior on value { NumberAnimation { duration: 300 } }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: parent.height/2
                    color: "transparent"

                    SGLabelledInfoBox {
                        id: inputVoltage
                        label: "Input Voltage"
                        //unit: "V"
                        infoBoxWidth: parent.width/5.5
                        infoBoxHeight : parent.height/5
                        //fontSize :  (parent.width + parent.height)/50
                        //unitSize: (parent.width + parent.height)/40
                        info: platformInterface.status_voltage_current.vin.toFixed(2)
                        anchors {
                            top : parent.top
                            topMargin : 10
                            left: parent.left
                            leftMargin : 20
                        }
                    }
                    SGLabelledInfoBox {
                        id: inputCurrent
                        label: "Input Current"
                        //unit: "A"
                        infoBoxWidth: parent.width/5.5
                        infoBoxHeight : parent.height/5
                        //fontSize :  (parent.width + parent.height)/50
                        //unitSize: (parent.width + parent.height)/40
                        info:  platformInterface.status_voltage_current.iin.toFixed(2)
                        anchors {
                            top : inputVoltage.bottom
                            topMargin: 10
                            left: parent.left
                            leftMargin : 20
                        }
                    }
                    SGLabelledInfoBox {
                        id: outputVoltage
                        label: "Output Voltage"
                        info: platformInterface.status_voltage_current.vout
                        //unit: "V"
                        infoBoxWidth: parent.width/5.5
                        infoBoxHeight : parent.height/5
                        //fontSize: (parent.width + parent.height)/50
                       // unitSize: (parent.width + parent.height)/40
                        anchors {
                            top: parent.top
                            topMargin : 10
                            right: parent.right
                            rightMargin: 20
                        }
                    }
                    SGLabelledInfoBox {
                        id: ouputCurrent
                        label: "Output Current"
                        info: platformInterface.status_voltage_current.iout.toFixed(2)
                        //unit: "A"
                        infoBoxWidth: parent.width/5.5
                        infoBoxHeight : parent.height/5
                        //fontSize : (parent.width + parent.height)/50
                        //unitSize: (parent.width + parent.height)/40
                        anchors {
                            top: outputVoltage.bottom
                            topMargin: 10
                            right: parent.right
                            rightMargin: 20
                        }
                    }
                }
            }
        }
        SGLayoutDivider {
            id: divider
            position: "right"
        }
    }

    Item {
        id: rightColumn
        anchors {
            left: leftColumn.right
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        Item {
            id: margins2
            anchors {
                fill: parent
                margins: 15
            }

            Rectangle {
                id: faultContainer
                height: parent.height/1.4
                width: parent.width
                border.color: "black"
                border.width: 3
                radius: 10
                anchors{
                    top: resetContainer.bottom
                    topMargin: 10
                }

                SGStatusListBox {
                    id: interruptError
                    height: parent.height/2.2
                    width: parent.width/1.1
                    anchors {
                        top: parent.top
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                    }
                    title: "Faults Log:"
                    model: faultModel
                }

                property var errorArray: platformInterface.status_ack_register.events_detected
                onErrorArrayChanged: {
                    for (var i in errorArray){
                        faultModel.insert(0,{ status : errorArray[i] })
                    }
                }
                ListModel {
                    id: faultModel

                }
                SGStatusListBox {
                    id: faultHistory
                    height: parent.height/2.2
                    width: parent.width/1.1
                    anchors {
                        top: interruptError.bottom
                        topMargin: 5
                        horizontalCenter: parent.horizontalCenter
                    }
                    title: "Faults History:"
                    model: faultHistoryModel
                    ListModel {
                        id: faultHistoryModel

                    }
                }
            }

            Rectangle {
                id:resetContainer
                height: rightColumn.height/4
                width: rightColumn.width/1.4
                color: "transparent"
                border.color: "black"
                border.width: 3
                radius: 10
                anchors{
                    top: parent.top
                    topMargin: 5
                }
                RowLayout {
                    anchors.fill: parent

                    ColumnLayout{
                        spacing: 10
                        Layout.minimumWidth: 50
                        Layout.preferredWidth: 100
                        Layout.maximumWidth: 150
                        Layout.minimumHeight: 100

                        SGStatusLight {
                            id: resetLed
                            // Optional Configuration:
                            label: "Reset"+ "\n"+ "Indicator" // Default: "" (if not entered, label will not appear)
                            Layout.alignment: Qt.AlignCenter
                            Layout.topMargin: 10
                            status: platformInterface.reset_indicator
                        }

                        Button {
                            id: resetButton
                            Layout.minimumWidth: 40
                            Layout.preferredWidth: 110
                            Layout.maximumWidth: 70
                            Layout.minimumHeight:40
                            Layout.alignment: Qt.AlignCenter
                            background: Rectangle {
                                color: "light gray"
                                border.width: 1
                                border.color: "gray"
                                radius: 10
                            }
                            Text {
                                text: "Force \n Reset"
                                font.bold: true
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                            }
                            onClicked: {
                                platformInterface.force_reset_registers.update("reset")
                                platformInterface.rearm_device.update("off")
                                platformInterface.read_initial_status.update()

                            }
                        }
                    }

                    ColumnLayout{
                        spacing: 10
                        Layout.minimumWidth: 50
                        Layout.preferredWidth: 100
                        Layout.maximumWidth: 150
                        Layout.minimumHeight: 100

                        SGStatusLight {
                            id: ledLight
                            // Optional Configuration:
                            label: "VIN Ready" +"\n" + "(under 2.25V)" // Default: "" (if not entered, label will not appear)
                            Layout.alignment: Qt.AlignCenter

                            property string vinMonitor: platformInterface.status_vin_good.vingood
                            onVinMonitorChanged:  {
                                if(vinMonitor === "good") {
                                    status = "green"
                                    vinlable = "over"
                                    platformInterface.hide_enable = true
                                    label = "VIN Ready \n ("+ vinlable + " 2.25V)"
                                    platformInterface.read_initial_status.update()

                                }
                                else if(vinMonitor === "bad") {
                                    status = "red"
                                    platformInterface.hide_enable = false
                                    vinlable = "under"
                                    label = "VIN Ready \n ("+ vinlable + " 2.25V)"
                                    platformInterface.enabled = false
                                    platformInterface.set_enable.update("off")
                                }
                            }
                        }

                        SGStatusLight {
                            id: errorLed
                            Layout.alignment: Qt.AlignCenter
                            Layout.leftMargin: 10
                            // Optional Configuration:
                            label: "Interrupt \n Error" // Default: "" (if not entered, label will not appear)
                            status: platformInterface.inbt_state
                        }

                    }
                }
            }
        }
    }
}

