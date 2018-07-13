import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/motor-vortex/sgwidgets"

Rectangle {
    id: controlPage
    objectName: "control"
    anchors { fill: parent }
    // used to check whether the motor slider has been already updated from platform notification
    property bool isMotorSliderUpdated: false;
    color: "white"

    Component.onCompleted: {
        platformInterface.set_drive_mode.update("manual")
    }


    // Control Section
    Rectangle {
        id: controlSection1
        width: parent.width-100
        height: parent.height / 2
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            id: leftControl
            anchors {
                left: parent.left
                top: parent.top
            }
            width: parent.width / 2
            height: parent.height

            SGCircularGauge {
                id: tachMeterGauge
                anchors {
                    fill: parent
                }
                gaugeFrontColor1: Qt.rgba(0,1,.25,1)
                gaugeFrontColor2: Qt.rgba(1,0,0,1)
                minimumValue: motorSpeedControl.minimumValue
                maximumValue: motorSpeedControl.maximumValue
                tickmarkStepSize: 500
                outerColor: "#999"
                unitLabel: "RPM"

                value:  platformInterface.pi_stats.current_speed

                Behavior on value { NumberAnimation { duration: 300 } }
            }
        }

        Rectangle {
            id: rightControl
            anchors {
                left: leftControl.right
                verticalCenter: leftControl.verticalCenter
            }
            width: parent.width / 2
            height: motorSpeedControl.height + operationModeControl.height + 40

            SGSlider {
                id: motorSpeedControl
                width: parent.width * 0.75
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                label: "<b>Motor Speed:</b>"
                labelLeft: false
                value: 1500
                minimumValue: 1500
                maximumValue: 5500
                startLabel: minimumValue
                endLabel: maximumValue
                showDial:  false

                onValueChanged: {
                    platformInterface.motor_speed.update(value);
                    setSpeed.input = value
                }
            }

            SGSubmitInfoBox {
                id: setSpeed
                infoBoxColor: "white"
                buttonVisible: false
                anchors {
                    top: rightControl.top
                    topMargin: 10
                    right: rightControl.right
                    rightMargin: 10
                }
                onApplied: { motorSpeedControl.value = parseInt(value, 10) }
            }


            SGRadioButtonContainer {
                id: operationModeControl
                anchors {
                    top: motorSpeedControl.bottom
                    topMargin: 40
                    left: motorSpeedControl.left
                }

                label: "<b>Operation Mode:</b>"
                labelLeft: false
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
                        onCheckedChanged: {
                            if (checked) {
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
    } // end Control Section Rectangle
}
