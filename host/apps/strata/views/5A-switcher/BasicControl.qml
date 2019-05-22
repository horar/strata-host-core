import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/5A-switcher/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

Item {
    anchors.fill: parent

    FontLoader {
        id: icons
        source: "sgwidgets/fonts/sgicons.ttf"
    }

    property alias warningVisible: warningBox.visible
    property string vinlable: ""

    // When the load is turned on before enable is on, the part sends out the surge and resets the mcu.
    // Detect the mcu reset and turn of the pause periodic.
    // Part of Windows Serial USB mouse hack
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
        if(read_enable_state === "on") {
            platformInterface.enabled = true
            warningBox.visible = false
        }
        else  {
            platformInterface.enabled = false

        }
    }

    property var read_vsel_status: platformInterface.initial_status_0.vsel_status
    onRead_vsel_statusChanged: {
        if(read_vsel_status === "on") {
            platformInterface.vsel_state = true
        }
        else platformInterface.vsel_state = false
    }

    property var read_vin: platformInterface.initial_status_0.vingood_status
    onRead_vinChanged: {
        if(read_vin === "good") {
            ledLight.status = "green"
            vinlable = "over"
            ledLight.label = "VIN Ready ("+ vinlable + " 2.25V)"
            enableSwitch.enabled  = true
            enableSwitch.opacity = 1.0
        }
        else {
            ledLight.status = "red"
            vinlable = "under"
            ledLight.label = "VIN Ready ("+ vinlable + " 2.25V)"
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
        Help.registerTarget(powerGoodSwitch, "The VSEL switch will switch the output voltage between the two default values of the part. In this case the two default values are 0.875V and 0.90625V.", 6, "basic5AHelp")
        Help.registerTarget(ouputCurrent, " Output current is shown here in A.", 8, "basic5AHelp")
        Help.registerTarget(outputVoltage, "Output voltage is shown here in Volts.", 7, "basic5AHelp")
    }

    Rectangle{
        anchors.centerIn: parent
        width : parent.width
        height: parent.height - 150

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
                text:  "<b> NCV6356 </b>"
                font.pixelSize: (parent.width + parent.height)/ 30
                color: "black"
            }
            Text {
                id: pageText2
                anchors {
                    top: pageText.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                text: "<b>Programmable Synchronous Adaption On-time Buck Converter</b>"
                font.pixelSize:(parent.width + parent.height)/ 30
                color: "black"
            }
        }
        Rectangle {
            id: warningBox
            color: "red"
            anchors {
                top: pageLable.bottom
                topMargin: 40
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
                font.pixelSize: (parent.width + parent.height)/ 32
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
                font.family: icons.name
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
                font.family: icons.name
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "white"
            }
        }

        Rectangle{
            width: parent.width
            height: parent.height - 100
            anchors{
                top: warningBox.bottom
                topMargin: 20
            }

            Rectangle {
                id:left
                width: parent.width/3
                height: (parent.height/2) + 100
                anchors {
                    top:parent.top
                    topMargin: 40
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
                SGStatusLight {
                    id: ledLight
                    // Optional Configuration:
                    label: "VIN Ready (under 2.5V)" // Default: "" (if not entered, label will not appear)
                    anchors {
                        top : line.bottom
                        topMargin : 20
                        horizontalCenter: parent.horizontalCenter
                    }
                    lightSize: (parent.width + parent.height)/23
                    fontSize:  (parent.width + parent.height)/46

                    property string vinMonitor: platformInterface.status_vin_good.vingood
                    onVinMonitorChanged:  {
                        if(vinMonitor === "good") {
                            status = "green"
                            vinlable = "over"
                            label = "VIN Ready ("+ vinlable + " 2.25V)"
                            //Show enableSwitch if vin is "good"
                            enableSwitch.enabled  = true
                            enableSwitch.opacity = 1.0
                        }
                        else if(vinMonitor === "bad") {
                            status = "red"
                            vinlable = "under"
                            label = "VIN Ready ("+ vinlable + " 2.25V)"
                            //Hide enableSwitch if vin is "good"
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
                        horizontalCenterOffset:  (width - inputCurrent.width)/2
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
                id: gauge
                width: parent.width/3.5
                height: (parent.height/2) + 100
                anchors{
                    left: left.right
                    top:parent.top
                    topMargin: 40
                }

                SGCircularGauge {
                    id: tempGauge
                    anchors {
                        fill : parent
                        horizontalCenter: gauge.horizontalCenter
                    }
                    width: parent.width
                    height: parent.height
                    gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    minimumValue: -55
                    maximumValue: 125
                    tickmarkStepSize: 20
                    outerColor: "#999"
                    unitLabel: "°C"
                    gaugeTitle : "Board" +"\n" + "Temperature"
                    value: platformInterface.status_temperature_sensor.temperature
                    Behavior on value { NumberAnimation { duration: 300 } }
                }
            }

            Rectangle {
                id:right
                anchors {
                    top:parent.top
                    topMargin: 40
                    left: gauge.right
                    right: parent.right
                    rightMargin: 20
                }
                width: parent.width/3
                height: (parent.height/2) + 100
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

                SGSwitch {
                    id: enableSwitch
                    anchors {
                        top: line2.bottom
                        topMargin :  20
                        horizontalCenter: parent.horizontalCenter
                    }

                    label : "Enable (EN)"
                    switchWidth: parent.width/8            // Default: 52 (change for long custom checkedLabels when labelsInside)
                    switchHeight: parent.height/20               // Default: 26
                    textColor: "black"              // Default: "black"
                    handleColor: "white"            // Default: "white"
                    grooveColor: "#ccc"             // Default: "#ccc"
                    grooveFillColor: "#0cf"         // Default: "#0cf"
                    fontSizeLabel: (parent.width + parent.height)/40
                    checked: platformInterface.enabled
                    onCheckedChanged: {
                        if(checked) {
                            platformInterface.intd_state = true
                        }
                        else {
                            platformInterface.intd_state = false
                        }
                    }
                    onToggled: {
                        platformInterface.enabled = checked
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
                    }
                }

                SGSwitch {
                    id: powerGoodSwitch
                    anchors {
                        top: enableSwitch.bottom
                        topMargin :  20
                        horizontalCenter: parent.horizontalCenter
                    }

                    label : "VSEL"
                    switchWidth: parent.width/8            // Default: 52 (change for long custom checkedLabels when labelsInside)
                    switchHeight: parent.height/20               // Default: 26
                    textColor: "black"              // Default: "black"
                    handleColor: "white"            // Default: "white"
                    grooveColor: "#ccc"             // Default: "#ccc"
                    grooveFillColor: "#0cf"         // Default: "#0cf"
                    fontSizeLabel: (parent.width + parent.height)/40
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

                SGLabelledInfoBox {
                    id: outputVoltage
                    label: "Output Voltage"
                    info: platformInterface.status_voltage_current.vout
                    unit: "V"

                    infoBoxWidth: parent.width/3
                    infoBoxHeight : parent.height/12
                    fontSize :  (parent.width + parent.height)/37
                    unitSize: (parent.width + parent.height)/35
                    anchors {
                        top : powerGoodSwitch.bottom
                        topMargin : 20
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset:  (width - ouputCurrent.width)/2
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
                        topMargin : 20
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}

