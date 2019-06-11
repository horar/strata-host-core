import QtQuick 2.7
import QtQuick.Layouts 1.3
//import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Controls 1.4
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/5A-switcher/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    height: 350
    width: parent.width

    property var outputvoltage0: []
    property bool check_enable_state: platformInterface.hide_enable
    onCheck_enable_stateChanged: {
        if(check_enable_state === true) {
            enableSwitch.enabled  = true
            enableSwitch.opacity = 1.0
        }
        else {
            enableSwitch.enabled  = false
            enableSwitch.opacity = 0.5
        }
    }

    property var read_enable_state: platformInterface.initial_status_0.enable_status
    onRead_enable_stateChanged: {
        if(read_enable_state === "on") {
            platformInterface.enabled = true
            platformInterface.intd_state = true
        }
        else  {
            platformInterface.enabled = false
            platformInterface.intd_state = false
        }
    }

    property var read_vsel_status: platformInterface.initial_status_0.vsel_status
    onRead_vsel_statusChanged: {
        if(read_vsel_status === "on") {
            platformInterface.vsel_state = true
            outputVolCombo.enabled = false
            outputVolCombo.opacity = 0.5
            dcdcModeCombo.enabled = false
            dcdcModeCombo.opacity = 0.5
            outputVolCombo2.enabled = true
            outputVolCombo2.opacity = 1.0
            dcdcModeCombo1.enabled = true
            dcdcModeCombo1.opacity = 1.0
        }
        else {
            platformInterface.vsel_state = false
            outputVolCombo.enabled = true
            outputVolCombo.opacity = 1.0
            dcdcModeCombo.enabled = true
            dcdcModeCombo.opacity = 1.0
            outputVolCombo2.enabled = false
            outputVolCombo2.opacity = 0.5
            dcdcModeCombo1.enabled = false
            dcdcModeCombo1.opacity = 0.5
        }
    }

    property var read_output_voltage0_status: platformInterface.initial_status_0.vout_vsel0_status
    onRead_output_voltage0_statusChanged: {
        platformInterface.output_voltage_selector0 = read_output_voltage0_status
    }
    property var read_output_voltage1_status: platformInterface.initial_status_0.vout_vsel1_status
    onRead_output_voltage1_statusChanged: {
        platformInterface.output_voltage_selector1 = read_output_voltage1_status
    }

    property var dcdc_mode0_status: platformInterface.initial_status_1.ppwmvsel0_mode_status
    onDcdc_mode0_statusChanged: {
        if(dcdc_mode0_status === "forced_ppwm"){
            platformInterface.dcdc_mode0 = 1
        }
        else {
            platformInterface.dcdc_mode0 = 0
        }
    }
    property var dcdc_mode1_status: platformInterface.initial_status_1.ppwmvsel1_mode_status
    onDcdc_mode1_statusChanged: {
        if(dcdc_mode1_status === "forced_ppwm"){
            platformInterface.dcdc_mode1 = 1
        }
        else {
            platformInterface.dcdc_mode1 = 0
        }
    }

    property var read_ipeak_state: platformInterface.initial_status_1.ipeak_status
    onRead_ipeak_stateChanged: {
        platformInterface.ipeak_state = read_ipeak_state
    }

    Component.onCompleted: {
        var value;
        for(var i = 0 ; i <= 127 ; ++i ) {
            value = (i * 6.25) + 600
            outputvoltage0.push(value + "mV")
        }
        outputVolCombo.model = outputvoltage0
        outputVolCombo2.model = outputvoltage0
        helpIcon.visible = true
        Help.registerTarget(enableSwitch, "Enable switch enables and disables the part.", 0, "advance5Asetting1Help")
        Help.registerTarget(peakCurrentCombo, "Set Inductor Peak Current dropdown menu will set the OCP level for the part.", 1 , "advance5Asetting1Help")
        Help.registerTarget(vselContainer, "The VSEL switch will switch the output voltage between the two default values of the part. In this case the two default values are 0.875V and 0.90625V.", 2, "advance5Asetting1Help")
        Help.registerTarget(outputvolcontainer, "Programmed Output Voltage dropdown menus will set the output voltage levels that the part will switch between. The box grayed out will be the voltage that is currently at the output.", 3, "advance5Asetting1Help")
        Help.registerTarget(dcdcModeContainer, "DCDC mode dropdown menus will set the DCDC mode the part is operating in. Auto mode means the part will switch between PFM for light loads and PPWM for normal operation. Forced PPWM means the part will always operate in PPWM for the entore load range.", 4, "advance5Asetting1Help")
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
                id: pageText
                width : parent.width
                height: parent.height/9
                Text {
                    id: pageLabel
                    text: "<b>DC-DC Settings</b>"
                    font {
                        pixelSize: 16
                    }
                }
            }

            Rectangle {
                width : parent.width - 20
                height: parent.height
                anchors {
                    top: parent.top
                    topMargin: 45
                }

                Column {

                    anchors.fill: parent
                    spacing:  20
                    Rectangle {
                        width: parent.width
                        height: parent.height/5

                        SGSwitch {
                            id: enableSwitch
                            anchors.horizontalCenter: parent.horizontalCenter
                            label : "Enable"
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            switchWidth: 85           // Default: 52 (change for long custom checkedLabels when labelsInside)
                            switchHeight: 26               // Default: 26
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            checked: platformInterface.enabled
                            fontSizeLabel: (parent.width + parent.height)/22
                            onCheckedChanged: {
                                if(checked) {
                                    platformInterface.intd_state = true
                                }
                                else {
                                    platformInterface.intd_state = false
                                }
                            }

                            onToggled : {
                                if(checked){
                                    platformInterface.set_enable.update("on")
                                    platformInterface.intd_state = true
                                    if(platformInterface.reset_flag === true) {
                                        platformInterface.reset_status_indicator.update("reset")
                                        platformInterface.reset_indicator = "off"
                                        platformInterface.reset_flag = false
                                    }
                                }
                                else{
                                    platformInterface.set_enable.update("off")
                                    platformInterface.intd_state = false
                                }
                                platformInterface.enabled = checked
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: parent.height/5

                        SGComboBox {
                            id: peakCurrentCombo
                            currentIndex: platformInterface.ipeak_state
                            fontSize: (parent.width + parent.height)/22
                            label :"Set Inductor\nPeak Current"
                            model: [ "7.0A (Iout = 5.3A)", "7.7A (Iout = 5.8A)","8.2A (Iout = 6.3A)", "8.8A (Iout = 6.8A)" ]
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                            }
                            comboBoxWidth: parent.width/2
                            comboBoxHeight: parent.height/2
                            onActivated: {
                                platformInterface.set_ipeak_current.update(currentIndex)
                                platformInterface.ipeak_state = currentIndex
                                platformInterface.set_ipeak_current.show()
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
                    topMargin: 40
                    horizontalCenter: parent.horizontalCenter
                }

                SGSwitch {
                    id: vselSwitch
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }

                    label : "VSEL"
                    checkedLabel: "On"
                    uncheckedLabel: "Off"
                    switchWidth: 85         // Default: 52 (change for long custom checkedLabels when labelsInside)
                    switchHeight: 26             // Default: 26
                    textColor: "black"              // Default: "black"
                    handleColor: "white"            // Default: "white"
                    grooveColor: "#ccc"             // Default: "#ccc"
                    grooveFillColor: "#0cf"         // Default: "#0cf"
                    fontSizeLabel: (parent.width + parent.height)/25
                    checked: platformInterface.vsel_state

                    onToggled: {
                        platformInterface.vsel_state = checked
                        if(checked){
                            platformInterface.set_vselect.update("on")
                            outputVolCombo.enabled = false
                            outputVolCombo.opacity = 0.5
                            dcdcModeCombo.enabled = false
                            dcdcModeCombo.opacity = 0.5
                            outputVolCombo2.enabled = true
                            outputVolCombo2.opacity = 1.0
                            dcdcModeCombo1.enabled = true
                            dcdcModeCombo1.opacity = 1.0
                        }
                        else{
                            platformInterface.set_vselect.update("off")
                            outputVolCombo.enabled = true
                            outputVolCombo.opacity = 1.0
                            dcdcModeCombo.enabled = true
                            dcdcModeCombo.opacity = 1.0
                            outputVolCombo2.enabled = false
                            outputVolCombo2.opacity = 0.5
                            dcdcModeCombo1.enabled = false
                            dcdcModeCombo1.opacity = 0.5
                        }
                    }
                }
            }

            Row {
                spacing: 5
                anchors {
                    top : vselContainer.bottom
                    topMargin: 15
                }
                width: parent.width
                height: parent.height - vselContainer.height
                Rectangle {
                    width: parent.width/1.6
                    height: parent.height

                    Column {
                        id: outputvolcontainer
                        anchors.fill: parent
                        spacing:  20
                        Rectangle {
                            width: parent.width
                            height: parent.height/5
                            SGComboBox {
                                id: outputVolCombo
                                currentIndex: platformInterface.output_voltage_selector0
                                fontSize: (parent.width + parent.height)/25
                                label : "Programmed Output Voltage 0"
                                model: outputvoltage0
                                comboBoxWidth: parent.width/4
                                comboBoxHeight: parent.height/2
                                onActivated: {
                                    platformInterface.vselect_prog0.update(currentIndex)
                                    platformInterface.output_voltage_selector0 = currentIndex
                                    platformInterface.vselect_prog0.show()
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: parent.height/5
                            SGComboBox {
                                id: outputVolCombo2
                                currentIndex: platformInterface.output_voltage_selector1
                                fontSize: (parent.width + parent.height)/25
                                label : "Programmed Output Voltage 1"
                                model: outputvoltage0
                                comboBoxWidth: parent.width/4
                                comboBoxHeight: parent.height/2
                                onActivated: {
                                    platformInterface.vselect_prog1.update(currentIndex)
                                    platformInterface.output_voltage_selector1 = currentIndex
                                    platformInterface.vselect_prog1.show()
                                }
                            }
                        }

                    } // end of column
                } // first rec of the row
                Rectangle {
                    width: parent.width/2
                    height: parent.height
                    Column {
                        id: dcdcModeContainer
                        anchors.fill: parent
                        spacing:  10
                        Rectangle {
                            width : parent.width
                            height: parent.height/5

                            SGComboBox {
                                id: dcdcModeCombo
                                currentIndex: platformInterface.dcdc_mode0
                                fontSize: (parent.width + parent.height)/25
                                label : "DCDC Mode"
                                model: [
                                    "Auto", "PPWM"
                                ]
                                onActivated: {
                                    if(currentIndex == 0) {
                                        platformInterface.ppwm_vsel0_mode.update("auto")
                                    }
                                    else {
                                        platformInterface.ppwm_vsel0_mode.update("forced_ppwm")
                                    }
                                    platformInterface.dcdc_mode0 = currentIndex
                                }
                                comboBoxWidth: parent.width/3
                                comboBoxHeight: parent.height/2
                            }
                        }
                        Rectangle {
                            width : parent.width
                            height: parent.height/5

                            SGComboBox {
                                id: dcdcModeCombo1
                                currentIndex: platformInterface.dcdc_mode1
                                fontSize: (parent.width + parent.height)/25
                                label : "DCDC Mode"
                                model: [
                                    "Auto", "PPWM"
                                ]
                                comboBoxWidth: parent.width/3
                                comboBoxHeight: parent.height/2
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
            } // end of row

            SGIcon {
                id: helpIcon
                anchors {
                    right: parent.right
                    rightMargin: 10
                    top: parent.top
                }
                source: "question-circle-solid.svg"
                iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
                sourceSize.height: 40
                visible: true

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
