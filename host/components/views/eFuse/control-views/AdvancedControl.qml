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
            console.log("invin good")
            vinLight.status = "green"
            eFuse1.enabled = true
            eFuse2.enabled = true
            eFuse1.opacity = 1.0
            eFuse2.opacity =  1.0
        }
        else {
            console.log("invin bad")
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
            console.log("in thermal1")
//            resetButton.visible = true
//            resetButton.enabled = true
            thermalLed1.status = "red"
            //warningBox2.visible = true
//            eFuse1.enabled = false
//            eFuse2.enabled = false
//            eFuse1.opacity = 0.5
//            eFuse2.opacity =  0.5
            //platformInterface.enable_1 = false
            warningPopup.open()
        }
        else {
            //warningBox2.visible = false
            thermalLed1.status = "off"

        }
    }

    property var thermal2_status_noti: platformInterface.thermal_shutdown_eFuse2.status
    onThermal2_status_notiChanged: {
        if(thermal2_status_noti === "yes"){
            console.log("in thermal2")
            thermalLed2.status = "red"
            warningPopup.open()
//            resetButton.visible = true
//            resetButton.enabled = true
            //warningBox2.visible = true
//            eFuse1.enabled = false
//            eFuse2.enabled = false
//            eFuse1.opacity = 0.5
//            eFuse2.opacity =  0.5
        }
        else {
            thermalLed2.status = "off"
            //warningBox2.visible = false
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
        width: root.width/2.4
        height: root.height/3
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        modal: true
        focus: true
        closePolicy:Popup.NoAutoClose
        background: Rectangle{
            width: warningPopup.width
            height: warningPopup.height
            color: "transparent"

        }
        Rectangle {
            id: warningBox
            color: "red"
            anchors {
                centerIn: parent

            }
            width: (parent.width) + 10
            height: parent.height/6
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
            id:resetButtonContainer
            width: parent.width
            height: parent.height/3
            color: "transparent"
            anchors.top: warningBox.bottom
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Button {
                id: resetButton
                visible: true
                anchors.horizontalCenter: {
                    resetButtonContainer.horizontalCenter
                }
                width: 100
                height: 40

                text: qsTr("Reset")
                checkable: true
                background: Rectangle {
                    id: backgroundContainer1
                    implicitWidth: 100
                    implicitHeight: 40
                    opacity: enabled ? 1 : 0.3
                    border.color: resetButton.down ? "#17a81a" : "black"//"#21be2b"
                    border.width: 1
                    color: "#33b13b"
                    radius: 10
                }

                contentItem: Text {
                    text: resetButton.text
                    font: resetButton.font
                    opacity: enabled ? 1.0 : 0.3
                    color: resetButton.down ? "#17a81a" : "white"//"#21be2b"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                onClicked: {
                    warningPopup.close()
                    platformInterface.reset.update()
                    eFuse1.enabled = true
                    eFuse2.enabled = true
                    eFuse1.opacity = 1.0
                    eFuse2.opacity =  1.0
                    platformInterface.set_enable_1.update("off")
                    platformInterface.set_enable_2.update("off")
                    platformInterface.enable_1 = false
                    platformInterface.enable_2 = false

                    thermalLed2.status = "off"
                    thermalLed1.status = "off"
                    //warningBox2.visible = false
//                    resetButton.visible = false
//                    resetButton.enabled = false
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
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            font.pixelSize: 35
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: topSetting
            width: parent.width/2.4
            height: parent.height/1.9
            color: "transparent"

            anchors {
                left: parent.left
                leftMargin: 40
                top: partNumber.bottom
                topMargin: 10
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
                    gaugeTitle: "Temp Sensor 1"
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
                    gaugeTitle: "Temp Sensor 2"
                    Layout.alignment: Qt.AlignCenter

                }

            }
        }
        Rectangle {
            id: leftSetting
            width: parent.width/2
            height: parent.height/1.9
            color: "transparent"
            border.color: "black"
            border.width: 5
            radius: 10

            anchors {
                left: topSetting.right
                leftMargin: 10
                top: partNumber.bottom
                topMargin: 10
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
                    font.pixelSize: ratioCalc * 35
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

                SGLabelledInfoBox {
                    id: inputVoltage
                    anchors{
                        top: line.bottom
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset: 12
                    }
                    width: parent.width/2
                    height: parent.height/6.7
                    infoBoxWidth: parent.width/4

                    label: "Input Voltage "
                    info: platformInterface.periodic_status.vin.toFixed(2)
                    unit: "V"
                    infoBoxColor: "black"
                    labelColor: "black"
                    unitSize: ratioCalc * 20
                    fontSize: ratioCalc * 20

                }

                SGLabelledInfoBox {
                    id: inputCurrent
                    anchors{
                        top: inputVoltage.bottom
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset: 12

                    }
                    width: parent.width/2
                    height: parent.height/6.7
                    infoBoxWidth: parent.width/4
                    label: "Input Current "
                    info: platformInterface.periodic_status.iin.toFixed(2)
                    unit: "A"
                    infoBoxColor: "black"
                    labelColor: "black"
                    fontSize: ratioCalc * 20
                    unitSize: ratioCalc * 20

                }
                SGLabelledInfoBox {
                    id: outputVoltage
                    width: parent.width/2
                    height: parent.height/6.7
                    anchors{
                        top: inputCurrent.bottom
                        horizontalCenter: parent.horizontalCenter

                    }
                    infoBoxWidth: parent.width/4
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
                    width: parent.width/2
                    height: parent.height/6.7
                    anchors{
                        top: outputVoltage.bottom
                        horizontalCenter: parent.horizontalCenter
                    }

                    infoBoxWidth: parent.width/4
                    label: "Output Current "
                    info: platformInterface.periodic_status.vout.toFixed(2)
                    unit: "A"
                    infoBoxColor: "black"
                    labelColor: "black"
                    fontSize: ratioCalc * 20
                    unitSize: ratioCalc * 20

                }
                Rectangle {
                    id:vinLed
                    width: parent.width/2
                    height: parent.height/12
                    anchors{
                        top: outputCurrent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    color: "transparent"
                    SGStatusLight {
                        id: vinLight
                        width: parent.width/2
                        height: parent.height
                        label: "<b>Input Voltage Good:</b>" // Default: "" (if not entered, label will not appear)
                        labelLeft: true       // Default: true
                        lightSize: ratioCalc * 30         // Default: 50
                        textColor: "black"      // Default: "black"
                        fontSize: ratioCalc * 20
                        anchors.centerIn: parent
                    }
                }
                RowLayout {
                    width: parent.width
                    height: parent.height/13
                    anchors{
                        top: vinLed.bottom
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
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

            }
        }

        Rectangle {
            id: bottomSetting
            width: parent.width/1.5
            height: parent.height/3.1
            anchors {
                top: topSetting.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
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
                font.pixelSize: ratioCalc * 35
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
                height: parent.height/1.4
                color: "transparent"
                anchors {
                    left: parent.left
                    leftMargin: 15
                    top: lineUnderControlTitle.bottom
                    topMargin: 5
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"

                    SGSwitch {
                        id: eFuse1
                        label: "Enable 1"
                        fontSizeLabel: ratioCalc * 20
                        labelLeft: true              // Default: true (controls whether label appears at left side or on top of switch)
                        checkedLabel: "On"       // Default: "" (if not entered, label will not appear)
                        uncheckedLabel: "Off"    // Default: "" (if not entered, label will not appear)
                        labelsInside: true              // Default: true (controls whether checked labels appear inside the control or outside of it
                        switchWidth: parent.width/4.5                // Default: 52 (change for long custom checkedLabels when labelsInside)
                        switchHeight: parent.height/8              // Default: 26
                        textColor: "black"              // Default: "black"
                        handleColor: "#33b13b"            // Default: "white"
                        grooveColor: "black"             // Default: "#ccc"
                        grooveFillColor: "black"         // Default: "#0cf"
                        anchors{
                            top: parent.top
                            topMargin: 20
                            horizontalCenter: parent.horizontalCenter
                        }

                        checked: platformInterface.enable_1
                        onToggled: {
                            if(checked)
                                platformInterface.set_enable_1.update("on")
                            else
                                platformInterface.set_enable_1.update("off")

                            platformInterface.enable_1 = checked
                        }
                    }

                    SGComboBox {
                        id: rlim1
                        comboBoxWidth: parent.width/3
                        comboBoxHeight: parent.height/5
                        label: "<b>RLIM 1</b>"   // Default: "" (if not entered, label will not appear)
                        labelLeft: true            // Default: true
                        textColor: "black"         // Default: "black"
                        indicatorColor: "#33b13b"      // Default: "#aaa"
                        borderColor: "black"         // Default: "#aaa"
                        boxColor: "black"           // Default: "white"
                        dividers: true              // Default: false
                        model: ["100", "55", "38", "29"]
                        anchors{
                            top: eFuse1.bottom
                            topMargin: 20
                            horizontalCenter: parent.horizontalCenter
                        }

                        fontSize: ratioCalc * 20
                        onActivated: {
                            platformInterface.set_rlim_1.update(currentText)
                        }
                    }

                    SGComboBox {
                        id: sr1
                        comboBoxWidth: parent.width/3
                        comboBoxHeight: parent.height/5
                        label: "<b>\t Slew Rate 1</b>"   // Default: "" (if not entered, label will not appear)
                        labelLeft: true            // Default: true
                        textColor: "black"         // Default: "black"
                        indicatorColor: "#33b13b"      // Default: "#aaa"
                        borderColor: "black"         // Default: "#aaa"
                        boxColor: "black"           // Default: "white"
                        dividers: true              // Default: false
                        model: ["1ms", "5ms"]
                        anchors{
                            top: rlim1.bottom
                            topMargin: 20
                            horizontalCenter: parent.horizontalCenter
                            horizontalCenterOffset: (rlim1.width - width)/2
                        }

                        fontSize: ratioCalc * 20
                        onActivated: {
                            if(currentIndex === 0)
                                platformInterface.set_SR_1.update("default")
                            else platformInterface.set_SR_1.update("slow")
                        }
                    }
                }
            }
            Rectangle {
                id: middleSetting
                width: parent.width/5
                height: parent.height/1.5
                color: "transparent"
                anchors {
                    left: bottomLeftSetting.right
                    leftMargin: 20
                    top: lineUnderControlTitle.bottom
                    topMargin: 5
                    horizontalCenter: titleControl.horizontalCenter

                }
                Rectangle{
                    anchors.fill: parent
                    color: "transparent"

                    Rectangle{
                        width: parent.width
                        height: parent.height/7
                        color: "transparent"
                        anchors {
                            centerIn: parent
                        }
                        Button {
                            id: circuitEnableButton
                            text:"Short Circuit EN"
                            checkable: true
                            background: Rectangle {
                                id: backgroundContainer2
                                implicitWidth: 100
                                implicitHeight: 40
                                opacity: enabled ? 1 : 0.3
                                border.color: circuitEnableButton.down ? "#17a81a" : "black"//"#21be2b"
                                border.width: 1
                                color: "#33b13b"
                                radius: 10
                            }
                            anchors{
                                horizontalCenter: parent.horizontalCenter
                            }

                            contentItem: Text {
                                text: circuitEnableButton.text
                                font: circuitEnableButton.font
                                opacity: enabled ? 1.0 : 0.3
                                color: circuitEnableButton.down ? "#17a81a" : "white"//"#21be2b"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                            }

                            onClicked: {
                                platformInterface.sc_on.update()
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: bottomRightSetting
                width: parent.width/3.2
                height: parent.height/1.4
                color: "transparent"
                anchors {
                    left: middleSetting.right
                    leftMargin: 15
                    top: lineUnderControlTitle.bottom
                    topMargin: 5
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    SGSwitch {
                        id: eFuse2
                        label: "Enable 2"
                        anchors{
                            top: parent.top
                            topMargin: 20
                            horizontalCenter: parent.horizontalCenter
                        }
                        switchWidth: parent.width/4.5              // Default: 52 (change for long custom checkedLabels when labelsInside)
                        switchHeight: parent.height/8
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

                    SGComboBox {
                        id: rlim2
                        comboBoxWidth: parent.width/3
                        comboBoxHeight: parent.height/5
                        anchors{
                            top: eFuse2.bottom
                            topMargin: 20
                            horizontalCenter: parent.horizontalCenter
                        }
                        
                        label: "<b>RLIM 2</b>"   // Default: "" (if not entered, label will not appear)
                        labelLeft: true            // Default: true
                        textColor: "black"         // Default: "black"
                        indicatorColor: "#33b13b"      // Default: "#aaa"
                        borderColor: "black"         // Default: "#aaa"
                        boxColor: "black"           // Default: "white"
                        dividers: true              // Default: false
                        model: ["100", "55", "38", "29"]
                        fontSize: ratioCalc * 20
                        onActivated: {
                            platformInterface.set_rlim_2.update(currentText)
                        }
                    }

                    SGComboBox {
                        id: sr2
                        comboBoxWidth: parent.width/3
                        comboBoxHeight: parent.height/5
                        label: "<b>\t Slew Rate 2</b>"   // Default: "" (if not entered, label will not appear)
                        labelLeft: true            // Default: true
                        textColor: "black"         // Default: "black"
                        indicatorColor: "#33b13b"      // Default: "#aaa"
                        borderColor: "black"         // Default: "#aaa"
                        boxColor: "black"           // Default: "white"
                        dividers: true              // Default: false
                        model: ["1ms", "5ms"]
                        fontSize: ratioCalc * 20
                        anchors{
                            top: rlim2.bottom
                            topMargin: 20
                            horizontalCenter: parent.horizontalCenter
                            horizontalCenterOffset: (rlim2.width - width)/2
                        }
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
