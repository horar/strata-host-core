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
    function parseCurrentSpeed(notification)
    {
        var periodic_current_speed = notification.payload.current_speed;

        if(periodic_current_speed !== undefined)
        {
            speedBox.info = periodic_current_speed;
        }
        else
        {
            console.log("Junk data found", periodic_current_speed);
        }
    }

    function parseVin(notification)
    {
        var input_voltage =  notification.payload.vin;

        if(input_voltage !== undefined)
        {
            vInBox.info = input_voltage;
        }
        else
        {
            console.log("Junk data found", input_voltage);
        }
    }

    function parseSystemError(notification)
    {
        var system_error = notification.payload.system_error
        if(system_error !== undefined)
        {

            // set the status list box ask david
          for ( var i = 0; i < system_error.length; ++i)
           {
            demoModel.append({ "status" : system_error[i] });
           }
        }
        else
        {
            console.log("Junk data found", system_error);
        }
    }


    Component.onCompleted:  {
        /*
          Setting the deflaut to be trapezoidal
        */
        MotorControl.setDriveMode(parseInt("0"));
        MotorControl.printDriveMode();
        MotorControl.setPhaseAngle(parseInt("15"));
        MotorControl.printPhaseAngle();
        // coreInterface.sendCommand(MotorControl.getDriveMode());
        //coreInterface.sendCommand(MotorControl.getSetPhaseAngle());
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
                font.pointSize: 18
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
                font.pointSize: 50
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
                font.pointSize: 50
                color: "white"
            }

            FontLoader {
                id: icons
                source: "sgwidgets/fonts/sgicons.ttf"
            }
        }

        SGLabelledInfoBox{
            id: vInBox
            label: "Vin:"
            info: "12.3v"
            infoBoxWidth: 80
            anchors {
                top: warningBox.bottom
                topMargin: 20
                horizontalCenter: vInGraph.horizontalCenter
            }
        }

        SGLabelledInfoBox{
            id: speedBox
            label: "Current Speed:"
            info: "4050 rpm"
            infoBoxWidth: 80
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
            inputData: vInBox.info
            maxYValue: 15
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
            inputData: speedBox.info
            maxYValue: 6500
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
            model: demoModel
        }

        ListModel {
            id: demoModel
            ListElement {
                status: ""
            }
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

                onClicked: {
                    if(checked) {
                        MotorControl.setMotorOnOff(parseInt("0"));
                        MotorControl.printSetMotorState();
                        //   coreInterface.sendCommand(MotorControl.getMotorstate());
                    }
                    else {
                        MotorControl.setMotorOnOff(parseInt("1"));
                        MotorControl.printSetMotorState();
                        //    coreInterface.sendCommand(MotorControl.getMotorstate());
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
                    coreInterface.sendCommand(MotorControl.getResetcmd());
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
                topMargin: 20
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

                    SGRadioButton {
                        id: manual
                        text: "Manual Control"
                        checked: true
                        onCheckedChanged: {
                            if (checked) {
                                MotorControl.setSystemModeSelection("manual");
                                MotorControl.printsystemModeSelection()
                                // send command to platform
                                // coreInterface.sendCommand(MotorControl.getSystemModeSelection())
                            }
                        }
                    }

                    SGRadioButton {
                        id: automatic
                        text: "Automatic Demo Pattern"
                        onCheckedChanged: {
                            if (checked) {
                                MotorControl.setSystemModeSelection("automation");
                                MotorControl.printsystemModeSelection()
                                // send command to platform
                                //coreInterface.sendCommand(MotorControl.getSystemModeSelection())
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
                topMargin: 20
            }

            SGSlider {
                id: targetSpeedSlider
                label: "Target Speed:"
                width: 350
                minimumValue: speedSafetyButton.checked ? 0 : 1500
                maximumValue: speedSafetyButton.checked ? 10000 : 5500
                endLabel: speedSafetyButton.checked? "<font color='red'><b>"+ maximumValue +"</b></font>" : maximumValue
                startLabel: minimumValue
                anchors {
                    top: speedControlContainer.top
                    topMargin: 10
                    left: speedControlContainer.left
                    leftMargin: 10
                    right: speedControlContainer.right
                    rightMargin: 10
                }
                function setMotorSpeedCommand(value) {
                    var truncated_value = Math.floor(value)
                    MotorControl.setTarget(truncated_value)
                    MotorControl.printsystemModeSelection()
                }
                onValueChanged: {
                    setMotorSpeedCommand(value)
                }

            }

            SGSlider {
                id: rampRateSlider
                label: "Ramp Rate:"
                width: 350
                value: 3
                minimumValue: 0
                maximumValue: 6
                endLabel: maximumValue
                startLabel: minimumValue
                anchors {
                    top: targetSpeedSlider.bottom
                    topMargin: 10
                    left: speedControlContainer.left
                    leftMargin: 10
                    right: speedControlContainer.right
                    rightMargin: 10
                }
                onValueChanged: {
                    MotorControl.setRampRate(rampRateSlider.value);
                    MotorControl.printSetRampRate();

                }
            }

            Item {
                id: speedSafety
                height: childrenRect.height
                anchors {
                    top: rampRateSlider.bottom
                    topMargin: 20
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
                topMargin: 20
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

                    SGRadioButton {
                        id: ps
                        text: "Pseudo-Sinusoidal"
                        checked: true
                        onCheckedChanged: {
                            if (checked) {
                                console.log ( "PS Checked!")
                                MotorControl.setDriveMode(parseInt("1"));
                                MotorControl.printDriveMode();
                                //   coreInterface.sendCommand(MotorControl.getDriveMode())
                            }
                        }
                    }

                    SGRadioButton {
                        id: trap
                        text: "Trapezoidal"
                        onCheckedChanged: { if (checked) {
                                console.log ( "Trap Checked!")
                                MotorControl.setDriveMode(parseInt("0"));
                                MotorControl.printDriveMode();
                                //   coreInterface.sendCommand(MotorControl.getDriveMode());
                            }
                        }
                    }
                }
            }

            Item {
                id: phaseAngleRow
                width: childrenRect.width
                height: childrenRect.height
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
                    model: ["0", "1.875", "3.75","5.625","7.5", "9.375", "11.25","13.125", "15", "16.875", "18.75", "20.625", "22.5" , "24.375" , "26.25" , "28.125"]
                    anchors {
                        top: phaseAngleRow.top
                        left: phaseAngleTitle.right
                        leftMargin: 20
                    }
                    onCurrentIndexChanged: {
                        console.log("index of the combo box", currentIndex)
                        MotorControl.setPhaseAngle(parseInt(currentIndex));
                        MotorControl.printPhaseAngle();
                    }
                }
            }
        }

        Rectangle {
            id: ledControlContainer
            width: 500
            height: childrenRect.height + 20
            color: "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: driveModeContainer.bottom
                topMargin: 20
            }

            SGHueSlider {
                id: hueSlider
                label: "Set LED color:"
                labelLeft: true
                anchors {
                    verticalCenter: whiteButton.verticalCenter
                    left: ledControlContainer.left
                    leftMargin: 10
                }

                onValueChanged: console.log("Color set to ", value)
            }

            Button {
                id: whiteButton
                checkable: false
                text: "White"
                anchors {
                    top: ledControlContainer.top
                    topMargin: 10
                    right: ledControlContainer.right
                    rightMargin: 10
                }
            }
        }

        Rectangle {
            id: directionControlContainer
            width: 500
            height: childrenRect.height + 20
            color: directionSafetyButton.checked ? "#ffb4aa" : "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: ledControlContainer.bottom
                topMargin: 20
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
