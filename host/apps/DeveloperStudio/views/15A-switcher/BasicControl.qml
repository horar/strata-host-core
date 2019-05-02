import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/15A-switcher/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: controlPage

    property string vinlable: ""
    property bool check_initial_state: false
    property var read_enable_state: platformInterface.initial_status.enable_status

    onRead_enable_stateChanged: {
        if(read_enable_state === "on") {
            platformInterface.enabled = true

        }
        else  {
            platformInterface.enabled = false
        }
    }

    property var read_vin: platformInterface.status_voltage_current.vingood
    onRead_vinChanged: {
        if(read_vin === "good") {
            ledLight.status = "green"
            vinlable = "over"
            ledLight.label = "VIN Ready ("+ vinlable + " 4.5V)"
            enableSwitch.enabled  = true
            enableSwitch.opacity = 1.0
        }
        else {
            ledLight.status = "red"
            vinlable = "under"
            ledLight.label = "VIN Ready ("+ vinlable + " 4.5V)"
            platformInterface.enabled = false
            enableSwitch.opacity = 0.5
        }
    }


    Component.onCompleted:  {
        platformInterface.read_initial_status.update()
        Help.registerTarget(ledLight, "The LED will light up green when input voltage is ready and greater than 4.5V. It will light up red when under 4.5V to warn the user that input voltage is not high enough.", 1, "basic15AHelp")
        Help.registerTarget(inputVoltage, "Input voltage is shown here in Volts.", 2, "basic15AHelp")
        Help.registerTarget(inputCurrent, "Input current is shown here in A", 3, "basic15AHelp")
        Help.registerTarget(tempGauge, "The center gauge shows the temperature of the board.", 4, "basic15AHelp")
        Help.registerTarget(enableSwitch, "Enables and disables 15A switcher output.", 5, "basic15AHelp")
        Help.registerTarget(ouputCurrent, " Output current is shown here in A.", 7, "basic15AHelp")
        Help.registerTarget(outputVoltage, "Output voltage is shown here in Volts.", 6, "basic15AHelp")
    }

    FontLoader {
        id: icons
        source: "sgwidgets/fonts/sgicons.ttf"
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
                topMargin: 50
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
                id: pageText2
                anchors {
                    top: pageText.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                text: multiplePlatform.title
                font.pixelSize: (parent.width + parent.height)/ 30
                color: "black"
            }
        }
        Rectangle{
            width: parent.width
            height: parent.height - 100

            anchors{
                top: pageLable.bottom
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
                    label: "VIN Ready (under 4.5V)" // Default: "" (if not entered, label will not appear)
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
                    gaugeTitle : "Board" + "\n" + "Temperature"
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
                height: (parent.height/2)+ 100
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
                    checked: platformInterface.enabled
                    fontSizeLabel: (parent.width + parent.height)/40
                    onToggled: {

                        if(checked){
                            platformInterface.set_enable.update("on")
                        }
                        else {
                            platformInterface.set_enable.update("off")
                        }

                        platformInterface.enabled = checked
                    }

                    onCheckedChanged:  {
                        if(checked) {
                            platformInterface.enabled = true
                        }
                        else {
                            platformInterface.enabled = false
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
                        top : enableSwitch.bottom
                        topMargin : 20
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
                        topMargin : 20
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
