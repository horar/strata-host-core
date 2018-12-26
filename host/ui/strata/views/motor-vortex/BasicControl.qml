import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/motor-vortex/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

Rectangle {
    id: controlPage
    objectName: "control"
    width: 1200
    height: 725
    color: "white"

    property alias warningVisible: warningBox.visible

    Component.onCompleted: {
        Help.registerTarget(navTabs, "These tabs switch between Basic and Advanced control views. The FAE Only tab is restricted for ON Semiconductor field engineers.", 0, "basicViewHelp")
        Help.registerTarget(motorSpeedControl, "The slider sets motor speed from 1500-4000 rpm" , 1 , "basicViewHelp")
        Help.registerTarget(tachMeterGauge, "The gauage shows the speed of the motor", 3, "basicViewHelp")
        Help.registerTarget(operationModeControl, "These are two modes to control the system. In manual mode, speed of the motor will be set by the slider above. In Automatic Demo Pattern mode, the system will go through a particular speed profile.", 2 , "basicViewHelp")
    }

    // Control Section
    Rectangle {
        id: controlSection1
        width: leftControl.width + rightControl.width + rightControl.anchors.leftMargin
        height: controlPage.height / 2
        anchors {
            verticalCenter: controlPage.verticalCenter
            horizontalCenter: controlPage.horizontalCenter
        }

        Rectangle {
            id: leftControl
            anchors {
                left: controlSection1.left
                top: controlSection1.top
            }
            width: height
            height: controlSection1.height

            SGCircularGauge {
                id: tachMeterGauge
                anchors {
                    fill: leftControl
                }
                gaugeFrontColor1: Qt.rgba(0,1,.25,1)
                gaugeFrontColor2: Qt.rgba(1,0,0,1)
                minimumValue: 0
                maximumValue: 8000
                tickmarkStepSize: 1000
                outerColor: "#999"
                unitLabel: "RPM"
                value: platformInterface.pi_stats.current_speed
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
                from: 1500
                to: 4000
                label: "<b>Motor Speed:</b>"
                labelLeft: false
                value:
                {
                    if(platformInterface.motorSpeedSliderValue <= 1500 ){
                        return 1500
                    }
                    if( platformInterface.motorSpeedSliderValue >= 4000 ) {
                        return 4000
                    }
                    return platformInterface.motorSpeedSliderValue
                }

                onValueChanged: {
                    setSpeed.input = value.toFixed(0)
                    var current_slider_value = value.toFixed(0)
                    //  Don't change if FAE safety limit is enabled
                    if(current_slider_value >= 4000 && platformInterface.motorSpeedSliderValue >= 4000){
                        console.log("Do nothing")
                    }
                    else if(current_slider_value <= 1500 && platformInterface.motorSpeedSliderValue <= 1500){
                        console.log("Do nothing")
                    }
                    else{
                        platformInterface.motorSpeedSliderValue = current_slider_value
                    }
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
                onApplied: {
                    platformInterface.motorSpeedSliderValue = parseInt(value, 10)
                }
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

                    SGRadioButton {
                        id: manual
                        text: "Manual Control"
                        checked: platformInterface.systemMode
                        onCheckedChanged: {
                            if (checked) {
                                console.log("manu adv")
                                platformInterface.systemMode = true
                                platformInterface.motorSpeedSliderValue = 1500
                                motorSpeedControl.sliderEnable = true
                                motorSpeedControl.opacity = 1.0
                            }
                            else {
                                console.log("auto adv")
                                platformInterface.systemMode = false
                                motorSpeedControl.sliderEnable = false
                                motorSpeedControl.opacity = 0.5
                            }
                        }
                    }

                    SGRadioButton {
                        id: automatic
                        text: "Automatic Demo Pattern"
                        checked : !manual.checked
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
            visible: false

            Text {
                id: warningText
                anchors {
                    centerIn: warningBox
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
