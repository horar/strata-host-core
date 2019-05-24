import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/XDFN-LDO/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help


Item {
    anchors.fill: parent
    property string vinlable: ""
    property bool hideEcoSwitch: false
    property string warningVin: multiplePlatform.warningVinLable

    // property that reads the initial notification
    property string read_enable_state: platformInterface.initial_status.enable_status
    onRead_enable_stateChanged: {
        if(read_enable_state === "on") {
            platformInterface.enabled = true
        }
        else  {
            platformInterface.enabled = false
        }
    }

    property string read_power_mode_state: platformInterface.initial_status.power_mode_status
    onRead_power_mode_stateChanged:  {
        if(read_power_mode_state === "on") {
            platformInterface.power_mode = true
        }
        else  {
            platformInterface.power_mode = false
        }
    }

    property string read_vin_mon: platformInterface.initial_status.vin_mon_status
    onRead_vin_monChanged: {
        if(read_vin_mon === "good") {
            ledLight.status = "green"
            vinlable = "over"
            ledLight.label = "VIN Ready ("+ vinlable + " " + warningVin + ")"
            enableSwitch.enabled  = true
            enableSwitch.opacity = 1.0
        }
        else {
            ledLight.status = "red"
            vinlable = "under"
            ledLight.label = "VIN Ready ("+ vinlable + " " + warningVin + ")"
            enableSwitch.enabled  = false
            enableSwitch.opacity = 0.5
            platformInterface.enabled = false
        }
    }

    FontLoader {
        id: icons
        source: "sgwidgets/fonts/sgicons.ttf"
    }

    Component.onCompleted:  {
        multiplePlatform.check_class_id()
        Help.registerTarget(efficiencyGauge, "This gauge shows the efficiency of the LDO. This is calculated with Pout/Pin. Regulator efficiency-accurate when a load is present.", 0, "advanceHelp")
        Help.registerTarget(powerDissipatedGauge, "This gauge shows the power dissipated by the LDO in mW. This is calculated with Pout - Pin.", 1, "advanceHelp")
        Help.registerTarget(tempGauge, "This gauge shows the temperature of the board.", 2, "advanceHelp")
        Help.registerTarget(powerOutputGauge, "This gauge shows the Output Power in mW.", 3, "advanceHelp")
        Help.registerTarget(ledLight, "The LED will light up green when input voltage is ready and greater than" + " " + warningVin + ".It will light up red when under"+ " "+ warningVin + "to warn the user that input voltage is not high enough.", 4, "advanceHelp")
        Help.registerTarget(inputCurrent, "Input current is shown here in milliamps.", 6, "advanceHelp")
        Help.registerTarget(inputVoltage, "Input voltage is shown here in Volts.", 5, "advanceHelp")
        Help.registerTarget(enableSwitch, "This switch enables or disables the LDO output.", 7, "advanceHelp")
        Help.registerTarget(ouputCurrent, "Output current is shown here in milliamps.", 9, "advanceHelp")
        Help.registerTarget(outputVoltage, "Output voltage is shown here in Volts.", 8, "advanceHelp")
        if(multiplePlatform.ecoVisible === true) {
             Help.registerTarget(ecoSwitch, "The switch puts NCP171 into Low Power Mode.", 10, "advanceHelp")
        }
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
                topMargin: 30
                horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: pageText
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }

                text:  multiplePlatform.partNumber
                font.pixelSize: (parent.width + parent.height)/ 30
                color: "black"
            }
            Text {
                id: pageText2
                anchors {
                    top: pageText.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                text: multiplePlatform.title
                font.pixelSize: (parent.width + parent.height)/ 40
                color: "black"

            }
        }

        Rectangle {
            id: controlSection1
            width: parent.width
            height: parent.height - 100
            anchors{
                top: pageLable.bottom
                topMargin: 20
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
                    id: efficiencyGauge
                    anchors {
                        top: parent.top
                        left: parent.left
                        leftMargin: 20
                    }

                    width: parent.width/4.5
                    height: parent.height
                    gaugeFrontColor1: Qt.rgba(1,0,0,1)
                    gaugeFrontColor2: Qt.rgba(0,1,.25,1)
                    minimumValue: 0
                    maximumValue: 100
                    tickmarkStepSize: 10
                    outerColor: "#999"
                    unitLabel: "%"
                    gaugeTitle: "Efficiency"
                    value: platformInterface.status_voltage_current.efficiency
                    Behavior on value { NumberAnimation { duration: 300 } }

                }

                SGCircularGauge {
                    id: powerDissipatedGauge
                    anchors {
                        left: efficiencyGauge.right
                        leftMargin: 20
                        top: parent.top
                    }

                    width: parent.width/4.5
                    height: parent.height
                    gaugeFrontColor1: Qt.rgba(0,1,.25,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    minimumValue: 0
                    maximumValue: 1000
                    tickmarkStepSize: 100
                    outerColor: "#999"
                    gaugeTitle: "Power Loss"
                    unitLabel: "mW"
                    value: platformInterface.status_voltage_current.power_dissipated
                    Behavior on value { NumberAnimation { duration: 300 } }
                }


                SGCircularGauge {
                    id: tempGauge
                    anchors {
                        left: powerDissipatedGauge.right
                        leftMargin: 20
                        top: parent.top
                    }

                    width: parent.width/4.5
                    height: parent.height
                    gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    minimumValue: -55
                    maximumValue: 125
                    tickmarkStepSize: 20
                    outerColor: "#999"
                    unitLabel: "°C"
                    gaugeTitle: "Board" + "\n" +"Temperature"
                    value: platformInterface.status_temperature_sensor.temperature
                    Behavior on value { NumberAnimation { duration: 300 } }
                }
                SGCircularGauge {
                    id: powerOutputGauge
                    anchors {
                        left: tempGauge.right
                        leftMargin: 20
                        top: parent.top
                    }

                    width: parent.width/4.5
                    height: parent.height
                    gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    minimumValue: 0
                    maximumValue: multiplePlatform.maxValue
                    tickmarkStepSize: multiplePlatform.stepValue
                    outerColor: "#999"
                    unitLabel: "mW"
                    gaugeTitle: "Output Power"
                    value: platformInterface.status_voltage_current.output_power
                    Behavior on value { NumberAnimation { duration: 300 } }
                }

            } // end of left control

            Rectangle {
                width: parent.width
                height: parent.height/2

                anchors {
                    top : topControl.bottom
                    topMargin: 20
                }

                Rectangle {
                    id: dataContainer
                    color: "transparent"
                    border.color: "black"
                    border.width: 5
                    radius: 10
                    width: parent.width/3
                    height: (parent.height/2) + 100

                    anchors {
                        top: parent.top
                        topMargin : 20
                        left: parent.left
                        leftMargin : 100
                    }

                    Text {
                        id: containerLabel
                        text: "Input"
                        width: parent.width/5
                        height: parent.height/10
                        anchors {
                            top: parent.top
                            topMargin: 20
                            horizontalCenter: parent.horizontalCenter
                        }
                        font.pixelSize: height
                        fontSizeMode: Text.Fit
                        font.bold: true
                    }

                    Rectangle {
                        id: line
                        height: 2
                        width: parent.width - 9

                        anchors {
                            top: containerLabel.bottom
                            topMargin: 2
                            left: parent.left
                            leftMargin: 5
                        }
                        border.color: "gray"
                        radius: 2
                    }
                    SGStatusLight {
                        id: ledLight
                        // Optional Configuration:
                        label: "VIN Ready (under 2.25V)" // Default: "" (if not entered, label will not appear)
                        anchors {
                            top : line.bottom
                            topMargin : 20
                            horizontalCenter: parent.horizontalCenter
                        }

                        lightSize: (parent.width + parent.height)/23
                        fontSize:  (parent.width + parent.height)/46

                        property string vinMonitor: platformInterface.status_vin_good.vingood
                        //                        vinMonitor: read_vin_mon
                        onVinMonitorChanged:  {
                            if(vinMonitor === "good") {

                                status = "green"
                                vinlable = "over"
                                label = "VIN Ready ("+ vinlable + " " + warningVin + ")"
                                enableSwitch.enabled  = true
                                enableSwitch.opacity = 1.0

                            }
                            else if(vinMonitor === "bad") {
                                status = "red"
                                vinlable = "under"
                                label = "VIN Ready ("+ vinlable + " " + warningVin + ")"
                                enableSwitch.enabled  = false
                                enableSwitch.opacity = 0.5
                                platformInterface.enabled = false
                            }
                        }
                    }
                    Rectangle {
                        id: warningBox2
                        color: "red"
                        anchors {
                            top: ledLight.bottom
                            topMargin: 15
                            horizontalCenter: parent.horizontalCenter
                        }
                        width: parent.width - 40
                        height: parent.height/10

                        Text {
                            id: warningText2
                            anchors {
                                centerIn: warningBox2
                            }
                            text: "<b>DO NOT exceed input voltage more than 5.5V</b>"
                            font.pixelSize: (parent.width + parent.height)/32
                            color: "white"
                        }

                        Text {
                            id: warningIconleft
                            anchors {
                                right: warningText2.left
                                verticalCenter: warningText2.verticalCenter
                                rightMargin: 5
                            }
                            text: "\ue80e"
                            font.family: icons.name
                            font.pixelSize: (parent.width + parent.height)/19
                            color: "white"
                        }

                        Text {
                            id: warningIconright
                            anchors {
                                left: warningText2.right
                                verticalCenter: warningText2.verticalCenter
                                leftMargin: 5
                            }
                            text: "\ue80e"
                            font.family: icons.name
                            font.pixelSize: (parent.width + parent.height)/19
                            color: "white"
                        }
                    }

                    SGLabelledInfoBox {
                        id: inputVoltage
                        label: "Input Voltage"
                        info: platformInterface.status_voltage_current.vin.toFixed(2)
                        unit: "V"
                        infoBoxWidth: parent.width/3
                        infoBoxHeight : parent.height/12
                        fontSize :  (parent.width + parent.height)/37
                        unitSize: (parent.width + parent.height)/35
                        anchors {
                            top : warningBox2.bottom
                            topMargin : 20
                            horizontalCenter: parent.horizontalCenter
                            horizontalCenterOffset: (width - inputCurrent.width)/2
                        }
                    }

                    SGLabelledInfoBox {
                        id: inputCurrent
                        label: "Input Current"
                        info: platformInterface.status_voltage_current.iin.toFixed(2)
                        unit: "mA"
                        infoBoxWidth: parent.width/3
                        infoBoxHeight :  parent.height/12
                        fontSize :   (parent.width + parent.height)/37
                        unitSize: (parent.width + parent.height)/35
                        anchors {
                            top : inputVoltage.bottom
                            topMargin : 20
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Rectangle {
                    id: dataContainerRight
                    color: "transparent"
                    border.color: "black"
                    border.width: 5
                    radius: 10
                    width: parent.width/3
                    height: (parent.height/2) + 100

                    anchors {
                        right: parent.right
                        rightMargin: 150
                        top: parent.top
                        topMargin : 20
                    }

                    Text {
                        id: containerLabelout
                        text: "Output"
                        width: parent.width/5
                        height: parent.height/10
                        anchors {
                            top: parent.top
                            topMargin: 20
                            horizontalCenter: parent.horizontalCenter
                        }

                        font.pixelSize: height
                        font.bold: true
                        fontSizeMode: Text.Fit
                    }

                    Rectangle {
                        id: line2
                        height: 2
                        width: parent.width - 9

                        anchors {
                            top: containerLabelout.bottom
                            topMargin: 2
                            left: parent.left
                            leftMargin: 5
                        }
                        border.color: "gray"
                        radius: 2
                    }

                    SGSwitch {
                        id: enableSwitch
                        anchors {
                            top: line2.bottom
                            topMargin :  20
                            horizontalCenter: parent.horizontalCenter
                        }

                        label : "Enable (EN)"
                        switchWidth: parent.width/9          // Default: 52 (change for long custom checkedLabels when labelsInside)
                        switchHeight: parent.height/15             // Default: 26
                        textColor: "black"              // Default: "black"
                        handleColor: "white"            // Default: "white"
                        grooveColor: "#ccc"             // Default: "#ccc"
                        grooveFillColor: "#0cf"         // Default: "#0cf"
                        fontSizeLabel: (parent.width + parent.height)/40
                        checked:  platformInterface.enabled
                        onToggled: {
                            platformInterface.enabled = checked
                            if(checked){
                                platformInterface.set_enable.update("on")
                            }
                            else{
                                platformInterface.set_enable.update("off")
                            }
                        }
                    }

                    SGSwitch {
                        id: ecoSwitch
                        anchors {
                            top: enableSwitch.bottom
                            topMargin :  20
                            horizontalCenter: parent.horizontalCenter
                        }

                        visible: multiplePlatform.ecoVisible
                        label : "Low Power Mode"
                        switchWidth: parent.width/9          // Default: 52 (change for long custom checkedLabels when labelsInside)
                        switchHeight: parent.height/15             // Default: 26
                        textColor: "black"              // Default: "black"
                        handleColor: "white"            // Default: "white"
                        grooveColor: "#ccc"             // Default: "#ccc"
                        grooveFillColor: "#0cf"         // Default: "#0cf"
                        fontSizeLabel: (parent.width + parent.height)/40
                        checked:  platformInterface.power_mode
                        onToggled: {
                            platformInterface.power_mode = checked
                            if(checked){
                                platformInterface.set_power_mode.update("on")
                            }
                            else{
                                platformInterface.set_power_mode.update("off")
                            }
                        }

                    }

                    SGLabelledInfoBox {
                        id: outputVoltage
                        label: "Output Voltage"
                        info: platformInterface.status_voltage_current.vout.toFixed(2)
                        unit: "V"
                        infoBoxWidth: parent.width/3
                        infoBoxHeight : parent.height/12
                        fontSize :  (parent.width + parent.height)/37
                        unitSize: (parent.width + parent.height)/35
                        anchors {
                            top : ecoSwitch.bottom
                            topMargin : 20
                            horizontalCenter: parent.horizontalCenter
                            horizontalCenterOffset: ( width - ouputCurrent.width)/2
                        }
                    }

                    SGLabelledInfoBox {
                        id: ouputCurrent
                        label: "Output Current"
                        info: {
                            if(multiplePlatform.showDecimal === true) {
                                platformInterface.status_voltage_current.iout.toFixed(2)
                            }
                            else {
                                platformInterface.status_voltage_current.iout
                            }

                        }
                        unit: "mA"
                        infoBoxWidth: parent.width/3
                        infoBoxHeight :  parent.height/12
                        fontSize :   (parent.width + parent.height)/37
                        unitSize: (parent.width + parent.height)/35
                        anchors {
                            top : outputVoltage.bottom
                            topMargin : 20
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }
}

