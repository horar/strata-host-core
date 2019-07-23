import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "../sgwidgets"
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    property bool holder: false
    property int bitData: 0
    property string binaryConversion: ""
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    Component.onCompleted: {
        Help.registerTarget(topSetting, "These gauges monitor the board temperature around each eFuse in degrees Celsius.", 0, "advanceHelp")
        Help.registerTarget(leftSetting,"The LED is green when input voltage is good (above 9.2V). Both input and output voltage and current are displayed here. ", 1, "advanceHelp")
        Help.registerTarget(eFuse1,"The enable switches can enable eFuse 1 and will be grayed out if the input voltage is not above the minimum threshold (9.2V).", 2 , "advanceHelp")
        Help.registerTarget(eFuse2,"The enable switches can enable eFuse 2 and will be grayed out if the input voltage is not above the minimum threshold (9.2V).", 3 , "advanceHelp")
        Help.registerTarget(rlim1,"These set the RLIM value for each of the eFuses individually. The corresponding current limit for the RLIM selected can be found in the datasheet for the eFuse 1.", 4 , "advanceHelp")
        Help.registerTarget(rlim2,"These set the RLIM value for each of the eFuses individually. The corresponding current limit for the RLIM selected can be found in the datasheet for the eFuse 2.", 5 , "advanceHelp")
        Help.registerTarget(sr1,"These set the slew rate for each of the eFuse 1. ", 6 , "advanceHelp")
        Help.registerTarget(sr2,"This enables/disables the short circuit load of the board which will short the output to GND.", 7 , "advanceHelp")
        Help.registerTarget(shortCircuit,"These set the slew rate for each of the eFuse .", 8 , "advanceHelp")
        Help.registerTarget(bottomSetting,"If the board goes into thermal shutdown a popup window will appear displaying which eFuse went into thermal shutdown. Once the reset button is pressed, the popup window will disappear and the eFuses will be disabled. ", 9 , "advanceHelp")

    }


    property var temp1_noti: platformInterface.periodic_status.temperature1
    onTemp1_notiChanged: {
        sgCircularGauge.value = temp1_noti
    }
    property var temp2_noti: platformInterface.periodic_status.temperature2
    onTemp2_notiChanged: {
        sgCircularGauge2.value = temp2_noti
    }
    property var vin_noti: platformInterface.periodic_status.vin
    onVin_notiChanged: {
        inputVoltage.info = vin_noti.toFixed(2)
    }
    property var vout_noti: platformInterface.periodic_status.vout
    onVout_notiChanged: {
        outputVoltage.info = vout_noti.toFixed(2)
    }
    property var iin_noti: platformInterface.periodic_status.iin
    onIin_notiChanged: {
        inputCurrent.info = iin_noti.toFixed(2)
    }
    property var iout_noti: platformInterface.periodic_status.iout
    onIout_notiChanged: {
        outputCurrent.info = iout_noti.toFixed(2)
    }
    property var vin_status_noti: platformInterface.periodic_status.vin_led
    onVin_status_notiChanged: {
        if(vin_status_noti === "good"){
            vinLight.status = "green"
            eFuse1.enabled = true
            eFuse2.enabled = true
            eFuse1.opacity = 1.0
            eFuse2.opacity =  1.0
        }
        else {
            vinLight.status = "red"
            eFuse1.enabled = false
            eFuse2.enabled = false
            eFuse1.opacity = 0.5
            eFuse2.opacity =  0.5
            platformInterface.enable_1 = false
            platformInterface.enable_2 = false
        }
    }
    property var thermal1_status_noti: platformInterface.thermal_shutdown_eFuse1.status
    onThermal1_status_notiChanged: {
        if(thermal1_status_noti === "yes"){
            thermalLed1.status = "red"
            warningPopup.open()
        }
        else {
            thermalLed1.status = "off"
        }
    }

    property var thermal2_status_noti: platformInterface.thermal_shutdown_eFuse2.status
    onThermal2_status_notiChanged: {
        if(thermal2_status_noti === "yes"){
            console.log("in thermal2")
            thermalLed2.status = "red"
            warningPopup.open()
        }
        else {
            thermalLed2.status = "off"
        }
    }
    property var periodic_status_en1: platformInterface.enable_status.en1
    onPeriodic_status_en1Changed: {
        if(periodic_status_en1 === "on"){
            platformInterface.enable_1 = true
        }
        else  platformInterface.enable_1 = false
    }

    property var periodic_status_en2: platformInterface.enable_status.en2
    onPeriodic_status_en2Changed: {
        if(periodic_status_en2 === "on"){
            platformInterface.enable_2 = true
        }
        else  platformInterface.enable_2 = false
    }


    Popup{
        id: warningPopup
        width: root.width/2.6
        height: root.height/5
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        modal: true
        focus: true
        closePolicy:Popup.NoAutoClose
        background: Rectangle{
            width: warningPopup.width
            height: warningPopup.height
            color: "white"

        }
        Rectangle {
            id: warningBox
            color: "red"
            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter

            }
            width: (parent.width)
            height: parent.height/5
            Text {
                id: warningText
                anchors {
                    centerIn: warningBox
                }
                text: "<b>Thermal Warning detected. To proceed click reset.</b>"
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
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 17
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
                font.pixelSize: (parent.width + parent.height)/ 17
                color: "white"
            }
        }

        RowLayout {
            id: thermalContainer
            width: parent.width
            height: parent.height/4
            anchors{
                top: warningBox.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            SGStatusLight {
                id: thermalLed1
                width: parent.width/2
                height: parent.height
                label: "<b>Thermal Failure 1:</b>" // Default: "" (if not entered, label will not appear)
                labelLeft: true       // Default: true
                lightSize: ratioCalc * 30           // Default: 50
                textColor: "black"      // Default: "black"
                fontSize: ratioCalc * 20
                Layout.alignment: Qt.AlignCenter
            }
            SGStatusLight {
                id: thermalLed2
                width: parent.width/2
                height: parent.height
                label: "<b>Thermal Failure 2:</b>" // Default: "" (if not entered, label will not appear)
                labelLeft: true       // Default: true
                lightSize: ratioCalc * 30           // Default: 50
                textColor: "black"      // Default: "black"
                fontSize: ratioCalc * 20
                Layout.alignment: Qt.AlignCenter
            }
        }

        Rectangle{
            id:resetButtonContainer
            width: parent.width
            height: parent.height/4
            color: "transparent"
            anchors.top: thermalContainer.bottom
            anchors.topMargin: 10


            Button {
                id: resetButton
                visible: true
                anchors.horizontalCenter: {
                    resetButtonContainer.horizontalCenter
                }
                width: parent.width/5
                height: parent.height

                text: qsTr("Reset")
                checkable: true
                background: Rectangle {
                    id: backgroundContainer1
                    implicitWidth: 100
                    implicitHeight: 50
                    opacity: enabled ? 1 : 0.3
                    border.color: resetButton.down ? "#17a81a" : "black"//"#21be2b"
                    border.width: 1
                    color: "#33b13b"
                    radius: 10
                }

                contentItem: Text {
                    text: resetButton.text
                    font.pixelSize: 18
                    //font: resetButton.font
                    font.bold: true
                    opacity: enabled ? 1.0 : 0.3
                    color: resetButton.down ? "#17a81a" : "white"//"#21be2b"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                onClicked: {
                    warningPopup.close()
                    platformInterface.reset.update()
                    platformInterface.set_enable_1.update("off")
                    platformInterface.set_enable_2.update("off")
                    platformInterface.short_circuit_en.update("off")
                    platformInterface.enable_1 = false
                    platformInterface.enable_2 = false
                    platformInterface.short_circuit_state = false
                    eFuse1.enabled = true
                    eFuse2.enabled = true
                    eFuse1.opacity = 1.0
                    eFuse2.opacity =  1.0
                    thermalLed2.status = "off"
                    thermalLed1.status = "off"
                }
            }
        }
    } // end of the popup
    Rectangle{
        width: parent.width
        height: parent.height
        color: "transparent"
        id: graphContainer

        Text {
            id: partNumber
            text: efuseClassID.partNumber
            font.bold: true
            color: "black"
            anchors{
                top: parent.top
                topMargin: 15
                horizontalCenter: parent.horizontalCenter
            }
            font.pixelSize: (parent.height + parent.width)/70
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: topSetting
            width: parent.width/2.4
            height: parent.height/3.7
            color: "transparent"

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: partNumber.bottom
                topMargin: 5
            }


            RowLayout {
                anchors.fill: parent

                SGCircularGauge {
                    id: sgCircularGauge
                    value: platformInterface.periodic_status.temperature1.toFixed(2)
                    minimumValue: 0
                    maximumValue: 100
                    tickmarkStepSize: 10
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    gaugeRearColor: "#ddd"                // Default: "#ddd"(background color that gets filled in by gauge)
                    centerColor: "black"
                    outerColor: "#999"
                    gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    unitLabel: "˚C"
                    gaugeTitle: "Board Temperature \n Sensor 1"
                    Layout.alignment: Qt.AlignCenter

                }


                SGCircularGauge {
                    id: sgCircularGauge2
                    value: platformInterface.periodic_status.temperature2.toFixed(2)
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    minimumValue: 0
                    maximumValue: 100
                    tickmarkStepSize: 10
                    gaugeRearColor: "#ddd"                // Default: "#ddd"(background color that gets filled in by gauge)
                    centerColor: "black"
                    outerColor: "#999"
                    gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    unitLabel: "˚C"                        // Default: "RPM"
                    gaugeTitle: "Board Temperature  \n Sensor 2"
                    Layout.alignment: Qt.AlignCenter

                }

            }
        }
        Rectangle {
            id: leftSetting
            width: parent.width/1.5
            height: parent.height/3.2
            color: "transparent"
            border.color: "black"
            border.width: 5
            radius: 10

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: topSetting.bottom
                topMargin: 20
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                Text {
                    id: title
                    anchors{
                        top: parent.top
                        topMargin: 5
                        horizontalCenter: parent.horizontalCenter
                    }

                    text: "Telemetry"
                    font.bold: true
                    color: "black"
                    font.pixelSize: ratioCalc * 25
                    horizontalAlignment: Text.AlignHCenter

                }
                Rectangle {
                    id: line
                    height: 2
                    width: parent.width - 15
                    anchors {
                        top: title.bottom
                        topMargin: 7
                        left: parent.left
                        leftMargin: 5
                    }
                    border.color: "gray"
                    radius: 2
                }
                Rectangle {
                    id: inputVoltageGoodContainter
                    width: parent.width
                    height: parent.height/4
                    anchors {

                        top: line.bottom
                        topMargin: 5
                    }
                    color: "transparent"
                    SGStatusLight {
                        id: vinLight
                        anchors.centerIn: parent
                        label: "<b>Input Voltage Good:</b>" // Default: "" (if not entered, label will not appear)
                        labelLeft: true       // Default: true
                        lightSize: ratioCalc * 30         // Default: 50
                        textColor: "black"      // Default: "black"
                        fontSize: ratioCalc * 20

                    }
                }

                Rectangle {
                    id: inputVoltageContainter
                    width: parent.width/2
                    height: (parent.height - inputVoltageGoodContainter.height) - 80
                    anchors {
                        left: parent.left
                        leftMargin: 30
                        top: inputVoltageGoodContainter.bottom
                        topMargin: 5
                    }

                    color: "transparent"


                    SGLabelledInfoBox {
                        id: inputVoltage
                        anchors{
                            top: parent.top
                            topMargin: 10
                            horizontalCenter: parent.horizontalCenter
                        }
                        width: parent.width
                        height: parent.height/2
                        infoBoxWidth: parent.width/2.5
                        infoBoxHeight: parent.height/2.5
                        label: "Input Voltage "
                        info: platformInterface.periodic_status.vin.toFixed(2)
                        unit: "V"
                        infoBoxColor: "black"
                        labelColor: "black"
                        fontSize: ratioCalc * 20 // sets the font size of the lable
                        unitSize: ratioCalc * 20 // sets the unit size of the lable

                    }

                    SGLabelledInfoBox {
                        id: inputCurrent
                        anchors{
                            top: inputVoltage.bottom
                            topMargin: 10
                            horizontalCenter: parent.horizontalCenter
                        }

                        width: parent.width
                        height: parent.height/2
                        infoBoxWidth: parent.width/2.5
                        infoBoxHeight: parent.height/2.5
                        label: "Input Current "
                        info: platformInterface.periodic_status.iin.toFixed(2)
                        unit: "A"
                        infoBoxColor: "black"
                        labelColor: "black"
                        fontSize: ratioCalc * 20 // sets the font size of the lable
                        unitSize: ratioCalc * 20 // sets the unit size of the lable

                    }



                }

                Rectangle {
                    id: ouputVoltageContainter
                    width: parent.width/2
                    height: (parent.height - inputVoltageGoodContainter.height) - 80
                    anchors {
                        right:parent.right
                        rightMargin: 10
                        left: inputVoltageContainter.right
//                        leftMargin: 10
                        top: inputVoltageGoodContainter.bottom
                        topMargin: 5
                    }

                    color: "transparent"
                    SGLabelledInfoBox {
                        id: outputVoltage
                        anchors{
                            top: parent.top
                            topMargin: 10
                            horizontalCenter: parent.horizontalCenter
                        }
                        width: parent.width
                        height: parent.height/2
                        infoBoxWidth: parent.width/2.5
                        infoBoxHeight: parent.height/2.5
                        label: "Output Voltage "
                        info: platformInterface.periodic_status.vout.toFixed(2)
                        unit: "V"
                        infoBoxColor: "black"
                        labelColor: "black"
                        unitSize: ratioCalc * 20
                        fontSize: ratioCalc * 20

                    }

                    SGLabelledInfoBox {
                        id: outputCurrent
                        anchors{
                            top: outputVoltage.bottom
                            topMargin: 10
                            horizontalCenter: parent.horizontalCenter
                        }
                        width: parent.width
                        height: parent.height/2
                        infoBoxWidth: parent.width/2.5
                        infoBoxHeight: parent.height/2.5
                        label: "Output Current "
                        info: platformInterface.periodic_status.vout.toFixed(2)
                        unit: "A"
                        infoBoxColor: "black"
                        labelColor: "black"
                        fontSize: ratioCalc * 20
                        unitSize: ratioCalc * 20

                    }

                }

            }
        }

        Rectangle {
            id: bottomSetting
            width: parent.width/1.5
            height: parent.height/2.1
            anchors {
                top: leftSetting.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 10
            }
            color: "transparent"
            border.color: "black"
            border.width: 5
            radius: 10

            Text {
                id: titleControl
                text: "Control"
                font.bold: true
                color: "black"
                anchors{
                    top: parent.top
                    topMargin: 15
                    horizontalCenter: parent.horizontalCenter
                }
                font.pixelSize: ratioCalc * 25
                horizontalAlignment: Text.AlignHCenter
            }
            Rectangle {
                id: lineUnderControlTitle
                height: 2
                width: parent.width - 15
                anchors {
                    top: titleControl.bottom
                    topMargin: 7
                    left: parent.left
                    leftMargin: 5
                }
                border.color: "darkgray"
                radius: 2
            }


            Rectangle {
                id: bottomLeftSetting
                width: parent.width/3.2
                height: parent.height/1.3
                anchors {
                    left: parent.left
                    leftMargin: 30
                    top: lineUnderControlTitle.bottom
                    topMargin: 5
                }
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"


                    Rectangle{
                        id: containerOne
                        width: parent.width
                        height: parent.height/3.3
                        color: "transparent"
                        anchors{
                            top: parent.top
                            topMargin: 4
                            horizontalCenter: parent.horizontalCenter
                            //horizontalCenterOffset: ((sr1.width - width)/2) + 10
                        }

                        SGSwitch {
                            id: eFuse1
                            label: "Enable 1"
                            anchors.centerIn: parent
                            fontSizeLabel: ratioCalc * 20
                            labelLeft: true              // Default: true (controls whether label appears at left side or on top of switch)
                            checkedLabel: "On"       // Default: "" (if not entered, label will not appear)
                            uncheckedLabel: "Off"    // Default: "" (if not entered, label will not appear)
                            labelsInside: true              // Default: true (controls whether checked labels appear inside the control or outside of it
                            switchWidth: parent.width/3.5              // Default: 52 (change for long custom checkedLabels when labelsInside)
                            switchHeight: parent.height/2              // Default: 26
                            textColor: "black"              // Default: "black"
                            handleColor: "#33b13b"            // Default: "white"
                            grooveColor: "black"             // Default: "#ccc"
                            grooveFillColor: "black"         // Default: "#0cf"
                            checked: platformInterface.enable_1
                            onToggled: {
                                if(checked)
                                    platformInterface.set_enable_1.update("on")
                                else
                                    platformInterface.set_enable_1.update("off")

                                platformInterface.enable_1 = checked
                            }
                        }
                    }
                    Rectangle{
                        id: containerTwo
                        width: parent.width
                        height: parent.height/3.3
                        anchors{
                            top: containerOne.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        color: "transparent"
                        SGComboBox {
                            id: rlim1
                            anchors{
                                horizontalCenter: parent.horizontalCenter
                                //horizontalCenterOffset: ((sr1.width - width)/2)
                            }
                            comboBoxWidth: parent.width/3
                            comboBoxHeight: parent.height/1.5
                            label: "RLIM 1"   // Default: "" (if not entered, label will not appear)
                            labelLeft: true            // Default: true
                            textColor: "black"         // Default: "black"
                            indicatorColor: "#33b13b"      // Default: "#aaa"
                            borderColor: "black"         // Default: "#aaa"
                            boxColor: "black"           // Default: "white"
                            dividers: true              // Default: false
                            model: ["100Ω", "55Ω", "38Ω", "29Ω"]
                            fontSize: ratioCalc * 20
                            dataSize: ratioCalc * 16
                            onActivated: {
                                platformInterface.set_rlim_1.update(currentText.substring(0,currentText.length - 1))
                            }
                        }
                    }

                    Rectangle{
                        id: containerThree
                        width: parent.width
                        height: parent.height/3.3
                        anchors{
                            top: containerTwo.bottom
                            horizontalCenter: parent.horizontalCenter
                            //horizontalCenterOffset: ((rlim1.width - width)/2)
                        }
                        color: "transparent"

                        SGComboBox {
                            id: sr1
                            anchors{
                                //centerIn: parent
                                 horizontalCenter: parent.horizontalCenter
                                horizontalCenterOffset: (rlim1.width - width)/2
                            }
                            comboBoxWidth: parent.width/3
                            comboBoxHeight: parent.height/1.5
                            label: "Slew Rate 1"   // Default: "" (if not entered, label will not appear)
                            labelLeft: true            // Default: true
                            textColor: "black"         // Default: "black"
                            indicatorColor: "#33b13b"      // Default: "#aaa"
                            borderColor: "black"         // Default: "#aaa"
                            boxColor: "black"           // Default: "white"
                            dividers: true              // Default: false
                            model: efuseClassID.slewModel
                            fontSize: ratioCalc * 20
                            dataSize: ratioCalc * 16
                            onActivated: {
                                if(currentIndex === 0)
                                    platformInterface.set_SR_1.update("default")
                                else platformInterface.set_SR_1.update("slow")
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: middleSetting
                width: parent.width/5
                height: parent.height/1.4
                color: "transparent"
                anchors {
                    left: bottomLeftSetting.right
                    leftMargin: 20
                    top: lineUnderControlTitle.bottom
                    topMargin: 5
                    horizontalCenter: titleControl.horizontalCenter
                }

                Rectangle{
                    id: shortCircuit
                    width: parent.width
                    height: parent.height/3.3
                    color: "transparent"
                    anchors.centerIn: parent
                    Text {
                        id: name
                        text: qsTr("Short Circuit EN")
                        font.bold: true
                        font.pixelSize: ratioCalc * 20
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    SGSwitch {
                        id: scEnable
                        labelLeft: false              // Default: true (controls whether label appears at left side or on top of switch)
                        checkedLabel: "On"       // Default: "" (if not entered, label will not appear)
                        uncheckedLabel: "Off"    // Default: "" (if not entered, label will not appear)
                        labelsInside: true              // Default: true (controls whether checked labels appear inside the control or outside of it
                        switchWidth: parent.width/3              // Default: 52 (change for long custom checkedLabels when labelsInside)
                        switchHeight: parent.height/1.8          // Default: 26
                        textColor: "black"              // Default: "black"
                        handleColor: "#33b13b"            // Default: "white"
                        grooveColor: "black"             // Default: "#ccc"
                        grooveFillColor: "black"         // Default: "#0cf"
                        anchors {
                            top: name.bottom
                            topMargin: 5
                            horizontalCenter: parent.horizontalCenter
                        }
                        checked: platformInterface.short_circuit_state
                        onToggled: {
                            if(checked)
                                platformInterface.short_circuit_en.update("on")
                            else
                                platformInterface.short_circuit_en.update("off")
                            platformInterface.short_circuit_state = checked

                        }
                    }
                }
            }

            Rectangle {
                id: bottomRightSetting
                width: parent.width/3.2
                height: parent.height/1.3
                color: "transparent"
                anchors {
                    left: middleSetting.right
                    leftMargin: 15
                    right: parent.right
                    rightMargin: 20
                    top: lineUnderControlTitle.bottom
                    topMargin: 5
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    Rectangle{
                        id: containerOneRight
                        width: parent.width
                        height: parent.height/3.3
                        color: "transparent"
                        anchors{
                            top: parent.top
                            topMargin: 4
                            horizontalCenter: parent.horizontalCenter
                            //horizontalCenterOffset: ((sr1.width - width)/2) + 10
                        }
                        SGSwitch {
                            id: eFuse2
                            label: "Enable 2"
                            anchors.centerIn: parent
                            switchWidth: parent.width/3.5              // Default: 52 (change for long custom checkedLabels when labelsInside)
                            switchHeight: parent.height/2
                            fontSizeLabel: ratioCalc * 20
                            labelLeft: true              // Default: true (controls whether label appears at left side or on top of switch)
                            checkedLabel: "On"       // Default: "" (if not entered, label will not appear)
                            uncheckedLabel: "Off"    // Default: "" (if not entered, label will not appear)
                            labelsInside: true              // Default: true (controls whether checked labels appear inside the control or outside of it
                            textColor: "black"              // Default: "black"
                            handleColor: "#33b13b"            // Default: "white"
                            grooveColor: "black"             // Default: "#ccc"
                            grooveFillColor: "black"         // Default: "#0cf"

                            checked: platformInterface.enable_2
                            onToggled: {
                                if(checked)
                                    platformInterface.set_enable_2.update("on")
                                else
                                    platformInterface.set_enable_2.update("off")

                                platformInterface.enable_2 = checked
                            }
                        }
                    }
                    Rectangle{
                        id: containerTwoRight
                        width: parent.width
                        height: parent.height/3.3
                        anchors{
                            top: containerOneRight.bottom
                            horizontalCenter: parent.horizontalCenter
                            //horizontalCenterOffset: ((sr2.width - width)/2)
                        }
                        color: "transparent"

                        SGComboBox {
                            id: rlim2
                            comboBoxWidth: parent.width/3
                            comboBoxHeight: parent.height/1.5
                            anchors{
                                horizontalCenter: parent.horizontalCenter
                                //horizontalCenterOffset: ((sr2.width - width)/2)
                            }

                            label: "RLIM 2"   // Default: "" (if not entered, label will not appear)
                            labelLeft: true            // Default: true
                            textColor: "black"         // Default: "black"
                            indicatorColor: "#33b13b"      // Default: "#aaa"
                            borderColor: "black"         // Default: "#aaa"
                            boxColor: "black"           // Default: "white"
                            dividers: true              // Default: false
                            model: ["100Ω", "55Ω", "38Ω", "29Ω"]
                            fontSize: ratioCalc * 20
                            dataSize: ratioCalc * 16
                            onActivated: {
                                platformInterface.set_rlim_2.update(currentText.substring(0,currentText.length - 1))
                            }
                        }
                    }
                    Rectangle{
                        id: containerThreeRight
                        width: parent.width
                        height: parent.height/3.3
                        anchors{
                            top: containerTwoRight.bottom
                            horizontalCenter: parent.horizontalCenter
                            //horizontalCenterOffset: ((rlim2.width - width)/2) - 10
                        }
                        color: "transparent"

                        SGComboBox {
                            id: sr2
                            anchors{
                                horizontalCenter: parent.horizontalCenter
                                horizontalCenterOffset: (rlim2.width - width)/2
                            }
                            comboBoxWidth: parent.width/3
                            comboBoxHeight: parent.height/1.5
                            label: " Slew Rate 2"   // Default: "" (if not entered, label will not appear)
                            labelLeft: true            // Default: true
                            textColor: "black"         // Default: "black"
                            indicatorColor: "#33b13b"      // Default: "#aaa"
                            borderColor: "black"         // Default: "#aaa"
                            boxColor: "black"           // Default: "white"
                            dividers: true              // Default: false
                            model: efuseClassID.slewModel
                            fontSize: ratioCalc * 20
                            dataSize: ratioCalc * 16

                            onActivated: {
                                if(currentIndex === 0)
                                    platformInterface.set_SR_2.update("default")
                                else platformInterface.set_SR_2.update("slow")
                            }
                        }
                    }
                }
            }
        }
    }
}
