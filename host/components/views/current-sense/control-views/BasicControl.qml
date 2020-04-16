import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    anchors.centerIn: parent

    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    MouseArea {
        id: containMouseArea
        anchors.fill: parent
        onClicked: {
            console.log("in mouse area")
            forceActiveFocus()
        }
    }


    property var initial_status: platformInterface.initial_status
    onInitial_statusChanged: {
        if(initial_status.en_210 === "on") {
            enable3.checked = true
        }
        else enable3.checked = false

        if (initial_status.en_211 === "on") {
            enable4.checked = true
        }
        else  enable4.checked = false

        if(initial_status.en_213 === "on") {
            enable1.checked = true
        }
        else enable1.checked = false

        if(initial_status.en_214 === "on") {
            enable2.checked = true
        }
        else enable2.checked = false

        if(initial_status.en_333 === "on") {
            enable5.checked = true
        }
        else enable5.checked = false

        if(initial_status.manual_mode === "Manual") {
            enableModeSet.checked = true
            maxInputCurrentContainer.enabled = true
            maxInputCurrentContainer.opacity = 1.0
            maxInputVoltageContainer.enabled = true
            maxInputVoltageContainer.opacity = 1.0
        }
        else {
            enableModeSet.checked = false
            maxInputCurrentContainer.enabled = false
            maxInputCurrentContainer.opacity = 0.5
            maxInputVoltageContainer.enabled = false
            maxInputVoltageContainer.opacity = 0.5

        }

        maxInputCurrent.value = initial_status.max_input_current
        maxInputVoltage.value = initial_status.max_input_voltage

        if(initial_status.low_load_en === "on")
            lowLoadEnable.checked = true

        else
            lowLoadEnable.checked = false

        if(initial_status.mid_load_en === "on")
            midCurrentEnable.checked = true

        else
            midCurrentEnable.checked = false

        if(initial_status.high_load_en === "on")
            highCurrentEnable.checked = true

        else
            highCurrentEnable.checked = false

    }

    property var reset_status: platformInterface.reset_status
    onReset_statusChanged: {
        if(reset_status.en_210 === "on")
            enable3.checked = true
        else enable3.checked = false

        if (reset_status.en_211 === "on")
            enable4.checked = true
        else  enable4.checked = false

        if(reset_status.en_213 === "on")
            enable1.checked = true
        else enable1.checked = false

        if(reset_status.en_214 === "on")
            enable2.checked = true
        else enable2.checked = false

        if(reset_status.en_333 === "on")
            enable5.checked = true
        else enable5.checked = false

        if(reset_status.low_load_en === "on")
            lowLoadEnable.checked = true
        else lowLoadEnable.checked = false

        if(reset_status.mid_load_en === "on")
            midCurrentEnable.checked = true
        else midCurrentEnable.checked = false

        if(reset_status.high_load_en === "on")
            highCurrentEnable.checked = true
        else highCurrentEnable.checked = false

        if (reset_status.load_fault === "on")
            loadFault.status = SGStatusLight.Red
        else  loadFault.status = SGStatusLight.Off


    }


    property  var switch_enable_status_en_210: platformInterface.switch_enable_status.en_210
    onSwitch_enable_status_en_210Changed: {
        if(switch_enable_status_en_210 === "on") {
            enable3.checked = true
        }
        else enable3.checked = false
    }

    property  var switch_enable_status_en_211: platformInterface.switch_enable_status.en_211
    onSwitch_enable_status_en_211Changed: {
        if(switch_enable_status_en_211 === "on") {
            enable4.checked = true
        }
        else enable4.checked = false
    }

    property  var switch_enable_status_en_214: platformInterface.switch_enable_status.en_214
    onSwitch_enable_status_en_214Changed: {
        console.log(switch_enable_status_en_214)
        if(switch_enable_status_en_214 === "on") {
            enable2.checked = true
        }
        else enable2.checked = false
    }

    property  var switch_enable_status_en_213: platformInterface.switch_enable_status.en_213
    onSwitch_enable_status_en_213Changed: {

        if(switch_enable_status_en_213 === "on") {
            enable1.checked = true
        }
        else enable1.checked = false
    }


    property  var switch_enable_status_en_333: platformInterface.switch_enable_status.en_333
    onSwitch_enable_status_en_333Changed: {
        if(switch_enable_status_en_333 === "on") {
            enable5.checked = true
        }
        else enable5.checked = false
    }



    function pushMessagesToLog (messageIs) {
        // Change text color to black of the entire existing list of faults
        for(var j = 0; j < logFault.model.count; j++){
            logFault.model.get(j).color = "black"
        }

        logFault.insert(messageIs, 0, "red")

    }

    ColumnLayout {
        // id: root
        anchors.fill: parent
        spacing: 5

        property var periodic_status: platformInterface.periodic_status
        onPeriodic_statusChanged: {
            setting1Reading.text = periodic_status.ADC_213
            setting2Reading.text = periodic_status.ADC_214
            setting3Reading.text = periodic_status.ADC_210
            setting4Reading.text = periodic_status.ADC_211
            setting5Reading.text = periodic_status.ADC_333
            vinReading.text = periodic_status.ADC_VIN

            if(periodic_status.interrupts.vs_int === "on") {
                voltageStatusLight.status = SGStatusLight.Red
            }
            else voltageStatusLight.status = SGStatusLight.Off

            if(periodic_status.interrupts.cs_int === "on") {
                currentStatusLight.status = SGStatusLight.Red
            }
            else currentStatusLight.status = SGStatusLight.Off

            if(periodic_status.interrupts.i_in_int === "on") {
                loadCurrent.status = SGStatusLight.Red
            }
            else loadCurrent.status = SGStatusLight.Off

        }

        property var current_sense_interrupt: platformInterface.current_sense_interrupt
        onCurrent_sense_interruptChanged:  {
            if(current_sense_interrupt.value === "yes") {
                currentStatusLight.status = SGStatusLight.Red
                pushMessagesToLog("On-Board Load Current Interrupt")
            }
            else currentStatusLight.status = SGStatusLight.Off

            if(current_sense_interrupt.load_fault === "on")
                loadFault.status = SGStatusLight.Red

            else loadFault.status = SGStatusLight.off
        }



        property var voltage_sense_interrupt: platformInterface.voltage_sense_interrupt
        onVoltage_sense_interruptChanged: {
            if(voltage_sense_interrupt.value === "yes") {
                voltageStatusLight.status = SGStatusLight.Red
                pushMessagesToLog("Input Voltage Interruptt")
            }
            else voltageStatusLight.status = SGStatusLight.Off

            if(voltage_sense_interrupt.load_fault === "on")
                loadFault.status = SGStatusLight.Red

            else loadFault.status = SGStatusLight.off

        }

        property var i_in_interrupt: platformInterface.i_in_interrupt
        onI_in_interruptChanged: {
            if(i_in_interrupt.value === "yes") {
                loadCurrent.status = SGStatusLight.Red
                pushMessagesToLog("Input Current Interrupt")

            }
            else loadCurrent.status = SGStatusLight.Off

            if(i_in_interrupt.load_fault === "on")
                loadFault.status = SGStatusLight.Red

            else loadFault.status = SGStatusLight.Off


        }

        Text {
            id: platformName
            Layout.alignment: Qt.AlignHCenter
            text: "Strata Enable Current Sense"
            font.bold: true
            font.pixelSize: ratioCalc * 25
            topPadding: 7
        }


        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - platformName.contentHeight - 40
            Layout.alignment: Qt.AlignCenter


            RowLayout {
                anchors.fill:parent
                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    ColumnLayout {
                        anchors.fill: parent

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Text {
                                id: settings
                                text: "Settings"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
                                color: "#696969"
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    top: parent.top
                                }
                            }

                            Rectangle {
                                id: line1
                                height: 2
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: settings.bottom
                                    topMargin: 7
                                }
                            }

                            ColumnLayout{
                                anchors {
                                    top: line1.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout{
                                        anchors.fill:parent
                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        // anchors.centerIn: parent

                                                        text: "NCS213R"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                    }
                                                }

                                                Rectangle {

                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.top:parent.top
                                                        anchors.horizontalCenter: parent.horizontalCenter

                                                        text: "30A Max"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc
                                                        color: "red"
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGSwitch {
                                                id: enable1
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                fontSizeMultiplier: ratioCalc
                                                anchors.centerIn: parent



                                                onToggled: {
                                                    if(checked)
                                                        platformInterface.switch_enables.update("213_on")
                                                    else platformInterface.switch_enables.update("off")
                                                }

                                            }


                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGInfoBox {
                                                id: setting1Reading
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height:  35 * ratioCalc
                                                width: 140 * ratioCalc
                                                unit: " A"
                                                unitFont.bold: true
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                    }
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout{
                                        anchors.fill:parent
                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "NCS214R"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                    }
                                                }
                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.top:parent.top
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "1A Max"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc
                                                        color: "red"
                                                    }
                                                }

                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGSwitch {
                                                id: enable2

                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                fontSizeMultiplier: ratioCalc

                                                anchors.centerIn: parent


                                                onToggled: {

                                                    if(checked)
                                                        platformInterface.switch_enables.update("214_on")
                                                    else platformInterface.switch_enables.update("off")
                                                }


                                            }

                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGInfoBox {
                                                id: setting2Reading
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height:  35 * ratioCalc
                                                width: 140 * ratioCalc
                                                unit: " A"
                                                unitFont.bold: true
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                                //                                                anchors.horizontalCenter: parent.horizontalCenter
                                                //                                                anchors.horizontalCenterOffset: 5
                                            }
                                        }

                                    }
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout{
                                        anchors.fill:parent
                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            ColumnLayout {
                                                anchors.fill: parent
                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "NCS210R"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc * 1.2
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.top:parent.top
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "100mA Max"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc
                                                        color: "red"
                                                    }

                                                }

                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGSwitch {
                                                id: enable3
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                fontSizeMultiplier: ratioCalc

                                                anchors.centerIn: parent
                                                onToggled:  {
                                                    if(checked)
                                                        platformInterface.switch_enables.update("210_on")
                                                    else platformInterface.switch_enables.update("off")
                                                }

                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            // color: "red"

                                            SGInfoBox {
                                                id: setting3Reading
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height:  35 * ratioCalc
                                                width: 155 * ratioCalc
                                                unit: " mA"
                                                unitFont.bold: true
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                    }
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout{
                                        anchors.fill:parent
                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            ColumnLayout {
                                                anchors.fill: parent

                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.bottom: parent.bottom
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "NCS211R"
                                                        font.bold: true
                                                        fontSizeMultiplier:ratioCalc * 1.2
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    SGText {
                                                        anchors.top:parent.top
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: "2mA Max"
                                                        font.bold: true
                                                        fontSizeMultiplier: ratioCalc
                                                        color: "red"
                                                    }
                                                }
                                            }

                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGSwitch {
                                                id: enable4
                                                //                                            height: 35 * ratioCalc
                                                //                                            width: 95 * ratioCalc
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                fontSizeMultiplier: ratioCalc

                                                anchors.centerIn: parent

                                                onToggled:  {
                                                    if(checked)
                                                        platformInterface.switch_enables.update("211_on")
                                                    else platformInterface.switch_enables.update("off")
                                                }

                                            }

                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGInfoBox {
                                                id: setting4Reading
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height:  35 * ratioCalc
                                                width: 155 * ratioCalc
                                                unit: " mA"
                                                unitFont.bold: true
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                    }
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout{
                                        anchors.fill:parent
                                        ColumnLayout {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            Rectangle{
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                SGText {
                                                    anchors.bottom: parent.bottom
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: "NCS333A"
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    font.bold: true
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                SGText {
                                                    anchors.top:parent.top
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: "100uA Max"
                                                    font.bold: true
                                                    fontSizeMultiplier: ratioCalc
                                                    color: "red"

                                                }
                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGSwitch {
                                                id: enable5
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                fontSizeMultiplier: ratioCalc

                                                anchors.centerIn: parent


                                                onToggled:  {
                                                    if(checked)
                                                        platformInterface.switch_enables.update("333_on")
                                                    else platformInterface.switch_enables.update("off")

                                                }
                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGInfoBox {
                                                id: setting5Reading
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height:  35 * ratioCalc
                                                width: 155 * ratioCalc
                                                unit: " µA"
                                                unitFont.bold: true
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter

                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    RowLayout {
                                        anchors.fill: parent

                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGText {
                                                id: vinText
                                                text : "VIN"
                                                fontSizeMultiplier:ratioCalc * 1.2
                                                font.bold: true
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGInfoBox {
                                                id: vinReading
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                height:  35 * ratioCalc
                                                width: 140 * ratioCalc
                                                unit: " V"
                                                unitFont.bold: true
                                                boxColor: "lightgrey"
                                                boxFont.family: Fonts.digitalseven
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }


                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    RowLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGButton {
                                                text: "Recalibrate"
                                                anchors.centerIn: parent
                                                fontSizeMultiplier: ratioCalc
                                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                                hoverEnabled: true
                                                height: parent.height/2
                                                width: parent.width/2
                                                onClicked: platformInterface.set_recalibrate.send()
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGButton {
                                                text: "Reset"
                                                fontSizeMultiplier: ratioCalc
                                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                                hoverEnabled: true
                                                height: parent.height/2
                                                width: parent.width/2
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                                onClicked: {
                                                    platformInterface.reset_board.send()
                                                    platformInterface.switch_enables.update("off")
                                                    platformInterface.load_enables.update("off")
                                                    logFault.clear()
                                                    enable1.checked = false
                                                    enable2.checked = false
                                                    enable3.checked = false
                                                    enable4.checked = false
                                                    enable5.checked = false
                                                    lowLoadEnable.checked = false
                                                    midCurrentEnable.checked = false
                                                    highCurrentEnable.checked = false


                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: parent.height/3
                            Layout.fillWidth: true

                            Text {
                                id: modeSet
                                text: "Manual Mode Set"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
                                color: "#696969"
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    top: parent.top
                                }
                            }

                            Rectangle {
                                id: line4
                                height: 2
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: modeSet.bottom
                                    topMargin: 7
                                }
                            }

                            RowLayout {
                                anchors {
                                    top: line4.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width/4

                                    SGAlignedLabel {
                                        id:  enableModeSetLabel
                                        target: enableModeSet
                                        text: "Enable"
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        alignment: SGAlignedLabel.SideTopCenter
                                        anchors.centerIn: parent
                                        SGSwitch {
                                            id: enableModeSet
                                            checkedLabel: "Manual"
                                            uncheckedLabel: "Auto"
                                            fontSizeMultiplier: ratioCalc
                                            onCheckedChanged: {
                                                if(checked) {
                                                    maxInputCurrentContainer.enabled = true
                                                    maxInputCurrentContainer.opacity = 1.0
                                                    maxInputVoltageContainer.enabled = true
                                                    maxInputVoltageContainer.opacity = 1.0
                                                    platformInterface.set_mode.update("Manual")
                                                }
                                                else {
                                                    maxInputCurrentContainer.enabled = false
                                                    maxInputCurrentContainer.opacity = 0.5
                                                    maxInputVoltageContainer.enabled = false
                                                    maxInputVoltageContainer.opacity = 0.5
                                                    platformInterface.set_mode.update("Auto")
                                                }
                                            }
                                        }

                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    ColumnLayout{
                                        anchors.fill: parent
                                        Rectangle {
                                            id: maxInputCurrentContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGAlignedLabel {
                                                id:  maxInputCurrentLabel
                                                target: maxInputCurrent
                                                text: "Set Max Input Current"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.centerIn: parent

                                                SGSlider {
                                                    id: maxInputCurrent
                                                    width: maxInputCurrentContainer.width - 50
                                                    live: false
                                                    from: 0
                                                    to: 30
                                                    stepSize: 0.1
                                                    fromText.text: "0A"
                                                    toText.text: "30A"

                                                    inputBoxWidth: maxInputCurrentContainer/9
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    inputBox.validator: DoubleValidator { }
                                                    onUserSet: {
                                                        var valueSet = parseInt(value)
                                                        if (valueSet > maxInputCurrent.to) {
                                                            value = maxInputCurrent.to
                                                        }
                                                        if (valueSet < maxInputCurrent.from) {
                                                            value = maxInputCurrent.from
                                                        }
                                                        platformInterface.set_i_in_dac.update(value)

                                                    }

                                                    property var switch_enable_status_in_max: platformInterface.switch_enable_status.i_in_max
                                                    onSwitch_enable_status_in_maxChanged:  {
                                                        console.log(switch_enable_status_in_max)
                                                        if(switch_enable_status_in_max !== "N/A") {
                                                            maxInputCurrent.value = switch_enable_status_in_max
                                                        }
                                                    }





                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: maxInputVoltageContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id:  maxInputVoltageLabel
                                                target: maxInputVoltage
                                                text: "Set Max Input Voltage"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.centerIn: parent

                                                SGSlider {
                                                    id: maxInputVoltage
                                                    width: maxInputVoltageContainer.width - 50
                                                    live: false
                                                    from: 0
                                                    to: 26
                                                    stepSize: 0.1
                                                    fromText.text: "0V"
                                                    toText.text: "26V"

                                                    inputBoxWidth: maxInputVoltageContainer/9
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    inputBox.validator: DoubleValidator { top: 26; bottom: 0}



                                                    onUserSet:{
                                                        var valueSet = parseInt(value)
                                                        if (valueSet > maxInputVoltage.to) {
                                                            value = maxInputVoltage.to
                                                        }
                                                        if (valueSet < maxInputVoltage.from) {
                                                            value = maxInputVoltage.from

                                                        }


                                                        platformInterface.set_v_set.update(parseFloat(value.toFixed(2)))

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

                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    ColumnLayout {
                        anchors.fill: parent

                        Rectangle {
                            Layout.preferredHeight: parent.height/1.8
                            Layout.fillWidth: true


                            Text {
                                id: onboardLoadControl
                                text: "On-Board Load Controls"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
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
                                    top: onboardLoadControl.bottom
                                    topMargin: 7
                                }
                            }

                            ColumnLayout{
                                anchors {
                                    top: line3.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }

                                ColumnLayout {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true

                                        RowLayout {
                                            anchors.fill: parent

                                            Rectangle {
                                                Layout.preferredWidth: parent.width/6
                                                Layout.fillHeight: true
                                                SGAlignedLabel {
                                                    id: lowCurrentLabel
                                                    target: lowLoadEnable
                                                    text: "<b>" + qsTr("Low Current") + "</b>"
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    alignment: SGAlignedLabel.SideTopCenter
                                                    anchors.centerIn: parent
                                                    SGSwitch {
                                                        id: lowLoadEnable
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        fontSizeMultiplier: ratioCalc
                                                        onToggled:  {
                                                            if(checked) {
                                                                platformInterface.load_enables.update("low_load_on")
                                                                platformInterface.set_load_dac_load.update(lowloadSetting.value)
                                                            }
                                                            else  {
                                                                platformInterface.load_enables.update("off")
                                                            }
                                                        }

                                                        property var load_enable_status_low_load: platformInterface.load_enable_status.low_load_en
                                                        onLoad_enable_status_low_loadChanged: {
                                                            if(load_enable_status_low_load === "on") {
                                                                lowLoadEnable.checked = true
                                                                // platformInterface.set_load_dac_load.update(lowloadSetting.value)
                                                            }
                                                            else {
                                                                lowLoadEnable.checked = false
                                                            }
                                                        }

                                                    }
                                                }
                                            }

                                            Rectangle {
                                                id: lowLoadSettingContainer
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true


                                                SGSlider {
                                                    id: lowloadSetting
                                                    width: lowLoadSettingContainer.width - 50
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.verticalCenterOffset: 10
                                                    live: false
                                                    from: 1
                                                    to:  100
                                                    stepSize: 1
                                                    fromText.text: "1µA"
                                                    toText.text: "100µA"
                                                    value: 0
                                                    inputBoxWidth: lowLoadSettingContainer.width/9
                                                    inputBox.enabled: true
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    inputBox.validator: IntValidator { top: 100; bottom: 1 }
                                                    onUserSet: {
                                                        if(lowLoadEnable.checked)
                                                            platformInterface.set_load_dac_load.update(lowloadSetting.value)
                                                    }
                                                }

                                            }

                                        }
                                    }
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true

                                        RowLayout{
                                            anchors.fill: parent
                                            Rectangle {
                                                Layout.preferredWidth: parent.width/6
                                                Layout.fillHeight: true
                                                //color: "red"
                                                SGAlignedLabel {
                                                    id: midCurrentLabel
                                                    target: midCurrentEnable
                                                    text: "<b>" + qsTr("Mid Current") + "</b>"
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    anchors.centerIn: parent
                                                    alignment: SGAlignedLabel.SideTopCenter
                                                    SGSwitch {
                                                        id: midCurrentEnable

                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        fontSizeMultiplier: ratioCalc

                                                        onToggled:  {
                                                            if(checked) {
                                                                platformInterface.load_enables.update("mid_load_on")
                                                                platformInterface.set_load_dac_load.update(midloadSetting.value.toFixed(2))
                                                            }
                                                            else {
                                                                platformInterface.load_enables.update("off")

                                                            }
                                                        }

                                                        property var load_enable_status_mid_load: platformInterface.load_enable_status.mid_load_en
                                                        onLoad_enable_status_mid_loadChanged: {
                                                            if(load_enable_status_mid_load === "on") {
                                                                midCurrentEnable.checked = true
                                                                //platformInterface.set_load_dac_load.update(midloadSetting.value.toFixed(2))
                                                            }
                                                            else {
                                                                midCurrentEnable.checked = false

                                                            }
                                                        }

                                                    }
                                                }
                                            }

                                            Rectangle {
                                                id: midLoadSettingContainer
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true


                                                SGSlider {
                                                    id: midloadSetting
                                                    width: midLoadSettingContainer.width - 50
                                                    live: false
                                                    from: 0.1
                                                    to:  100
                                                    stepSize: 0.1
                                                    fromText.text: "0.1mA"
                                                    toText.text: "100mA"
                                                    value: 0
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.verticalCenterOffset: 10
                                                    inputBoxWidth: midLoadSettingContainer.width/9
                                                    inputBox.enabled: true
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    inputBox.validator: DoubleValidator { top: 100; bottom: 0.1}
                                                    onUserSet: {
                                                        if(midCurrentEnable.checked)
                                                            platformInterface.set_load_dac_load.update(midloadSetting.value.toFixed(2))
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
                                            Rectangle {
                                                Layout.preferredWidth: parent.width/6
                                                Layout.fillHeight: true
                                                SGAlignedLabel {
                                                    id: highCurrentLabel
                                                    target: highCurrentEnable
                                                    text: "<b>" + qsTr("High Current") + "</b>"
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    anchors.centerIn: parent
                                                    alignment: SGAlignedLabel.SideTopCenter
                                                    SGSwitch {
                                                        id: highCurrentEnable
                                                        checkedLabel: "On"
                                                        uncheckedLabel: "Off"
                                                        fontSizeMultiplier: ratioCalc

                                                        onToggled:  {
                                                            if(checked) {
                                                                platformInterface.load_enables.update("high_load_on")
                                                                platformInterface.set_load_dac_load.update(highloadSetting.value.toFixed(2))
                                                            }
                                                            else {
                                                                platformInterface.load_enables.update("off")
                                                            }
                                                        }

                                                        property var load_enable_status_high_load: platformInterface.load_enable_status.high_load_en
                                                        onLoad_enable_status_high_loadChanged: {
                                                            if(load_enable_status_high_load === "on") {
                                                                highCurrentEnable.checked = true
                                                            }
                                                            else {
                                                                highCurrentEnable.checked = false
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                id: highLoadSettingContainer
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true


                                                SGSlider {
                                                    id: highloadSetting
                                                    width: highLoadSettingContainer.width - 50
                                                    live: false
                                                    from: 0.01
                                                    to:  10
                                                    stepSize: 0.01
                                                    fromText.text: "0.01A"
                                                    toText.text: "10A"
                                                    value: 0
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.verticalCenterOffset: 10
                                                    inputBoxWidth: highLoadSettingContainer.width/9
                                                    inputBox.enabled: true
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    inputBox.validator: DoubleValidator { top: 10;  bottom: 0.01 }
                                                    onUserSet: {
                                                        if(highCurrentEnable.checked)
                                                            platformInterface.set_load_dac_load.update(highloadSetting.value.toFixed(2))
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
                                            Rectangle{
                                                id: maxLoadContainer
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true

                                                SGAlignedLabel {
                                                    id: maxLoadLabel
                                                    target: maxLoadCurrent
                                                    font.bold: true
                                                    alignment: SGAlignedLabel.SideLeftCenter
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    text: "Max Load \n Current"
                                                    anchors.left: parent.left
                                                    anchors.verticalCenter: parent.verticalCenter

                                                    SGInfoBox {
                                                        id: maxLoadCurrent
                                                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                        boxColor: "lightgrey"
                                                        boxFont.family: Fonts.digitalseven
                                                        height:  35 * ratioCalc
                                                        width: 140 * ratioCalc
                                                        unit: "µA"
                                                        unitFont.bold: true

                                                        property var load_enable_status_current: platformInterface.load_enable_status.max_current
                                                        onLoad_enable_status_currentChanged:  {
                                                            maxLoadCurrent.text = load_enable_status_current
                                                        }

                                                        property var max_current_unit: platformInterface.load_enable_status.max_current_units
                                                        onMax_current_unitChanged: {
                                                            if(max_current_unit !== undefined)
                                                                maxLoadCurrent.unit = max_current_unit
                                                        }
                                                    }
                                                }
                                            }

                                            Rectangle{
                                                id: maxIVoltageContainer
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true

                                                SGAlignedLabel {
                                                    id: maxInputVolatgeLabel
                                                    target: maxInputVolage
                                                    font.bold: true
                                                    alignment: SGAlignedLabel.SideLeftCenter
                                                    fontSizeMultiplier: ratioCalc * 1.2
                                                    text: "Max Input \n Voltage"
                                                    anchors.centerIn: parent

                                                    SGInfoBox {
                                                        id: maxInputVolage
                                                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                        boxColor: "lightgrey"
                                                        boxFont.family: Fonts.digitalseven
                                                        height:  35 * ratioCalc
                                                        width: 140 * ratioCalc
                                                        unit: "<b>V</b>"
                                                        anchors.left: parent.left
                                                        anchors.verticalCenter: parent.verticalCenter

                                                        property var load_enable_status_input_voltage: platformInterface.load_enable_status.max_input_voltage
                                                        onLoad_enable_status_input_voltageChanged:  {
                                                            maxInputVolage.text = load_enable_status_input_voltage
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                    }
                                }
                            }
                        }


                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true


                            Text {
                                id: interrupt
                                text: "Interrupts"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
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
                                    top: interrupt.bottom
                                    topMargin: 7
                                }
                            }

                            ColumnLayout{
                                anchors {
                                    top: line2.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }

                                RowLayout {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        SGAlignedLabel {
                                            id:voltageStatusLabel
                                            target: voltageStatusLight
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc * 1.2
                                            text: "Input Voltage\n Status"
                                            font.bold: true

                                            SGStatusLight {
                                                id: voltageStatusLight
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true

                                        SGAlignedLabel {
                                            id: currentStatusLabel
                                            target: currentStatusLight
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc * 1.2
                                            text: "On-Board Load\n Current Status"
                                            font.bold: true

                                            SGStatusLight {
                                                id: currentStatusLight
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        SGAlignedLabel {
                                            id:loadCurrentStatusLabel
                                            target: loadCurrent
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc * 1.2
                                            text: "Input Current\n Status"
                                            font.bold: true

                                            SGStatusLight {
                                                id: loadCurrent
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        SGAlignedLabel {
                                            id: loadFaultLabel
                                            target: loadFault
                                            alignment: SGAlignedLabel.SideTopCenter
                                            anchors.centerIn: parent
                                            fontSizeMultiplier: ratioCalc * 1.2
                                            text: "Load\n Fault "
                                            font.bold: true

                                            SGStatusLight {
                                                id: loadFault
                                            }
                                        }
                                    }
                                }


                                Rectangle {
                                    id: statusListContainer
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    SGStatusLogBox{
                                        id: logFault
                                        width: parent.width/1.5
                                        height: parent.height - 10
                                        title: "Status List"
                                        anchors.centerIn: parent

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
                                                            logFault.showMessageIds ?
                                                                model.id + ": " + model.message :
                                                                model.message
                                                            )}

                                                fontSizeMultiplier: logFault.fontSizeMultiplier
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
                            }

                        }
                    }
                }
            } // end of RowLayout
        }
    }
}
