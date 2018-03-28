import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl


Item {
    id: controlPage
    objectName: "control"
    anchors { fill: parent }
    property var isMotorSliderUpdated: false;

    // Platform Implementation signals
    Connections {
        target: coreInterface
        onNotification: {
            try {
                /*
                    Attempt to parse JSON
                    Note: Motor platform sometimes has noise in json and can corrupt values
                */
                var notification = JSON.parse(payload)
            }
            catch(e)
            {
                if ( e instanceof SyntaxError){
                    console.log("Notification JSON is invalid. ignoring")
                }
            }

            //get speed value from json; check i
            var speed = notification.payload.current_speed;
            if(speed !== undefined){
                tachMeterGauge.value = ((speed - 1500) / 4000) * 100
            }
            else
            {
                console.log("Junk data found on speed ", speed)
            }

            //system mode
            var systemMode = notification.payload.mode;
            if (systemMode !== undefined){
                if(systemMode ==="manual"){
                    manualButton.checked = true;
                    automaticButton.checked = false;
                }else if(systemMode ==="automation") {
                    manualButton.checked = false;
                    automaticButton.checked = true;
                }
            }
            else
            {
                console.log("Junk data found on mode")
            }

            if(!isMotorSliderUpdated){
                //set value only once
                motorSpeedControl.value = (speed/5500.0)
                isMotorSliderUpdated = !isMotorSliderUpdated
            }
        }
    }

    // Control Section
    Rectangle {
        id: controlSection
        width: parent.width; height: parent.height * 0.5
        color: "white"

        ColumnLayout {
            id: layoutId
            anchors { fill: parent }

            /*
              Created a rectangle as a container for the element inside which solves alignment in linux/mac
            */
            Rectangle {
                id: meterGaugeContainer
                width: parent.width;height: parent.height/1.5
                anchors { top: layoutId.top
                    topMargin: 10
                }

                CircularGauge {
                    id: tachMeterGauges
                    height: parent.height
                    anchors.centerIn: parent
                    minimumValue: 0; maximumValue: 100
                    stepSize: 1

                    Behavior on value { NumberAnimation { duration: 1500 } }

                    style: CircularGaugeStyle {
                        minimumValueAngle: -90; maximumValueAngle: 90
                        needle: Rectangle {
                            y: outerRadius * 0.15
                            implicitWidth: outerRadius * 0.03
                            implicitHeight: outerRadius * 0.9
                            antialiasing: true
                            color: Qt.rgba(0.66, 0.3, 0, 1)
                        }

                        foreground: Item {
                            Rectangle {
                                width: outerRadius * 0.2
                                height: width
                                radius: width / 2
                                color: "black"
                                anchors.centerIn: parent

                            }
                        }
                        tickmarkLabel:  Text {
                            font.pixelSize: Math.max(6, outerRadius * 0.1)
                            text: styleData.value
                            color: styleData.value >= 80 ? "#e34c22" : "black"
                            antialiasing: true
                        }
                    }

                } // end CircularGauge
            }

            /*
              Created a rectangle as a container for the element inside which solves alignment in linux/mac
            */
            Rectangle {
                id: speedSliderContainer
                anchors.top : meterGaugeContainer.bottom
                /*
                  Use a negative margin on slider to close the gap from meter gauge. The gap in the meter gauge occurs due to having a _semi-circle_ for the gauge
                  when it's allocated for the _full_ circle gauge.
                */
                anchors.topMargin: -50
                width: parent.width
                height: parent.height/6

                Slider {
                    id: motorSpeedControl
                    from: 0; to: 1
                    value: 0   // start value
                    snapMode: Slider.SnapAlways
                    stepSize : 0.05
                    live: false
                    anchors.centerIn: parent

                    function setMotorSpeedCommand(value) {
                        var setSpeedCmd ={
                            "cmd":"speed_input",
                            "payload": {
                                "speed_target":value * 4000 + 1500
                            }
                        }
                        // send set speed command to platform
                        coreInterface.sendCommand(JSON.stringify(setSpeedCmd))
                    }

                    onMoved: {
                        gauge1.value = position * 200  // TODO [ian] false temp values until hooked up
                        gauge2.value = position * 200
                        gauge3.value = position * 200
                        setMotorSpeedCommand(position)
                    }

                    ToolTip {
                        parent: motorSpeedControl.handle
                        visible: motorSpeedControl.pressed
                        text: motorSpeedControl.valueAt(motorSpeedControl.position).toFixed(1) * 5400
                    }
                }
            }

            /*
              Created a rectangle as a container for the element inside which solves alignment in linux/mac
            */
            Rectangle {
                id: buttonContainer
                anchors.top : speedSliderContainer.bottom
                width: parent.width
                height: parent.height/3.5

                ButtonGroup {
                    buttons: buttonColumn.children
                }

                GroupBox {
                    title: "<b><font color='red'>Operation Mode</b></font>"
                    anchors.centerIn: parent
                    Row {
                        id: buttonColumn
                        anchors {fill: parent}

                        RadioButton {
                            id:manualButton
                            checked: true
                            text: "Manual Control"

                            onPressed: {
                                console.log("MANUAL CONTROL")
                                var systemModeCmd ={
                                    "cmd":"set_system_mode",
                                    "payload": {
                                        "system_mode":"manual"
                                    }
                                }
                                // send Manual mode command to platform
                                coreInterface.sendCommand(JSON.stringify(systemModeCmd))
                            }
                        }

                        RadioButton {
                            id:automaticButton
                            text: "Automatic Test Pattern"
                            onPressed: {
                                console.log("AUTOMATIC")
                                var systemModeCmd ={
                                    "cmd":"set_system_mode",
                                    "payload": {
                                        "system_mode":"automation"
                                    }
                                }
                                // send Automation command to platform
                                coreInterface.sendCommand(JSON.stringify(systemModeCmd))
                            }
                        }
                    }
                }
            }
        } // end Column Layout
    } // end Control Section Rectangle

    // Environment Section
    Rectangle {
        id: environmentSection
        anchors {top: controlSection.bottom
            topMargin: 50
            bottom: controlPage.bottom
        }

        color: "white"
        width: controlPage.width
        // Phase U temperature
        RowLayout {
            spacing: 180
            ColumnLayout {
                Layout.alignment: Qt.AlignCenter

                width: environmentSection.width / 3;  height: environmentSection.height - 30
                Gauge {
                    id: gauge1
                    width: parent.width; height: parent.height * 0.9
                    anchors { fill: parent; margins: 10 }
                    minimumValue: -40
                    maximumValue: 200

                    value: 20

                    Behavior on value { NumberAnimation {duration: 6000 } }

                    style: GaugeStyle {
                        valueBar: Rectangle {
                            implicitWidth: 16
                            color: Qt.rgba(gauge1.value / gauge1.maximumValue, 0, 1 - gauge1.value / gauge1.maximumValue, 1)
                        }

                        tickmark: Item {
                            implicitWidth: 18
                            implicitHeight: 1

                            Rectangle {
                                color: "black"
                                anchors.fill: parent
                                anchors.leftMargin: 3
                                anchors.rightMargin: 3
                            }
                        }

                        minorTickmark: Item {
                            implicitWidth: 8
                            implicitHeight: 1

                            Rectangle {
                                color: "#cccccc"
                                anchors.fill: parent
                                anchors.leftMargin: 2
                                anchors.rightMargin: 4
                            }
                        }
                    }
                }
                Label {
                    id: gaugeLabel1
                    anchors {top: gauge1.bottom; left: parent.left; leftMargin: 5 }
                    width: parent.width; height: parent.height * 0.1
                    text: "Phase U"
                }
            }

            // Phase U temperature
            ColumnLayout {
                width: environmentSection.width / 3;  height: environmentSection.height - 30
                Gauge {
                    id: gauge2
                    width: parent.width; height: parent.height * 0.9
                    anchors.fill: parent
                    anchors.margins: 10
                    minimumValue: -40
                    maximumValue: 200
                    value: 20

                    Behavior on value { NumberAnimation {duration: 2000 } }

                    style: GaugeStyle {
                        valueBar: Rectangle {
                            implicitWidth: 16
                            color: Qt.rgba(gauge2.value / gauge2.maximumValue, 0, 1 - gauge2.value / gauge2.maximumValue, 1)
                        }

                        tickmark: Item {
                            implicitWidth: 18
                            implicitHeight: 1

                            Rectangle {
                                color: "black"
                                anchors.fill: parent
                                anchors.leftMargin: 3
                                anchors.rightMargin: 3
                            }
                        }

                        minorTickmark: Item {
                            implicitWidth: 8
                            implicitHeight: 1

                            Rectangle {
                                color: "#cccccc"
                                anchors.fill: parent
                                anchors.leftMargin: 2
                                anchors.rightMargin: 4
                            }
                        }
                    }
                }
                Label {
                    id: gaugeLabel2
                    anchors {top: gauge2.bottom; left: parent.left; leftMargin: 5 }
                    width: parent.width; height: parent.height * 0.1
                    text: "Phase V"
                }
            }

            // Phase W temperature
            ColumnLayout {
                width: environmentSection.width / 3;  height: environmentSection.height - 30
                Gauge {
                    id: gauge3
                    width: parent.width; height: parent.height * 0.9
                    anchors { fill: parent; margins: 10 }
                    minimumValue: -40
                    maximumValue: 200
                    value: 20

                    Behavior on value { NumberAnimation {duration: 4000 } }

                    style: GaugeStyle {
                        valueBar: Rectangle {
                            implicitWidth: 16
                            color: Qt.rgba(gauge3.value / gauge3.maximumValue, 0, 1 - gauge3.value / gauge3.maximumValue, 1)
                        }

                        tickmark: Item {
                            implicitWidth: 18
                            implicitHeight: 1

                            Rectangle {
                                color: "black"
                                anchors.fill: parent
                                anchors.leftMargin: 3
                                anchors.rightMargin: 3
                            }
                        }

                        minorTickmark: Item {
                            implicitWidth: 8
                            implicitHeight: 1

                            Rectangle {
                                color: "#cccccc"
                                anchors.fill: parent
                                anchors.leftMargin: 2
                                anchors.rightMargin: 4
                            }
                        }
                    }
                }
                Label {
                    id: gaugeLabel3
                    anchors {top: gauge3.bottom; left: parent.left; leftMargin: 5 }
                    width: parent.width; height: parent.height * 0.1
                    text: "Phase W"
                }
            }
        }
    }
    Image {
        id: flipButton
        source:"./images/icons/infoIcon.svg"
        anchors { bottom: parent.bottom; right: parent.right }
        height: 40;width:40
    }
    MouseArea {
        width: flipButton.width; height: flipButton.height
        anchors { bottom: controlPage.bottom; right: controlPage.right }
        visible: true
        onClicked: {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
}

