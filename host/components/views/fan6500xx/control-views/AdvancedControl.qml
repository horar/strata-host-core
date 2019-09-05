import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.strata.sgwidgets 0.9
import tech.strata.sgwidgets 1.0 as Widget01
import tech.strata.fonts 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/15A-switcher/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help



Item {
    id: root
    anchors.fill: parent
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height


    property string vinlable: ""
    property var read_enable_state: platformInterface.initial_status.enable_status

    onRead_enable_stateChanged: {
        if(read_enable_state === "on") {
            platformInterface.enabled = true
        }
        else  {
            platformInterface.enabled = false
        }
    }

    property var soft_start_state: platformInterface.initial_status.soft_start_status
    onSoft_start_stateChanged: {
        if(soft_start_state === "5ms"){
            platformInterface.soft_start = 0
        }
        else {
            platformInterface.soft_start = 1
        }
    }

    property var vout_state: platformInterface.initial_status.vout_selector_status
    onVout_stateChanged: {
        platformInterface.vout = vout_state
    }

    property var ocp_threshold_state: platformInterface.initial_status.ocp_threshold_status
    onOcp_threshold_stateChanged: {
        if(ocp_threshold_state === 3){
            platformInterface.ocp_threshold = 2
        }
        else platformInterface.ocp_threshold = ocp_threshold_state
    }

    property var mode_state: platformInterface.initial_status.mode_index_status
    onMode_stateChanged: {
        platformInterface.mode = mode_state
    }


    //    property var read_vin: platformInterface.status_voltage_current.vingood
    //    onRead_vinChanged: {
    //        if(read_vin === "good") {
    //            ledLight.status = "green"
    //            vinlable = "over"
    //            ledLight.label = "VIN Ready ("+vinlable + " 4.5V)"
    //            enableSwitch.enabled  = true
    //            enableSwitch.opacity = 1.0

    //        }
    //        else {
    //            ledLight.status = "red"
    //            vinlable = "under"
    //            ledLight.label = "VIN Ready ("+vinlable +" 4.5V)"
    //            enableSwitch.enabled  = false
    //            enableSwitch.opacity = 0.5
    //            platformInterface.enabled = false
    //        }
    //    }

    //    Component.onCompleted:  {
    ////        multiplePlatform.check_class_id()
    //        Help.registerTarget(efficiencyGauge, "This gauge shows the efficiency of the Switcher. This is calculated with Pout/Pin. Regulator efficiency-accurate when a load is present.", 0, "advance15AHelp")
    //        Help.registerTarget(powerDissipatedGauge, "This gauge shows the power dissipated by the Switcher in Watts. This is calculated with Pout - Pin.", 1, "advance15AHelp")
    //        Help.registerTarget(tempGauge, "This gauge shows the temperature of the board.", 2, "advance15AHelp")
    //        Help.registerTarget(powerOutputGauge, "This gauge shows the Output Power in Watts.", 3, "advance15AHelp")
    //        Help.registerTarget(ledLight, "The LED will light up green when input voltage is ready and greater than 4.5V. It will light up red when under 4.5V to warn the user that input voltage is not high enough.", 4, "advance15AHelp")
    //        Help.registerTarget(inputCurrent, "Input current is shown here in A.", 6, "advance15AHelp")
    //        Help.registerTarget(inputVoltage, "Input voltage is shown here in Volts.", 5, "advance15AHelp")
    //        Help.registerTarget(softStartList, "Select either a 5ms or 10ms softstart. Converter reset required to see changes", 7,"advance15AHelp")
    //        Help.registerTarget(vbVoltage, "This is internal LDO output voltage", 8, "advance15AHelp")
    //        Help.registerTarget(vccVoltage, "Biasing voltage used by converter- tied to input voltage by default.", 9, "advance15AHelp")
    //        Help.registerTarget(vboostVoltage, "This is boot-strap (pin BST) voltage. ", 10, "advance15AHelp")
    //        Help.registerTarget(enableSwitch, "Enables and disables 15A switcher output.", 11, "advance15AHelp")
    //        Help.registerTarget(outputVoltageList, "Select output voltages 1, 1.8, 2.5, and 3.3V. Converter will UVLO when changing from a higher output voltage to a lower output voltage when in DCM mode.", 12, "advance15AHelp")
    //        Help.registerTarget(ocplist,"Low-Side Sensing, Peak-Current detect threshold. Value is approximate as it is duty cycle and FSW dependant. CONVERTER RESET REQUIRED TO CHANGE THRESHOLD.", 13, "advance15AHelp")
    //        if(multiplePlatform.modeVisible === true) {
    //            Help.registerTarget(modeSelect, "Select Converter Switching Mode. 550Khz or 1.1Mhz in either DCM or FCCM. When in 1.1Mhz FCCM, converter may go into over-temperature protect mode after some time at max load.", 16, "advance15AHelp")
    //        }
    //        Help.registerTarget(ouputCurrent,"Output current is shown here in A.", 15, "advance15AHelp")
    //        Help.registerTarget(outputVoltage,"Output voltage is shown here in Volts.", 14, "advance15AHelp")
    //    }

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
                topMargin: 30
                horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: pageText
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }

                text:  platformIdentification.partNumber
                font.pixelSize: (parent.width + parent.height)/ 30
                color: "black"
            }
            Text {
                anchors {
                    top: pageText.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                text: platformIdentification.title
                font.pixelSize: (parent.width + parent.height)/ 40
                color: "black"

            }
        }

        Rectangle {
            id: controlSection
            width: parent.width
            height: parent.height - 100


            anchors{
                top: pageLable.bottom
                topMargin: 10
            }

            Rectangle {
                id: topControl
                anchors {
                    left: controlSection.left
                    top: controlSection.top
                }
                width: parent.width
                height: controlSection.height/4
                Rectangle {
                    id: efficiencyGaugeContainer
                    width: parent.width/4
                    height: parent.height/1.5
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                    color: "transparent"
                    Widget01.SGAlignedLabel {
                        id: efficiencyGaugeLabel
                        target: efficiencyGauge
                        text: "Efficiency"
                        margin: 0
                        anchors.centerIn: parent
                        alignment: Widget01.SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter
                        Widget01.SGCircularGauge {
                            id: efficiencyGauge
                            gaugeFillColor1: Qt.rgba(1,0,0,1)
                            gaugeFillColor2: Qt.rgba(0,1,.25,1)
                            minimumValue: 0
                            maximumValue: 100
                            tickmarkStepSize: 10
                            width: efficiencyGaugeContainer.width
                            height: efficiencyGaugeContainer.height/0.7
                            anchors.centerIn: parent
                            unitText: "%"
                            unitTextFontSizeMultiplier: ratioCalc * 2.2
                            //value: platformInterface.status_voltage_current.efficiency
                            Behavior on value { NumberAnimation { duration: 300 } }

                        }
                    }
                }

                Rectangle {
                    id: powerDissipatedContainer
                    width: parent.width/4
                    height: parent.height/1.5
                    anchors {
                        left: efficiencyGaugeContainer.right
                        top: parent.top
                    }
                    color: "transparent"
                    Widget01.SGAlignedLabel {
                        id: powerDissipatedLabel
                        target: powerDissipatedGauge
                        text: "Power Loss"
                        margin: 0
                        anchors.centerIn: parent
                        alignment: Widget01.SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter
                        Widget01.SGCircularGauge {
                            id: powerDissipatedGauge
                            gaugeFillColor1: Qt.rgba(0,1,.25,1)
                            gaugeFillColor2: Qt.rgba(1,0,0,1)
                            minimumValue: 0
                            maximumValue: 5
                            tickmarkStepSize: 0.5
                            width: powerDissipatedContainer.width
                            height: powerDissipatedContainer.height/0.7
                            anchors.centerIn: parent
                            unitText: "W"
                            unitTextFontSizeMultiplier: ratioCalc * 2.2

                            //value: platformInterface.status_voltage_current.power_dissipated
                            Behavior on value { NumberAnimation { duration: 300 } }
                        }
                    }

                }
                Rectangle {
                    id: powerOutputContainer
                    width: parent.width/4
                    height: parent.height/1.5
                    anchors {
                        left: powerDissipatedContainer.right
                        top: parent.top
                    }
                    color: "transparent"
                    Widget01.SGAlignedLabel {
                        id: powerOutputLabel
                        target: powerOutputGauge
                        text: "Output Power"
                        margin: 0
                        anchors.centerIn: parent
                        alignment: Widget01.SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter
                        Widget01.SGCircularGauge {
                            id: powerOutputGauge
                            gaugeFillColor1: Qt.rgba(0,0.5,1,1)
                            gaugeFillColor2: Qt.rgba(1,0,0,1)
                            minimumValue: 0
                            maximumValue: 100
                            tickmarkStepSize: 20
                            unitText: "W"
                            unitTextFontSizeMultiplier: ratioCalc * 2.2
                            width: powerOutputContainer.width
                            height: powerOutputContainer.height/0.7
                            anchors.centerIn: parent
                            //value: platformInterface.status_voltage_current.output_power
                            Behavior on value { NumberAnimation { duration: 300 } }
                        }
                    }
                }
                Rectangle {
                    id: tempGaugeContainer
                    width: parent.width/4
                    height: parent.height/1.5
                    anchors {
                        left: powerOutputContainer.right
                        top: parent.top
                    }
                    color: "transparent"
                    Widget01.SGAlignedLabel {
                        id: tempGaugeLabel
                        target: tempGauge
                        text: "Board Temperature"
                        margin: 0
                        anchors.centerIn: parent
                        alignment: Widget01.SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter

                        Widget01.SGCircularGauge {
                            id: tempGauge
                            gaugeFillColor1: Qt.rgba(0,1,.25,1)
                            gaugeFillColor2: Qt.rgba(1,0,0,1)
                            minimumValue: -55
                            maximumValue: 125
                            tickmarkStepSize: 20
                            //outerColor: "#999"
                            unitText: "°C"
                            unitTextFontSizeMultiplier: ratioCalc * 2.2
                            width: tempGaugeContainer.width
                            height: tempGaugeContainer.height/0.7
                            anchors.centerIn: parent
                            //value: platformInterface.status_temperature_sensor.temperature
                            Behavior on value { NumberAnimation { duration: 300 } }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: parent.height - topControl.height

                anchors {
                    top : topControl.bottom
                    topMargin: 20
                }
                Rectangle {
                    id: dataContainer
                    color: "transparent"
                    border.color: "black"
                    border.width: 5
                    radius: 10
                    width: parent.width/3.6
                    height: (parent.height/1.3) + 5

                    anchors {
                        top: parent.top
                        left: parent.left
                        leftMargin : 50
                    }

                    Text {
                        id: containerLabel
                        text: "Input"
                        width: parent.width/5
                        height: parent.height/11
                        anchors {
                            top: parent.top
                            topMargin: 5
                            horizontalCenter: parent.horizontalCenter
                        }
                        font.pixelSize: height
                        fontSizeMode: Text.Fit
                        font.bold: true
                    }

                    Rectangle {
                        id: line
                        height: 2
                        width: parent.width - 9
                        anchors {
                            top: containerLabel.bottom
                            topMargin: 2
                            left: parent.left
                            leftMargin: 5
                        }
                        border.color: "gray"
                        radius: 2
                    }

                    ColumnLayout{
                        width: dataContainer.width
                        height: (dataContainer.height - containerLabel.contentHeight - line.height) - 20
                        anchors.top: line.bottom

                        Rectangle {
                            id: statusLightContainer
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/10
                            color: "transparent"
                            Widget01.SGAlignedLabel {
                                id: vinLabel
                                target: ledLight
                                text:  "VIN Ready (under 2.5V)"
                                alignment: Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                Widget01.SGStatusLight {
                                    id: ledLight
                                    width: statusLightContainer.width/2
                                    height: statusLightContainer.height/2


                                }
                            }
                        }
                        Rectangle {
                            id: warningBox2
                            color: "red"
                            Layout.preferredWidth:parent.width - 40
                            Layout.preferredHeight: parent.height/12
                            Layout.alignment: Qt.AlignCenter

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
                                font.family:  Fonts.sgicons
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
                                font.family:  Fonts.sgicons
                                font.pixelSize: (parent.width + parent.height)/19
                                color: "white"
                            }
                        }
                        Rectangle {
                            id: inputContainer
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/8
                            color: "transparent"
                            Widget01.SGAlignedLabel {
                                id: inputVoltageLabel
                                target: inputVoltage
                                text: "Input Voltage"
                                alignment: Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                Widget01.SGInfoBox {
                                    id: inputVoltage
                                    text: platformInterface.status_voltage_current.vin.toFixed(2)
                                    unit: "V"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    height: (inputContainer.height - inputVoltageLabel.contentHeight) + 20
                                    width: (inputContainer.width - inputVoltageLabel.contentWidth)/2
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true


                                }
                            }
                        }
                        Rectangle {
                            id: inputCurrentConatiner
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/8
                            color: "transparent"
                            Widget01.SGAlignedLabel {
                                id: inputCurrentLabel
                                target: inputCurrent
                                text: "Input Current"
                                alignment: Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                Widget01.SGInfoBox {
                                    id: inputCurrent
                                    text: platformInterface.status_voltage_current.iin.toFixed(2)
                                    unit: "A"
                                    height: (inputCurrentConatiner.height - inputCurrentLabel.contentHeight) + 20
                                    width: (inputCurrentConatiner.width - inputCurrentLabel.contentWidth)/2
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true


                                }
                            }
                        }
                        Rectangle {
                            id: lineAboveVCC
                            Layout.preferredHeight: 2
                            Layout.preferredWidth: parent.width - 8
                            border.color: "gray"
                            radius: 2
                        }

                        Rectangle{
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/9
                            color: "transparent"
                            RowLayout {
                                id: vccContainer
                                anchors.fill: parent
                                Rectangle{
                                    Layout.preferredWidth:parent.width/2.5
                                    Layout.preferredHeight: parent.height
                                    Layout.alignment: Qt.AlignCenter

                                    Widget01.SGAlignedLabel {
                                        id: vccLabel
                                        target: vccCombo
                                        text: "VCC"
                                        horizontalAlignment: Text.AlignHCenter
                                        font.bold : true
                                        alignment:  Widget01.SGAlignedLabel.SideLeftCenter
                                        anchors {
                                            verticalCenter: parent.verticalCenter
                                            right: parent.right
                                        }
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        Widget01.SGComboBox {
                                            id:  vccCombo
                                            borderColor: "black"
                                            textColor: "black"          // Default: "black"
                                            indicatorColor: "black"
                                            model: [ "PVCC" , "External"]
                                        }
                                    }
                                }

                                Widget01.SGInfoBox {
                                    id: vccInfoBox
                                    unit: "V"
                                    Layout.alignment: Qt.AlignLeft
                                    Layout.preferredWidth:parent.width/4
                                    Layout.preferredHeight: parent.height/1.3
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true


                                }
                            }
                        }


                        Rectangle {
                            id: pvccConatiner
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/9
                            color: "transparent"
                            Widget01.SGAlignedLabel {
                                id: pvccLabel
                                target: pvccValue
                                text: "PVCC"
                                alignment: Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                Widget01.SGInfoBox {
                                    id: pvccValue
                                    //text: platformInterface.status_voltage_current.iin.toFixed(2)
                                    unit: "V"
                                    height: (pvccConatiner.height - pvccLabel.contentHeight) + 20
                                    width: (pvccConatiner.width - pvccLabel.contentWidth)/2
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true


                                }
                            }
                        }


                        Rectangle {
                            id: vbstConatiner
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/9
                            color: "transparent"
                            Widget01.SGAlignedLabel {
                                id: vbstLabel
                                target: vbstValue
                                text: "VBST"
                                alignment: Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                Widget01.SGInfoBox {
                                    id: vbstValue
                                    //text: platformInterface.status_voltage_current.iin.toFixed(2)
                                    unit: "V"
                                    height: (vbstConatiner.height - vbstLabel.contentHeight) + 15
                                    width: (vbstConatiner.width - vbstLabel.contentWidth)/2
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true
                                }
                            }
                        }

                    }
                }




                Rectangle {
                    id: dataContainerMiddle
                    width: parent.width/3.6
                    height: parent.height/1.3
                    color: "transparent"
                    border.color: "black"
                    border.width: 5
                    radius: 10


                    anchors {
                        left: dataContainer.right
                        leftMargin: 40
                        top: parent.top
                        right: dataContainerRight.left
                        rightMargin: 40
                    }

                    Text {
                        id: containerLabelMiddle
                        text: "Control"
                        width: parent.width/5
                        height: parent.height/11
                        anchors {
                            top: parent.top
                            topMargin: 5
                            horizontalCenter: parent.horizontalCenter
                        }
                        font.pixelSize: height
                        fontSizeMode: Text.Fit
                        font.bold: true
                    }

                    Rectangle {
                        id: lineUnderMiddle
                        height: 2
                        width: parent.width - 9
                        anchors {
                            top: containerLabelMiddle.bottom
                            topMargin: 2
                            left: parent.left
                            leftMargin: 5
                        }
                        border.color: "gray"
                        radius: 2
                    }
                    ColumnLayout{
                        width: dataContainerMiddle.width
                        height: (dataContainerMiddle.height - containerLabelMiddle.contentHeight - lineUnderMiddle.height) - 20
                        anchors {
                            top: lineUnderMiddle.bottom
                            topMargin :  5
                            horizontalCenter: parent.horizontalCenter
                        }
                        Rectangle {
                            id:enableContainer
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/10
                            color: "transparent"

                            Widget01.SGAlignedLabel {
                                id: enableSwitchLabel
                                target: enableSwitch
                                text: "Enable (EN)"
                                alignment:  Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true
                                Widget01.SGSwitch {
                                    id: enableSwitch
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel:   "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"


                                }
                            }
                        }
                        Rectangle {
                            id:hiccupContainer
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/10
                            color: "transparent"

                            Widget01.SGAlignedLabel {
                                id: hiccupLabel
                                target: hiccupSwitch
                                text: "Hiccup"
                                alignment:  Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.5
                                font.bold : true
                                SGSwitch {
                                    id: hiccupSwitch
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel:   "Off"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"

                                }
                            }
                        }
                        Rectangle{
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/9
                            color: "transparent"
                            RowLayout {
                                id: syncContainer
                                anchors.fill: parent
                                Rectangle{
                                    Layout.preferredWidth:parent.width/2.5
                                    Layout.preferredHeight: parent.height
                                    Layout.alignment: Qt.AlignCenter

                                    Widget01.SGAlignedLabel {
                                        id: syncLabel
                                        target: syncCombo
                                        text: "Sync"
                                        horizontalAlignment: Text.AlignHCenter
                                        font.bold : true
                                        alignment:  Widget01.SGAlignedLabel.SideLeftCenter
                                        anchors {
                                            verticalCenter: parent.verticalCenter
                                            right: parent.right
                                        }
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        Widget01.SGComboBox {
                                            id:  syncCombo
                                            borderColor: "black"
                                            textColor: "black"          // Default: "black"
                                            indicatorColor: "black"
                                            model: [ "Master", "Slave" ]
                                        }
                                    }
                                }
                                Widget01.SGInfoBox {
                                    id: syncInfoBox
                                    unit: "V"
                                    Layout.alignment: Qt.AlignLeft
                                    Layout.preferredWidth:parent.width/4
                                    Layout.preferredHeight: parent.height/1.3
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true
                                }
                            }
                        }

                        Rectangle{
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/9
                            color: "transparent"

                            Widget01.SGAlignedLabel {
                                id: modeLabel
                                target: modeCombo
                                text: "Mode"
                                horizontalAlignment: Text.AlignHCenter
                                font.bold : true
                                alignment:  Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                Widget01.SGComboBox {
                                    id:  modeCombo
                                    borderColor: "black"
                                    textColor: "black"          // Default: "black"
                                    indicatorColor: "black"
                                    model: [ "DCM" , "FCCM"]
                                }
                            }
                        }


                        Rectangle{
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/9
                            color: "transparent"

                            Widget01.SGAlignedLabel {
                                id: softStartLabel
                                target: softStartCombo
                                text: "Soft Start"
                                horizontalAlignment: Text.AlignHCenter
                                font.bold : true
                                alignment:  Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                Widget01.SGComboBox {
                                    id:  softStartCombo
                                    borderColor: "black"
                                    textColor: "black"          // Default: "black"
                                    indicatorColor: "black"
                                    model: [ "DCM" , "FCCM"]
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: dataContainerRight
                    color: "transparent"
                    border.color: "black"
                    border.width: 5
                    radius: 10
                    width: parent.width/3.6
                    height: parent.height/1.3

                    anchors {
                        right: parent.right
                        rightMargin: 50
                        top: parent.top
                    }

                    Text {
                        id: containerLabelout
                        text: "Output"
                        width: parent.width/5
                        height: parent.height/10
                        anchors {
                            top: parent.top
                            topMargin: 20
                            horizontalCenter: parent.horizontalCenter
                        }

                        font.pixelSize: height
                        font.bold: true
                        fontSizeMode: Text.Fit
                    }

                    Rectangle {
                        id: lineUnderOuput
                        height: 2
                        width: parent.width - 9
                        anchors {
                            top: containerLabelout.bottom
                            topMargin: 2
                            left: parent.left
                            leftMargin: 5
                        }
                        border.color: "gray"
                        radius: 2
                    }

                    ColumnLayout{
                        width: dataContainerRight.width
                        height: (dataContainerRight.height - containerLabelout.contentHeight - lineUnderOuput.height) - 40
                        anchors {
                            top: lineUnderOuput.bottom
                            horizontalCenter: parent.horizontalCenter
                        }

                        Rectangle {
                            id:frequencyContainer
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/8
                            color: "transparent"

                            Widget01.SGAlignedLabel {
                                id: frequencyLabel
                                target: frequencySlider
                                text: "Switch \n Frequency"
                                alignment:  Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.1
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                Widget01.SGSlider{
                                    id: frequencySlider
                                    fontSizeMultiplier: ratioCalc * 0.7
                                    fromText.text: "100 Khz"
                                    toText.text: "1.2 Mhz"
                                    from: 100
                                    to: 1200
                                    stepSize: 100
                                    width: (frequencyContainer.width - frequencyLabel.contentWidth) - 20
                                    height: (frequencyContainer.height)
                                    handleSize: 30

                                }

                            }

                        }

                        Rectangle {
                            id:outputContainer
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/8
                            color: "transparent"

                            Widget01.SGAlignedLabel {
                                id: outputLabel
                                target: selectOutputSlider
                                text: "Select \n Output"
                                alignment:  Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                Widget01.SGSlider{
                                    id: selectOutputSlider
                                    fontSizeMultiplier: ratioCalc * 0.8
                                    fromText.text: "2 V"
                                    toText.text: "30 V"
                                    from: 2
                                    to: 20
                                    stepSize: 0.1
                                    width: (outputContainer.width - outputLabel.contentWidth) - 40
                                    height: outputContainer.height
                                    handleSize: 30

                                }

                            }

                        }

                        Rectangle {
                            id:ocpContainer
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/8
                            color: "transparent"

                            Widget01.SGAlignedLabel {
                                id: ocpLabel
                                target: ocpSlider
                                text: "OCP \n Threshold"
                                alignment:  Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                Widget01.SGSlider{
                                    id: ocpSlider
                                    fontSizeMultiplier: ratioCalc * 0.8
                                    fromText.text: "0 A"
                                    toText.text: "6 A"
                                    from: 0
                                    to: 6
                                    stepSize: 0.5
                                    width: (ocpContainer.width - ocpLabel.contentWidth) - 20
                                    height: ocpContainer.height
                                    handleSize: 30
                                }

                            }
                        }

                        Rectangle {
                            id: outputVoltageContainer
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/8
                            color: "transparent"
                            Widget01.SGAlignedLabel {
                                id: outputVoltageLabel
                                target: outputVoltage
                                text: "Output Voltage"
                                alignment: Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                Widget01.SGInfoBox {
                                    id: outputVoltage
                                    text: platformInterface.status_voltage_current.vin.toFixed(2)
                                    unit: "V"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    height: (outputVoltageContainer.height - outputVoltageLabel.contentHeight) + 20
                                    width: (outputVoltageContainer.width - outputVoltageLabel.contentWidth)/2
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true


                                }
                            }
                        }
                        Rectangle {
                            id: outputCurrentConatiner
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight: parent.height/8
                            color: "transparent"
                            Widget01.SGAlignedLabel {
                                id: outputCurrentLabel
                                target: outputCurrent
                                text: "Output Current"
                                alignment: Widget01.SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                Widget01.SGInfoBox {
                                    id: outputCurrent
                                    text: platformInterface.status_voltage_current.iin.toFixed(2)
                                    unit: "A"
                                    height: (outputCurrentConatiner.height - outputCurrentLabel.contentHeight) + 20
                                    width: (outputCurrentConatiner.width - outputCurrentLabel.contentWidth)/2
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    unitFont.bold: true


                                }
                            }
                        }

                    }


                } // end of output
            }
        }
    }
} // end of controlContainer




