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


ColumnLayout {
    id: root
    anchors.leftMargin: -25
    anchors.rightMargin: 25
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    spacing: 10
    property string popup_message: ""


    property var initial_status: platformInterface.initial_status
    onInitial_statusChanged: {
        if(initial_status.enable_status === "on"){
            enableSwitch.checked = true
            platformInterface.set_enable.update("on")
            frequencyContainer.enabled = false
            frequencyContainer.opacity = 0.5
            vccContainer.enabled = false
            vccContainer.opacity = 0.5
            outputContainer.enabled = false
            outputContainer.opacity = 0.5
            ocpContainer.enabled = false
            ocpContainer.opacity = 0.5
            syncContainer.enabled = false
            syncContainer.opacity = 0.5
            softStartContainer.enabled = false
            softStartContainer.opacity = 0.5
            modeContainer.enabled = false
            modeContainer.opacity = 0.5}
        else  enableSwitch.checked = false

        if(initial_status.soft_start_status === "3ms")
            softStartCombo.currentIndex = 0
        else  softStartCombo.currentIndex = 1

        if(initial_status.pgood_status === "bad")
            pgoodLight.status = SGStatusLight.Red
        else  pgoodLight.status = SGStatusLight.Green

        if(initial_status.operating_mode_status === "dcm" || initial_status.operating_mode_status === "DCM" ){
            modeCombo.currentIndex = 0
            vbstConatiner.enabled = false
            vbstConatiner.opacity = 0.5}
        else  modeCombo.currentIndex = 1

        if(initial_status.vcc_select_status === "external")
            vccCombo.currentIndex = 1
        else  vccCombo.currentIndex = 0



        if(initial_status.sync_mode_status === "master" || initial_status.sync_mode_status === "Master")
            syncCombo.currentIndex = 0
        else syncCombo.currentIndex = 1

        frequencySlider.value = initial_status.switching_frequency_status
        selectOutputSlider.value = initial_status.vout_setting_status
        ocpSlider.value = initial_status.ocp_status
        boardTitle.text = initial_status.variant


        //var ocp_max = initial_status.ocp_max
        //var ocp_min = initial_status.ocp_min
        ocpSlider.to = initial_status.ocp_max
        ocpSlider.from = initial_status.ocp_min
        ocpSlider.toText.text = initial_status.ocp_max + " A"
        ocpSlider.fromText.text = initial_status.ocp_min + " A"


    }

    Component.onCompleted:  {
        Help.registerTarget(vinLEDLabelContainer, "This LED indicates whether the input voltage is above the required 4.5 V for proper operation. Green indicates above 4.5 V and red indicates below 4.5 V.", 0,"basicFan65Help")
        Help.registerTarget(inputVoltageLabel, "This box displays the input current supplied to the board.", 1,"basicFan65Help")
        Help.registerTarget(inputCurrentLabel, "This box displays the input current supplied to the board.", 2,"basicFan65Help")
        Help.registerTarget(inputVCCLabel, "This box displays the voltage of the VCC pin of the FAN6500XX.", 3,"basicFan65Help")
        Help.registerTarget(pvccLabel, "This box displays the voltage of the PVCC pin of the FAN6500XX.", 4,"basicFan65Help")
        Help.registerTarget(vbstLabel, "This box displays the voltage of the VBST pin of the FAN6500XX.", 5,"basicFan65Help")
        Help.registerTarget(pgoodLabel, "This LED will be green when the regulator is operating normally (PGOOD pin is high).", 6,"basicFan65Help")
        Help.registerTarget(outputVoltage, "This box displays the regulated output voltage.", 7,"basicFan65Help")
        Help.registerTarget(outputCurrent, " This box displays the regulated output current.",8,"basicFan65Help")
        Help.registerTarget(frequencyLabel, "This slider enables modification of the switching frequency. It is disabled while the regulator is enabled.", 9,"basicFan65Help")
        Help.registerTarget(outputLabel, "This slider allows you to adjust the desired output voltage. Adjustment is allowed in when the regulator is enabled.", 10,"basicFan65Help")
        Help.registerTarget(ocpLabel, "This slider changes the OCP threshold of the regulator.", 11,"basicFan65Help")
        Help.registerTarget(efficiencyGaugeContainer, "This gauge shows the efficiency of the regulator.", 12,"basicFan65Help")
        Help.registerTarget(powerDissipatedContainer, "This gauge shows the power loss of the regulator.", 13,"basicFan65Help")
        Help.registerTarget(powerOutputContainer, "This gauge shows the output power of the regulator.", 14,"basicFan65Help")
        Help.registerTarget(tempGaugeContainer, "This gauge shows the board temperature near the ground pad of the regulator.", 15,"basicFan65Help")
        Help.registerTarget(osAlertLabel, "This indicator will be red when the temperature sensor detects a board temperature near the ground pad of the regulator of 80°C.", 16,"basicFan65Help")
        Help.registerTarget(enableSwitchLabel, "This switch enables the regulator..", 17,"basicFan65Help")
        Help.registerTarget(dltConnectedLabel, "??", 18,"basicFan65Help")
        Help.registerTarget(syncLabel, "This box allows the regulator to be set into master and slave mode. In slave mode, entering a value into the box will set the switching frequency in kHz.", 19,"basicFan65Help")
        Help.registerTarget(modeLabel, "DCM (Discontinuous conduction mode) is a power saving mode that is built into the regulator. It will save power at lower current levels. FCCM (Forced continuous conduction mode) will maintain the set switching frequency, regardless of power.", 20,"basicFan65Help")
        Help.registerTarget(softStartLabel, "This control allows the soft start time to be adjusted.", 21,"basicFan65Help")
        Help.registerTarget(vccLabel, "This control allows the user to switch between the internally supplied 5V source (PVCC) or an external 5V source (5V).", 22,"basicFan65Help")

        platformInterface.read_initial_status.update()
    }

    //For demo

    //    Item {
    //        id: filterHelpContainer
    //        property point topLeft
    //        property point bottomRight
    //        width: inputVoltageContainer.width + inputCurrentContainer.width - 80
    //        height: (bottomRight.y - topLeft.y) - 20
    //        x: topLeft.x
    //        y: topLeft.y
    //        function update() {
    //            topLeft = inputVoltageContainer.mapToItem(root, 0,  0)
    //            bottomRight = inputCurrentContainer.mapToItem(root, inputCurrentContainer.width, inputCurrentContainer.height)
    //        }
    //    }

    //    Item {
    //        id: filterHelp2Container
    //        property point topLeft
    //        property point bottomRight
    //        width: frequencyContainer.width - 80
    //        height: (bottomRight.y - topLeft.y) - 20
    //        x: topLeft.x
    //        y: topLeft.y
    //        function update() {
    //            topLeft = frequencyContainer.mapToItem(root, 0,  0)
    //            bottomRight = ocpContainer.mapToItem(root, ocpContainer.width, ocpContainer.height)
    //        }
    //    }

    //    Item {
    //        id: filterHelp3Container
    //        property point topLeft
    //        property point bottomRight
    //        width: gaugeContainer.width
    //        height: (bottomRight.y - topLeft.y) - 30
    //        x: topLeft.x
    //        y: topLeft.y
    //        function update() {
    //            topLeft = efficiencyGaugeContainer.mapToItem(root, 0,  0)
    //            bottomRight = tempGaugeContainer.mapToItem(root, tempGaugeContainer.width, tempGaugeContainer.height)
    //        }

    //    }

    //    Connections {
    //        target: Help.utility
    //        onTour_runningChanged:{
    //            filterHelpContainer.update()
    //            filterHelp2Container.update()
    //            filterHelp3Container.update()
    //        }
    //    }

    Popup{
        id: warningPopup
        width: root.width/2
        height: root.height/4
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle{
            id: warningPopupContainer
            width: warningPopup.width
            height: warningPopup.height
            color: "#dcdcdc"
            border.color: "grey"
            border.width: 2
            radius: 10
            Rectangle {
                id:topBorder
                width: parent.width
                height: parent.height/7
                anchors{
                    top: parent.top
                    topMargin: 2
                    right: parent.right
                    rightMargin: 2
                    left: parent.left
                    leftMargin: 2
                }
                radius: 5
                color: "#c0c0c0"
                border.color: "#c0c0c0"
                border.width: 2
            }
        }

        Rectangle {
            id: warningPopupBox
            color: "transparent"
            anchors {
                top: parent.top
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            width: warningPopupContainer.width - 50
            height: warningPopupContainer.height - 50

            Rectangle {
                id: messageContainerForPopup
                anchors {
                    top: parent.top
                    topMargin: 10
                    centerIn:  parent.Center
                }
                color: "transparent"
                width: parent.width
                height:  parent.height - selectionContainerForPopup.height
                Text {
                    id: warningTextForPopup
                    anchors.fill:parent
                    text: popup_message
                    verticalAlignment:  Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    fontSizeMode: Text.Fit
                    width: parent.width
                    font.family: "Helvetica Neue"
                    font.pixelSize: ratioCalc * 15
                }
            }
            SGAlignedLabel {
                id: displayPopupAgainCheckboxLabel
                target: displayPopupAgainCheckbox
                text: "Don't display message again?"
                margin: -5
                font.bold : true
                font.italic: true
                alignment: SGAlignedLabel.SideTopCenter
                fontSizeMultiplier: ratioCalc
                anchors{
                    top: messageContainerForPopup.bottom
                    right: selectionContainerForPopup.left
                    rightMargin: 10
                }

                CheckBox {
                    id: displayPopupAgainCheckbox
                    checked: false
                    z:1
                }
            }

            Rectangle {
                id: selectionContainerForPopup
                width: parent.width/2
                height: parent.height/4.5
                anchors{
                    top: messageContainerForPopup.bottom
                    topMargin: 10
                    right: parent.right
                }
                color: "transparent"
                SGButton {
                    width: parent.width/3
                    height:parent.height
                    anchors.centerIn: parent
                    text: "OK"
                    color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                    roundedLeft: true
                    roundedRight: true

                    onClicked: {
                        if (displayPopupAgainCheckbox.checked){
                            platformInterface.vout_warning_response.update("off")
                        } else {
                            platformInterface.vout_warning_response.update("on")
                        }
                        warningPopup.close()
                    }
                }
            }

            property var voutBelowValue: platformInterface.vout_below_threshold.vout_below_status
            onVoutBelowValueChanged: {
                if (!warningPopup.opened && voutBelowValue === "true") {
                    warningPopup.open()
                    popup_message = "Output voltage is below 5V. It is recommended to disconnect the EXTBIAS pin from the output and short the EXTBIAS pin to the HVBIAS pin."
                }
            }
        }
    }


    property string vinState: ""
    property var read_vin: platformInterface.status_voltage_current.vingood
    onRead_vinChanged: {
        if(read_vin === "good") {
            ledLight.status = SGStatusLight.Green
            vinState = "over"
            vinLabel.text = "VIN Ready \n ("+vinState + " 4.5V)"


        }
        else {
            ledLight.status = SGStatusLight.Red
            vinState = "under"
            vinLabel.text = "VIN Ready \n ("+vinState +" 4.5V)"

        }
    }



    Text {
        id: boardTitle
        Layout.alignment: Qt.AlignHCenter
        // text: multiplePlatform.partNumber
        font.bold: true
        font.pixelSize: ratioCalc * 30
        topPadding: 5
    }

    Rectangle {
        id: mainSetting
        Layout.fillWidth: true
        Layout.preferredHeight:root.height - boardTitle.contentHeight - 20
        Layout.alignment: Qt.AlignCenter

        Rectangle{
            id: mainSettingContainer
            anchors.fill: parent
            anchors {
                bottom: parent.bottom
                bottomMargin: 30
            }
            ColumnLayout{
                anchors {
                    margins: 15
                    fill: parent
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/1.8


                    RowLayout {
                        anchors.fill: parent
                        spacing: 20

                        Rectangle {
                            id: inputContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            Text {
                                id: inputContainerHeading
                                text: "Input"
                                font.bold: true
                                font.pixelSize: ratioCalc * 15
                                color: "#696969"
                                anchors.top: parent.top
                            }

                            Rectangle {
                                id: line3
                                height: 2
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: inputContainerHeading.bottom
                                    topMargin: 7
                                }
                            }

                            ColumnLayout {
                                anchors {
                                    top: line3.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                spacing: 5

                                Rectangle {
                                    Layout.preferredWidth: parent.width/1.5
                                    Layout.preferredHeight: 40
                                    Layout.alignment: Qt.AlignCenter
                                    Rectangle {
                                        id: warningBox
                                        color: "red"
                                        anchors.fill: parent

                                        Text {
                                            id: warningText
                                            anchors.centerIn: warningBox
                                            text: "<b>DO NOT Exceed LDO Input Voltage more than 65V</b>"
                                            font.pixelSize:  ratioCalc * 12
                                            color: "white"
                                        }

                                        Text {
                                            id: warningIconleft
                                            anchors {
                                                right: warningText.left
                                                verticalCenter: warningText.verticalCenter
                                                rightMargin: 5
                                            }
                                            text: "\ue80e"
                                            font.family: Fonts.sgicons
                                            font.pixelSize:  ratioCalc * 14
                                            color: "white"
                                        }

                                        Text {
                                            id: warningIconright
                                            anchors {
                                                left: warningText.right
                                                verticalCenter: warningText.verticalCenter
                                                leftMargin: 5
                                            }
                                            text: "\ue80e"
                                            font.family: Fonts.sgicons
                                            font.pixelSize:  ratioCalc * 14
                                            color: "white"
                                        }
                                    }
                                }


                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 10


                                        Rectangle {

                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            ColumnLayout{
                                                id: vinLEDLabelContainer
                                                //anchors.fill: parent
                                                width: parent.width/2
                                                height: parent.height
                                                anchors.verticalCenter: parent.verticalCenter
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGText {
                                                        id: vinLabel
                                                        anchors.left: parent.left
                                                        anchors.bottom: parent.bottom
                                                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                        font.bold : true
                                                        horizontalAlignment: Text.AlignHCenter
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    SGStatusLight {
                                                        id: ledLight
                                                        anchors.left: parent.left
                                                        anchors.leftMargin: 20
                                                        anchors.top: parent.top
                                                        height: 40 * ratioCalc
                                                        width: 40 * ratioCalc
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: inputVoltageContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: inputVoltageLabel
                                                target: inputVoltage
                                                text: "Input Voltage"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: inputVoltage
                                                    unit: "V"
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    width: 100 * ratioCalc
                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
                                                    property var inputVoltageValue: platformInterface.status_voltage_current.vin.toFixed(2)
                                                    onInputVoltageValueChanged: {
                                                        inputVoltage.text = inputVoltageValue
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: inputCurrentContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: inputCurrentLabel
                                                target: inputCurrent
                                                text: "Input Current"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: inputCurrent
                                                    //text: platformInterface.status_voltage_current.iin.toFixed(2)
                                                    unit: "A"
                                                    width: 100 * ratioCalc
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    //boxColor: "lightgrey"
                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
                                                    property var inputCurrentValue: platformInterface.status_voltage_current.iin.toFixed(2)
                                                    onInputCurrentValueChanged: {
                                                        inputCurrent.text = inputCurrentValue
                                                    }


                                                }
                                            }
                                        }

                                    }
                                }


                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 10
                                        Rectangle {
                                            id: inputVCCContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGAlignedLabel {
                                                id: inputVCCLabel
                                                target: inputVCC
                                                text: "VCC"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                // anchors.horizontalCenter: parent.horizontalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: inputVCC
                                                    //text: platformInterface.status_voltage_current.vin.toFixed(2)
                                                    unit: "V"
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    width: 100 * ratioCalc

                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
                                                    property var vccValue: platformInterface.status_voltage_current.vcc.toFixed(2)
                                                    onVccValueChanged: {
                                                        inputVCC.text = vccValue
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: pvccConatiner
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGAlignedLabel {
                                                id: pvccLabel
                                                target: pvccValue
                                                text: "PVCC"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: pvccValue
                                                    property var pvccValueMonitor: platformInterface.status_voltage_current.pvcc.toFixed(2)
                                                    onPvccValueMonitorChanged: {
                                                        text = pvccValueMonitor
                                                    }

                                                    unit: "V"
                                                    width: 100 * ratioCalc
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    //boxColor: "lightgrey"
                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
                                                }
                                            }

                                        }
                                        Rectangle {
                                            id: vbstConatiner
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGAlignedLabel {
                                                id: vbstLabel
                                                target: vbstValue
                                                text: "VBST"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: vbstValue
                                                    property var vboostValue: platformInterface.status_voltage_current.vboost.toFixed(2)
                                                    onVboostValueChanged: {
                                                        vbstValue.text = vboostValue
                                                    }
                                                    unit: "V"
                                                    width: 100 * ratioCalc
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    //boxColor: "lightgrey"
                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
                                                }
                                            }
                                        }

                                    }
                                }

                            }


                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Text {
                                id: outputContainerHeading
                                text: "Output"
                                font.bold: true
                                font.pixelSize: ratioCalc * 15
                                color: "#696969"
                                anchors.top: parent.top
                            }

                            Rectangle {
                                id: line4
                                height: 2
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: outputContainerHeading.bottom
                                    topMargin: 7
                                }
                            }

                            ColumnLayout {
                                anchors {
                                    top: line4.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                spacing: 5

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 10
                                        Rectangle {
                                            id: pgoodLightContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGAlignedLabel {
                                                id: pgoodLabel
                                                target: pgoodLight
                                                text:  "PGOOD"
                                                alignment: SGAlignedLabel.SideTopCenter
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGStatusLight {
                                                    id: pgoodLight
                                                    height: 40 * ratioCalc
                                                    width: 40 * ratioCalc

                                                    property var read_pgood: platformInterface.status_pgood.pgood
                                                    onRead_pgoodChanged: {
                                                        if(read_pgood === "good")
                                                            pgoodLight.status = SGStatusLight.Green
                                                        else  pgoodLight.status = SGStatusLight.Red
                                                    }

                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: outputVoltageContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGAlignedLabel {
                                                id: outputVoltageLabel
                                                target: outputVoltage
                                                text: "Output Voltage"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: outputVoltage
                                                    //text: platformInterface.status_voltage_current.vin.toFixed(2)
                                                    unit: "V"
                                                    width: 100 * ratioCalc
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2

                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true

                                                    property var ouputVoltageValue:  platformInterface.status_voltage_current.vout.toFixed(2)
                                                    onOuputVoltageValueChanged: {
                                                        outputVoltage.text = ouputVoltageValue
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGAlignedLabel {
                                                id: outputCurrentLabel
                                                target: outputCurrent
                                                text: "Output Current"
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGInfoBox {
                                                    id: outputCurrent
                                                    //text: platformInterface.status_voltage_current.iin.toFixed(2)
                                                    unit: "A"
                                                    width: 100 * ratioCalc
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2

                                                    boxFont.family: Fonts.digitalseven
                                                    unitFont.bold: true
                                                    property var ouputCurrentValue:  platformInterface.status_voltage_current.iout.toFixed(2)
                                                    onOuputCurrentValueChanged: {
                                                        text = ouputCurrentValue
                                                    }

                                                }
                                            }
                                        }

                                    }
                                }

                                Rectangle {
                                    id:frequencyContainer
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    SGAlignedLabel {
                                        id: frequencyLabel
                                        target: frequencySlider
                                        text: "Switch Frequency"
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true
                                        horizontalAlignment: Text.AlignHCenter

                                        SGSlider{
                                            id: frequencySlider
                                            fontSizeMultiplier: ratioCalc * 0.8
                                            fromText.text: "100 kHz"
                                            toText.text: "1.2 MHz"
                                            from: 100
                                            to: 1200
                                            live: false
                                            stepSize: 5
                                            width: frequencyContainer.width/1.2

                                            inputBoxWidth: frequencyContainer.width/8
                                            inputBox.validator: DoubleValidator {
                                                top: frequencySlider.to
                                                bottom: frequencySlider.from
                                            }
                                            onUserSet: {
                                                platformInterface.switchFrequency = value
                                                platformInterface.set_switching_frequency.update(value)

                                                //re-enable for REV1
                                                //platformInterface.set_sync_slave_frequency.update(value)

                                                //if (SGComboBox.model === "Slave"){
                                                //platformInterface.set_sync_slave_frequency.update(value)
                                                //}
                                            }

                                        }

                                    }

                                }

                                Rectangle {
                                    id:outputContainer
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    SGAlignedLabel {
                                        id: outputLabel
                                        target: selectOutputSlider
                                        text: "Select Output Voltage"
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true
                                        horizontalAlignment: Text.AlignHCenter

                                        SGSlider{
                                            id: selectOutputSlider
                                            width: outputContainer.width/1.2
                                            inputBoxWidth: outputContainer.width/8
                                            fontSizeMultiplier: ratioCalc * 0.8
                                            fromText.text: "2 V"
                                            toText.text: "28 V"
                                            from: 2
                                            to: 28
                                            stepSize: 0.05
                                            live: false

                                            inputBox.validator: DoubleValidator {
                                                top: selectOutputSlider.to
                                                bottom: selectOutputSlider.from
                                            }
                                            onUserSet: {
                                                platformInterface.set_output_voltage.update(value)
                                            }
                                        }
                                    }

                                }

                                Rectangle {
                                    id:ocpContainer
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    SGAlignedLabel {
                                        id: ocpLabel
                                        target: ocpSlider
                                        text: "OCP Threshold"
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.verticalCenter: parent.verticalCenter
                                        fontSizeMultiplier: ratioCalc
                                        font.bold : true
                                        horizontalAlignment: Text.AlignHCenter

                                        SGSlider{
                                            id: ocpSlider
                                            width: ocpContainer.width/1.2
                                            inputBoxWidth: ocpContainer.width/8
                                            fontSizeMultiplier: ratioCalc * 0.8
                                            fromText.text: "0 A"


                                            toText.text: "13 A"
                                            from: 0
                                            to: 13
                                            stepSize: 0.5
                                            //handleSize: 30
                                            live: false
                                            inputBox.validator: DoubleValidator {
                                                top: ocpSlider.to
                                                bottom: ocpSlider.from
                                            }
                                            onUserSet: {
                                                platformInterface.set_ocp.update(value)

                                            }
                                        }

                                    }



                                }




                            }

                        }

                    }


                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        anchors.fill: parent
                        spacing: 20
                        Rectangle {
                            id: gaugeReading
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"

                            Text {
                                id: gaugeContainerHeading
                                text: "Board Temperature, Power Loss, Output Power & Efficiency"
                                font.bold: true
                                font.pixelSize: ratioCalc * 15
                                color: "#696969"
                                anchors.top: parent.top
                            }

                            Rectangle {
                                id: line1
                                height: 2
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: gaugeContainerHeading.bottom
                                    topMargin: 7
                                }
                            }

                            RowLayout {
                                id: gaugeContainer
                                anchors {
                                    top: line1.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                spacing: 5
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout {
                                        anchors.fill:parent

                                        Rectangle {
                                            id: efficiencyGaugeContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            color: "transparent"
                                            SGAlignedLabel {
                                                id: efficiencyGaugeLabel
                                                target: efficiencyGauge
                                                text: "Efficiency"
                                                margin: 0
                                                anchors.centerIn: parent
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter
                                                SGCircularGauge {
                                                    id: efficiencyGauge
                                                    gaugeFillColor1: Qt.rgba(1,0,0,1)
                                                    gaugeFillColor2: Qt.rgba(0,1,.25,1)
                                                    minimumValue: 0
                                                    maximumValue: 100
                                                    tickmarkStepSize: 10
                                                    width: efficiencyGaugeContainer.width
                                                    height: efficiencyGaugeContainer.height/1.3

                                                    unitText: "%"
                                                    unitTextFontSizeMultiplier: ratioCalc * 2.2
                                                    //value: platformInterface.status_voltage_current.efficiency
                                                    property var efficiencyValue: platformInterface.status_voltage_current.efficiency
                                                    onEfficiencyValueChanged: {
                                                        value = efficiencyValue
                                                    }

                                                    // Behavior on value { NumberAnimation { duration: 300 } }

                                                }
                                            }



                                        }

                                        Rectangle {
                                            id: powerDissipatedContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            color: "transparent"

                                            SGAlignedLabel {
                                                id: powerDissipatedLabel
                                                target: powerDissipatedGauge
                                                text: "Power Loss"
                                                margin: 0
                                                anchors.centerIn: parent
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter
                                                SGCircularGauge {
                                                    id: powerDissipatedGauge
                                                    gaugeFillColor1: Qt.rgba(0,1,.25,1)
                                                    gaugeFillColor2: Qt.rgba(1,0,0,1)
                                                    minimumValue: 0
                                                    maximumValue: 5
                                                    tickmarkStepSize: 0.5
                                                    width: powerDissipatedContainer.width
                                                    height: powerDissipatedContainer.height/1.3
                                                    unitText: "W"
                                                    unitTextFontSizeMultiplier: ratioCalc * 2.2
                                                    valueDecimalPlaces: 2
                                                    property var powerDissipatedValue: platformInterface.status_voltage_current.power_dissipated
                                                    onPowerDissipatedValueChanged: {
                                                        value = powerDissipatedValue
                                                    }
                                                    //Behavior on value { NumberAnimation { duration: 300 } }
                                                }
                                            }
                                        }


                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    RowLayout {
                                        anchors.fill:parent

                                        Rectangle {
                                            id: powerOutputContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: powerOutputLabel
                                                target: powerOutputGauge
                                                text: "Output Power"
                                                margin: 0
                                                anchors.centerIn: parent
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter
                                                SGCircularGauge {
                                                    id: powerOutputGauge
                                                    gaugeFillColor1: Qt.rgba(0,0.5,1,1)
                                                    gaugeFillColor2: Qt.rgba(1,0,0,1)
                                                    minimumValue: 0
                                                    maximumValue: 100
                                                    tickmarkStepSize: 20
                                                    unitText: "W"
                                                    unitTextFontSizeMultiplier: ratioCalc * 2.2
                                                    width: powerOutputContainer.width
                                                    height: powerOutputContainer.height/1.3
                                                    valueDecimalPlaces: 2

                                                    property var outputPowerValue: platformInterface.status_voltage_current.output_power
                                                    onOutputPowerValueChanged: {
                                                        value = outputPowerValue
                                                    }

                                                    //Behavior on value { NumberAnimation { duration: 300 } }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: tempGaugeContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: tempGaugeLabel
                                                target: tempGauge
                                                text: "Board Temperature"
                                                margin: 0
                                                anchors.centerIn: parent
                                                alignment: SGAlignedLabel.SideBottomCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                horizontalAlignment: Text.AlignHCenter

                                                SGCircularGauge {
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
                                                    height: tempGaugeContainer.height/1.3

                                                    property var tempValue: platformInterface.status_temperature_sensor.temperature
                                                    onTempValueChanged: {
                                                        value = tempValue
                                                    }
                                                    //Behavior on value { NumberAnimation { duration: 300 } }
                                                }
                                            }
                                        }
                                    }
                                }
                                Rectangle{
                                    Layout.preferredHeight: parent.height/1.5
                                    Layout.preferredWidth: parent.width/7

                                    ColumnLayout{
                                        anchors.fill: parent
                                        Rectangle {
                                            id: dltConnectedContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGAlignedLabel {
                                                id: dltConnectedLabel
                                                target: dltConnected
                                                text: "DLT \n Connected"
                                                alignment:  SGAlignedLabel.SideTopCenter
                                                anchors.verticalCenter: parent
                                                fontSizeMultiplier: ratioCalc
                                                horizontalAlignment: Text.AlignHCenter
                                                font.bold : true
                                                CheckBox{
                                                    id: dltConnected
                                                    width: 25
                                                    height: 25
                                                    onCheckedChanged: {
                                                        platformInterface.set_dlt_connected.update(checked)
                                                    }
                                                }


                                            }
                                        }

                                        Rectangle {

                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: osAlertLabel
                                                target: osALERT
                                                text:  "OS/ALERT"
                                                alignment: SGAlignedLabel.SideTopCenter
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGStatusLight {
                                                    id: osALERT
                                                    height: 40 * ratioCalc
                                                    width: 40 * ratioCalc

                                                    property var status_os_alert: platformInterface.status_os_alert.os_alert
                                                    onStatus_os_alertChanged: {
                                                        if(status_os_alert === true)
                                                            osALERT.status = SGStatusLight.Red
                                                        else  osALERT.status = SGStatusLight.Off
                                                    }

                                                }
                                            }

                                        }
                                    }
                                }


                            }
                        }

                        Rectangle {
                            id: controlContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            Text {
                                id: controlContainerHeading
                                text: "Control"
                                font.bold: true
                                font.pixelSize: ratioCalc * 15
                                color: "#696969"
                                anchors.top: parent.top
                            }

                            Rectangle {
                                id: line2
                                height: 2
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: controlContainerHeading.bottom
                                    topMargin: 7
                                }
                            }

                            ColumnLayout {
                                anchors {
                                    top: line2.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                spacing: 5

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 10
                                        Rectangle {
                                            id:enableContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGAlignedLabel {
                                                id: enableSwitchLabel
                                                target: enableSwitch
                                                text: "Enable (EN)"
                                                alignment:  SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                font.bold : true
                                                SGSwitch {
                                                    id: enableSwitch

                                                    labelsInside: true
                                                    checkedLabel: "On"
                                                    uncheckedLabel:   "Off"
                                                    textColor: "black"              // Default: "black"
                                                    handleColor: "white"            // Default: "white"
                                                    grooveColor: "#ccc"             // Default: "#ccc"
                                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                                    checked: platformInterface.enabled
                                                    fontSizeMultiplier: ratioCalc
                                                    onToggled: {
                                                        platformInterface.enabled = checked
                                                        if(checked){
                                                            platformInterface.set_enable.update("on")
                                                            frequencyContainer.enabled = false
                                                            frequencyContainer.opacity = 0.5
                                                            vccContainer.enabled = false
                                                            vccContainer.opacity = 0.5
                                                            outputContainer.enabled = false
                                                            outputContainer.opacity = 0.5
                                                            ocpContainer.enabled = false
                                                            ocpContainer.opacity = 0.5
                                                            syncContainer.enabled = false
                                                            syncContainer.opacity = 0.5
                                                            softStartContainer.enabled = false
                                                            softStartContainer.opacity = 0.5
                                                            modeContainer.enabled = false
                                                            modeContainer.opacity = 0.5
                                                        }
                                                        else{
                                                            platformInterface.set_enable.update("off")
                                                            frequencyContainer.enabled = true
                                                            frequencyContainer.opacity = 1.0
                                                            vccContainer.enabled = true
                                                            vccContainer.opacity = 1.0
                                                            outputContainer.enabled = true
                                                            outputContainer.opacity = 1
                                                            ocpContainer.enabled = true
                                                            ocpContainer.opacity = 1
                                                            syncContainer.enabled = true
                                                            syncContainer.opacity = 1
                                                            softStartContainer.enabled = true
                                                            softStartContainer.opacity = 1
                                                            modeContainer.enabled = true
                                                            modeContainer.opacity = 1
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true


                                            RowLayout {
                                                anchors.fill: parent
                                                spacing: 10
                                                Rectangle {
                                                    id: syncContainer
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGAlignedLabel {
                                                        id: syncLabel
                                                        target: syncCombo
                                                        text: "Sync Mode"
                                                        horizontalAlignment: Text.AlignHCenter
                                                        font.bold : true
                                                        alignment: SGAlignedLabel.SideTopLeft
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        fontSizeMultiplier: ratioCalc
                                                        SGComboBox {
                                                            id:  syncCombo
                                                            fontSizeMultiplier: ratioCalc

                                                            model: [ "Master", "Slave" ]
                                                            onActivated: {
                                                                platformInterface.set_sync_mode.update(currentText.toLowerCase())

                                                            }
                                                        }

                                                    }
                                                }


                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                        }

                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 10
                                        Rectangle {
                                            id : modeContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: modeLabel
                                                target: modeCombo
                                                text: "Operating Mode"
                                                horizontalAlignment: Text.AlignHCenter
                                                font.bold : true
                                                alignment:  SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                SGComboBox {
                                                    id:  modeCombo
                                                    //                                                    borderColor: "black"
                                                    //                                                    textColor: "black"          // Default: "black"
                                                    //                                                    indicatorColor: "black"
                                                    model: [ "DCM" , "FCCM"]
                                                    fontSizeMultiplier: ratioCalc
                                                    onActivated: {
                                                        if(currentIndex == 0){
                                                            platformInterface.select_mode.update("dcm")
                                                            vbstConatiner.enabled = false
                                                            vbstConatiner.opacity = 0.5
                                                        }
                                                        else  {
                                                            platformInterface.select_mode.update("fccm")
                                                            vbstConatiner.enabled = true
                                                            vbstConatiner.opacity = 1.0
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: softStartContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: softStartLabel
                                                target: softStartCombo
                                                text: "Soft Start"
                                                horizontalAlignment: Text.AlignHCenter
                                                font.bold : true
                                                alignment:  SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                SGComboBox {
                                                    id:  softStartCombo
                                                    model: [ "3ms" , "6ms"]
                                                    fontSizeMultiplier: ratioCalc
                                                    onActivated: {
                                                        platformInterface.set_soft_start.update(currentText)

                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: vccContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: vccLabel
                                                target: vccCombo
                                                text: "VCC Source"
                                                horizontalAlignment: Text.AlignHCenter
                                                font.bold : true
                                                alignment:  SGAlignedLabel.SideTopLeft
                                                anchors.verticalCenter: parent.verticalCenter
                                                fontSizeMultiplier: ratioCalc
                                                SGComboBox {
                                                    id:  vccCombo
                                                    model: [ "PVCC" , "USB 5V"]
                                                    fontSizeMultiplier: ratioCalc
                                                    onActivated: {
                                                        platformInterface.select_VCC_mode.update(currentText.toLowerCase())
                                                    }
                                                }
                                            }

                                        }
                                    }
                                }

                            }
                        }
                    }
                }

            }

        }



    }




}
