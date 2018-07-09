import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/motor-vortex/sgwidgets"
import "qrc:/views/motor-vortex/Control.js" as MotorControl

Rectangle {
    id: advancedControl
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
        MotorControl.setPhaseAngle(parseInt("28.125"));
        MotorControl.printPhaseAngle();
    }
    
    Rectangle {
        id: leftSide
        width: 600
        height: childrenRect.height
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        
        SGLabelledInfoBox {
            id: vInBox
            label: "Vin:"
            info: "12.3v"
            infoBoxWidth: 80
            anchors {
                top: leftSide.top
                horizontalCenter: vInGraph.horizontalCenter
            }
        }
        
        SGLabelledInfoBox {
            id: speedBox
            label: "Current Speed:"
            info: "4050 rpm"
            infoBoxWidth: 80
            anchors {
                top: leftSide.top
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
            inputData: speedBox.info
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
            id: buttonContainer
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

                    }
                    else {
                        MotorControl.setMotorOnOff(parseInt("1"));
                        MotorControl.printSetMotorState();

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
                    MotorControl.setReset();
                }
            }
        }

        Rectangle {
            id: operationModeControlContainer
            width: 500
            height: childrenRect.height + 20
            color: "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: buttonContainer.bottom
                topMargin: 20
            }

            SGRadioButtonContainer {
                id: operationModeControl
                anchors {
                    top: operationModeControlContainer.top
                    topMargin: 10
                    horizontalCenter: operationModeControlContainer.horizontalCenter
                }

                label: "Operation Mode:"
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
            color: "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: operationModeControlContainer.bottom
                topMargin: 20
            }

            SGSlider {
                id: targetSpeedSlider
                label: "Target Speed:"
                width: 350
                minimumValue: 1500
                maximumValue: 5500
                endLabel: maximumValue
                startLabel: minimumValue
                anchors {
                  //  verticalCenter: setSpeed.verticalCenter
                    top: speedControlContainer.top
                    topMargin: 10
                    left: speedControlContainer.left
                    leftMargin: 10
                   // right: setSpeed.left
                    right: speedControlContainer.right
                    rightMargin: 10
                }
                showDial: false

                function setMotorSpeedCommand(value) {
                    var truncated_value = Math.floor(value)
                    MotorControl.setTarget(truncated_value)
                    MotorControl.printsystemModeSelection()
                }
                onValueChanged: {
                    setMotorSpeedCommand(value)
                    setSpeed.input = value
                }

                MouseArea {
                    id: targetSpeedSliderHover
                    anchors { fill: targetSpeedSlider.children[0] }
                    hoverEnabled: true
                }

                SGToolTipPopup {
                    id: sgToolTipPopup

                    showOn: targetSpeedSliderHover.containsMouse
                    anchors {
                        bottom: targetSpeedSliderHover.top
                        horizontalCenter: targetSpeedSliderHover.horizontalCenter
                    }
                    color: "#0bd"   // Default: "#00ccee"

                    content: Text {
                        text: qsTr("To change values or remove safety\nlimits, contact your FAE.")
                        color: "white"
                    }
                }
            }


            SGSlider {
                id: rampRateSlider
                label: "Ramp Rate:"
                width: 350
                value: 1
                minimumValue: 0
                maximumValue:6
                endLabel: maximumValue
                startLabel: minimumValue
                anchors {
                    top: targetSpeedSlider.bottom
                    topMargin: 10
                    left: speedControlContainer.left
                    leftMargin: 10
                    rightMargin: 10
                }
                showDial: false
                onValueChanged: {
                    MotorControl.setRampRate(rampRateSlider.value);
                    MotorControl.printSetRampRate();

                }
            }
        }

        Rectangle {
            id: driveModeContainer
            width: 500
            height: childrenRect.height + 20 // 20 for margins
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
                                MotorControl.setDriveMode(parseInt("1"));
                                MotorControl.printDriveMode();
                            }
                        }
                    }

                    SGRadioButton {
                        id: trap
                        text: "Trapezoidal"
                        onCheckedChanged: {
                            if (checked) {
                                MotorControl.setDriveMode(parseInt("0"));
                                MotorControl.printDriveMode();

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
                    currentIndex: 15
                    model: ["0", "1.875", "3.75","5.625","7.5", "9.375", "11.25","13.125", "15", "16.875", "18.75", "20.625", "22.5" , "24.375" , "26.25" , "28.125"]
                    anchors {
                        top: phaseAngleRow.top
                        left: phaseAngleTitle.right
                        leftMargin: 20
                    }

                    onCurrentIndexChanged: {
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
                    right: whiteButton.left
                    rightMargin: 10
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

            SGSlider {
                id: ledPulseFrequency
                label: "LED Pulse Frequency:"
                value: 50
                minimumValue: 2
                maximumValue: 152
                startLabel: "2"
                endLabel: "152"
                anchors {
                    verticalCenter: setLedPulse.verticalCenter
                    left: ledControlContainer.left
                    leftMargin: 10
                    right: setLedPulse.left
                    rightMargin: 10
                }
                showDial: false

                onValueChanged: { setLedPulse.input = value }
            }

            SGSubmitInfoBox {
                id: setLedPulse
                infoBoxColor: "white"
                anchors {
                    top: whiteButton.bottom
                    topMargin: 10
                    right: ledControlContainer.right
                    rightMargin: 10
                }
                onApplied: { ledPulseFrequency.value = parseInt(value, 10) }
            }
        }

        Rectangle {
            id: directionControlContainer
            width: 500
            height: childrenRect.height + 20 - directionToolTip.height
            color: "#eeeeee"
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
                        enabled: false
                    }

                    SGRadioButton {
                        text: "Reverse"
                        enabled: false
                    }
                }
            }

            MouseArea {
                id: directionRadiosHover
                anchors { fill: directionRadios }
                hoverEnabled: true
            }

            SGToolTipPopup {
                id: directionToolTip

                showOn: directionRadiosHover.containsMouse
                anchors {
                    bottom: directionRadiosHover.top
                    horizontalCenter: directionRadiosHover.horizontalCenter
                }
                color: "#0bd"   // Default: "#00ccee"

                content: Text {
                    text: qsTr("Reversing direction will damage setup.\nTo remove safety limits, contact your FAE.")
                    color: "white"
                }
            }
        }
    }
}
