import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 0.9 as Widget09
import tech.strata.sgwidgets 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help


Item {
    id: root
    height: 350
    width: parent.width
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    anchors {
        left: parent.left
    }

    property bool ppwm_button_state
    property bool auto_button_state

    property var read_dvs_speed_state: platformInterface.initial_status_1.dvs_speed_status
    onRead_dvs_speed_stateChanged: {
        platformInterface.dvs_speed_state = read_dvs_speed_state
    }

    property var read_delay_enable_state: platformInterface.initial_status_1.delay_enable_status
    onRead_delay_enable_stateChanged: {
        platformInterface.delay_enable_state = read_delay_enable_state
    }

    property var read_thermal_pre_warn_state: platformInterface.initial_status_1.thermal_pre_status
    onRead_thermal_pre_warn_stateChanged: {
        platformInterface.thermal_prewarn_state = read_thermal_pre_warn_state
        thresholdCombo.currentIndex = read_thermal_pre_warn_state
    }

    property var read_sleep_mode_state: platformInterface.initial_status_1.sleep_mode_status
    onRead_sleep_mode_stateChanged: {
        platformInterface.sleep_mode_state = (read_sleep_mode_state === "on") ? true : false
    }

    property var read_active_discharge_state: platformInterface.initial_status_0.active_discharge_status
    onRead_active_discharge_stateChanged: {
        platformInterface.active_discharge_state = (read_active_discharge_state === "on") ? true : false
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

    property var read_pgood_status : platformInterface.initial_status_0.pgood_enable_status
    onRead_pgood_statusChanged: {
        platformInterface.pgood_enable_status = (read_pgood_status === "on") ? true : false
    }

    property var read_pgood_enable : platformInterface.initial_status_0.dvs_pgood_enable_status
    onRead_pgood_enableChanged: {
        platformInterface.pgood_enable = (read_pgood_enable === "on") ? true : false
    }

    property var reset_timeout_pgood: platformInterface.initial_status_0.reset_timeout_pgood_status
    onReset_timeout_pgoodChanged: {
        platformInterface.timeout_status = reset_timeout_pgood
        thresholdCombo.currentIndex = reset_timeout_pgood
    }

    Component.onCompleted: {
        helpIcon.visible = true
        Help.registerTarget(dvsSpeedContainer,"DVS Speed sets the slew rate of the output voltage when switching between voltages. This can be on startup or when using the VSEL switch.", 0, "advance5Asetting2Help")
        Help.registerTarget(delayenableContainer, "Delay Upon Enable will set the delay time between the enable signal and the output voltage rising.", 1 , "advance5Asetting2Help")
        Help.registerTarget(thresholdContainer, "Thermal Pre-Warning Threshold dropdown menu selects the temperature at which NCV6357 will give a pre-warning thermal interrupt.", 2, "advance5Asetting2Help")
        Help.registerTarget(dvsButtonContainer, "DVS Mode will determine the mode the regulator switches in while switching in between output voltages. This control only applies when switching to a programmed voltage that is in DCDC mode of Auto. When switching to a programmed voltage set to DCDC mode of PPWM, the DVS sequence will be in PPWM even if this DVS setting is set to Auto. When switching to a programmed voltage with DCDC mode of Auto and this DVS mode is set to PPWM, the DVS sequence will be PPWM.", 3, "advance5Asetting2Help")
        Help.registerTarget(sleepMode, "Sleep Mode enabled will mean when the NCV6357 is disabled it will be put into sleep mode rather than being turned off. The NCV6357 will start up faster from sleep mode than it will from being completely off.", 4, "advance5Asetting2Help")
        Help.registerTarget(activeDischarge, "Active Discharge Path enabled will actively discharge the output voltage when the part is disabled.", 5, "advance5Asetting2Help")
        Help.registerTarget(powerGoodSwitchContainer, "PGOOD enabled will enable the PGOOD pin of the part, meaning the PGOOD signal will go high when output voltage is 93% of the programmed output voltage. Further settings can be programmed using PGOOD Active on DVS and Reset Timeout for PGOOD.", 6, "advance5Asetting2Help")
        Help.registerTarget(powerGoodSwitchDVContainer, "Power Good Active on DVS enabled means the PGOOD signal will be low when the NCV6357 is switching between the two programmed output voltages and will go high once the output voltage transition is complete.", 7, "advance5Asetting2Help")
        Help.registerTarget(resetTimeoutContainer, "Reset Timeout for Power Good allows the user to add a delay in the rise of the PGOOD signal from where the PGOOD signal is supposed to rise.", 8, "advance5Asetting2Help")
    }

    Item {
        id: leftColumn
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/3
        height: parent.height

        Item {
            id: margins1
            anchors {
                fill: parent
                margins: 15
            }
            Rectangle {
                id: timeAndwarning
                width : parent.width/1.09
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
                    width : parent.width - 40
                    height: parent.height/4
                    anchors {
                        top: parent.top
                        topMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                    SGAlignedLabel {
                        id: dvsSpeedLabel
                        target: dvsSpeedCombo
                        text: "DVS\nSpeed"
                        horizontalAlignment: Text.AlignHCenter
                        font.bold : true
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2

                        SGComboBox {
                            id: dvsSpeedCombo
                            currentIndex: platformInterface.dvs_speed_state
                            model: [
                                "6.25mV step / 0.333us", "6.25mV step / 0.666us", "6.25mV step / 1.333us",
                                "6.25mV step / 2.666us"
                            ]
                            borderColor: "black"
                            textColor: "black"          // Default: "black"
                            indicatorColor: "black"
                            onActivated: {
                                platformInterface.set_dvs_speed.update(currentIndex)
                                platformInterface.dvs_speed_state = currentIndex
                            }
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
                    SGAlignedLabel {
                        id: delayEnableLabel
                        target: delayEnableCombo
                        text: "Delay Upon \n Enabled"
                        horizontalAlignment: Text.AlignHCenter
                        font.bold : true
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        SGComboBox {
                            id:  delayEnableCombo
                            currentIndex: platformInterface.delay_enable_state
                            borderColor: "black"
                            textColor: "black"          // Default: "black"
                            indicatorColor: "black"
                            model: [ "0 ms", "2 ms", "4 ms", "6 ms", "8 ms", "10 ms", "12 ms", "14 ms"]
                            onActivated: {
                                platformInterface.set_delay_on_enable.update(currentIndex)
                                platformInterface.delay_enable_state = currentIndex
                            }
                        }
                    }
                }

                Rectangle {
                    id: thresholdContainer
                    width : parent.width - 30
                    height: parent.height/4

                    anchors {
                        top: delayenableContainer.bottom
                        bottom: parent.bottom
                        bottomMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                    SGAlignedLabel {
                        id: thresholdLabel
                        target: thresholdCombo
                        text:  "Thermal Pre-Warning \n Threshold"
                        horizontalAlignment: Text.AlignHCenter
                        font.bold : true
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        SGComboBox {
                            id: thresholdCombo
                            borderColor: "black"
                            textColor: "black"          // Default: "black"
                            indicatorColor: "black"
                            currentIndex: platformInterface.thermal_prewarn_state
                            model: [ "83˚C","94˚C", "105˚C", "116˚C" ]
                            onActivated: {
                                platformInterface.set_thermal_threshold.update(currentIndex)
                                platformInterface.thermal_prewarn_state = currentIndex
                            }
                        }
                    }
                }
            }
        }
        Widget09.SGLayoutDivider {
            id: divider
            position: "right"
        }
    }

    Item {
        id: middleColumn
        anchors {
            left: leftColumn.right
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/3
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

                Rectangle {
                    id: buttonContainer
                    width : parent.width - 30
                    height: parent.height/4
                    anchors {
                        top: parent.top
                        topMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }

                    SGAlignedLabel {
                        id: dvsButtonLabel
                        target: dvsButtonContainer
                        text: "DVS Mode"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGRadioButtonContainer {
                            id: dvsButtonContainer
                            columnSpacing: 10
                            rowSpacing: 10

                            SGRadioButton {
                                id: auto
                                text: "Auto"
                                checked: auto_button_state
                                onCheckedChanged: {
                                    if(checked){
                                        platformInterface.dvs_mode.update("auto")
                                    }
                                }
                            }

                            SGRadioButton {
                                id: ppwm
                                text: "PPWM"
                                checked: ppwm_button_state

                                onCheckedChanged: {
                                    if(checked) {
                                        platformInterface.dvs_mode.update("forced_ppwm")
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle{
                    id: sleepMode
                    width : parent.width - 30
                    height: parent.height/4
                    anchors {
                        top: buttonContainer.bottom
                        horizontalCenter: parent.horizontalCenter
                    }

                    SGAlignedLabel {
                        id:  sleepModeLabel
                        target: sleepModeSwitch
                        text: "Sleep Mode"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: sleepModeSwitch
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            anchors {
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
                    }
                }
                Rectangle{
                    id: activeDischarge
                    width : parent.width - 30
                    height: parent.height/4
                    anchors {
                        top: sleepMode.bottom
                        bottom: parent.bottom
                        bottomMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                    SGAlignedLabel {
                        id:  activeDischargeLabel
                        target: activeDischargeSwitch
                        text: "Active Discharge Path"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: activeDischargeSwitch
                            checkedLabel: "Enable"
                            uncheckedLabel: "Disable"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
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
                }
            }
        }

        Widget09.SGLayoutDivider {
            id: divider2
            position: "right"
        }
    }

    Item {

        id: lastColumn
        anchors {
            left: middleColumn.right
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/3
        height: parent.height

        Item {
            id: margins3
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
                Rectangle {
                    id: powerGoodSwitchContainer
                    width : parent.width - 30
                    height: parent.height/4
                    anchors {
                        top: parent.top
                        topMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                    SGAlignedLabel {
                        id: powerGoodLabel
                        target: powerGoodSwitch
                        text: "Power Good"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        SGSwitch {
                            id: powerGoodSwitch
                            checkedLabel: "Enable"
                            uncheckedLabel: "Disable"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            checked: platformInterface.pgood_enable_status
                            onToggled : {
                                platformInterface.pgood_enable_status = checked
                                if(checked){
                                    platformInterface.set_pgood_enable.update("on")
                                    platformInterface.set_pgood_enable.show()
                                }
                                else{
                                    platformInterface.set_pgood_enable.update("off")
                                    platformInterface.set_pgood_enable.show()
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    id: powerGoodSwitchDVContainer
                    width : parent.width - 30
                    height: parent.height/4
                    anchors {
                        top: powerGoodSwitchContainer.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    SGAlignedLabel {
                        id: powerGoodDVSLabel
                        target: powerGoodDVSwitch
                        text: "Power Good Active \n on DVS"
                        horizontalAlignment: Text.AlignHCenter
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        SGSwitch {
                            id: powerGoodDVSwitch
                            checkedLabel: "Enable"
                            uncheckedLabel: "Disable"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            checked: platformInterface.pgood_enable
                            onToggled : {
                                platformInterface.pgood_enable = checked
                                if(checked){
                                    platformInterface.set_pgood_on_dvs.update("on")
                                    platformInterface.set_pgood_on_dvs.show()
                                }
                                else{
                                    platformInterface.set_pgood_on_dvs.update("off")
                                    platformInterface.set_pgood_on_dvs.show()
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    id: resetTimeoutContainer
                    width : parent.width - 30
                    height: parent.height/4
                    anchors {
                        top: powerGoodSwitchDVContainer.bottom
                        bottom: parent.bottom
                        bottomMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                    color: "transparent"
                    SGAlignedLabel {
                        id: resetTimeoutLabel
                        target: resetTimeoutCombo
                        text:  "Reset Timeout For\nPower Good"
                        horizontalAlignment: Text.AlignHCenter
                        font.bold : true
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        SGComboBox {
                            id: resetTimeoutCombo
                            borderColor: "black"
                            textColor: "black"          // Default: "black"
                            indicatorColor: "black"
                            currentIndex: platformInterface.timeout_status
                            model: [ "0 ms","8 ms", "32 ms", "64 ms" ]
                            onActivated: {
                                platformInterface.set_timeout_reset_pgood.update(currentIndex)
                                platformInterface.timeout_status = currentIndex
                            }
                        }
                    }
                }
            }
        }
    }
    Rectangle {
        width: 40
        height: 40
        anchors {
            right: parent.right
            rightMargin: 6
            top: parent.top
            topMargin: 10
        }
        SGIcon {
            id: helpIcon
            anchors.fill: parent
            source: "question-circle-solid.svg"
            iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
            sourceSize.height: 40
            visible: true

            MouseArea {
                id: helpMouse
                anchors.fill: helpIcon
                onClicked:Help.startHelpTour("advance5Asetting2Help")
                hoverEnabled: true
            }
        }
    }
}
