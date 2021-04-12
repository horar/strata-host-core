import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help


Item {
    id: root
    anchors.fill: parent
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    property alias warningVisible: warningBox.visible
    property string vinlable: ""

    // When the load is turned on before enable is on, the part sends out the surge and resets the mcu.
    // Detect the mcu reset and turn of the pause periodic.
    property var read_mcu_reset_state: platformInterface.status_mcu_reset.mcu_reset
    onRead_mcu_reset_stateChanged: {
        if(read_mcu_reset_state === "occurred") {
            platformInterface.pause_periodic.update(false)
        }
        else  {
            platformInterface.status_mcu_reset.mcu_reset = ""
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

    property var read_vin: platformInterface.initial_status_0.vingood_status
    onRead_vinChanged: {
        if(read_vin === "good") {
            ledLight.status = SGStatusLight.Green
            vinlable = "over"
            vinLabel.text = "VIN Ready ("+ vinlable + " 6V)"
            enableSwitch_3v3.enabled = true
            enableSwitch_3v3.opacity = 1.0
            enableSwitch_3v3Label.opacity = 1.0
        }
        else {
            ledLight.status = SGStatusLight.Red
            vinlable = "under"
            vinLabel.text = "VIN Ready ("+ vinlable + " 6V)"
            enableSwitch_3v3.enabled = false
            enableSwitch_3v3.opacity = 0.5
            enableSwitch_3v3Label.opacity = 0.5
            platformInterface.enabled = false
        }
    }

    Component.onCompleted:  {
        helpIcon.visible = true
        Help.registerTarget(statusLightContainer, "Vin Ready LED will light up green when the USB in the Platform MCU will be ready, and will light up red otherwise to warn the user that the USB in the Platform MCU is not ready.", 1, "basicViewHelp")
        Help.registerTarget(voltageContainer, "The digital gauges here show the mains input voltage and current to the 5V rail of the evaluation board. The NCV214R current sense amplifier provides the current measurement.", 2, "basicViewHelp")
        Help.registerTarget(tempGauge, "The gauge shows the board temperature next to the Power Mosfets (T2 and T3) NVMFS5C460NL in degrees Celsius. This temperature will be less than the temperature internal to the NVMFS5C460NL due to the thermal isolation between the die of the NVMFS5C460NL and the die of the temperature sensor.", 3, "basicViewHelp")
        Help.registerTarget(enable5vContainer, "This switch enables/disables the 5V rail NCV881930. It will be grayed out if the USB in the Platform MCU is not ready.", 4, "basicViewHelp")
        Help.registerTarget(enable3v3Container, "This switch enables/disables the 3.3V rail NCV6357. It will be grayed out if the input voltage is not high enough (above 2.5V).", 5, "basicViewHelp")
        Help.registerTarget(vselContainer, "VSEL will switch the output voltage between the two voltage values stored in the VoutVSEL registers in the NCV6357. Default register setting values for VoutVSEL0 and VoutVSEL1 are 0.9V and 1.0V respectively.", 6, "basicViewHelp")
        Help.registerTarget(current3v3Container, "The digital gauges here show the output voltage and current from the 3.3V rail (3V3/5A) to the DC-DC NCV6357 of the evaluation board. The NCV214R current sense amplifier provides the current measurement.", 7, "basicViewHelp")
        Help.registerTarget(current5vContainer, "The digital gauges here show the output voltage and current from the 5V rail (5V/10A) to the power stage Power Mosfets (T2 and T3) NVMFS5C460NL of the evaluation board. The NCV214R current sense amplifier provides the current measurement.", 8, "basicViewHelp")
    }

    Rectangle{
        anchors.centerIn: parent
        width : parent.width
        height: parent.height - 80
        color: "transparent"
        Rectangle {
            id: pageLable
            width: parent.width/2
            height: parent.height/ 12
            anchors {
                top: parent.top
                topMargin: 0
                horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: pageText
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                text:  "<b> Automotive ADAS Preregulator </b>"
                font.pixelSize: (parent.width + parent.height)/ 12
                color: "green"
            }
            Text {
                id: pageText2
                anchors {
                    top: pageText.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                text: "<b> The STR-ADAS-PREREGULATOR-GEVB provides an evaluation kit for the NCV881930, NVMFS5C460NL and for the NCV6357 </b>"
                font.pixelSize:(parent.width + parent.height)/ 35
                color: "blue"
            }
        }

        Rectangle {
            id: warningBox
            color: "white"
            anchors {
                top: leftContainer.bottom
                topMargin: 15
                horizontalCenter: parent.horizontalCenter

            }
            width: (parent.width/2) + 40
            height: parent.height/16
            visible: true

            Text {
                id: warningText
                anchors.centerIn: warningBox
                text: "<b>See Advanced Controls for Current Fault Status</b>"
                font.pixelSize: ratioCalc * 20
                color: "white"
            }
            Text {
                id: warningIcon1
                anchors {
                    right: warningText.left
                    verticalCenter: warningText.verticalCenter
                    rightMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 18
                color: "white"
            }

            Text {
                id: warningIcon2
                anchors {
                    left: warningText.right
                    verticalCenter: warningText.verticalCenter
                    leftMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 18
                color: "white"
            }
        }

        Rectangle{
            id: leftContainer
            width: parent.width
            height: parent.height - 150
            anchors{
                top: pageLable.bottom
                topMargin: 20
            }
            color: "transparent"
            Rectangle {
                id:left
                width: parent.width/3
                height: (parent.height/2) + 140
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 20
                }
                color: "transparent"
                border.color: "black"
                border.width: 7
                radius: 20
                Rectangle {
                    id: textContainer2
                    width: parent.width/2
                    height: parent.height/8
                    anchors {
                        top: parent.top
                        topMargin: 12
                        horizontalCenter: parent.horizontalCenter
                    }
                    color: "transparent"
                    Text {
                        id: containerLabel2
                        text: "Input Mains"
                        anchors{
                            fill: parent
                            centerIn: parent
                        }
                        font.pixelSize: height
                        font.bold: true
                        fontSizeMode: Text.Fit
                    }
                }
                Rectangle {
                    id: line
                    height: 2
                    width: parent.width - 9
                    anchors {
                        top: textContainer2.bottom
                        topMargin: 2
                        left: parent.left
                        leftMargin: 5
                    }
                    border.color: "black"
                    radius: 2
                }
                Rectangle {
                    id: statusLightContainer
                    width: parent.width
                    height: parent.height/5
                    anchors {
                        top : line.bottom
                        topMargin : 10
                        horizontalCenter: parent.horizontalCenter
                    }
                    color: "transparent"
                    SGAlignedLabel {
                        id: vinLabel
                        target: ledLight
                        text:  "VIN Ready (under 6V)"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        SGStatusLight {
                            id: ledLight
                            property string vinMonitor: platformInterface.status_vin_good.vingood
                            onVinMonitorChanged:  {
                                if(vinMonitor === "good") {
                                    ledLight.status = SGStatusLight.Green
                                    vinlable = "over"
                                    vinLabel.text = "VIN Ready ("+ vinlable + " 6V)"
                                    //Show enableSwitch if vin is "good"
                                    enableContainer.enabled  = true
                                    enableContainer.opacity = 1.0
                                }
                                else if(vinMonitor === "bad") {
                                    ledLight.status = SGStatusLight.Red
                                    vinlable = "under"
                                    vinLabel.text= "VIN Ready ("+ vinlable + " 6V)"
                                    //Hide enableSwitch if vin is "good"
                                    enableContainer.enabled  = false
                                    enableContainer.opacity = 0.5
                                    platformInterface.enabled = false
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: warningBox2
                    color: "red"
                    anchors {
                        top: statusLightContainer.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width - 40
                    height: parent.height/10
                    Text {
                        id: warningText2
                        anchors.centerIn: warningBox2
                        text: "<b>Vin: 6-16 V. DO NOT exceed Vin more than 40V</b>"
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
                        font.family: Fonts.sgicons
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
                        font.family: Fonts.sgicons
                        font.pixelSize: (parent.width + parent.height)/19
                        color: "white"
                    }
                }
                Rectangle{
                    id: voltageContainer
                    width: parent.width
                    height: parent.height/2.3
                    color: "transparent"
                    anchors {
                        top : warningBox2.bottom
                        topMargin : 10
                        horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        id: inputContainer
                        width: parent.width
                        height: parent.height/2
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }

                        color: "transparent"
                        SGAlignedLabel {
                            id: inputVoltageLabel
                            target: inputVoltage
                            text: "Input Voltage"
                            alignment: SGAlignedLabel.SideLeftCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 2
                            font.bold : true

                            SGInfoBox {
                                id: inputVoltage
                                text: platformInterface.status_voltage_current.vin.toFixed(2)
                                unit: "V"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 2.6
                                height: (inputContainer.height - inputVoltageLabel.contentHeight) + 5
                                width: (inputContainer.width - inputVoltageLabel.contentWidth)/1.6
                                boxColor: "lightgreen"
                                boxFont.family: Fonts.digitalseven
                                unitFont.bold: true

                            }
                        }
                    }

                    Rectangle {
                        id: inputCurrentConatiner
                        width: parent.width
                        height: parent.height/2
                        color: "transparent"
                        anchors {
                            top : inputContainer.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        SGAlignedLabel {
                            id: inputCurrentLabel
                            target: inputCurrent
                            text: "Input Current"
                            alignment: SGAlignedLabel.SideLeftCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 2
                            font.bold : true

                            SGInfoBox {
                                id: inputCurrent
                                text: platformInterface.status_voltage_current.iin.toFixed(2)
                                unit: "A"
                                height: (inputCurrentConatiner.height - inputCurrentLabel.contentHeight) + 5
                                width: (inputCurrentConatiner.width - inputCurrentLabel.contentWidth)/1.6
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 2.6
                                boxColor: "lightgreen"
                                boxFont.family: Fonts.digitalseven
                                unitFont.bold: true

                            }
                        }
                    }
                }
            }
            Rectangle {
                id: gauge
                width: parent.width/3.5
                height: (parent.height/2) + 100
                anchors{
                    left: left.right
                    verticalCenter: parent.verticalCenter
                }
                color: "transparent"

                SGAlignedLabel {
                    id: tempLabel
                    target: tempGauge
                    text: "Board \n Temperature"
                    margin: 0
                    anchors.centerIn: parent
                    alignment: SGAlignedLabel.SideBottomCenter
                    fontSizeMultiplier: ratioCalc * 1.5
                    font.bold : true
                    horizontalAlignment: Text.AlignHCenter

                    SGCircularGauge {
                        id: tempGauge
                        minimumValue: -60
                        maximumValue: 130
                        tickmarkStepSize: 10
                        gaugeFillColor1: "blue"
                        gaugeFillColor2: "red"
                        unitText: "°C"
                        unitTextFontSizeMultiplier: ratioCalc * 2.2
                        value: platformInterface.status_temperature_sensor.temperature
                        Behavior on value { NumberAnimation { duration: 300 } }
                        function lerpColor (color1, color2, x){
                            if (Qt.colorEqual(color1, color2)){
                                return color1;
                            } else {
                                return Qt.rgba(
                                            color1.r * (1 - x) + color2.r * x,
                                            color1.g * (1 - x) + color2.g * x,
                                            color1.b * (1 - x) + color2.b * x, 1
                                            );
                            }
                        }
                    }
                }
            }

            Rectangle {
                id:right
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: gauge.right
                    right: parent.right
                    rightMargin: 20
                }
                width: parent.width/3.5
                height: (parent.height/2) + 140
                color: "transparent"
                border.color: "black"
                border.width: 7
                radius: 20

                Rectangle {
                    id: textContainer
                    width: parent.width/2
                    height: parent.height/8
                    anchors {
                        top: parent.top
                        topMargin: 12
                        horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        id: containerLabel
                        text: "    Outputs"
                        anchors{
                            fill: parent
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: 7
                        }
                        font.pixelSize: height
                        font.bold: true
                        fontSizeMode: Text.Fit
                    }
                }

                Rectangle {
                    id: line2
                    height: 2
                    width: parent.width - 9

                    anchors {
                        top: textContainer.bottom
                        topMargin: 2
                        left: parent.left
                        leftMargin: 5
                    }
                    border.color: "gray"
                    radius: 2
                }
                Rectangle {
                    id:enable5vContainer
                    width: parent.width
                    height: parent.height/10
                    color: "transparent"
                    anchors {
                        top: line2.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    SGAlignedLabel {
                        id: enableSwitch_5vLabel
                        target: enableSwitch_5v
                        text: "Enable (5V)"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        SGSwitch {
                            id: enableSwitch_5v
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel:   "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            checked: platformInterface.enabled
                            onToggled: {
                                platformInterface.enabled = checked
                                if(checked){
                                    platformInterface.set_enable_5v.update("on")

                                    if(platformInterface.reset_flag === true) {
                                        platformInterface.reset_status_indicator.update("reset")
                                        platformInterface.reset_indicator = SGStatusLight.Off
                                        platformInterface.reset_flag = false
                                    }
                                }
                                else{
                                    platformInterface.set_enable_5v.update("off")
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    id:enable3v3Container
                    width: parent.width
                    height: parent.height/10
                    color: "transparent"
                    anchors {
                        top: enable5vContainer.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    SGAlignedLabel {
                        id: enableSwitch_3v3Label
                        target: enableSwitch_3v3
                        text: "Enable (3V3)"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        SGSwitch {
                            id: enableSwitch_3v3
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel:   "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            checked: platformInterface.enabled
                            onToggled: {
                                platformInterface.enabled = checked
                                if(checked){
                                    platformInterface.set_enable_3v3.update("on")

                                    if(platformInterface.reset_flag === true) {
                                        platformInterface.reset_status_indicator.update("reset")
                                        platformInterface.reset_indicator = SGStatusLight.off
                                        platformInterface.reset_flag = false
                                    }
                                }
                                else{
                                    platformInterface.set_enable_3v3.update("off")
                                }
                            }
                        }
                    }
                }

                Rectangle{
                    id: vselContainer
                    anchors {
                        top: enable3v3Container.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width
                    height: parent.height/10
                    color: "transparent"
                    SGAlignedLabel {
                        id: vselSwitchLabel
                        target: vselSwitch
                        text: "VSEL"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        SGSwitch {
                            id: vselSwitch
                            textColor: "black"
                            handleColor: "white"
                            grooveColor: "#ccc"
                            grooveFillColor: "#0cf"
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            labelsInside: true
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
                Rectangle {
                    id: current3v3Container
                    width: parent.width
                    height: parent.height/4
                    color: "transparent"
                    anchors {
                        top : vselContainer.bottom
                        topMargin : 5
                        horizontalCenter: parent.horizontalCenter
                    }
                    Rectangle {
                        id: output_3v3Container
                        width: parent.width
                        height: parent.height/2
                        anchors {
                            top : parent.top
                            horizontalCenter: parent.horizontalCenter
                        }
                        color: "transparent"
                        SGAlignedLabel {
                            id: ouputVoltage_3v3Label
                            target: outputVoltage_3v3
                            text: "3.3V rail"
                            alignment: SGAlignedLabel.SideLeftCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.5
                            font.bold : true
                            SGInfoBox {
                                id: outputVoltage_3v3
                                text: platformInterface.status_voltage_current.vout_3v3.toFixed(2)
                                unit: "V"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.8
                                boxColor: "lightblue"
                                height: (output_3v3Container.height - ouputVoltage_3v3Label.contentHeight) + 10
                                width: (output_3v3Container.width - ouputVoltage_3v3Label.contentWidth)/3.8
                                boxFont.family: Fonts.digitalseven
                                unitFont.bold: true
                            }
                        }
                    }

                    Rectangle {
                        id: outputCurrent_3v3Container
                        width: parent.width
                        height: parent.height/2
                        color: "transparent"
                        anchors {
                            top : output_3v3Container.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        SGAlignedLabel {
                            id: ouputCurrent_3v3Label
                            target: ouputCurrent_3v3
                            text:  "3.3V rail"
                            alignment: SGAlignedLabel.SideLeftCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.5
                            font.bold : true
                            SGInfoBox {
                                id: ouputCurrent_3v3
                                text: platformInterface.status_voltage_current.iout_3v3.toFixed(2)
                                unit: "A"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.8
                                height: (outputCurrent_3v3Container.height - ouputCurrent_3v3Label.contentHeight) + 10
                                width: (outputCurrent_3v3Container.width - ouputCurrent_3v3Label.contentWidth)/3.8
                                boxColor: "lightblue"
                                boxFont.family: Fonts.digitalseven
                                unitFont.bold: true
                                }
                            }
                        }
                    }
                Rectangle {
                    id: current5vContainer
                    width: parent.width
                    height: parent.height/4
                    color: "transparent"
                    anchors {
                        top : current3v3Container.bottom
                        horizontalCenter: parent.horizontalCenter
                     }
                    Rectangle {
                        id: output_5vContainer
                        width: parent.width
                        height: parent.height/2
                        anchors {
                            top : parent.top
                            horizontalCenter: parent.horizontalCenter
                        }
                        color: "transparent"
                        SGAlignedLabel {
                            id: ouputVoltage_5vLabel
                            target: outputVoltage_5v
                            text: "5V rail   "
                            alignment: SGAlignedLabel.SideLeftCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.5
                            font.bold : true
                            SGInfoBox {
                                id: outputVoltage_5v
                                text: platformInterface.status_voltage_current.vout_5v.toFixed(2)
                                unit: "V"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.8
                                boxColor: "lightyellow"
                                height: (output_5vContainer.height - ouputVoltage_5vLabel.contentHeight) + 10
                                width: (output_5vContainer.width - ouputVoltage_5vLabel.contentWidth)/3.8
                                boxFont.family: Fonts.digitalseven
                                unitFont.bold: true
                            }
                        }
                    }

                    Rectangle {
                        id: outputCurrent_5vContainer
                        width: parent.width
                        height: parent.height/2
                        color: "transparent"
                        anchors {
                            top : output_5vContainer.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        SGAlignedLabel {
                            id: ouputCurrent_5vLabel
                            target: ouputCurrent_5v
                            text:  "5V rail   "
                            alignment: SGAlignedLabel.SideLeftCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.5
                            font.bold : true
                            SGInfoBox {
                                id: ouputCurrent_5v
                                text: platformInterface.status_voltage_current.iout_5v.toFixed(2)
                                unit: "A"
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.8
                                height: (outputCurrent_5vContainer.height - ouputCurrent_5vLabel.contentHeight) + 10
                                width: (outputCurrent_5vContainer.width - ouputCurrent_5vLabel.contentWidth)/3.8
                                boxColor: "lightyellow"
                                boxFont.family: Fonts.digitalseven
                                unitFont.bold: true

                            }
                        }
                    }
                }
            }
        }
    }
}
