import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Controls 1.4
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/5A-switcher/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help
import Fonts 1.0

Item {
    id: root
    height: 350
    width: parent.width
    anchors {
        left: parent.left
    }

    property bool ppwm_button_state
    property bool auto_button_state

    property var read_dvs_speed_state: platformInterface.initial_status_0.dvs_speed_status
    onRead_dvs_speed_stateChanged: {
        platformInterface.dvs_speed_state = read_dvs_speed_state
    }

    property var read_delay_enable_state: platformInterface.initial_status_0.delay_enable_status
    onRead_delay_enable_stateChanged: {
        platformInterface.delay_enable_state = read_delay_enable_state
    }

    property var read_thermal_pre_warn_state: platformInterface.initial_status_1.thermal_pre_status
    onRead_thermal_pre_warn_stateChanged: {
        platformInterface.thermal_prewarn_state = read_thermal_pre_warn_state
    }

    property var read_sleep_mode_state: platformInterface.initial_status_1.sleep_mode_status
    onRead_sleep_mode_stateChanged: {
        if(read_sleep_mode_state === "on") {
            platformInterface.sleep_mode_state = true
        }
        else  {
            platformInterface.sleep_mode_state = false
        }
    }

    property var read_active_discharge_state: platformInterface.initial_status_0.active_discharge_status
    onRead_active_discharge_stateChanged: {
        if(read_active_discharge_state === "on") {
            platformInterface.active_discharge_state = true
        }
        else  {
            platformInterface.active_discharge_state = false
        }
    }

    property var read_dvs_mode_state: platformInterface.initial_status_1.dvs_mode_status
    onRead_dvs_mode_stateChanged:
    {
        if(read_dvs_mode_state === "forced_ppwm") {
            ppwm_button_state = true
            auto_button_state = false
        }
        else if(read_dvs_mode_state === "auto") {
            auto_button_state = true
            ppwm_button_state = false
        }

    }

    Component.onCompleted: {
        helpIcon.visible = true
        Help.registerTarget(dvsSpeedContainer,"DVS speed sets the slew rate of the regulator when switching between voltages.", 0, "advance5Asetting2Help")
        Help.registerTarget(delayenableContainer, "Delay Upon Enabled sets the delay time between the enable signal and the part regulating to an output voltage.", 1 , "advance5Asetting2Help")
        Help.registerTarget(thresholdContainer, "Thermal pre-warning dropdown menu will select the temperature that the part will give a thermal pre-warning interrupt at.", 2, "advance5Asetting2Help")
        Help.registerTarget(dvsButtonContainer, "DVS Mode selects the mode the part is in when switching between voltages.", 3, "advance5Asetting2Help")
        Help.registerTarget(sleepModeSwitch, "Sleep mode switch will set if the part goes into sleep mode when disabled.", 4, "advance5Asetting2Help")
        Help.registerTarget(activeDischargeSwitch, "Active discharge path switch will turn on/off the active discharge capabilities of the part. ", 5, "advance5Asetting2Help")

    }

    Item {
        id: leftColumn
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/2
        height: parent.height

        Item {
            id: margins1
            anchors {
                fill: parent
                margins: 15
            }

            Rectangle {
                id: timeAndwarning
                width : parent.width/1.1
                height: parent.height/1.3
                color: "transparent"
                border.color: "black"
                border.width: 3
                radius: 10
                anchors {
                    centerIn: parent
                }

                Rectangle {
                    id: dvsSpeedContainer
                    width : parent.width - 30
                    height: parent.height/4
                    anchors {
                        top: parent.top
                        topMargin: 40
                        horizontalCenter: parent.horizontalCenter
                    }

                    SGComboBox {
                        id: dvsSpeedCombo
                        currentIndex: platformInterface.dvs_speed_state
                        fontSize: (parent.width + parent.height)/26
                        label : "DVS Speed"
                        model: [
                            "6.25mV step / 0.333uS", "6.25mV step / 0.666uS", "6.25mV step / 1.333uS",
                            "6.25mV step / 2.666uS"
                        ]
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            horizontalCenterOffset: (thresholdCombo.width - width)/2

                        }
                        comboBoxWidth: parent.width/2
                        comboBoxHeight: parent.height/2
                        onActivated: {
                            platformInterface.set_dvs_speed.update(currentIndex)
                            platformInterface.dvs_speed_state = currentIndex
                        }
                    }
                }

                Rectangle {
                    id: delayenableContainer
                    width : parent.width - 30
                    height: parent.height/4
                    anchors {
                        top: dvsSpeedContainer.bottom
                        topMargin: 5
                        horizontalCenter: parent.horizontalCenter
                    }

                    SGComboBox {
                        id:  delayEnableCombo
                        currentIndex: platformInterface.delay_enable_state
                        fontSize: (parent.width + parent.height)/26
                        label : "Delay upon Enabled"
                        model: [ "0mS", "2mS", "4mS", "6mS", "8mS", "10mS", "12mS", "14mS"]
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            horizontalCenterOffset: (thresholdCombo.width - width)/2
                        }
                        comboBoxWidth: parent.width/2
                        comboBoxHeight: parent.height/2
                        onActivated: {
                            platformInterface.set_delay_on_enable.update(currentIndex)
                            platformInterface.delay_enable_state = currentIndex
                        }

                    }

                }

                Rectangle {
                    id: thresholdContainer
                    width : parent.width - 30
                    height: parent.height/4

                    anchors {
                        top: delayenableContainer.bottom
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                    }

                    SGComboBox {
                        id: thresholdCombo
                        currentIndex: platformInterface.thermal_prewarn_state
                        fontSize: (parent.width + parent.height)/26
                        label : "Thermal pre-warning"+"\n"+ "Threshold"
                        model: [ "83˚c","94˚c", "105˚c", "116˚c" ]
                        anchors.horizontalCenter: parent.horizontalCenter
                        comboBoxWidth: parent.width/2
                        comboBoxHeight: parent.height/2
                        onActivated: {
                            platformInterface.set_thermal_threshold.update(currentIndex)
                            platformInterface.thermal_prewarn_state = currentIndex
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
        id: lastColumn
        anchors {
            left: leftColumn.right
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/2
        height: parent.height

        Item {
            id: margins2
            anchors {
                fill: parent
                margins: 15
            }

            Rectangle {

                width : parent.width/1.1
                height: parent.height/1.3
                color: "transparent"
                border.color: "black"
                border.width: 3
                radius: 10
                anchors {
                    centerIn: parent
                }

                SGRadioButtonContainer {
                    id: dvsButtonContainer
                    // Optional configuration:
                    fontSize: (parent.width+parent.height)/35
                    label: "DVS Mode:" // Default: "" (will not appear if not entered)
                    labelLeft: true         // Default: true
                    textColor: "black"      // Default: "#000000"  (black)
                    radioColor: "black"     // Default: "#000000"  (black)
                    exclusive: true         // Default: true

                    anchors {
                        top: parent.top
                        topMargin:  40
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset: -(activeDischargeSwitch.width - width)/2
                    }

                    radioGroup: GridLayout {
                        columnSpacing: 10
                        rowSpacing: 10

                        property int fontSize: (parent.width+parent.height)/8
                        SGRadioButton {
                            id: auto
                            text: "Auto"
                            checked: auto_button_state

                            onClicked: {
                                platformInterface.dvs_mode.update("auto")
                                platformInterface.dvs_mode.show()
                            }
                        }

                        SGRadioButton {
                            id: ppwm
                            text: "PPWM"
                            checked: ppwm_button_state

                            onClicked: {
                                platformInterface.dvs_mode.update("forced_ppwm")
                                platformInterface.dvs_mode.show()
                            }

                        }
                    }
                }


                SGSwitch {
                    id: sleepModeSwitch
                    label : "Sleep Mode"
                    checkedLabel: "On"
                    uncheckedLabel: "Off"
                    switchWidth: 85       // Default: 52 (change for long custom checkedLabels when labelsInside)
                    switchHeight: 26               // Default: 26
                    textColor: "black"              // Default: "black"
                    handleColor: "white"            // Default: "white"
                    grooveColor: "#ccc"             // Default: "#ccc"
                    grooveFillColor: "#0cf"         // Default: "#0cf"

                    fontSizeLabel: (parent.width + parent.height)/35
                    anchors {
                        top: dvsButtonContainer.bottom
                        topMargin : 30
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset: -(activeDischargeSwitch.width - width)/2
                    }

                    checked: platformInterface.sleep_mode_state
                    onToggled : {
                        platformInterface.sleep_mode_state = checked
                        if(checked){
                            platformInterface.sleep_mode.update("on")
                            platformInterface.sleep_mode.show()
                        }
                        else{
                            platformInterface.sleep_mode.update("off")
                            platformInterface.sleep_mode.show()
                        }
                    }
                }


                SGSwitch {
                    id: activeDischargeSwitch
                    label : "Active Discharge Path"
                    checkedLabel: "Enable"
                    uncheckedLabel: "Disable"
                    switchWidth: 85     // Default: 52 (change for long custom checkedLabels when labelsInside)
                    switchHeight: 26               // Default: 26
                    textColor: "black"              // Default: "black"
                    handleColor: "white"            // Default: "white"
                    grooveColor: "#ccc"             // Default: "#ccc"
                    grooveFillColor: "#0cf"         // Default: "#0cf"

                    anchors {
                        top: sleepModeSwitch.bottom
                        topMargin : 30
                        horizontalCenter: parent.horizontalCenter

                    }
                    fontSizeLabel: (parent.width + parent.height)/35

                    checked: platformInterface.active_discharge_state
                    onToggled : {
                        if(checked){
                            platformInterface.active_discharge.update("on")
                            platformInterface.active_discharge.show()
                        }
                        else{
                            platformInterface.active_discharge.update("off")
                            platformInterface.active_discharge.show()
                        }
                        platformInterface.active_discharge_state = checked
                    }
                }
            }

            Text {
                id: helpIcon
                anchors {
                    right: parent.right
                    rightMargin: 7
                    top: parent.top

                }
                text: "\ue808"
                color: helpMouse.containsMouse ? "lightgrey" : "grey"
                font {
                    family: Fonts.sgicons
                    pixelSize: 40
                }
                visible: true

                MouseArea {
                    id: helpMouse
                    anchors {
                        fill: helpIcon
                    }
                    onClicked: {
                        Help.startHelpTour("advance5Asetting2Help")
                    }
                    hoverEnabled: true
                }
            }
        }

    }

}
