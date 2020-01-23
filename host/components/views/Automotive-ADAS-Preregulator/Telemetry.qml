import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import tech.strata.fonts 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    height: 200
    width: parent.width
    anchors.left: parent.left
    property string vinlable: ""
    property alias ledCalc: ledLight
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    property var reset_indicator_status: platformInterface.power_cycle_status.reset
    onReset_indicator_statusChanged: {
        if(reset_indicator_status === "occurred"){
            platformInterface.reset_indicator = SGStatusLight.Red
            platformInterface.reset_flag = true
        }
    }

    property var reset_led_status: platformInterface.reset_indicator
    onReset_led_statusChanged: {
        resetLed.status = platformInterface.reset_indicator
    }

    property var status_interrupt: platformInterface.initial_status_0.pgood_status
    onStatus_interruptChanged:  {
        if(status_interrupt === "bad"){
            pGoodLed.status = SGStatusLight.Red
        }
        else if(status_interrupt === "good"){
            pGoodLed.status =  SGStatusLight.Green
        }
    }

    property var read_enable_state: platformInterface.initial_status_0.enable_status
    onRead_enable_stateChanged: {
        platformInterface.enabled = (read_enable_state === "on") ? true : false
    }

    property var read_vin: platformInterface.initial_status_0.vingood_status
    onRead_vinChanged: {
        if(read_vin === "good") {
            ledLight.status =  SGStatusLight.Green
            platformInterface.hide_enable = true
            vinlable = "over"
            ledLightLabel.text = "VIN Ready \n  ("+ vinlable + " 2.5V)   "
            pGoodLabel.text = "PGOOD "
        }
        else {
            ledLight.status =  SGStatusLight.Red
            platformInterface.hide_enable = false
            vinlable = "under"
            ledLightLabel.text = "VIN Ready \n ("+ vinlable + " 2.5V) "
        }
    }

    property var pgood_status_interrupt: platformInterface.status_interrupt.pgood
    onPgood_status_interruptChanged: {
        if(pgood_status_interrupt === "bad"){
            pGoodLed.status = SGStatusLight.Red
        }
        else if(pgood_status_interrupt === "good"){
            pGoodLed.status = SGStatusLight.Green
        }
    }

    function setLogDateTime(){
        var today = new Date();
        var time = appendDigit(today.getHours()) + ":" + appendDigit(today.getMinutes()) + ":" + appendDigit(today.getSeconds());
        var dateTime = time+ ':  ' ;
        return dateTime

    }

    function appendDigit(number) {
        return (number < 10 ? '0' : '') + number
    }

    property var errorArray: platformInterface.status_ack_register.events_detected
    onErrorArrayChanged: {
        // Change text color to black of the entire existing list of faults
        for(var j = 0; j < interruptError.model.count; j++){
            interruptError.model.get(j).color = "black"
        }
        // Push current error on fault log and change the text to red color
        for (var i = 0; i < errorArray.length; i++){
            //interruptError.append((setLogDateTime()  + errorArray[i]).toString(),"red")
            interruptError.insert((setLogDateTime()  + errorArray[i]).toString(), 0 , "red")
        }
    }

    Component.onCompleted: {
        //reset default is off
        resetLed.status = SGStatusLight.Off
        Help.registerTarget(tempGauge,"The gauge shows the board temperature next to the Power Mosfets (T2 and T3) NVMFS5C460NL in degrees Celsius. This temperature will be less than the temperature internal to the NVMFS5C460NL due to the thermal isolation between the die of the NVMFS5C460NL and the die of the temperature sensor.", 0, "advanceViewHelp")
        Help.registerTarget(efficiencyGauge, "This gauge displays the efficiency of the power conversion by the power stage of the EVB (not including the input and output sense resistors). The efficiency is calculated with Pout/Pin where the input and output power are calculated using the measured input voltage/current and output voltage/current.", 1, "advanceViewHelp")
        Help.registerTarget(powerDissipatedGauge, "This gauge displays the total power loss in the power stage of the EVB (not including the input and output sense resistors). This is calculated through Pout - Pin where the input and output power are calculated using the measured input voltage/current and output voltage/current.", 2, "advanceViewHelp")
        Help.registerTarget(powerOutputGauge, "This gauge displays the output power of the power stage of the EVB (not including the input and output current sense resistors). The output power is calculated with the measured output voltage and current.", 3, "advanceViewHelp")
        Help.registerTarget(resetLedContainer, "Reset Indicator LED will come on if NCV6357 resets itself during an event (e.g. UVLO), telling the user the part has reset to its default register state. The LED will turn off as soon as enable is toggled.", 4, "advanceViewHelp")
        Help.registerTarget(resetButton, "The Force Reset button will reset NCV6357's internal registers to their default values.", 5, "advanceViewHelp")
        Help.registerTarget(ledLightContainer,"Vin Ready LED will light up green when the input voltage is ready (greater than 2.5V), and will light up red otherwise to warn the user that input voltage is not high enough.", 6, "advanceViewHelp")
        Help.registerTarget(pGoodContainer, "PGOOD LED will be red when the PGOOD signal on the board is low and green when the PGOOD signal is high. See the Power Good controls under the miscellaneous section for more information.", 7, "advanceViewHelp")
        Help.registerTarget(interruptError, "The Fault Log will keep track of all interrupts sent by INT_ACK register of NCV6357 and display them here with a time stamp. The most recent interrupt/interrupts to occur are shown in red.", 8, "advanceViewHelp")
        Help.registerTarget(currentVoltageContainer, "The digital gauges here show the input voltage/current and output voltage/current. The NCV214R current sense amplifier provides the input and output current measurement.", 9, "advanceViewHelp")

    }

    Item {
        id: leftColumn
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        width: parent.width/1.8

        Item {
            id: margins1
            anchors.fill: parent

            Rectangle {
                id:gauges
                width : parent.width
                height: parent.height/1.5
                color: "transparent"
                anchors.top: parent.top
                Rectangle{
                    id: tempGaugeContainer
                    width: parent.width/4
                    height: parent.height - 10
                    anchors{
                        top: parent.top
                        left: parent.left
                    }
                    color: "transparent"
                    SGAlignedLabel {
                        id: tempLabel
                        target: tempGauge
                        text: "Board \n Temperature"
                        margin: 0

                        alignment: SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier: ratioCalc * 1.1
                        font.bold : true
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter

                        SGCircularGauge {
                            id: tempGauge
                            minimumValue: -60
                            maximumValue: 130
                            width: tempGaugeContainer.width
                            height: tempGaugeContainer.height/1.5
                            anchors.centerIn: parent
                            gaugeFillColor1: "blue"
                            gaugeFillColor2: "red"
                            tickmarkStepSize: 10
                            unitText: "˚C"
                            unitTextFontSizeMultiplier: ratioCalc * 2.5
                            value:platformInterface.status_temperature_sensor.temperature
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
                    id: efficiencyGaugeContainer
                    width: parent.width/4
                    height: parent.height - 10
                    color: "transparent"
                    anchors {
                        top: parent.top
                        left: tempGaugeContainer.right
                    }
                    SGAlignedLabel {
                        id: efficiencyLabel
                        target: efficiencyGauge
                        text: "Efficiency"
                        margin: 0
                        anchors.centerIn: parent
                        alignment: SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier:  ratioCalc * 1.1
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter
                        SGCircularGauge {
                            id: efficiencyGauge
                            minimumValue: 0
                            maximumValue: 100
                            tickmarkStepSize: 5
                            gaugeFillColor1: "red"
                            gaugeFillColor2:  "green"
                            width: tempGaugeContainer.width
                            height: tempGaugeContainer.height/1.5
                            anchors.centerIn: parent
                            unitText: "%"
                            unitTextFontSizeMultiplier: ratioCalc * 2.5
                            value: platformInterface.status_voltage_current.efficiency
                            Behavior on value { NumberAnimation { duration: 300 } }

                        }
                    }
                }

                Rectangle {
                    id: powerDissipatedContainer
                    width: parent.width/4
                    height: parent.height - 10
                    color: "transparent"
                    anchors {
                        top: parent.top
                        left: efficiencyGaugeContainer.right
                    }
                    SGAlignedLabel {
                        id: powerDissipatedLabel
                        target: powerDissipatedGauge
                        text: "Power Loss"
                        margin: 0
                        anchors.centerIn: parent
                        alignment: SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier:  ratioCalc * 1.1
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter

                        SGCircularGauge {
                            id: powerDissipatedGauge
                            minimumValue: 0
                            maximumValue: 10
                            tickmarkStepSize: 0.5
                            gaugeFillColor1:"green"
                            gaugeFillColor2:"red"
                            width: tempGaugeContainer.width
                            height: tempGaugeContainer.height/1.5
                            anchors.centerIn: parent
                            unitTextFontSizeMultiplier: ratioCalc * 2.5
                            unitText: "W"
                            valueDecimalPlaces: 2
                            value: platformInterface.status_voltage_current.power_dissipated
                            Behavior on value { NumberAnimation { duration: 300 } }
                        }
                    }
                }

                Rectangle{
                    width: parent.width/4
                    height: parent.height - 10
                    color: "transparent"
                    anchors {
                        top: parent.top
                        left: powerDissipatedContainer.right
                    }
                    SGAlignedLabel {
                        id: ouputPowerLabel
                        target: powerOutputGauge
                        text: "Output Power"
                        margin: 0
                        anchors.centerIn: parent
                        alignment: SGAlignedLabel.SideBottomCenter
                        fontSizeMultiplier: ratioCalc * 1.1
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter
                        SGCircularGauge {
                            id: powerOutputGauge
                            minimumValue: 0
                            maximumValue:  50
                            tickmarkStepSize: 5
                            gaugeFillColor1:"green"
                            gaugeFillColor2:"red"
                            width: tempGaugeContainer.width
                            height: tempGaugeContainer.height/1.5
                            anchors.centerIn: parent
                            unitText: "W"
                            valueDecimalPlaces: 2
                            unitTextFontSizeMultiplier: ratioCalc * 2.5
                            value: platformInterface.status_voltage_current.output_power
                            Behavior on value { NumberAnimation { duration: 300 } }

                        }
                    }
                }
            }

            Rectangle {
                id: currentVoltageContainer
                width: parent.width
                height: parent.height/2.8
                color: "transparent"
                anchors.top: gauges.bottom
                Rectangle{
                    id: inputVoltageMainsContainer
                    anchors {
                        top : parent.top
                        topMargin: 0
                        left: parent.left
                    }
                    width : parent.width/2
                    height:  parent.height/3
/*
                    SGAlignedLabel {
                        id: inputVoltageMainsLabel
                        target: inputVoltageMains
                        text: "Mains      "
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true

                        SGInfoBox {
                            id: inputVoltageMains
                            text: platformInterface.status_voltage_current.vin.toFixed(2)
                            unit: "V"
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.5
                            height: (inputVoltageMainsContainer.height - inputVoltageMainsLabel.contentHeight) + 20
                            width: (inputVoltageMainsContainer.width - inputVoltageMainsLabel.contentWidth)/3
                            boxColor: "lightgreen"
                            boxFont.family: Fonts.digitalseven
                            unitFont.bold: true
                        }
                    }
                }
*/
                SGAlignedLabel {
                    id: inputVoltageMainsLabel
                    target: inputVoltageMainsCombo
                    text: "Set Input\nMains Voltage"
                    horizontalAlignment: Text.AlignHCenter
                    alignment: SGAlignedLabel.SideLeftCenter
                    anchors.centerIn: parent
                    fontSizeMultiplier: ratioCalc * 1.2
                    font.bold : true

                    SGComboBox {
                        id: inputVoltageMainsCombo
                        currentIndex: platformInterface.vin_mains_state
                        model: [ "0.0V","0.5V","1.0V","1.5V","2.0V","2.5V","3.0V","3.5V","4.0V","4.5V","5.0V","5.5V","6.0V","6.5V","7.0V","7.5V","8.0V","8.5V","9.0V","9.5V","10.0V","10.5V","11.0V","11.5V","12.0V","12.5V","13.0V","13.5V","14.0V","14.5V","15.0V","15.5V","16.0V"]
                        borderColor: "green"
                        textColor: "black"          // Default: "black"
                        indicatorColor: "green"
                        onActivated: {
                            platformInterface.set_vin_mains.update(currentIndex)
                            platformInterface.vin_mains_state = currentIndex
                        }
                    }
                }
            }
                Rectangle {
                    id: voltagePreRegContainer
                    anchors {
                        top : inputVoltageMainsContainer.bottom
                        topMargin: 0
                        left: parent.left
                    }
                    width : parent.width/2
                    height:  parent.height/3
                    SGAlignedLabel {
                        id: voltagePreRegLabel
                        target: voltagePreReg
                        text: "5V rail     "
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        SGInfoBox {
                            id: voltagePreReg
                            text:  platformInterface.status_voltage_current.vout_5v.toFixed(2)
                            unit: "V"
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.5
                            boxColor: "lightyellow"
                            height: (voltagePreRegContainer.height - voltagePreRegLabel.contentHeight) + 20
                            width: (voltagePreRegContainer.width - voltagePreRegLabel.contentWidth)/3
                            boxFont.family: Fonts.digitalseven
                            unitFont.bold: true
                        }
                    }
                }
                Rectangle {
                    id: voltageFinalRegContainer
                    anchors {
                        top : voltagePreRegContainer.bottom
                        topMargin: 0
                        left: parent.left
                    }
                    width : parent.width/2
                    height:  parent.height/3
                    SGAlignedLabel {
                        id: voltageFinalRegLabel
                        target: voltageFinalReg
                        text: "3.3V rail"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true

                        SGInfoBox {
                            id: voltageFinalReg
                            text:  platformInterface.status_voltage_current.vout_3v3.toFixed(2)
                            unit: "V"
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.5
                            boxColor: "lightblue"
                            height: (voltageFinalRegContainer.height - voltageFinalRegLabel.contentHeight) + 20
                            width: (voltageFinalRegContainer.width - voltageFinalRegLabel.contentWidth)/3
                            boxFont.family: Fonts.digitalseven
                            unitFont.bold: true
                        }
                    }
                }
                Rectangle {
                    id: inputCurrentMainsContainer
                    width : parent.width/2
                    height:  parent.height/3
                    anchors {
                        top: parent.top
                        topMargin: 0
                        right: parent.right
                        rightMargin: 20
                    }
                    SGAlignedLabel {
                        id: inputCurrentMainsLabel
                        target: inputCurrentMains
                        text: "Mains      "
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true

                        SGInfoBox {
                            id: inputCurrentMains
                            text: platformInterface.status_voltage_current.iin.toFixed(2)
                            unit: "A"
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.5
                            boxColor: "lightgreen"
                            height: (inputCurrentMainsContainer.height - inputCurrentMainsLabel.contentHeight) + 20
                            width: (inputCurrentMainsContainer.width - inputCurrentMainsLabel.contentWidth)/3
                            boxFont.family: Fonts.digitalseven
                            unitFont.bold: true

                        }
                    }
                }
                Rectangle {
                    id: outputCurrentPreRegContainer
                    width : parent.width/2
                    height:  parent.height/3
                    anchors {
                        top: inputCurrentMainsContainer.bottom
                        topMargin: 0
                        right: parent.right
                        rightMargin: 20

                    }
                    SGAlignedLabel {
                        id: outputCurrentPreRegLabel
                        target: outputCurrentPreReg
                        text:  "5V rail     "
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        SGInfoBox {
                            id: outputCurrentPreReg
                            text: platformInterface.status_voltage_current.iout_5v.toFixed(2)
                            unit: "A"
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.5
                            boxColor: "lightyellow"
                            height: (outputCurrentPreRegContainer.height - outputCurrentPreRegLabel.contentHeight) + 20
                            width: (outputCurrentPreRegContainer.width - outputCurrentPreRegLabel.contentWidth)/3
                            boxFont.family: Fonts.digitalseven
                            unitFont.bold: true
                        }
                    }
                }
                Rectangle {
                    id: ouputCurrentFinalRegContainer
                    width : parent.width/2
                    height:  parent.height/3
                    anchors {
                        top: outputCurrentPreRegContainer.bottom
                        topMargin: 0
                        right: parent.right
                        rightMargin: 20

                    }
                    SGAlignedLabel {
                        id: ouputCurrentFinalRegLabel
                        target: ouputCurrentFinalReg
                        text:  "3.3V rail"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors.centerIn: parent
                        fontSizeMultiplier: ratioCalc * 1.5
                        font.bold : true
                        SGInfoBox {
                            id: ouputCurrentFinalReg
                            text: platformInterface.status_voltage_current.iout_3v3.toFixed(2)
                            unit: "A"
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.5
                            boxColor: "lightblue"
                            height: (ouputCurrentFinalRegContainer.height - ouputCurrentFinalRegLabel.contentHeight) + 20
                            width: (ouputCurrentFinalRegContainer.width - ouputCurrentFinalRegLabel.contentWidth)/3
                            boxFont.family: Fonts.digitalseven
                            unitFont.bold: true
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
        id: rightColumn
        anchors {
            left: leftColumn.right
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        Item {
            id: margins2
            anchors {
                fill: parent
                margins: 15
            }

            Rectangle {
                id: faultContainer
                height: (parent.height - resetContainer.height) + 5
                width: parent.width + 3
                border.color: "black"
                border.width: 3
                radius: 10
                anchors{
                    top: resetContainer.bottom
                    topMargin: 3
                }

                SGStatusLogBox {
                    id: interruptError
                    height: parent.height - 20
                    width: (parent.width/1.1)
                    anchors {
                        top: parent.top
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                    }
                    title: " <b> Faults Log: </b>"
                    listElementTemplate : {
                        "message": "",
                        "id": 0,
                        "color": "black"
                    }
                    scrollToEnd: false
                    delegate: Rectangle {
                        id: delegatecontainer
                        height: delegateText.height
                        width: ListView.view.width

                        SGText {
                            id: delegateText
                            text: { return (
                                        interruptError.showMessageIds ?
                                            model.id + ": " + model.message :
                                            model.message
                                        )}

                            fontSizeMultiplier: interruptError.fontSizeMultiplier
                            color: model.color
                            wrapMode: Text.WrapAnywhere
                            width: parent.width
                        }
                    }

                    function append(message,color) {
                        listElementTemplate.message = message
                        listElementTemplate.color = color
                        model.append( listElementTemplate )
                        return (listElementTemplate.id++)
                    }
                    function insert(message,index,color){
                        listElementTemplate.message = message
                        listElementTemplate.color = color
                        model.insert(index, listElementTemplate )
                        return (listElementTemplate.id++)
                    }
                }
            }

            Rectangle {
                id:resetContainer
                height: rightColumn.height/3
                width: rightColumn.width/1.3
                color: "transparent"
                border.color: "black"
                border.width: 3
                radius: 10
                anchors{
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    anchors.horizontalCenter: parent.horizontalCenter

                    ColumnLayout{
                        id: leftTelemarySetting

                        width: parent.width/2
                        height: parent.height

                        Rectangle {
                            id: resetLedContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            SGAlignedLabel {
                                id: vinLabel
                                target: resetLed
                                text:  "Reset \n Indicator"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.1
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter
                                SGStatusLight {
                                    id: resetLed
                                    status: SGStatusLight.Off
                                }
                            }
                        }

                        Rectangle{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            SGButton {
                                id: resetButton
                                width: parent.width/1.7
                                height: parent.height - 20
                                anchors.centerIn: parent

                                background: Rectangle {
                                    color: "light gray"
                                    border.width: 1
                                    border.color: "gray"
                                    radius: 10
                                }
                                Text {
                                    text: "Force \n Reset"
                                    font.bold: true
                                    anchors.centerIn: parent
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                onClicked: {
                                    platformInterface.force_reset_registers.update("reset")
                                    platformInterface.rearm_device.update("off")
                                    platformInterface.read_initial_status.update()
                                }
                            }
                        }
                    }

                    Rectangle{
                        width: parent.width/2
                        height: parent.height
                        anchors.left: leftTelemarySetting.right
                        color: "transparent"
                        Rectangle {
                            id: ledLightContainer
                            width: parent.width/1.4
                            height: parent.height/2
                            anchors.top: parent.top
                            color: "transparent"
                            SGAlignedLabel {
                                id: ledLightLabel
                                target: ledLight
                                text:  "VIN Ready \n (over 2.5V)"
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.1
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter
                                SGStatusLight {
                                    id: ledLight
                                    property string vinMonitor: platformInterface.status_vin_good.vingood
                                    onVinMonitorChanged:  {
                                        if(vinMonitor === "good") {
                                            status =  SGStatusLight.Green
                                            vinlable = "over"
                                            platformInterface.hide_enable = true
                                            ledLightLabel.text = "VIN Ready \n ("+ vinlable + " 2.5V)"
                                            platformInterface.read_initial_status.update()

                                        }
                                        else if(vinMonitor === "bad") {
                                            status =  SGStatusLight.Red
                                            platformInterface.hide_enable = false
                                            vinlable = "under"
                                            ledLightLabel.text = "VIN Ready \n ("+ vinlable + " 2.5V)"
                                            platformInterface.enabled = false
                                            platformInterface.set_enable_3v3.update("off")
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: pGoodContainer
                            width: parent.width/1.9
                            height: parent.height/2
                            color: "transparent"
                            anchors {
                                top: ledLightContainer.bottom
                                horizontalCenter: ledLightContainer.horizontalCenter
                                horizontalCenterOffset: -(width - ledLightContainer.width)/2
                            }
                            Layout.alignment : Qt.AlignHCenter
                            SGAlignedLabel {
                                id: pGoodLabel
                                target: pGoodLed
                                text: " PGOOD"
                                alignment:SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 1.1
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGStatusLight {
                                    id: pGoodLed
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.horizontalCenterOffset: -(width + ledCalc.width)/2

                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
