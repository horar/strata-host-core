import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Rectangle{
    anchors.fill: parent
    color: "lightgray"
    Rectangle {
        id: root
        color: "lightgray"
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

        property var car_demo_brightness_headlights: platformInterface.car_demo_brightness.headlights
        onCar_demo_brightness_headlightsChanged: {
            if(car_demo_brightness_headlights === true){
                headlights.visible = true
                runningLight.visible = true
            }
            else {
                headlights.visible = false
                runningLight.visible = false
            }
        }



        RowLayout {
            anchors.fill: parent
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: parent.height
                Layout.preferredWidth: parent.width/1.2
                color: "lightgray"

                Image {
                    id: base
                    source: "car-Images/base.jpg"
                    fillMode: Image.PreserveAspectFit
                    anchors.fill: parent
                }

                BrightnessContrast {
                    id: baseCar
                    anchors.fill: base
                    source: base
                    contrast: 0
                }

                Image {
                    id: headlights
                    source: "car-Images/headlights.png"
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    visible: false
                }

                Image {
                    id: brakeLights
                    source: "car-Images/brakes.png"
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    visible: false

                }

                Image {
                    id: reverseLights
                    source: "car-Images/reverse.png"
                    anchors.fill: parent
                    visible: false
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    id: hazardLights
                    source: "car-Images/markers.png"
                    anchors.fill: parent
                    visible: false
                    fillMode: Image.PreserveAspectFit


                }

                Image {
                    id: leftSignal
                    source: "car-Images/left.png"
                    anchors.fill: parent
                    visible: false
                    fillMode: Image.PreserveAspectFit

                }

                Image {
                    id: rightSignal
                    source: "car-Images/right.png"
                    anchors.fill: parent
                    visible: false
                    fillMode: Image.PreserveAspectFit


                }

                Image {
                    id: runningLight
                    source: "car-Images/running.png"
                    anchors.fill: parent
                    visible: false
                    fillMode: Image.PreserveAspectFit
                }

            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "lightgray"

                ColumnLayout {
                    width: parent.width
                    height: parent.height/1.5
                    anchors.centerIn: parent
                    spacing: 20



                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "lightgray"
                        Image {
                            id: brake
                            source:  "car-icon/brake.svg"
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            visible: false

                            MouseArea {
                                id: withbrakes
                                anchors.fill: parent
                                onClicked: {
                                    console.log("withBrakes")
                                    if(platformInterface.brake_value === false) {
                                        noBrake.visible = false
                                        brake.visible = true
                                        brakeLights.visible = true
                                        platformInterface.brake_value = true
                                        platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                              platformInterface.right_value,
                                                                              platformInterface.brake_value,
                                                                              platformInterface.reverse_value

                                                                              )

                                    }
                                    else {
                                        noBrake.visible = true
                                        brake.visible = false
                                        brakeLights.visible = false
                                        platformInterface.brake_value = false
                                        platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                              platformInterface.right_value,
                                                                              platformInterface.brake_value,
                                                                              platformInterface.reverse_value

                                                                              )
                                    }
                                }

                            }

                        }


                        Image {
                            id: noBrake
                            source: "car-icon/no-brake.svg"
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            visible: false

                            MouseArea {
                                id: nobrakes
                                anchors.fill: parent
                                onClicked: {
                                    if(platformInterface.brake_value === false) {
                                        noBrake.visible = false
                                        brake.visible = true
                                        brakeLights.visible = true
                                        platformInterface.brake_value = true
                                        platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                              platformInterface.right_value,
                                                                              platformInterface.brake_value,
                                                                              platformInterface.reverse_value

                                                                              )

                                    }
                                    else {
                                        noBrake.visible = true
                                        brake.visible = false
                                        brakeLights.visible = false
                                        platformInterface.brake_value = false
                                        platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                              platformInterface.right_value,
                                                                              platformInterface.brake_value,
                                                                              platformInterface.reverse_value

                                                                              )
                                    }
                                }

                            }
                            property var car_demo_brake: platformInterface.car_demo.brake
                            onCar_demo_brakeChanged: {
                                console.log("car_demo_brake", car_demo_brake)
                                if(car_demo_brake === false) {
                                    brakeLights.visible = false
                                    noBrake.visible = true
                                    brake.visible = false
                                }
                                else {
                                    brakeLights.visible = true
                                    noBrake.visible = false
                                    brake.visible = true
                                }
                                platformInterface.brake_value = car_demo_brake
                            }

                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "lightgray"

                        Image {
                            id: hazard
                            width: 50
                            height: 50
                            source: "car-icon/hazard.svg"
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            visible: true
                            MouseArea {
                                id: hazards
                                anchors.fill: parent
                                onClicked: {
                                    if(platformInterface.hazard_value === false) {
                                        leftSignal.visible = true
                                        rightSignal.visible = true

                                        hazard.visible = true
                                        noHazard.visible = false
                                        platformInterface.hazard_value = true
                                        blinkerContainer.enabled = false
                                        //hazard on send true for right and left
                                        platformInterface.set_car_demo.update(true,
                                                                              true,
                                                                              platformInterface.brake_value,
                                                                              platformInterface.reverse_value
                                                                              )
                                    }
                                    else {
                                        hazard.visible = false
                                        noHazard.visible = true
                                        leftSignal.visible = false
                                        rightSignal.visible = false
                                        platformInterface.hazard_value = false
                                        blinkerContainer.enabled = true

                                        platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                              platformInterface.right_value,
                                                                              platformInterface.brake_value,
                                                                              platformInterface.reverse_value
                                                                              )

                                    }
                                }

                            }

                        }

                        Image {
                            id: noHazard
                            width: 50
                            height: 50
                            source: "car-icon/no-hazard.svg"
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            visible: false
                            MouseArea {
                                id: noHazards
                                anchors.fill: parent
                                onClicked: {
                                    if(platformInterface.hazard_value === false) {
                                        leftSignal.visible = true
                                        rightSignal.visible = true
                                        hazard.visible = true
                                        noHazard.visible = false
                                        blinkerContainer.enabled = false
                                        platformInterface.hazard_value = true
                                        //hazard on send true for right and left
                                        platformInterface.set_car_demo.update(true,
                                                                              true,
                                                                              platformInterface.brake_value,
                                                                              platformInterface.reverse_value
                                                                              )
                                    }
                                    else {
                                        console.log("hazard")
                                        leftSignal.visible = false
                                        rightSignal.visible = false
                                        hazard.visible = false
                                        noHazard.visible = true
                                        blinkerContainer.enabled = true
                                        platformInterface.hazard_value = false
                                        platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                              platformInterface.right_value,
                                                                              platformInterface.brake_value,
                                                                              platformInterface.reverse_value
                                                                              )

                                    }
                                }

                            }

                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "lightgray"

                        Image {
                            id: reverseIcon
                            source: "car-icon/reverse.svg"
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            MouseArea {
                                id: reverseClick
                                anchors.fill: parent
                                onClicked: {
                                    if(!reverseLights.visible){
                                        reverseIcon.visible = false
                                        noReverseIcon.visible = true
                                        platformInterface.reverse_value = true
                                        platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                              platformInterface.right_value,
                                                                              platformInterface.brake_value,
                                                                              platformInterface.reverse_value

                                                                              )
                                    }
                                    else {
                                        reverseIcon.visible = true
                                        noReverseIcon.visible = false
                                        platformInterface.reverse_value = false
                                        platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                              platformInterface.right_value,
                                                                              platformInterface.brake_value,
                                                                              platformInterface.reverse_value

                                                                              )
                                    }
                                }

                            }

                        }

                        Image {
                            id: noReverseIcon
                            source: "car-icon/drive.svg"
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            MouseArea {
                                id: noReverseClick
                                anchors.fill: parent
                                onClicked: {
                                    if(!reverseLights.visible){
                                        reverseIcon.visible = false
                                        noReverseIcon.visible = true
                                        platformInterface.reverse_value = true
                                        platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                              platformInterface.right_value,
                                                                              platformInterface.brake_value,
                                                                              platformInterface.reverse_value

                                                                              )
                                    }
                                    else {
                                        reverseIcon.visible = true
                                        noReverseIcon.visible = false
                                        platformInterface.reverse_value = false
                                        platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                              platformInterface.right_value,
                                                                              platformInterface.brake_value,
                                                                              platformInterface.reverse_value

                                                                              )
                                    }
                                }

                            }

                        }

                        property var car_demo_reverse: platformInterface.car_demo.reverse
                        onCar_demo_reverseChanged: {
                            reverseLights.visible = car_demo_reverse
                            if(car_demo_reverse === true){
                                reverseIcon.visible = true
                                noReverseIcon.visible = false
                            }
                            else {
                                reverseIcon.visible = false
                                noReverseIcon.visible = true
                            }

                            platformInterface.reverse_value = car_demo_reverse
                            //console.log(platformInterface.reverse_value)
                        }

                    }

                    Rectangle{
                        id: blinkerContainer
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "light gray"


                        Image{
                            id: blinkerBaseImage
                            source: "car-icon/no-signal.svg"
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit

                            Rectangle{
                                width: parent.width/2
                                height: parent.height
                                anchors.left: parent.left
                                color: "transparent"

                                MouseArea{
                                    id: leftSignalContainer
                                    anchors.fill: parent
                                    onClicked: {
                                        platformInterface.right_value = false
                                        rightSignal.visible = false
                                        console.log("left clicked", platformInterface.left_value)
                                        if(platformInterface.left_value === false){
                                            leftSignal.visible = true
                                            blinkerBaseImage.source = "car-icon/left-signal.svg"
                                            platformInterface.left_value = true
                                            platformInterface.set_car_demo.update(true,
                                                                                  platformInterface.right_value,
                                                                                  platformInterface.brake_value,
                                                                                  platformInterface.reverse_value
                                                                                  )
                                        }
                                        else {
                                            leftSignal.visible = false
                                            blinkerBaseImage.source = "car-icon/no-signal.svg"
                                            platformInterface.left_value = false
                                            platformInterface.set_car_demo.update(false,
                                                                                  platformInterface.right_value,
                                                                                  platformInterface.brake_value,
                                                                                  platformInterface.reverse_value
                                                                                  )
                                        }

                                        console.log("platformInterface.left_value", platformInterface.left_value)
                                    }
                                }
                            }

                            Rectangle{
                                width: parent.width/2
                                height: parent.height
                                anchors.right: parent.right
                                color: "transparent"
                                MouseArea{
                                    id: rightSignalContainer
                                    anchors.fill: parent

                                    onClicked: {
                                        leftSignal.visible = false
                                        platformInterface.left_value = false
                                        console.log("right clicked", platformInterface.right_value)
                                        if(platformInterface.right_value === false) {
                                            rightSignal.visible = true
                                            blinkerBaseImage.source = "car-icon/right-signal.svg"
                                            platformInterface.right_value = true
                                            platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                                  platformInterface.right_value,
                                                                                  platformInterface.brake_value,
                                                                                  platformInterface.reverse_value
                                                                                  )
                                        }
                                        else {
                                            rightSignal.visible = false
                                            blinkerBaseImage.source = "car-icon/no-signal.svg"
                                            platformInterface.right_value = false
                                            platformInterface.set_car_demo.update(platformInterface.left_value,
                                                                                  platformInterface.right_value,
                                                                                  platformInterface.brake_value,
                                                                                  platformInterface.reverse_value
                                                                                  )
                                        }

                                    }
                                }
                            }

                        }
                        property var car_demo_left: platformInterface.car_demo.left
                        onCar_demo_leftChanged: {
                            leftSignal.visible = car_demo_left
                            console.log("left on", car_demo_left)
                        }

                        property var car_demo_right: platformInterface.car_demo.right
                        onCar_demo_rightChanged: {
                            console.log("right on", car_demo_right)
                            rightSignal.visible = car_demo_right

                        }

//                        property var car_demo: platformInterface.car_demo
//                        onCar_demoChanged: {
//                            if(car_demo.left === false && car_demo.right === false) {
//                                noHazard.visible = true
//                                hazard.visible = false
//                                leftSignal.visible = false
//                                rightSignal.visible = false
//                            }

//                        }
                    }

                }
            }
        }
    }
}








