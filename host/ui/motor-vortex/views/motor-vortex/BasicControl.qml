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
    width: 1200
    height: 725
    color: "white"

    property alias motorSpeedSliderValue: motorSpeedControl.value

    Component.onCompleted: {
        platformInterface.system_mode_selection.update("manual")
    }

    // Control Section
    Rectangle {
        id: controlSection1
        width: leftControl.width + rightControl.width + rightControl.anchors.leftMargin
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
            width: height
            height: parent.height

            SGCircularGauge {
                id: tachMeterGauge
                anchors {
                    fill: parent
                }
                gaugeFrontColor1: Qt.rgba(0,1,.25,1)
                gaugeFrontColor2: Qt.rgba(1,0,0,1)
                minimumValue: 0
                maximumValue: 8000
                tickmarkStepSize: 1000
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
                leftMargin: 50
                verticalCenter: leftControl.verticalCenter
            }
            width: 400
            height: motorSpeedControl.height + operationModeControl.height + 40

            SGSlider {
                id: motorSpeedControl
                anchors {
                    left: rightControl.left
                    right: setSpeed.left
                    rightMargin: 10
                    top: rightControl.top
                }
                label: "<b>Motor Speed:</b>"
                labelLeft: false
                value: 1500
                from: 1500
                to: 5500

                onValueChanged: {
                    platformInterface.motor_speed.update(value.toFixed(0));
                    setSpeed.input = value.toFixed(0)
                }
            }

            SGSubmitInfoBox {
                id: setSpeed
                infoBoxColor: "white"
                buttonVisible: false
                anchors {
                    verticalCenter: motorSpeedControl.verticalCenter
                    right: rightControl.right
                    rightMargin: 10
                }
                onApplied: { motorSpeedControl.value = parseInt(value, 10) }
                input: motorSpeedControl.value
                infoBoxWidth: 80
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
                        if(systemMode === "automation") {
                            automatic.checked = true;
                        }
                        else {
                            manual.checked = true;
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

        Rectangle {
            id: warningBox
            color: "red"
            anchors {
                bottom: rightControl.top
                horizontalCenter: rightControl.horizontalCenter
                bottomMargin: 30
            }
            width: warningText.contentWidth + 100
            height: warningText.contentHeight + 40
            visible: platformInterface.system_error.error_and_warnings === [ ]

            Text {
                id: warningText
                anchors {
                    centerIn: parent
                }
                text: "See Advanced Controls for Current Fault Status"
                font.pixelSize: 12
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
                font.pixelSize: 40
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
                font.pixelSize: 40
                color: "white"
            }

            FontLoader {
                id: icons
                source: "sgwidgets/fonts/sgicons.ttf"
            }
        }
    } // end Control Section Rectangle
}
