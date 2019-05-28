import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/15A-switcher/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

Item {
    anchors.fill: parent
    property string vinlable: ""
    property var read_enable_state: platformInterface.initial_status.enable_status


    onRead_enable_stateChanged: {
        if(read_enable_state === "on") {
            platformInterface.enabled = true
        }
        else  {
            platformInterface.enabled = false
        }
    }

    property var soft_start_state: platformInterface.initial_status.soft_start_status
    onSoft_start_stateChanged: {
        if(soft_start_state === "5ms"){
            platformInterface.soft_start = 0
        }
        else {
            platformInterface.soft_start = 1
        }
    }

    property var vout_state: platformInterface.initial_status.vout_selector_status
    onVout_stateChanged: {
        platformInterface.vout = vout_state
    }

    property var ocp_threshold_state: platformInterface.initial_status.ocp_threshold_status
    onOcp_threshold_stateChanged: {
        if(ocp_threshold_state === 3){
            platformInterface.ocp_threshold = 2
        }
        else platformInterface.ocp_threshold = ocp_threshold_state
    }

    property var mode_state: platformInterface.initial_status.mode_index_status
    onMode_stateChanged: {
        platformInterface.mode = mode_state
    }

    property bool hide_ouput_vol: platformInterface.hideOutputVol
    onHide_ouput_volChanged: {
        if(hide_ouput_vol == true){
            outputVoltageList.opacity = 1.0
            outputVoltageList.enabled = true


        }
        else {
            outputVoltageList.enabled = false
            outputVoltageList.opacity = 0.5
        }

    }


    FontLoader {
        id: icons
        source: "sgwidgets/fonts/sgicons.ttf"
    }

    property var read_vin: platformInterface.status_voltage_current.vingood
    onRead_vinChanged: {
        if(read_vin === "good") {
            ledLight.status = "green"
            vinlable = "over"
            ledLight.label = "VIN Ready ("+vinlable + " 4.5V)"
            enableSwitch.enabled  = true
            enableSwitch.opacity = 1.0

        }
        else {
            ledLight.status = "red"
            vinlable = "under"
            ledLight.label = "VIN Ready ("+vinlable +" 4.5V)"
            enableSwitch.enabled  = false
            enableSwitch.opacity = 0.5
            platformInterface.enabled = false
        }
    }

    Component.onCompleted:  {
        multiplePlatform.check_class_id()
        Help.registerTarget(efficiencyGauge, "This gauge shows the efficiency of the Switcher. This is calculated with Pout/Pin. Regulator efficiency-accurate when a load is present.", 0, "advance15AHelp")
        Help.registerTarget(powerDissipatedGauge, "This gauge shows the power dissipated by the Switcher in Watts. This is calculated with Pout - Pin.", 1, "advance15AHelp")
        Help.registerTarget(tempGauge, "This gauge shows the temperature of the board.", 2, "advance15AHelp")
        Help.registerTarget(powerOutputGauge, "This gauge shows the Output Power in Watts.", 3, "advance15AHelp")
        Help.registerTarget(ledLight, "The LED will light up green when input voltage is ready and greater than 4.5V. It will light up red when under 4.5V to warn the user that input voltage is not high enough.", 4, "advance15AHelp")
        Help.registerTarget(inputCurrent, "Input current is shown here in A.", 6, "advance15AHelp")
        Help.registerTarget(inputVoltage, "Input voltage is shown here in Volts.", 5, "advance15AHelp")
        Help.registerTarget(softStartList, "Select either a 5ms or 10ms softstart. Converter reset required to see changes", 7,"advance15AHelp")

        Help.registerTarget(vbVoltage, "This is internal LDO output voltage", 8, "advance15AHelp")
        Help.registerTarget(vccVoltage, "Biasing voltage used by converter- tied to input voltage by default.", 9, "advance15AHelp")
        Help.registerTarget(vboostVoltage, "This is boot-strap (pin BST) voltage. ", 10, "advance15AHelp")
        Help.registerTarget(enableSwitch, "Enables and disables 15A switcher output.", 11, "advance15AHelp")
        Help.registerTarget(outputVoltageList, "Select output voltages 1, 1.8, 2.5, and 3.3V. Converter will UVLO when changing from a higher output voltage to a lower output voltage when in DCM mode.", 12, "advance15AHelp")
        Help.registerTarget(ocplist,"Low-Side Sensing, Peak-Current detect threshold. Value is approximate as it is duty cycle and FSW dependant. CONVERTER RESET REQUIRED TO CHANGE THRESHOLD.", 13, "advance15AHelp")
        if(multiplePlatform.modeVisible === true) {
            Help.registerTarget(modeSelect, "Select Converter Switching Mode. 550Khz or 1.1Mhz in either DCM or FCCM. When in 1.1Mhz FCCM, converter may go into over-temperature protect mode after some time at max load.", 16, "advance15AHelp")
        }
        Help.registerTarget(ouputCurrent,"Output current is shown here in A.", 15, "advance15AHelp")
        Help.registerTarget(outputVoltage,"Output voltage is shown here in Volts.", 14, "advance15AHelp")
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
            id: controlSection
            width: parent.width
            height: parent.height - 100

            anchors{
                top: pageLable.bottom
                topMargin: 20
            }

            Rectangle {
                id: topControl
                anchors {
                    left: controlSection.left
                    top: controlSection.top
                }
                width: parent.width
                height: controlSection.height/2.5

                SGCircularGauge {
                    id: efficiencyGauge
                    anchors {
                        top: parent.top
                        left: parent.left
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
                    gaugeTitle: "Efficiency"
                    value: platformInterface.status_voltage_current.efficiency
                    Behavior on value { NumberAnimation { duration: 300 } }

                }

                SGCircularGauge {
                    id: powerDissipatedGauge
                    anchors {
                        left: efficiencyGauge.right
                        top: parent.top
                    }

                    width: parent.width/4
                    height: parent.height
                    gaugeFrontColor1: Qt.rgba(0,1,.25,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    minimumValue: 0
                    maximumValue: 5
                    tickmarkStepSize: 0.5
                    outerColor: "#999"
                    unitLabel: "W"
                    gaugeTitle: "Power Loss"
                    decimal: 2

                    value: platformInterface.status_voltage_current.power_dissipated
                    Behavior on value { NumberAnimation { duration: 300 } }
                }


                SGCircularGauge {
                    id: tempGauge
                    anchors {
                        left: powerDissipatedGauge.right
                        top: parent.top
                    }

                    width: parent.width/4
                    height: parent.height
                    gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    minimumValue: -55
                    maximumValue: 125
                    tickmarkStepSize: 20
                    outerColor: "#999"
                    unitLabel: "°C"
                    gaugeTitle: "Board" + "\n" + "Temperature"
                    value: platformInterface.status_temperature_sensor.temperature
                    Behavior on value { NumberAnimation { duration: 300 } }
                }
                SGCircularGauge {
                    id: powerOutputGauge
                    anchors {
                        left: tempGauge.right
                        top: parent.top
                    }
                    width: parent.width/4
                    height: parent.height
                    gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    minimumValue: 0
                    maximumValue: multiplePlatform.maxValue
                    tickmarkStepSize: multiplePlatform.stepValue
                    outerColor: "#999"
                    unitLabel: "W"
                    gaugeTitle: "Output Power"
                    decimal: 1
                    value: platformInterface.status_voltage_current.output_power
                    Behavior on value { NumberAnimation { duration: 300 } }
                }

            }

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
                    width: parent.width/3.6
                    height: (parent.height/2) + 120

                    anchors {
                        top: parent.top
                        //  topMargin : 20
                        left: parent.left
                        leftMargin : 50
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

                        property string vinMonitor: platformInterface.status_voltage_current.vingood
                        onVinMonitorChanged:  {
                            if(vinMonitor === "good") {
                                status = "green"
                                vinlable = "over"
                                label = "VIN Ready ("+ vinlable + " 4.5V)"
                                enableSwitch.enabled  = true
                                enableSwitch.opacity = 1.0
                            }
                            else if(vinMonitor === "bad") {
                                status = "red"
                                vinlable = "under"
                                label = "VIN Ready ("+ vinlable + " 4.5V)"
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
                            text: "<b>DO NOT exceed input voltage more than 23V</b>"
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
                        }
                    }

                    SGLabelledInfoBox {
                        id: inputCurrent
                        label: "Input Current"
                        info: platformInterface.status_voltage_current.iin.toFixed(2)
                        unit: "A"
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
                    id: dataContainerMiddle
                    width: parent.width/3
                    height: (parent.height/2) + 120
                    anchors {
                        left: dataContainer.right
                        leftMargin: 40
                        top: parent.top
                        // topMargin : 20
                        right: dataContainerRight.left
                        rightMargin: 40
                    }

                    Rectangle {
                        id: selectList
                        width: parent.width
                        height: (parent.height/2.5) + 20
                        color: "transparent"
                        border.color: "black"
                        border.width: 5
                        radius: 10
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }
                        Rectangle {
                            id: softStartList
                            width: parent.width - 30
                            height: parent.height/3
                            anchors {
                                top: parent.top
                                topMargin: 10
                                horizontalCenter: parent.horizontalCenter
                            }

                            SGComboBox {
                                id: softStartCombo
                                currentIndex: platformInterface.soft_start
                                model: [
                                    "5ms", "10ms"
                                ]
                                label: "Soft Start:"

                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                    horizontalCenterOffset: (modeCombo.width -width)/2

                                }
                                fontSize :  (parent.width + parent.height)/26
                                comboBoxWidth: parent.width/1.6
                                comboBoxHeight: parent.height
                                onActivated: {
                                    if(currentIndex == 0) {
                                        platformInterface.set_soft_start.update("5ms")
                                    }
                                    else {
                                        platformInterface.set_soft_start.update("10ms")
                                    }
                                    platformInterface.soft_start = currentIndex
                                }
                            }
                        }

                        Rectangle {
                            id: modeSelect
                            width: parent.width - 30
                            height: parent.height/3
                            anchors {
                                top: softStartList.bottom
                                topMargin: 10
                                horizontalCenter: parent.horizontalCenter
                            }

                            SGComboBox {
                                id: modeCombo
                                currentIndex: platformInterface.mode
                                label: "Mode Select:"
                                model: [
                                    "Auto CCM/DCM, 550KHz, OVP Latch Off, Sonic Mode Enabled",
                                    "Auto CCM/DCM, 550KHz, OVP Latch Off, Sonic Mode Disabled",
                                    "Auto CCM/DCM, 1.1MHz, OVP Latch Off, Sonic Mode Enabled",
                                    "FCCM, 1.1MHz, OVP Hiccup, Sonic Mode Not Applied",
                                    "Auto CCM/DCM, 1.1MHz, OVP Latch Off, Sonic Mode Disabled"
                                ]
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                }

                                visible: multiplePlatform.modeVisible

                                fontSize :  (parent.width + parent.height)/26
                                comboBoxWidth: parent.width/1.6
                                comboBoxHeight: parent.height
                                onActivated:  {
                                    platformInterface.set_mode.update(currentIndex)
                                    platformInterface.mode = currentIndex
                                }
                            }
                        }
                    }

                    Rectangle {

                        color: "transparent"
                        border.color: "black"
                        border.width: 5
                        radius: 10
                        width: parent.width
                        height : parent.height/2
                        anchors {
                            top : selectList.bottom
                            topMargin: 10
                            horizontalCenter: parent.horizontalCenter
                        }

                        SGLabelledInfoBox {
                            id: vbVoltage
                            label: "VB Voltage"
                            info: platformInterface.status_voltage_current.vb.toFixed(2)
                            unit: "V"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/6
                            fontSize :  (parent.width + parent.height)/34
                            unitSize: (parent.width + parent.height)/30
                            anchors {
                                top : parent.top
                                topMargin : 20
                                horizontalCenter: parent.horizontalCenter
                                horizontalCenterOffset: (vboostVoltage.width - vbVoltage.width)/2

                            }



                        }
                        SGLabelledInfoBox {
                            id: vccVoltage
                            label: "VCC Voltage"
                            info: platformInterface.status_voltage_current.vcc.toFixed(2)
                            unit: "V"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/6
                            fontSize :  (parent.width + parent.height)/34
                            unitSize: (parent.width + parent.height)/30
                            anchors {
                                top : vbVoltage.bottom
                                topMargin : 10
                                horizontalCenter: parent.horizontalCenter
                                horizontalCenterOffset: (vboostVoltage.width - vccVoltage.width)/2

                            }

                        }
                        SGLabelledInfoBox {
                            id: vboostVoltage
                            label: "VBST Voltage"
                            info: platformInterface.status_voltage_current.vboost.toFixed(2)
                            unit: "V"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/6
                            fontSize :  (parent.width + parent.height)/34
                            unitSize: (parent.width + parent.height)/30
                            anchors {
                                top : vccVoltage.bottom
                                topMargin : 10
                                horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }

                Rectangle {
                    id: dataContainerRight
                    color: "transparent"
                    border.color: "black"
                    border.width: 5
                    radius: 10
                    width: parent.width/3.6
                    height: (parent.height/2) + 120

                    anchors {
                        right: parent.right
                        rightMargin: 50
                        top: parent.top
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
                            topMargin :  15
                            horizontalCenter: parent.horizontalCenter
                        }

                        label : "Enable (EN)"
                        switchWidth: parent.width/7         // Default: 52 (change for long custom checkedLabels when labelsInside)
                        switchHeight: parent.height/15             // Default: 26
                        textColor: "black"              // Default: "black"
                        handleColor: "white"            // Default: "white"
                        grooveColor: "#ccc"             // Default: "#ccc"
                        grooveFillColor: "#0cf"         // Default: "#0cf"

                        checked: platformInterface.enabled
                        fontSizeLabel: (parent.width + parent.height)/40

                        onCheckedChanged: {
                            if(multiplePlatform.holder3231 == true){
                                if(checked){
                                    ocplist.enabled = false
                                    ocplist.opacity = 0.5
                                    outputVoltageList.enabled = true
                                    outputVoltageList.opacity = 1.0

                                }
                                else{
                                    ocplist.enabled = true
                                    ocplist.opacity = 1.0
                                    outputVoltageList.enabled = false
                                    outputVoltageList.opacity = 0.5
                                }

                            }
                            else {
                                if(checked){
                                    ocplist.enabled = false
                                    ocplist.opacity = 0.5
                                }
                                else{
                                    ocplist.enabled = true
                                    ocplist.opacity = 1.0
                                }
                            }
                        }

                        onToggled: {
                            if(multiplePlatform.holder3231 == true){
                                if(checked){
                                    platformInterface.set_enable.update("on")
                                    outputVoltageList.enabled = false
                                    outputVoltageList.opacity = 0.5
                                }
                                else {

                                    platformInterface.set_enable.update("off")
                                    outputVoltageList.enabled = true
                                    outputVoltageList.opacity = 1.0
                                }

                                platformInterface.enabled = checked
                            }
                            else {
                                if(checked){
                                    platformInterface.set_enable.update("on")
                                }
                                else platformInterface.set_enable.update("off")

                                platformInterface.enabled = checked
                            }
                        }

                    }

                    Rectangle {
                        id: outputVoltageList
                        width: parent.width/1.3
                        height: parent.height/10
                        anchors {
                            top: enableSwitch.bottom
                            topMargin: 15
                            horizontalCenter: parent.horizontalCenter
                        }
                        SGComboBox {
                            id: ouputVolCombo
                            currentIndex: platformInterface.vout
                            model: [
                                "1V", "1.8V", "2.5V", "3.3V"
                            ]
                            label: "Select Output Voltage:"
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                horizontalCenterOffset: (width - outputVoltage.width)/2
                            }
                            fontSize :  (parent.width + parent.height)/16
                            comboBoxWidth: parent.width/3.4
                            comboBoxHeight: parent.height
                            onActivated: {
                                platformInterface.select_output_voltage.update(currentIndex)
                                platformInterface.vout = currentIndex
                            }


                        }
                    }

                    Rectangle {
                        id: ocplist
                        width: parent.width/1.3
                        height: parent.height/10
                        anchors {
                            top: outputVoltageList.bottom
                            topMargin: 15
                            horizontalCenter: parent.horizontalCenter
                        }
                        SGComboBox {
                            id: ocpCombo
                            currentIndex: {
                                if(platformInterface.ocp_threshold == 3) {
                                    currentIndex = 2
                                }
                                else platformInterface.ocp_threshold
                            }

                            model: multiplePlatform.listOfOutputValue
                            label: "OCP Threshold:"
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                horizontalCenterOffset: (width - outputVoltage.width)/2
                            }
                            fontSize :  (parent.width + parent.height)/16
                            comboBoxWidth: parent.width/3
                            comboBoxHeight: parent.height

                            onActivated: {
                                if(currentIndex == 2) {
                                    platformInterface.select_ocp_threshold.update(3)
                                    platformInterface.ocp_threshold = 2
                                }
                                else {
                                    platformInterface.select_ocp_threshold.update(currentIndex)
                                    platformInterface.ocp_threshold = currentIndex
                                }

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
                            top : ocplist.bottom
                            topMargin : 15
                            horizontalCenter: parent.horizontalCenter
                        }
                    }

                    SGLabelledInfoBox {
                        id: ouputCurrent
                        label: "Output Current"
                        info: platformInterface.status_voltage_current.iout.toFixed(2)
                        unit: "A"
                        infoBoxWidth: parent.width/3
                        infoBoxHeight :  parent.height/12
                        fontSize :   (parent.width + parent.height)/37
                        unitSize: (parent.width + parent.height)/35
                        anchors {
                            top : outputVoltage.bottom
                            topMargin : 14
                            horizontalCenter: parent.horizontalCenter

                        }
                    }
                }
            }
        } // end of controlContainer
    }
}



