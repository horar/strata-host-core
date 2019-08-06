import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 0.9
import tech.strata.sgwidgets 1.0 as Widget10
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
        Help.registerTarget(dvsSpeedContainer,"DVS speed sets the slew rate of the regulator when switching between voltages.", 0, "advance5Asetting2Help")
        Help.registerTarget(delayenableContainer, "Delay Upon Enabled sets programmable delay time between the enable signal and NCV6357 regulating to an output voltage.", 1 , "advance5Asetting2Help")
        Help.registerTarget(thresholdContainer, "Thermal pre-warning dropdown menu will select thermal pre-warning threshold for interrupt.", 2, "advance5Asetting2Help")
        Help.registerTarget(dvsButtonContainer, "DVS Mode selects the mode the part is in when switching between voltages.", 3, "advance5Asetting2Help")
        Help.registerTarget(sleepMode, "Sleep mode switch will set if the part goes into sleep mode when disabled.", 4, "advance5Asetting2Help")
        Help.registerTarget(activeDischarge, "Active discharge path switch will turn on/off the active discharge capabilities of the part.", 5, "advance5Asetting2Help")
        Help.registerTarget(powerGoodSwitchContainer, "This will enable the PGOOD pin of the part to be high when output voltage is 93% nominal.", 6, "advance5Asetting2Help")
        Help.registerTarget(powerGoodSwitchDVContainer, "This will set the PGOOD signal low when the output voltage is transitioning between the Vset values.", 7, "advance5Asetting2Help")
        Help.registerTarget(resetTimeoutContainer, "This will set a delay in the rise of the PGOOD signal from when output voltage is good. Can be used to generate a Reset signal.", 8, "advance5Asetting2Help")
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
                    Widget10.SGAlignedLabel {
                        id: dvsSpeedLabel
                        target: dvsSpeedCombo
                        text: "DVS\nSpeed"
                        horizontalAlignment: Text.AlignHCenter
                        font.bold : true
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2

                        Widget10.SGComboBox {
                            id: dvsSpeedCombo
                            currentIndex: platformInterface.dvs_speed_state
                            //modelWidth: (dvsSpeedContainer.width - dvsSpeedLabel.contentWidth)/2
                            //width: (dvsSpeedContainer.width - dvsSpeedLabel.contentWidth)/1.1

                            model: [
                                "6.25mV step / 0.333uS", "6.25mV step / 0.666uS", "6.25mV step / 1.333uS",
                                "6.25mV step / 2.666uS"
                            ]
                            borderColor: "black"
                            textColor: "black"          // Default: "black"
                            indicatorColor: "black"
                            //                            anchors {
                            //                                horizontalCenter: parent.horizontalCenter
                            //                                horizontalCenterOffset: (thresholdCombo.width - width)/2
                            //                            }
                            //                            comboBoxWidth: parent.width/2
                            //                            comboBoxHeight: parent.height/2
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
                    Widget10.SGAlignedLabel {
                        id: delayEnableLabel
                        target: delayEnableCombo
                        text: "Delay upon \n Enabled"
                        horizontalAlignment: Text.AlignHCenter
                        font.bold : true
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        Widget10.SGComboBox {
                            id:  delayEnableCombo
                            currentIndex: platformInterface.delay_enable_state
                            //fontSize: (parent.width + parent.height)/32
                            borderColor: "black"
                            textColor: "black"          // Default: "black"
                            indicatorColor: "black"
                            model: [ "0mS", "2mS", "4mS", "6mS", "8mS", "10mS", "12mS", "14mS"]
                            //                            anchors {
                            //                                horizontalCenter: parent.horizontalCenter
                            //                                horizontalCenterOffset: (thresholdCombo.width - width)/2
                            //                            }
                            //                            comboBoxWidth: parent.width/2
                            //                            comboBoxHeight: parent.height/2
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
                    Widget10.SGAlignedLabel {
                        id: thresholdLabel
                        target: thresholdCombo
                        text:  "Thermal pre-warning \n Threshold"
                        horizontalAlignment: Text.AlignHCenter
                        font.bold : true
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        Widget10.SGComboBox {
                            id: thresholdCombo
                            borderColor: "black"
                            textColor: "black"          // Default: "black"
                            indicatorColor: "black"
                            currentIndex: platformInterface.thermal_prewarn_state
                            model: [ "83˚C","94˚C", "105˚C", "116˚C" ]
                            //anchors.horizontalCenter: parent.horizontalCenter
                            //                            comboBoxWidth: parent.width/2
                            //                            comboBoxHeight: parent.height/2
                            onActivated: {
                                platformInterface.set_thermal_threshold.update(currentIndex)
                                platformInterface.thermal_prewarn_state = currentIndex
                            }
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

                    Widget10.SGAlignedLabel {
                        id: dvsButtonLabel
                        target: dvsButtonContainer
                        text: "DVS Mode"
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGRadioButtonContainer {
                            id: dvsButtonContainer
                            //columns: 1
                            radioGroup: GridLayout {
                                columnSpacing: 10
                                rowSpacing: 10

                                Widget10.SGRadioButton {
                                    id: auto
                                    text: "Auto"
                                    checked: auto_button_state

                                    onClicked: {
                                        platformInterface.dvs_mode.update("auto")
                                        platformInterface.dvs_mode.show()
                                    }
                                }

                                Widget10.SGRadioButton {
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

                    Widget10.SGAlignedLabel {
                        id:  sleepModeLabel
                        target: sleepModeSwitch
                        text: "Sleep Mode"
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        Widget10.SGSwitch {
                            id: sleepModeSwitch

                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            //fontSizeLabel: (parent.width + parent.height)/32
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
                    Widget10.SGAlignedLabel {
                        id:  activeDischargeLabel
                        target: activeDischargeSwitch
                        text: "Active Discharge Path"
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        Widget10.SGSwitch {
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

        SGLayoutDivider {
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
                    Widget10.SGAlignedLabel {
                        id: powerGoodLabel
                        target: powerGoodSwitch
                        text: "Power Good"
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        Widget10.SGSwitch {
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
                    Widget10.SGAlignedLabel {
                        id: powerGoodDVSLabel
                        target: powerGoodDVSwitch
                        text: "Power Good Active \n on DVS"
                        horizontalAlignment: Text.AlignHCenter
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        Widget10.SGSwitch {
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
                    Widget10.SGAlignedLabel {
                        id: resetTimeoutLabel
                        target: resetTimeoutCombo
                        text:  "Reset Timeout For\nPower Good"
                        horizontalAlignment: Text.AlignHCenter
                        font.bold : true
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.2
                        Widget10.SGComboBox {
                            id: resetTimeoutCombo
                            borderColor: "black"
                            textColor: "black"          // Default: "black"
                            indicatorColor: "black"
                            currentIndex: platformInterface.timeout_status
                            model: [ "0ms","8ms", "32ms", "64ms" ]
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
