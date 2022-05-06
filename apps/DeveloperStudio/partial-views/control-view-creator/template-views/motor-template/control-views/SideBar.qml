/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import "qrc:/js/help_layout_manager.js" as Help
import "../widgets"

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Rectangle {

    // ======================== General Settings ======================== //

    id: sideBar
    color: "#454545"
    implicitWidth: 70
    Layout.fillHeight: true

    // ======================== UI Initialization ======================== //

    Component.onCompleted: {

        // ------------------------ Help Messages ------------------------ //

        Help.registerTarget(speedButton, "Click here for a popout slider to set the motor's target speed. The maximum and minimum scales will be updated based on the Max RPM or Min RPM set on the Controls and Parameters tab in the Motor and Load Parameters section.\n\nThis slider and all subsequent sliders can be finely adjusted using the keyboard's left/right arrow keys when in focus.", 1, "BasicControlHelp")
        Help.registerTarget(accelButton, "Click here for a popout slider to set the motor's startup acceleration. The value is automatically updated based on the Acceleration Rate set on the Controls and Parameters tab in the Speed Loop Parameters section. The slider and input box will be disabled unless the Speed Loop Mode is set to Open Loop.", 2, "BasicControlHelp")
        Help.registerTarget(runButton, "Click the run icon to start spinning the motor. The run icon will change to a stop icon once clicked. Click the stop icon to stop the motor. The motor control values on the Controls and Parameters tab may need to be adjusted depending on the connected motor's specifications. The direction control icon will be disabled while the motor is spinning.", 3, "BasicControlHelp")
        Help.registerTarget(brakeButton, "Click the brake icon to brake the motor. This feature may be disabled for certain motor controllers.", 4, "BasicControlHelp")
        Help.registerTarget(directionButton, "Click this icon to change the direction of the motor. The direction control icon will be disabled while the motor is spinning. The direction is from the perspective of the load. An incorrect hall polarity configuration could render the rotation direction invalid.", 5, "BasicControlHelp")
        Help.registerTarget(warnings, "Warnings and errors are shown here for events such as Over Current Protection (OCP).", 6, "BasicControlHelp")

    }

    // ======================== UI Objects ======================== //

    ColumnLayout {
        id: sideBarColumn
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 10

        SGText {
            text: "Quick Start Controls"
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            fontSizeMultiplier: .8
            color: "white"
        }

        // ------------------------ Target Speed ------------------------ //

        IconButton {
            id: speedButton
            toolTipText: "Set " + platformInterface.notifications.target_speed.caption.toLowerCase()
            value: platformInterface.notifications.target_speed.value
            unit: platformInterface.notifications.target_speed.unit
            source: "qrc:/images/tach.svg"
            iconOpacity: speedPop.visible ? .5 : 1

            onClicked:  {
                speedPop.visible = !speedPop.visible
            }

            SliderPopup {
                id: speedPop
                x: parent.width + sideBarColumn.anchors.margins

                value: platformInterface.notifications.target_speed.value
                title: platformInterface.notifications.target_speed.caption + " (" + platformInterface.notifications.target_speed.unit + ")"
                // unit: platformInterface.notifications.target_speed.unit
                to: platformInterface.notifications.target_speed.scales.index_0
                from: platformInterface.notifications.target_speed.scales.index_1
                stepSize: platformInterface.notifications.target_speed.scales.index_2
                // states.index_0 for non-arrays, SGSlider automatically sets opacity
                // i.e., state = Disabled (not grayed) set to state = Disabled and Grayed Out
                enabled: !Boolean(platformInterface.notifications.target_speed.states.index_0)

                onUserSet: {
                    console.log("onUserSet:", speedPop.value)
                    platformInterface.notifications.target_speed.value = speedPop.value
                    platformInterface.commands.target_speed.update(speedPop.value)
                }

            }
        }

        // ------------------------ Acceleration ------------------------ //

        IconButton {
            id: accelButton
            toolTipText: "Set " + platformInterface.notifications.acceleration.caption.toLowerCase()
            value: platformInterface.notifications.acceleration.value
            unit: platformInterface.notifications.acceleration.unit
            source: "qrc:/images/tach.svg"
            iconOpacity: accelPop.visible ? .5 : 1

            onClicked:  {
                accelPop.visible = !accelPop.visible
            }

            SliderPopup {
                id: accelPop
                x: parent.width + sideBarColumn.anchors.margins

                value: platformInterface.notifications.acceleration.value
                title: platformInterface.notifications.acceleration.caption + " (" + platformInterface.notifications.acceleration.unit + ")"
                // unit: platformInterface.notifications.acceleration.unit
                to: platformInterface.notifications.acceleration.scales.index_0
                from: platformInterface.notifications.acceleration.scales.index_1
                stepSize: platformInterface.notifications.acceleration.scales.index_2
                // states.index_0 for non-arrays, SGSlider automatically sets opacity
                // i.e., state = Disabled (not grayed) set to state = Disabled and Grayed Out
                enabled: !Boolean(platformInterface.notifications.acceleration.states.index_0)

                onUserSet: {
                    console.log("onUserSet:", value)
                    platformInterface.commands.acceleration.update(accelPop.value)
                }

            }
        }

        // ------------------------ Motor Run, Brake, and Direction Buttons ------------------------ //

        // Run
        IconButton {
            id: runButton
            source: run ? "qrc:/images/stop-solid.svg" : "qrc:/images/play-solid.svg"
            iconColor: run ? Theme.palette.error : Theme.palette.success
            toolTipText: platformInterface.notifications.run.caption

            property bool run: false

            // states
            Connections {
                target: platformInterface.notifications.run
                onNotificationFinished: {
                    runButton.run = Boolean(platformInterface.notifications.run.value)
                    runButton.enabled = !Boolean(platformInterface.notifications.run.states.index_0)
                    if (platformInterface.notifications.run.states.index_0 == 2) {
                        runButton.opacity = 0.5
                    } else {
                        runButton.opacity = 1
                    }
                    // Ensure direction button is disabled when control_props enables motor
                    directionButton.enabled = !runButton.run
                    directionButton.opacity = !runButton.run ? 1 : .5
                }
            }

            onClicked:  {
                run = !run
                console.log("onClicked:", run)
                platformInterface.commands.run.update(run)
            }
        }

        // Brake
        IconButton {

            id: brakeButton
            source: "qrc:/images/brake.svg"
            iconColor: brake ? Theme.palette.warning : "white"
            toolTipText: platformInterface.notifications.brake.caption

            property bool brake: false

            // states
            Connections {
                target: platformInterface.notifications.brake
                onNotificationFinished: {
                    brakeButton.brake = Boolean(platformInterface.notifications.brake.value)
                    brakeButton.enabled = !Boolean(platformInterface.notifications.brake.states.index_0)
                    if (platformInterface.notifications.brake.states.index_0 === 2) {
                        brakeButton.opacity = 0.5
                    } else {
                        brakeButton.opacity = 1
                    }
                }
            }

            onClicked:  {
                brake = !brake
                console.log("onClicked:", brake)
                platformInterface.commands.brake.update(brake)
           }
        }

        // Direction
        IconButton {
            id: directionButton
            source: direction ? "qrc:/images/redo-alt-solid.svg" : "qrc:/images/undo.svg"
            toolTipText: platformInterface.notifications.direction.caption
            animationRunning: runButton.run
            animationDirection: direction ? RotationAnimator.Clockwise : RotationAnimator.Counterclockwise

            property bool direction: true // true/1 = CW, false/0 = CCW

            // states
            Connections {
                target: platformInterface.notifications.direction
                onNotificationFinished: {
                    // Ignore control properties if motor is running to avoid direction change
                    if (runButton.run === false) {
                        directionButton.direction = Boolean(platformInterface.notifications.direction.value)
                        directionButton.enabled = !Boolean(platformInterface.notifications.direction.states.index_0)
                        if (platformInterface.notifications.direction.states.index_0 == 2) {
                            directionButton.opacity = 0.5
                        } else {
                            directionButton.opacity = 1
                        }
                    }
                }
            }
            // Disable direction button when motor is enabled
            Connections {
                target: runButton
                onClicked: {
                    directionButton.enabled = !runButton.run
                    directionButton.opacity = !runButton.run ? 1 : .5
                }
            }

            onClicked:  {
                direction = !direction
                console.log("onClicked:", direction)
                platformInterface.commands.direction.update(direction)
            }
        }

        // ------------------------ Column Sidebar Filler ------------------------ //

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        // ------------------------ Warnings ------------------------ //

        ColumnLayout {
            id: warnings
            spacing: 8

            FaultLight {
                text: platformInterface.notifications.warning_1.caption
                toolTipText: platformInterface.notifications.warning_1.caption
                status: {
                    if (platformInterface.notifications.warning_1.value) {
                        status: SGStatusLight.Red
                    } else {
                        SGStatusLight.Off
                    }
                }
            }

            FaultLight {
                text: platformInterface.notifications.warning_2.caption
                toolTipText: platformInterface.notifications.warning_2.caption
                status: {
                    if (platformInterface.notifications.warning_2.value) {
                        status: SGStatusLight.Red
                    } else {
                        SGStatusLight.Off
                    }
                }
            }

            FaultLight {
                text: platformInterface.notifications.warning_3.caption
                toolTipText: platformInterface.notifications.warning_3.caption
                status: {
                    if (platformInterface.notifications.warning_3.value) {
                        status: SGStatusLight.Red
                    } else {
                        SGStatusLight.Off
                    }
                }
            }
        }

        // ------------------------ Column Sidebar Filler ------------------------ //

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        // ------------------------ Help Messages ------------------------ //

        IconButton {
            id: helpIcon
            source: "qrc:/sgimages/question-circle.svg" // Generic icon from SGWidgets
            iconColor: containsMouse ? "grey" : "lightgrey"

            onClicked:  {
                // Start different help tours depending on which view is visible
                switch (tabBar.currentIndex) {
                case 0:
                    Help.startHelpTour("BasicControlHelp")
                    return
                case 1:
                    Help.startHelpTour("AdvancedControlHelp")
                    return
                }
            }
        }
    }
}
