import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import "qrc:/js/navigation_control.js" as NavigationControl
import tech.strata.sgwidgets 0.9 as Widget09
import tech.strata.sgwidgets 1.0
import "qrc:/js/help_layout_manager.js" as Help
//import "content-views/content-widgets"

Item {
    id: root
    height: 200
    width: parent.width
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    property var reset_indicator_status: platformInterface.power_cycle_status.reset

    property var outputvoltage0: []
    property var check_enable_state: platformInterface.hide_enable
    onCheck_enable_stateChanged: {
        if(check_enable_state === true) {
            enableSwitch.enabled  = true
            enableSwitch.opacity = 1.0
            enableSwitchLabel.opacity = 1.0
        }
        else {
            enableSwitch.enabled  = false
            enableSwitch.opacity = 0.5
            enableSwitchLabel.opacity = 0.5
        }

    }

    property var read_vsel_basic_status: platformInterface.vsel_state
    onRead_vsel_basic_statusChanged: {
        if(read_vsel_basic_status === true) {
            outputVolCombo.enabled = false
            outputVolCombo.opacity = 0.5
            outputVol1Label.opacity = 0.5
            dcdcModeCombo.enabled = false
            dcdcModeCombo.opacity = 0.5
            dcdcMode1Label.opacity = 0.5
            outputVolCombo2.enabled = true
            outputVolCombo2.opacity = 1.0
            outputVol2Label.opacity = 1.0
            dcdcModeCombo2.enabled = true
            dcdcModeCombo2.opacity = 1.0
            dcdcMode2Label.opacity = 1.0

        }
        else {
            outputVolCombo.enabled = true
            outputVolCombo.opacity = 1.0
            dcdcModeCombo.enabled = true
            dcdcModeCombo.opacity = 1.0
            dcdcMode1Label.opacity = 1.0
            outputVol1Label.opacity = 1.0
            outputVolCombo2.enabled = false
            outputVolCombo2.opacity = 0.5
            outputVol2Label.opacity = 0.5
            dcdcModeCombo2.enabled = false
            dcdcModeCombo2.opacity = 0.5
            dcdcMode2Label.opacity = 0.5
        }
    }

    property var read_enable_state: platformInterface.initial_status_0.enable_status
    onRead_enable_stateChanged: {
        platformInterface.enabled = (read_enable_state === "on") ? true : false
    }

    property var read_vsel_status: platformInterface.initial_status_0.vsel_status
    onRead_vsel_statusChanged: {
        platformInterface.vsel_state = (read_vsel_status === "on") ? true : false
    }

    property var read_output_voltage0_status: platformInterface.initial_status_0.vout_vsel0_status
    onRead_output_voltage0_statusChanged: {
        platformInterface.output_voltage_selector0 = read_output_voltage0_status
        outputVolCombo.currentIndex = read_output_voltage0_status
    }
    property var read_output_voltage1_status: platformInterface.initial_status_0.vout_vsel1_status
    onRead_output_voltage1_statusChanged: {
        platformInterface.output_voltage_selector1 = read_output_voltage1_status
        outputVolCombo2.currentIndex = read_output_voltage1_status
    }

    property var dcdc_mode0_status: platformInterface.initial_status_1.ppwmvsel0_mode_status
    onDcdc_mode0_statusChanged: {
        platformInterface.dcdc_mode0 = (dcdc_mode0_status === "forced_ppwm") ? true : false
    }
    property var dcdc_mode1_status: platformInterface.initial_status_1.ppwmvsel1_mode_status
    onDcdc_mode1_statusChanged: {
        platformInterface.dcdc_mode1 = (dcdc_mode1_status === "forced_ppwm") ? true : false
    }

    property var read_ipeak_state: platformInterface.initial_status_1.ipeak_status
    onRead_ipeak_stateChanged: {
        platformInterface.ipeak_state = read_ipeak_state
    }
    /*property var read_vin_mains_state: platformInterface.initial_status_1.vin_mains_status
    onRead_vin_mains_stateChanged: {
        platformInterface.vin_mains_state = read_vin_mains_state
    }*/
    Component.onCompleted: {
        var value;
        for(var i = 0 ; i <= 216 ; ++i ) {
            value = (i * 12.5) + 600
            outputvoltage0.push(value + " mV")
        }
        outputVolCombo.model = outputvoltage0
        outputVolCombo2.model = outputvoltage0
        outputVolCombo.currentIndex = 24
        outputVolCombo2.currentIndex = 32
        helpIcon.visible = true
        Help.registerTarget(enableSwitchContainer, "This switch enables/disables the NCV6357. It will be grayed out if the input voltage is not high enough (above 2.5V).", 0, "advanceViewSetting1Help")
        Help.registerTarget(peakcurrentContainer, "This dropdown menu will set the peak inductor current of the converter. The NCV6357 measures the peak inductor current internally by measuring the current through the P-MOSFET.", 1 , "advanceViewSetting1Help")
        //Help.registerTarget(inputVoltageMainsContainer, "This dropdown menu will set the Input Mains of the converter. The Preregulator is ready (greater than 6V), and will light up red otherwise to warn the user that input voltage is not high enough..", 2 , "advanceViewSetting1Help")
        Help.registerTarget(vselContainer, "VSEL will switch the output voltage between the two voltage values stored in the VoutVSEL registers in the NCV6357. Default register setting values for VoutVSEL0 and VoutVSEL1 are 0.9V and 1.0V respectively.", 2, "advanceViewSetting1Help")
        Help.registerTarget(outputvolcontainer,"Programmed Output Voltage 0 and 1 will set the output voltage levels that the NCV6357 will switch between. The output voltage will be determined by the box that is not grayed out.", 3, "advanceViewSetting1Help")
        Help.registerTarget(dcdcModeContainer, "DCDC Mode dropdown menu will set the DCDC mode the NCV6357 operates in. Auto mode means the NCV6357 will switch between PFM for light loads and PPWM for normal operation. PPWM means the NCV6357 will always operate in PPWM for the entire load range.", 4, "advanceViewSetting1Help")
    }

    Item {
        id: leftColumn
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/3

        Item {
            id: margins1
            anchors {
                fill: parent
                margins: 15
            }

            Rectangle {
                width : parent.width - 20
                height: parent.height
                anchors {
                    top: parent.top
                    topMargin: 20
                }

                Column {
                    anchors.fill: parent
                    spacing:  25
                    Rectangle {
                        id: enableSwitchContainer
                        width: parent.width
                        height: parent.height/5
                        anchors.horizontalCenter: parent.horizontalCenter
                        SGAlignedLabel {
                            id: enableSwitchLabel
                            target: enableSwitch
                            text: "Enable (3V3)"
                            alignment: SGAlignedLabel.SideLeftCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            SGSwitch {
                                id: enableSwitch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel:   "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"        // Default: "#0cf"
                                checked: platformInterface.enabled
                                onToggled : {
                                    if(checked){
                                        platformInterface.set_enable_3v3.update("on")
                                        if(platformInterface.reset_flag === true) {
                                            platformInterface.reset_status_indicator.update("reset")
                                            platformInterface.reset_indicator = SGStatusLight.Off
                                            platformInterface.reset_flag = false
                                        }
                                    }
                                    else{
                                        platformInterface.set_enable_3v3.update("off")
                                    }
                                    platformInterface.enabled = checked
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: peakcurrentContainer
                        width: parent.width
                        height: parent.height/5
                        anchors.horizontalCenter: parent.horizontalCenter
                        SGAlignedLabel {
                            id: peakCurrentLabel
                            target: peakCurrentCombo
                            text: "Set Inductor\nPeak Current"
                            horizontalAlignment: Text.AlignHCenter
                            alignment: SGAlignedLabel.SideLeftCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true

                            SGComboBox {
                                id: peakCurrentCombo
                                currentIndex: platformInterface.ipeak_state
                                model: [ "5.2A", "5.8A","6.2A", "6.8A" ]
                                borderColor: "black"
                                textColor: "black"          // Default: "black"
                                indicatorColor: "black"
                                onActivated: {
                                    platformInterface.set_ipeak_current.update(currentIndex)
                                    platformInterface.ipeak_state = currentIndex
                                }
                            }
                        }
                    }
/*
                    Rectangle {
                        id: inputVoltageMainsContainer
                        width: parent.width
                        height: parent.height/5
                        anchors.horizontalCenter: parent.horizontalCenter
                        SGAlignedLabel {
                            id: inputVoltageMainsLabel
                            target: inputVoltageMainsCombo
                            text: "Set Input\nMains Voltage"
                            horizontalAlignment: Text.AlignHCenter
                            alignment: SGAlignedLabel.SideLeftCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true

                            SGComboBox {
                                id: inputVoltageMainsCombo
                                currentIndex: platformInterface.vin_mains_state
                                model: [ "0.0V","0.5V","1.0V","1.5V","2.0V","2.5V","3.0V","3.5V","4.0V","4.5V","5.0V","5.5V","6.0V","6.5V","7.0V","7.5V","8.0V","8.5V","9.0V","9.5V","10.0V","10.5V","11.0V","11.5V","12.0V","12.5V","13.0V","13.5V","14.0V","14.5V","15.0V","15.5V","16.0V"]
                                borderColor: "green"
                                textColor: "black"          // Default: "black"
                                indicatorColor: "green"
                                onActivated: {
                                    platformInterface.set_vin_mains.update(currentIndex)
                                    platformInterface.vin_mains_state = currentIndex
                                }
                            }
                        }
                    }
  */
                    Rectangle {
                        width: parent.width
                        height: parent.height/5
                    }
                }
            }
        }
        Widget09.SGLayoutDivider {
            id: divider1
            position: "right"
        }
    }

    Rectangle {
        id: lastColumn
        anchors {
            left: leftColumn.right
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/1.5
        height: parent.height

        Item{
            id: margins3
            anchors {
                fill: parent
                margins: 15
            }

            Rectangle {
                id: vselContainer
                width: parent.width/2
                height: parent.height/5
                anchors {
                    top:parent.top
                    topMargin: 20
                    horizontalCenter: parent.horizontalCenter
                }
                SGAlignedLabel {
                    id: vselSwitchLabel
                    target: vselSwitch
                    text: "VSEL"
                    alignment: SGAlignedLabel.SideLeftCenter
                    anchors.centerIn: parent
                    fontSizeMultiplier: ratioCalc * 1.2
                    font.bold : true

                    SGSwitch {
                        id: vselSwitch
                        anchors.horizontalCenter: parent.horizontalCenter
                        checkedLabel: "On"
                        uncheckedLabel: "Off"
                        textColor: "black"              // Default: "black"
                        handleColor: "white"            // Default: "white"
                        grooveColor: "#ccc"             // Default: "#ccc"
                        grooveFillColor: "#0cf"         // Default: "#0cf"
                        checked: platformInterface.vsel_state
                        onToggled: {
                            platformInterface.vsel_state = checked
                            if(checked){
                                platformInterface.set_vselect.update("on")
                            }
                            else{
                                platformInterface.set_vselect.update("off")
                            }
                        }
                    }
                }
            }

            Row {
                spacing: 10
                anchors {
                    top : vselContainer.bottom
                    topMargin: 15
                    left: parent.left
                    leftMargin: 40
                    right: parent.right
                    rightMargin: 20
                }
                width: parent.width
                height: (parent.height - vselContainer.height)
                Rectangle {
                    id: outputvolcontainer
                    width: parent.width/2
                    height: parent.height - 50
                    color: "transparent"

                    Column {

                        anchors.fill: parent
                        spacing:  40
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        Rectangle {
                            width: parent.width
                            height: parent.height/5

                            SGAlignedLabel {
                                id: outputVol1Label
                                target: outputVolCombo
                                text: "Programmed Output \n Voltage 0"
                                horizontalAlignment: Text.AlignHCenter
                                font.bold : true
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                SGComboBox {
                                    id: outputVolCombo
                                    borderColor: "black"
                                    textColor: "black"
                                    indicatorColor: "black"
                                    currentIndex: platformInterface.output_voltage_selector0
                                    model: outputvoltage0
                                    onActivated: {
                                        platformInterface.set_prog_vselect0.update(currentIndex)
                                        platformInterface.output_voltage_selector0 = currentIndex
                                        console.log("dh",platformInterface.output_voltage_selector0)
                                        platformInterface.set_prog_vselect0.show()
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: parent.height/5
                            SGAlignedLabel {
                                id: outputVol2Label
                                target: outputVolCombo2
                                text: "Programmed Output \n Voltage 1"
                                horizontalAlignment: Text.AlignHCenter
                                font.bold : true
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                SGComboBox {
                                    id: outputVolCombo2
                                    currentIndex: platformInterface.output_voltage_selector1
                                    model: outputvoltage0
                                    borderColor: "black"
                                    textColor: "black"
                                    indicatorColor: "black"
                                    onActivated: {
                                        platformInterface.set_prog_vsel1.update(currentIndex)
                                        platformInterface.output_voltage_selector1 = currentIndex
                                        platformInterface.set_prog_vsel1.show()
                                    }
                                }
                            }
                        }
                    } // end of column
                } // first rec of the row
                Rectangle {
                    width: parent.width/2.5
                    height: parent.height - 50
                    color: "transparent"
                    Column {
                        id: dcdcModeContainer
                        anchors.fill: parent
                        spacing:  40
                        Rectangle {
                            width : parent.width
                            height: parent.height/5
                            color: "transparent"

                            SGAlignedLabel {
                                id: dcdcMode1Label
                                target: dcdcModeCombo
                                text: "DCDC Mode"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGComboBox {
                                    id: dcdcModeCombo
                                    currentIndex: platformInterface.dcdc_mode0
                                    model: ["Auto", "PPWM"]
                                    borderColor: "black"
                                    textColor: "black"          // Default: "black"
                                    indicatorColor: "black"
                                    onActivated: {
                                        if(currentIndex == 0) {
                                            platformInterface.ppwm_vsel0_mode.update("auto")
                                        }
                                        else {
                                            platformInterface.ppwm_vsel0_mode.update("forced_ppwm")
                                        }
                                        platformInterface.dcdc_mode0 = currentIndex
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width : parent.width
                            height: parent.height/5
                            SGAlignedLabel {
                                id: dcdcMode2Label
                                target: dcdcModeCombo2
                                text: "DCDC Mode"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGComboBox {
                                    id: dcdcModeCombo2
                                    currentIndex: platformInterface.dcdc_mode1
                                    model: ["Auto", "PPWM"]
                                    borderColor: "black"
                                    textColor: "black"          // Default: "black"
                                    indicatorColor: "black"
                                    onActivated: {
                                        if(currentIndex == 0) {
                                            platformInterface.ppwm_vsel1_mode.update("auto")
                                        }
                                        else {
                                            platformInterface.ppwm_vsel1_mode.update("forced_ppwm")
                                        }
                                        platformInterface.dcdc_mode1 = currentIndex
                                    }
                                }
                            }
                        }
                    }
                }
            } // end of row
        }

        Rectangle{
            height: 40
            width: 40
            color: "transparent"
            anchors {
                right: parent.right
                rightMargin: 6
                top: parent.top
                topMargin: 5
            }
            SGIcon {
                id: helpIcon

                source: "question-circle-solid.svg"
                iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
                sourceSize.height: 40
                visible: true
                anchors.fill: parent
                MouseArea {
                    id: helpMouse
                    anchors {
                        fill: helpIcon
                    }
                    onClicked: {
                        Help.startHelpTour("advanceViewSetting1Help")
                    }
                    hoverEnabled: true
                }
            }
        }

    }
}
