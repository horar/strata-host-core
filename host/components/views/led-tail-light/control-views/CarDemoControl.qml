import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Rectangle {
    id: root
    color: "black"
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    anchors.centerIn: parent
    height: parent.height
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width


    property int transformX:0;
    property int transformY:0;

    property var car_demo_brightness: platformInterface.car_demo_brightness.value
    onCar_demo_brightnessChanged: {
        baseCar.brightness = car_demo_brightness
    }

    RowLayout {
        anchors.fill: parent
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: parent.height
            Layout.preferredWidth: parent.width/1.2

            Image {
                id: base
                source: "car-Images/base.jpg"
                anchors.fill: parent
            }

            BrightnessContrast {
                id: baseCar
                anchors.fill: base
                source: base
                // brightness: slider.value
                contrast: 0


            }

            Image {
                id: headlights
                source: "car-Images/headlights.png"
                anchors.fill: parent
                visible: car_demo_brightness.value < -.6
            }

            //            Image {
            //                id: runninglights
            //                source: "running.png"
            //                anchors.fill: parent
            //                visible: running.checked
            //            }

            Image {
                id: brakeLights
                source: "car-Images/brakes.png"
                anchors.fill: parent
                visible: false
            }

            Image {
                id: reverseLights
                source: "car-Images/reverse.png"
                anchors.fill: parent
                visible: reverse.checked
            }

            Image {
                id: hazardLights
                source: "car-Images/markers.png"
                anchors.fill: parent
                visible: false

                Timer {
                    id: hazardLightsTimer
                    interval: 200
                    repeat: true
                    //running: hazards.checked

                    onTriggered: {
                        hazardLights.visible = !hazardLights.visible
                    }
                    onRunningChanged: {
                        hazardLights.visible = false
                    }
                }
            }

            Image {
                id: leftSignal
                source: "car-Images/left.png"
                anchors.fill: parent
                visible: false

                Timer {
                    id: leftTimer
                    interval: 200
                    repeat: true
                    // running: left.checked

                    onTriggered: {
                        leftSignal.visible = !leftSignal.visible
                    }
                    onRunningChanged: {
                        leftSignal.visible = false
                    }
                }
            }

            Image {
                id: rightSignal
                source: "car-Images/right.png"
                anchors.fill: parent
                visible: false

                Timer {
                    id: rightTimer
                    interval: 200
                    repeat: true
                    //running: right.checked

                    onTriggered: {
                        rightSignal.visible = !rightSignal.visible
                    }
                    onRunningChanged: {
                        rightSignal.visible = false
                    }
                }
            }

        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                height: parent.height/1.5
                anchors.centerIn: parent
                spacing: 20



                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true


                    Image {
                        source: "control-Images/Brake.png"
                        anchors.fill: parent

                        MouseArea {
                            id: brakes
                            anchors.fill: parent
                            onClicked: {
                                if(!brakeLights.visible) {
                                    brakeLights.visible = true
                                    platformInterface.brake_value = true
                                    platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                          platformInterface.right_value,
                                                                          platformInterface.brake_value,
                                                                          platformInterface.hazard_value,
                                                                          platformInterface.reverse_value

                                                                          )
                                }
                                else {

                                    brakeLights.visible = false
                                    platformInterface.brake_value = false
                                    platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                          platformInterface.right_value,
                                                                          platformInterface.brake_value,
                                                                          platformInterface.hazard_value,
                                                                          platformInterface.reverse_value

                                                                          )
                                }
                            }

                        }
                        property var car_demo_brake: platformInterface.car_demo.brake
                        onCar_demo_brakeChanged: {
                            if(car_demo_brake === false)
                                brakeLights.visible = false
                            else brakeLights.visible = true

                            platformInterface.brake_value = car_demo_brake
                        }

                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Image {
                        width: 50
                        height: 50
                        source: "control-Images/flasher.png"
                        anchors.fill: parent
                        MouseArea {
                            id: hazards
                            anchors.fill: parent
                            onClicked: {
                                if(!hazardLightsTimer.running) {
                                    hazardLightsTimer.start()
                                    platformInterface.hazard_value = true
                                    platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                          platformInterface.right_value,
                                                                          platformInterface.brake_value,
                                                                          platformInterface.hazard_value,
                                                                          platformInterface.reverse_value

                                                                          )
                                }
                                else {

                                    hazardLightsTimer.stop()
                                    platformInterface.hazard_value = false
                                    platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                          platformInterface.right_value,
                                                                          platformInterface.brake_value,
                                                                          platformInterface.hazard_value,
                                                                          platformInterface.reverse_value

                                                                          )

                                }
                            }

                        }

                    }
                }

                Button {
                    id: reverse
                    text: "Reverse"
                    checkable: true
                    checked: false
                    Layout.alignment: Qt.AlignHCenter
                    onCheckedChanged: {
                        if(checked) {
                            platformInterface.reverse_value = true
                            platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                  platformInterface.right_value,
                                                                  platformInterface.brake_value,
                                                                  platformInterface.hazard_value,
                                                                  platformInterface.reverse_value

                                                                  )
                        }
                        else {
                            platformInterface.reverse_value = false
                            platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                  platformInterface.right_value,
                                                                  platformInterface.brake_value,
                                                                  platformInterface.hazard_value,
                                                                  platformInterface.reverse_value

                                                                  )
                        }
                    }
                    property var car_demo_reverse: platformInterface.car_demo.reverse
                    onCar_demo_reverseChanged: {
                        if(car_demo_reverse === false)
                            reverse.checked = false
                        else reverse.checked = true

                        platformInterface.reverse_value = car_demo_reverse
                    }

                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Image {
                        id: blinker
                        source: "control-Images/Blinker.png"
                        anchors.fill: parent

                        MouseArea {
                            id: left
                            width: parent.width/2
                            height: parent.height
                            onClicked: {
                                if(!leftTimer.running) {
                                    leftTimer.start()
                                    platformInterface.left_value = true
                                    platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                          platformInterface.right_value,
                                                                          platformInterface.brake_value,
                                                                          platformInterface.hazard_value,
                                                                          platformInterface.reverse_value
                                                                          )
                                }
                                else {

                                    leftTimer.stop()
                                    platformInterface.left_value = false
                                    platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                          platformInterface.right_value,
                                                                          platformInterface.brake_value,
                                                                          platformInterface.hazard_value,
                                                                          platformInterface.reverse_value
                                                                          )
                                }
                            }

                            property var car_demo_left: platformInterface.car_demo.left
                            onCar_demo_leftChanged: {
                                if(car_demo_left === false)
                                    leftTimer.stop()
                                else  leftTimer.start()

                                platformInterface.left_value = car_demo_left
                            }

                        }

                        MouseArea {
                            id: right
                            anchors.left: left.right
                            width: parent.width/2
                            height: parent.height
                            onClicked: {
                                if(!rightTimer.running) {
                                    rightTimer.start()
                                    platformInterface.right_value = true
                                    platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                          platformInterface.right_value,
                                                                          platformInterface.brake_value,
                                                                          platformInterface.hazard_value,
                                                                          platformInterface.reverse_value
                                                                          )
                                }
                                else {
                                    rightTimer.stop()
                                    platformInterface.right_value = true
                                    platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                          platformInterface.right_value,
                                                                          platformInterface.brake_value,
                                                                          platformInterface.hazard_value,
                                                                          platformInterface.reverse_value
                                                                          )
                                }
                            }
                        }

                        property var car_demo_right: platformInterface.car_demo.right
                        onCar_demo_rightChanged: {
                            if(car_demo_right === false)
                                rightTimer.stop()
                            else  rightTimer.start()

                            platformInterface.right_value = car_demo_right
                        }
                    }
                }



                //                Rectangle {
                //                    Layout.fillHeight: true
                //                    Layout.fillWidth: true
                //                    Slider {
                //                        id: slider
                //                        anchors.centerIn: parent
                //                        orientation: Qt.Vertical
                //                        from: -.85
                //                        to: 0
                //                    }
                //                }
            }
        }
    }

}








