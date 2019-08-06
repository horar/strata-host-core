import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import "qrc:/js/navigation_control.js" as NavigationControl
import tech.strata.sgwidgets 0.9
import tech.strata.sgwidgets 1.0 as Widget10
import "qrc:/js/help_layout_manager.js" as Help
//import "content-views/content-widgets"

Item {
    id: root
    height: 200
    width: parent.width
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    property var reset_indicator_status: platformInterface.power_cycle_status.reset

    property var outputvoltage0: ["600 mV"]
    property var check_enable_state: platformInterface.hide_enable
    onCheck_enable_stateChanged: {
        console.log("advance enable")
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

    Component.onCompleted: {
        var value;
        for(var i = 0 ; i <= 216 ; ++i ) {
            value = (i * 12.5) + 600
            outputvoltage0.push(value + "mV")
        }
        outputVolCombo.model = outputvoltage0
        outputVolCombo2.model = outputvoltage0
        helpIcon.visible = true
        Help.registerTarget(enableSwitchContainer, "Enable switch enables and disables NCV6357.", 0, "advance5Asetting1Help")
        Help.registerTarget(peakcurrentContainer, "Set Inductor Peak Current dropdown menu will set the OCP level for NCV6357.", 1 , "advance5Asetting1Help")
        Help.registerTarget(vselContainer, "The VSEL switch will switch the output voltage between the two values stored in VoutVSEL register. The default values are 0.900V and 1.000V.", 2, "advance5Asetting1Help")
        Help.registerTarget(outputvolcontainer, "Programmed Output Voltage dropdown menus will select between various output voltage levels (600mV to 3.3V in steps of 6.25mV). Dropdown box will be disabled based on VSEL switch setting.", 3, "advance5Asetting1Help")
        Help.registerTarget(dcdcModeContainer, "DCDC mode dropdown menus will set between following operating modes forced PPWM and auto mode. In Auto mode NCV6357 will switch between PFM for light loads and PPWM for normal operation. In Forced PPWM mode NCV6357 will always operate in PPWM for the entore load range.", 4, "advance5Asetting1Help")
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
                    topMargin: 25
                }

                Column {
                    anchors.fill: parent
                    spacing:  40
                    Rectangle {
                        id: enableSwitchContainer
                        width: parent.width
                        height: parent.height/5
                        anchors.horizontalCenter: parent.horizontalCenter
                        Widget10.SGAlignedLabel {
                            id: enableSwitchLabel
                            target: enableSwitch
                            text: "Enable (EN)"
                            alignment: Widget10.SGAlignedLabel.SideLeftCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            Widget10.SGSwitch {
                                id: enableSwitch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel:   "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"        // Default: "#0cf"
                                checked: platformInterface.enabled
                                //fontSizeLabel: (parent.width + parent.height)/22
                                onCheckedChanged: {
                                    platformInterface.intd_state = (checked) ? true : false
                                }

                                onToggled : {
                                    if(checked){
                                        platformInterface.set_enable.update("on")
                                        if(platformInterface.reset_flag === true) {
                                            platformInterface.reset_status_indicator.update("reset")
                                            platformInterface.reset_indicator = Widget10.SGStatusLight.Off
                                            platformInterface.reset_flag = false
                                        }
                                    }
                                    else{
                                        platformInterface.set_enable.update("off")
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
                        Widget10.SGAlignedLabel {
                            id: peakCurrentLabel
                            target: peakCurrentCombo
                            text: "Set Inductor\nPeak Current"
                            horizontalAlignment: Text.AlignHCenter
                            alignment: Widget10.SGAlignedLabel.SideLeftCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true

                            Widget10.SGComboBox {
                                id: peakCurrentCombo
                                currentIndex: platformInterface.ipeak_state
                                model: [ "5.2A(Iout = 3.5A)", "5.8A(Iout = 4.0A)","6.2A(Iout = 4.5A)", "6.8A(Iout = 5.0A)" ]
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

                    Rectangle {
                        width: parent.width
                        height: parent.height/5
                    }
                }
            }
        }
        SGLayoutDivider {
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
                    topMargin: 25
                    horizontalCenter: parent.horizontalCenter
                }
                Widget10.SGAlignedLabel {
                    id: vselSwitchLabel
                    target: vselSwitch
                    text: "VSEL"
                    alignment: Widget10.SGAlignedLabel.SideLeftCenter
                    anchors.centerIn: parent
                    fontSizeMultiplier: ratioCalc * 1.2
                    font.bold : true

                    Widget10.SGSwitch {
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

                            Widget10.SGAlignedLabel {
                                id: outputVol1Label
                                target: outputVolCombo
                                text: "Programmed Output \n Voltage 0"
                                horizontalAlignment: Text.AlignHCenter
                                font.bold : true
                                alignment: Widget10.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                Widget10.SGComboBox {
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
                            Widget10.SGAlignedLabel {
                                id: outputVol2Label
                                target: outputVolCombo2
                                text: "Programmed Output \n Voltage 1"
                                horizontalAlignment: Text.AlignHCenter
                                font.bold : true
                                alignment: Widget10.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                Widget10.SGComboBox {
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

                            Widget10.SGAlignedLabel {
                                id: dcdcMode1Label
                                target: dcdcModeCombo
                                text: "DCDC Mode"
                                alignment: Widget10.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                Widget10.SGComboBox {
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
                            Widget10.SGAlignedLabel {
                                id: dcdcMode2Label
                                target: dcdcModeCombo2
                                text: "DCDC Mode"
                                alignment: Widget10.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                Widget10.SGComboBox {
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
                        Help.startHelpTour("advance5Asetting1Help")
                    }
                    hoverEnabled: true
                }
            }
        }

    }
}
