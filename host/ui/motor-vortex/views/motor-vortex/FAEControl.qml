import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/motor-vortex/sgwidgets"
import "qrc:/views/motor-vortex/Control.js" as MotorControl

Rectangle {
    id: faeControl
    anchors {
        fill: parent
    }

    property alias motorSpeedSliderValue: targetSpeedSlider.value
    property alias rampRateSlider: rampRateSlider.value
    property alias phaseAngle: phaseAngleRow.phaseAngleValue
    property alias ledSlider: hueSlider.value
    property alias singleLEDSlider: singleColorSlider.value
    property alias ledPulseSlider: ledPulseFrequency.value

    signal motorStateSignal()
    signal driveModeSignal(var mode_type)

    Component.onCompleted:  {
        /*
          Setting the deflaut to be trapezoidal
        */
        phaseAngle = 15
        platformInterface.set_system_mode.update("manual");
        platformInterface.set_phase_angle.update(parseInt(15));
        console.log("phase angle", phaseAngle)
        platformInterface.set_drive_mode.update(parseInt(0));

    }

    Rectangle {
        id: leftSide
        width: 600
        height: childrenRect.height
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: warningBox
            color: "red"
            anchors {
                top: leftSide.top
                horizontalCenter: leftSide.horizontalCenter
            }
            width: warningText.contentWidth + 120
            height: warningText.contentHeight + 40

            Text {
                id: warningText
                anchors {
                    centerIn: parent
                }
                text: "<b>Restricted Access:</b> ON Semi Employees Only"
                font.pixelSize: 18
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
                font.pixelSize: 50
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
                font.pixelSize: 50
                color: "white"
            }

            FontLoader {
                id: icons
                source: "sgwidgets/fonts/sgicons.ttf"
            }
        }

        SGLabelledInfoBox{
            id: vInBox
            label: "Vin (volts):"
            info: platformInterface.input_voltage_notification.vin
            infoBoxWidth: 80
            anchors {
                top: warningBox.bottom
                topMargin: 20
                horizontalCenter: vInGraph.horizontalCenter
            }
        }

        SGLabelledInfoBox{
            id: speedBox
            label: "Current Speed (rpm):"
            info: platformInterface.pi_stats.current_speed
            infoBoxWidth: 100
            anchors {
                top: warningBox.bottom
                topMargin: 20
                horizontalCenter: speedGraph.horizontalCenter
            }
        }

        SGGraph{
            id: vInGraph
            width: 300
            height: 300
            anchors {
                top: vInBox.bottom
            }
            showOptions: false
            xAxisTitle: "Seconds"
            yAxisTitle: "Voltage"
            inputData: platformInterface.input_voltage_notification.vin
            maxYValue: 15
            repeatingData: true
        }

        SGGraph{
            id: speedGraph
            width: 300
            height: 300
            anchors {
                top: vInBox.bottom
                left: vInGraph.right
            }
            showOptions: false
            xAxisTitle: "Seconds"
            yAxisTitle: "RPM"
            inputData: platformInterface.pi_stats.current_speed
            maxYValue: 6500
            repeatingData: true
        }

        SGStatusListBox {
            id: faultBox
            title: "Faults:"
            anchors {
                top: speedGraph.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: 500
            height: 200
            model: faultModel
        }

        property var errorArray: platformInterface.system_error.error_and_warnings
        onErrorArrayChanged: {
            for (var i in errorArray){
                faultModel.append({ status : errorArray[i] })
            }
        }

        ListModel {
            id: faultModel

        }
    }

    Rectangle {
        id: rightSide
        width: 600
        height: childrenRect.height
        anchors {
            left: leftSide.right
            verticalCenter: parent.verticalCenter
        }

        Item {
            id: ssButtonContainer
            width: childrenRect.width
            height: childrenRect.height
            anchors {
                horizontalCenter: rightSide.horizontalCenter
            }

            Button {
                id: startStopButton
                text: checked ? qsTr("Start Motor") : qsTr("Stop Motor")
                checkable: true
                property var motorOff: platformInterface.motor_off.enable;

                onMotorOffChanged: {
                    if(motorOff === "off") {
                        startStopButton.checked = true;
                    }
                }
                background: Rectangle {
                    color: startStopButton.checked ? "lightgreen" : "red"
                    implicitWidth: 100
                    implicitHeight: 40
                }
                contentItem: Text {
                    text: startStopButton.text
                    color: startStopButton.checked ? "black" : "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                Connections {
                    target: advanceView
                    onMotorStateSignal: {
                        console.log("signal called");
                        startStopButton.checked = false;
                    }
                }

                onClicked: {
                    if(checked) {
                        platformInterface.set_motor_on_off.update(parseInt("0"))
                    }
                    else {
                        platformInterface.motor_speed.update(targetSpeedSlider.value.toFixed(0));
                        platformInterface.set_motor_on_off.update(parseInt("1"))
                        motorStateSignal();
                        faultModel.clear();
                    }
                }
            }

            Button {
                id: resetButton
                anchors {
                    left: startStopButton.right
                    leftMargin: 20
                }
                text: qsTr("Reset")
                onClicked: {
                    platformInterface.set_reset_mcu.update()
                }
            }
        }

        Rectangle {
            id: operationModeControlContainer
            width: 500
            height: childrenRect.height + 20
            color: speedSafetyButton.checked ? "#ffb4aa" : "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: ssButtonContainer.bottom
                topMargin: 10
            }

            SGRadioButtonContainer {
                id: operationModeControl
                anchors {
                    top: operationModeControlContainer.top
                    topMargin: 10
                    horizontalCenter: operationModeControlContainer.horizontalCenter
                }

                label: "<b>Operation Mode:</b>"
                labelLeft: true
                exclusive: true

                radioGroup: GridLayout {
                    columnSpacing: 10
                    rowSpacing: 10

                    // Optional properties to access specific buttons cleanly from outside
                    property alias manual : manual
                    property alias automatic: automatic

                    property var systemMode: platformInterface.set_mode.system_mode

                    onSystemModeChanged: {
                        if(systemMode === "manual") {
                            manual.checked = true;
                        }
                        else {
                            automatic.checked = true;
                        }
                    }

                    SGRadioButton {
                        id: manual
                        text: "Manual Control"
                        checked: true
                        onClicked: {
                            if(checked) {
                                platformInterface.system_mode_selection.update("manual")
                            }
                        }

                    }

                    SGRadioButton {
                        id: automatic
                        text: "Automatic Demo Pattern"

                        onCheckedChanged: {
                            if (checked) {
                                platformInterface.system_mode_selection.update("automation")

                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: speedControlContainer
            width: 500
            height: childrenRect.height + 20
            color: speedSafetyButton.checked ? "#ffb4aa" : "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: operationModeControlContainer.bottom
                topMargin: 10
            }

            SGSlider {
                id: targetSpeedSlider
                label: "Target Speed:"
                width: 350
                from: speedSafetyButton.checked ? 0 : 1500
                to: speedSafetyButton.checked ? 10000 : 5500
                endLabel: speedSafetyButton.checked? "<font color='red'><b>"+ to +"</b></font>" : to
                anchors {
                    verticalCenter: setSpeed.verticalCenter
                    left: speedControlContainer.left
                    leftMargin: 10
                    right: setSpeed.left
                    rightMargin: 10
                }

                onValueChanged: {
                    platformInterface.motor_speed.update(value.toFixed(0));
                    setSpeed.input = value.toFixed(0)
                }
            }

            SGSubmitInfoBox {
                id: setSpeed
                infoBoxColor: "white"
                anchors {
                    top: speedControlContainer.top
                    topMargin: 10
                    right: speedControlContainer.right
                    rightMargin: 10
                }
                buttonVisible: false
                onApplied: { targetSpeedSlider.value = parseInt(value, 10) }
                input: targetSpeedSlider.value
                infoBoxWidth: 80
            }

            SGSlider {
                id: rampRateSlider
                label: "Ramp Rate:"
                width: 350
                value: 3
                from : 0
                to: 6
                anchors {
                    verticalCenter: setRampRate.verticalCenter
                    left: speedControlContainer.left
                    leftMargin: 10
                    right: setRampRate.left
                    rightMargin: 10
                }
                onValueChanged: {
                    platformInterface.set_ramp_rate.update(rampRateSlider.value.toFixed(0))
                    setRampRate.input = value.toFixed(0)
                }
            }

            SGSubmitInfoBox {
                id: setRampRate
                infoBoxColor: "white"
                anchors {
                    top: setSpeed.bottom
                    topMargin: 10
                    right: speedControlContainer.right
                    rightMargin: 10
                }
                buttonVisible: false
                onApplied: { rampRateSlider.value = parseInt(value, 10) }
                input: rampRateSlider.value
                infoBoxWidth: 80
            }

            Item {
                id: speedSafety
                height: childrenRect.height
                anchors {
                    top: rampRateSlider.bottom
                    topMargin: 10
                    left: speedControlContainer.left
                    leftMargin: 10
                    right: speedControlContainer.right
                    rightMargin: 10
                }

                Button {
                    id: speedSafetyButton
                    width: 160
                    anchors {
                        left: speedSafety.left
                    }
                    text: checked ? "Turn Safety Limits On" : "<font color='red'><b>Turn Safety Limits Off</b></font>"
                    checkable: true
                    onClicked: if (checked) speedPopup.open()
                }

                Text {
                    id: speedWarning
                    text: "<font color='red'><strong>Warning:</strong></font> The demo setup can be damaged by running past the safety limits"
                    wrapMode: Text.WordWrap
                    anchors {
                        left: speedSafetyButton.right
                        leftMargin: 20
                        right: speedSafety.right
                        verticalCenter: speedSafetyButton.verticalCenter
                    }
                }
            }
        }

        Rectangle {
            id: driveModeContainer
            width: 500
            height: childrenRect.height + 20 // 20 for margina
            color: "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: speedControlContainer.bottom
                topMargin: 10
            }

            SGRadioButtonContainer {
                id: driveModeRadios
                anchors {
                    horizontalCenter: driveModeContainer.horizontalCenter
                    top: driveModeContainer.top
                    topMargin: 10
                }
                label: "Drive Mode:"



                radioGroup: GridLayout {
                    columnSpacing: 10
                    rowSpacing: 10

                    // Optional properties to access specific buttons cleanly from outside
                    property alias ps : ps
                    property alias trap: trap

                    Connections {
                        target: advanceView
                        onDriveModeSignal: {
                            console.log("mode type", mode_type)
                            if(mode_type == "Trapezoidal"){
                                trap.checked = true;
                                ps.checked = false;
                            }

                            else {
                                trap.checked = false;
                                ps.checked = true;
                            }

                        }
                    }
                    SGRadioButton {
                        id: ps
                        text: "Pseudo-Sinusoidal"
                        onCheckedChanged: {
                            if (checked) {
                                platformInterface.set_drive_mode.update(parseInt("1"))
                                driveModeSignal("Pseudo-Sinusoidal");
                            }
                        }
                    }

                    SGRadioButton {
                        id: trap
                        text: "Trapezoidal"
                        checked: true
                        onCheckedChanged: {
                            if (checked) {
                                platformInterface.set_drive_mode.update(parseInt("0"))
                                driveModeSignal("Trapezoidal");
                            }
                        }
                    }
                }
            }

            Item {
                id: phaseAngleRow
                width: childrenRect.width
                height: childrenRect.height
                property int phaseAngleValue: phaseAngle
                anchors {
                    top: driveModeRadios.bottom
                    topMargin: 10
                    horizontalCenter: driveModeContainer.horizontalCenter
                }

                Text {
                    width: contentWidth
                    id: phaseAngleTitle
                    text: qsTr("Phase Angle:")
                    anchors {
                        verticalCenter: driveModeCombo.verticalCenter
                    }
                }

                ComboBox{
                    id: driveModeCombo
                    currentIndex: phaseAngleRow.phaseAngleValue
                    model: ["0", "1.875", "3.75","5.625","7.5", "9.375", "11.25","13.125", "15", "16.875", "18.75", "20.625", "22.5" , "24.375" , "26.25" , "28.125"]
                    anchors {
                        top: phaseAngleRow.top
                        left: phaseAngleTitle.right
                        leftMargin: 20
                    }

                    onCurrentIndexChanged: {
                        platformInterface.set_phase_angle.update((currentIndex));
                        phaseAngleRow.phaseAngleValue =  driveModeCombo.currentIndex;
                    }
                }
            }
        }

        Rectangle {
            id: ledControlContainer
            width: 500
            height: childrenRect.height + 10
            color: "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: driveModeContainer.bottom
                topMargin: 10
            }

            SGHueSlider {
                id: hueSlider
                label: "Set LED color:"
                labelLeft: true
                value: 128
                anchors {
                    verticalCenter: whiteButton.verticalCenter
                    left: ledControlContainer.left
                    leftMargin: 10
                    right: ledControlContainer.right
                    rightMargin: 10
                    top: ledControlContainer.top
                    topMargin: 10
                }
                onValueChanged: {
                    platformInterface.set_color_mixing.update(color1,color_value1,color2,color_value2)
                }
            }

            Item {
                id: buttonControlContainer
                anchors{
                    top: hueSlider.bottom
                    topMargin: 10
                    horizontalCenter: ledControlContainer.horizontalCenter
                    horizontalCenterOffset: 40
                }
                width: 300; height: 50

                Button {
                    id: whiteButton
                    checkable: false
                    text: "White"
                    onClicked: {
                        platformInterface.set_led_outputs_on_off.update("white")
                    }
                }

                Button {
                    id: turnOff
                    checkable: false
                    text: "Turn Off"
                    anchors {
                        left: whiteButton.right
                        leftMargin: 30
                    }
                    onClicked: {
                        platformInterface.set_led_outputs_on_off.update("off")
                    }
                }
            }
        }

        Rectangle {
            id: ledSecondContainer
            width: 500
            height: childrenRect.height + 20
            color: "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: ledControlContainer.bottom
                topMargin: 10
            }

            SGRGBSlider {
                id: singleColorSlider
                label: "Single LED color:"
                labelLeft: true
                anchors {
                    top: ledSecondContainer.top
                    topMargin: 10
                    left: ledSecondContainer.left
                    leftMargin: 10
                    right: ledSecondContainer.right
                    rightMargin: 10
                }
                onValueChanged: {
                    platformInterface.set_single_color.update(color, color_value)
                }
            }

            SGSlider {
                id: ledPulseFrequency
                label: "LED Pulse Frequency:"
                value: 50
                from: 2
                to: 152
                anchors {
                    left: ledSecondContainer.left
                    leftMargin: 10
                    top: singleColorSlider.bottom
                    topMargin: 10
                    right: setLedPulse.left
                    rightMargin: 10
                }

                onValueChanged: {
                    setLedPulse.input = value.toFixed(0)
                    platformInterface.set_blink0_frequency.update(value.toFixed(0));
                }
            }

            SGSubmitInfoBox {
                id: setLedPulse
                infoBoxColor: "white"
                anchors {
                    right: ledSecondContainer.right
                    rightMargin: 10
                    verticalCenter: ledPulseFrequency.verticalCenter
                }
                buttonVisible: false
                onApplied:  {
                    ledPulseFrequency.value = parseInt(value, 10)
                }
                input: ledPulseFrequency.value
                infoBoxWidth: 80
            }
        }

        Rectangle {
            id: directionControlContainer
            width: 500
            height: childrenRect.height + 20
            color: directionSafetyButton.checked ? "#ffb4aa" : "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: ledSecondContainer.bottom
                topMargin: 10
            }

            SGRadioButtonContainer {
                id: directionRadios
                anchors {
                    horizontalCenter: directionControlContainer.horizontalCenter
                    top: directionControlContainer.top
                    topMargin: 10
                }

                // Optional configuration:
                label: "Direction:"

                radioGroup: GridLayout {
                    columnSpacing: 10
                    rowSpacing: 10

                    SGRadioButton {
                        text: "Forward"
                        checked: true
                        enabled: directionSafetyButton.checked
                    }

                    SGRadioButton {
                        text: "Reverse"
                        enabled: directionSafetyButton.checked
                    }
                }
            }

            Item {
                id: directionSafety
                height: childrenRect.height
                anchors {
                    top: directionRadios.bottom
                    topMargin: 10
                    left: directionControlContainer.left
                    leftMargin: 10
                    right: directionControlContainer.right
                    rightMargin: 10
                }

                Button {
                    id: directionSafetyButton
                    width: 185
                    anchors {
                        left: directionSafety.left
                    }
                    text: checked ? "Turn Direction Lock On" : "<font color='red'><b>Turn Direction Lock Off</b></font>"
                    checkable: true
                    checked: false
                    onClicked: if (checked) directionPopup.open()
                }

                Text {
                    id: directionWarning
                    text: "<font color='red'><strong>Warning:</strong></font> Changing the direction of the motor will damage the pump."
                    wrapMode: Text.WordWrap
                    anchors {
                        left: directionSafetyButton.right
                        leftMargin: 20
                        right: directionSafety.right
                        verticalCenter: directionSafetyButton.verticalCenter
                    }
                }
            }
        }
    }

    Dialog {
        id: speedPopup
        x: Math.round((advancedControl.width - width) / 2)
        y: Math.round((advancedControl.height - height) / 2)
        width: 350
        height: speedPopupText.height + footer.height + padding * 2
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        padding: 20
        background: Rectangle {
            border.width: 0
        }
        standardButtons: Dialog.Ok | Dialog.Cancel
        onRejected: { speedSafetyButton.checked = false }

        Text {
            id: speedPopupText
            width: speedPopup.width - speedPopup.padding * 2
            height: contentHeight
            wrapMode: Text.WordWrap
            text: "<font color='red'><strong>Warning:</strong></font> The demo setup may be damaged if run beyond the safety limits. Are you sure you'd like to turn off the limits?"
        }
        Component.onCompleted: {
            console.log("directionPop", directionPopup.x, directionPopup.y);
        }
    }

    Dialog {
        id: directionPopup
        x: Math.round((faeControl.width - width) / 2)
        y: Math.round((faeControl.height - height) / 2)
        width: 350
        height: directionPopupText.height + footer.height + padding * 2
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        padding: 20
        background: Rectangle {
            border.width: 0
        }
        standardButtons: Dialog.Ok | Dialog.Cancel
        onRejected: { directionSafetyButton.checked = false }

        Text {
            id: directionPopupText
            width: directionPopup.width - directionPopup.padding * 2
            height: contentHeight
            wrapMode: Text.WordWrap
            text: "<font color='red'><strong>Warning:</strong></font> The pump will be damaged if run in reverse. Are you sure you'd like to turn off the direction lock?"
        }
    }
}
