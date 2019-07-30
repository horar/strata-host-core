import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.strata.sgwidgets 0.9
import tech.strata.sgwidgets 1.0 as Widget10
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
            ledLight.status = Widget10.SGStatusLight.Green
            vinlable = "over"
            vinLabel.text = "VIN Ready ("+ vinlable + " 2.5V)"
            enableSwitch.enabled  = true
            enableSwitch.opacity = 1.0
        }
        else {
            ledLight.status = Widget10.SGStatusLight.Red
            vinlable = "under"
            vinLabel.text = "VIN Ready ("+ vinlable + " 2.5V)"
            enableSwitch.enabled  = false
            enableSwitch.opacity = 0.5
            platformInterface.enabled = false
        }
    }

    Component.onCompleted:  {
        Help.registerTarget(ledLight, "The LED will light up green when input voltage is ready and greater than 4.5V. It will light up red when under 4.5V to warn the user that input voltage is not high enough.", 1, "basic5AHelp")
        Help.registerTarget(inputVoltage, "Input voltage is shown here in Volts.", 2, "basic5AHelp")
        Help.registerTarget(inputCurrent, "Input current is shown here in A", 3, "basic5AHelp")
        Help.registerTarget(tempGauge, "The center gauge shows the temperature of the board.", 4, "basic5AHelp")
        Help.registerTarget(enableSwitch, "Enable switch enables and disables the part.", 5, "basic5AHelp")
        Help.registerTarget(vselSwitch, "The VSEL switch will switch the output voltage between the two default values of the part. In this case the two default values are 0.875V and 0.90625V.", 6, "basic5AHelp")
        Help.registerTarget(ouputCurrent, " Output current is shown here in A.", 8, "basic5AHelp")
        Help.registerTarget(outputVoltage, "Output voltage is shown here in Volts.", 7, "basic5AHelp")
    }

    Rectangle{
        anchors.centerIn: parent
        width : parent.width
        height: parent.height - 150

          color: "transparent"


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
                text:  "<b> NCV6357 </b>"
                font.pixelSize: (parent.width + parent.height)/ 30
                color: "black"
            }
            Text {
                id: pageText2
                anchors {
                    top: pageText.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                text: "<b> Programmable Synchronous Adaptive On-Tine Buck Converter</b>"
                font.pixelSize:(parent.width + parent.height)/ 30
                color: "black"
            }
        }
        Rectangle {
            id: warningBox
            color: "grey"
            anchors {
                top: leftContainer.bottom
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            width: (parent.width/2) + 40
            height: parent.height/12
            visible: platformInterface.warning_visibility

            Text {
                id: warningText
                anchors {
                    centerIn: warningBox
                }
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
                font.pixelSize: (parent.width + parent.height)/ 15
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
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "white"
            }
        }

        Rectangle{
            id: leftContainer
            width: parent.width
            height: parent.height - 200
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
                border.width: 5
                radius: 10
                Rectangle {
                    id: textContainer2
                    width: parent.width/5
                    height: parent.height/10
                    anchors {
                        top: parent.top
                        topMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                      color: "transparent"
                    Text {
                        id: containerLabel2
                        text: "Input"
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
                    border.color: "gray"
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
                    Widget10.SGAlignedLabel {
                        id: vinLabel
                        target: ledLight
                        text:  "VIN Ready (under 2.5V)"
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        Widget10.SGStatusLight {
                            id: ledLight
                            property string vinMonitor: platformInterface.status_vin_good.vingood
                            onVinMonitorChanged:  {
                                if(vinMonitor === "good") {
                                    status = SGStatusLight.Green
                                    vinlable = "over"
                                    label = "VIN Ready ("+ vinlable + " 2.5V)"
                                    //Show enableSwitch if vin is "good"
                                    enableSwitch.enabled  = true
                                    enableSwitch.opacity = 1.0
                                }
                                else if(vinMonitor === "bad") {
                                    status = SGStatusLight.Red
                                    vinlable = "under"
                                    label = "VIN Ready ("+ vinlable + " 2.5V)"
                                    //Hide enableSwitch if vin is "good"
                                    enableSwitch.enabled  = false
                                    enableSwitch.opacity = 0.5
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
                        //topMargin: 10
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

                Rectangle {
                    id: inputContainer
                    width: parent.width
                    height: parent.height/5
                    anchors {
                        top : warningBox2.bottom
                        topMargin : 10
                        horizontalCenter: parent.horizontalCenter

                    }
                    color: "transparent"
                    Widget10.SGAlignedLabel {
                        id: inputVoltageLabel
                        target: inputVoltage
                        text: "Input Voltage"
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true

                        Widget10.SGInfoBox {
                            id: inputVoltage
                            text: platformInterface.status_voltage_current.vin.toFixed(2)
                            unit: "V"
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.5
                           // boxBorderWidth: (parent.width+parent.height)/0.9
                            boxColor: "lightgrey"

                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: parent.height/5
                    color: "transparent"
                    anchors {
                        top : inputContainer.bottom
                        topMargin : 10
                        horizontalCenter: parent.horizontalCenter
                    }
                    Widget10.SGAlignedLabel {
                        id: inputCurrentLabel
                        target: inputCurrent
                        text: "Input Current"
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true

                        Widget10.SGInfoBox {
                            id: inputCurrent
                            text: platformInterface.status_voltage_current.iin.toFixed(2)
                            unit: "A"
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.5
                            //boxBorderWidth: (parent.width+parent.height)/0.9
                            boxColor: "lightgrey"

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

                Widget10.SGAlignedLabel {
                    id: tempLabel
                    target: tempGauge
                    text: "Board \n Temperature"
                    margin: 0
                    anchors.centerIn: parent
                    alignment: Widget10.SGAlignedLabel.SideBottomCenter
                    fontSizeMultiplier: ratioCalc * 1.5
                    font.bold : true
                    horizontalAlignment: Text.AlignHCenter

                    Widget10.SGCircularGauge {
                        id: tempGauge
                        minimumValue: -55
                        maximumValue: 125
                        tickmarkStepSize: 20
                        //outerColor: "#999"
                        unitText: "°C"
                        //gaugeTitle : "Board" +"\n" + "Temperature"
                        value: platformInterface.status_temperature_sensor.temperature
                        Behavior on value { NumberAnimation { duration: 300 } }
                    }
                }

            }

            Rectangle {
                id:right
                anchors {
                    //                    top:parent.top
                    //                    topMargin: 40
                    verticalCenter: parent.verticalCenter
                    left: gauge.right
                    right: parent.right
                    rightMargin: 20
                }
                width: parent.width/3
                height: (parent.height/2) + 140
                color: "transparent"
                border.color: "black"
                border.width: 5
                radius: 10

                Rectangle {
                    id: textContainer
                    width: parent.width/4.5
                    height: parent.height/10
                    anchors {
                        top: parent.top
                        topMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        id: containerLabel
                        text: "Output"
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
                    id:enableContainer
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"
                    anchors {
                        top: line2.bottom
                        topMargin :  10
                        horizontalCenter: parent.horizontalCenter
                    }
                    Widget10.SGAlignedLabel {
                        id: enableSwitchLabel
                        target: enableSwitch
                        text: "Enable (EN)"
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        Widget10.SGSwitch {
                            id: enableSwitch
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
                                    platformInterface.set_enable.update("on")

                                    if(platformInterface.reset_flag === true) {
                                        platformInterface.reset_status_indicator.update("reset")
                                        platformInterface.reset_indicator = "off"
                                        platformInterface.reset_flag = false
                                    }
                                }
                                else{
                                    platformInterface.set_enable.update("off")
                                }
                            }
                        }
                    }
                }

                Rectangle{
                    id: vselContainer
                    anchors {
                        top: enableContainer.bottom
                        topMargin :  5
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"
                    Widget10.SGAlignedLabel {
                        id: vselSwitchLabel
                        target: vselSwitch
                        text: "VSEL"
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                         Widget10.SGSwitch {
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
                    id: outputContainer
                    width: parent.width
                    height: parent.height/6
                    anchors {
                        top : vselContainer.bottom
                        topMargin : 10
                        horizontalCenter: parent.horizontalCenter
                    }
                    color: "transparent"
                    Widget10.SGAlignedLabel {
                        id: ouputVoltageLabel
                        target: outputVoltage
                        text: "Output Voltage"
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        Widget10.SGInfoBox {
                            id: outputVoltage
                            text: platformInterface.status_voltage_current.vout.toFixed(2)
                            unit: "V"
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.5
                            //boxBorderWidth: (parent.width+parent.height)/0.9
                            boxColor: "lightgrey"


                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"
                    anchors {
                        top : outputContainer.bottom
                        topMargin : 10
                        horizontalCenter: parent.horizontalCenter
                    }
                    Widget10.SGAlignedLabel {
                        id: ouputCurrentLabel
                        target: ouputCurrent
                        text:  "Output Current"
                        alignment: Widget10.SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        Widget10.SGInfoBox {
                            id: ouputCurrent
                            text: platformInterface.status_voltage_current.iout.toFixed(2)
                            unit: "A"
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.5
                            //boxBorderWidth: (parent.width+parent.height)/0.9
                            boxColor: "lightgrey"

                        }
                    }
                }
            }
        }
    }
}

