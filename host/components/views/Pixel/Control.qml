import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0


Item {
    id: controlNavigation
    anchors {
        fill: parent
    }

    PlatformInterface {
        id: platformInterface
    }

    Component.onCompleted: {
        Help.registerTarget(navTabs, "Using these two tabs, you may select between basic and advanced controls.", 0, "controlHelp")
    }

    TabBar {
        id: navTabs
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        TabButton {
            id: controlButton2
            text: qsTr("Pixel Control")
            onClicked: {
                platformInterface.stop_periodic_mapena.update("pxnBRCMAPENCommand")   // 20201014 YI
                //platformInterface.stop_periodic_diagread.update("pxn_diag_clear")   // 20201023 YI
                controlContainer.currentIndex = 0
                controldemo.handlar_stop_control()
                platformInterface.pxn_datasend_all.update(0)
                //platformInterface.start_periodic_mapena.update("pxnBRCMAPENCommand", -1, 100)   // 20201002 YI
                platformInterface.auto_addr_sw_block = false
                platformInterface.clear_intensity_slider_led1 = true
                platformInterface.clear_intensity_slider_led2 = true
                platformInterface.clear_intensity_slider_led3 = true
                platformInterface.clear_demo_setup = false

                intensitycontrol.sgSwitch_off = false
                intensitycontrol.sgSwitch_label = "<b>Watch Dog<br>OFF</b>"  // YI

            }
        }

        TabButton {
            id: demoButton
            text: qsTr("Pixel Demo")
            onClicked: {
                controlContainer.currentIndex = 1
                controldemo.handlar_start_control()
                platformInterface.clear_intensity_slider_led1 = false
                platformInterface.clear_intensity_slider_led2 = false
                platformInterface.clear_intensity_slider_led3 = false
                platformInterface.clear_demo_setup = true
                //platformInterface.stop_periodic_mapena.update("pxnBRCMAPENCommand")   // 20201002 YI
                platformInterface.start_periodic_mapena.update("pxnBRCMAPENCommand", -1, 100)   // 20201002 YI
                //platformInterface.start_periodic_diagread.update("pxn_diag_clear", -1, 500)   // 20201023 YI
            }
        }

        TabButton {
            id: diagpxnButton
            text: qsTr("Pixel Diagnostic information")
            onClicked: {
                //platformInterface.stop_periodic_mapena.update("pxnBRCMAPENCommand")   // 20201002 YI
                //platformInterface.stop_periodic_diagread.update("pxn_diag_clear")   // 20201023 YI
                platformInterface.start_periodic_mapena.update("pxnBRCMAPENCommand", -1, 100)   // 20201022 YI
                controlContainer.currentIndex = 2
                controldemo.handlar_stop_control()
                platformInterface.clear_intensity_slider_led1 = false
                platformInterface.clear_intensity_slider_led2 = false
                platformInterface.clear_intensity_slider_led3 = false
                platformInterface.clear_demo_setup = false
            }
        }

        TabButton {
            id: setupButton
            text: qsTr("Boost and Buck IC setup")
            onClicked: {
                //platformInterface.stop_periodic_mapena.update("pxnBRCMAPENCommand")   // 20201002 YI
                platformInterface.start_periodic_mapena.update("pxnBRCMAPENCommand", -1, 100)   // 20201022 YI
                //platformInterface.stop_periodic_diagread.update("pxn_diag_clear")   // 20201023 YI
                controlContainer.currentIndex = 3
                controldemo.handlar_stop_control()
                platformInterface.pxn_datasend_all.update(0)
                platformInterface.clear_intensity_slider_led1 = false
                platformInterface.clear_intensity_slider_led2 = false
                platformInterface.clear_intensity_slider_led3 = false
                platformInterface.clear_demo_setup = false
            }
        }

        TabButton {
            id: diagButton
            text: qsTr("Buck Boost Diagnostic information")
            onClicked: {
                //platformInterface.stop_periodic_mapena.update("pxnBRCMAPENCommand")   // 20201002 YI
                platformInterface.start_periodic_mapena.update("pxnBRCMAPENCommand", -1, 100)   // 20201022 YI
                //platformInterface.stop_periodic_diagread.update("pxn_diag_clear")   // 20201023 YI
                controlContainer.currentIndex = 4
                controldemo.handlar_stop_control()
                platformInterface.pxn_datasend_all.update(0)
                platformInterface.clear_intensity_slider_led1 = false
                platformInterface.clear_intensity_slider_led2 = false
                platformInterface.clear_intensity_slider_led3 = false
                platformInterface.clear_demo_setup = false
            }
        }
    }

    StackLayout {
        id: controlContainer
        anchors {
            top: navTabs.bottom
            bottom: controlNavigation.bottom
            right: controlNavigation.right
            left: controlNavigation.left
        }

        IntensityControl {
            id: intensitycontrol
        }

        ControlDemo {
            id: controldemo
        }

        DiagWindowPxn {
            id:diagwindowpxn
        }

        SetupControl {
            id: setupcontrol
        }

        DiagWindow {
            id:diagwindow
        }
    }

    Rectangle {
        width: 30
        height: 30
        anchors {
            right: parent.right
            rightMargin: 6
            top: navTabs.bottom
            topMargin: 32
        }
        color: "transparent"

        SGIcon {
            id: helpIcon
            anchors.fill: parent
            source: "qrc:/sgimages/question-circle.svg"
            iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
            visible: true

            MouseArea {
                id: helpMouse
                anchors {
                    fill: helpIcon
                }
                hoverEnabled: true

                property var count: 0
                property var callCount: 0
                property string tourToOpen: ""

                onClicked: {
                    if (intensitycontrol.visible === true) {
                        count = 0
                        callCount = 0

                        // Figure out how many accordions are in the wrong position
                        if (!intensitycontrol.accordion.contentItem.children[0].open) {
                            count++
                        }
                        if (intensitycontrol.accordion.contentItem.children[1].open) {
                            count++
                        }
                        if (intensitycontrol.accordion.contentItem.children[2].open) {
                            count++
                        }
                        if (!intensitycontrol.accordion.contentItem.children[3].open) {
                            count++
                        }

                        if (count === 0) {
                            // No accordions in the wrong position, start help
                            Help.startHelpTour("Help1")
                        } else {
                            // >0 accordions are in the wrong position, correct them, then start help when all <count> animations have finished
                            tourToOpen = "Help1"
                            intensitycontrol.accordion.contentItem.children[0].open = true
                            intensitycontrol.accordion.contentItem.children[1].open = false
                            intensitycontrol.accordion.contentItem.children[2].open = false
                            intensitycontrol.accordion.contentItem.children[3].open = true
                        }
                    }
                    else if(controldemo.visible === true) {
                        Help.startHelpTour("Help2")
                    }
                    else if(diagwindowpxn.visible === true) {
                        count = 0
                        callCount = 0

                        // Figure out how many accordions are in the wrong position
                        if (!diagwindowpxn.accordion.contentItem.children[0].open) {
                            count++
                        }
                        if(!diagwindowpxn.accordion.contentItem.children[1].open) {
                            count++
                        }

                        if (count === 0) {
                            // No accordions in the wrong position, start help
                            Help.startHelpTour("Help3")
                        } else {
                            // >0 accordions are in the wrong position, correct them, then start help when all <count> animations have finished
                            tourToOpen = "Help3"
                            diagwindowpxn.accordion.contentItem.children[0].open = true
                            diagwindowpxn.accordion.contentItem.children[1].open = true
                        }

                    }
                    else if(setupcontrol.visible === true) {
                        Help.startHelpTour("Help4")
                    }
                    else if(diagwindow.visible === true) {
                        count = 0
                        callCount = 0

                        // Figure out how many accordions are in the wrong position
                        if (!diagwindow.accordion.contentItem.children[0].open) {
                            count++
                        }
                        if(!diagwindow.accordion.contentItem.children[1].open) {
                            count++
                        }

                        if (count === 0) {
                            // No accordions in the wrong position, start help
                            Help.startHelpTour("Help5")
                        } else {
                            // >0 accordions are in the wrong position, correct them, then start help when all <count> animations have finished
                            tourToOpen = "Help5"
                            diagwindow.accordion.contentItem.children[0].open = true
                            diagwindow.accordion.contentItem.children[1].open = true
                        }
                    }
                }

                Component.onCompleted: {
                    // Connect startHelpAfterAnimationComplete() to all accordion 'animation complete' signals
                    intensitycontrol.accordion.contentItem.children[0].animationCompleted.connect(startHelpAfterAnimationComplete)
                    intensitycontrol.accordion.contentItem.children[1].animationCompleted.connect(startHelpAfterAnimationComplete)
                    intensitycontrol.accordion.contentItem.children[2].animationCompleted.connect(startHelpAfterAnimationComplete)
                    intensitycontrol.accordion.contentItem.children[3].animationCompleted.connect(startHelpAfterAnimationComplete)
                    diagwindowpxn.accordion.contentItem.children[0].animationCompleted.connect(startHelpAfterAnimationComplete)
                    diagwindowpxn.accordion.contentItem.children[1].animationCompleted.connect(startHelpAfterAnimationComplete)
                    diagwindow.accordion.contentItem.children[0].animationCompleted.connect(startHelpAfterAnimationComplete)
                    diagwindow.accordion.contentItem.children[1].animationCompleted.connect(startHelpAfterAnimationComplete)


                }

                function startHelpAfterAnimationComplete() {
                    // If help has been requested, wait until all 'animation complete' signals have been called before opening it
                    if (count !== 0) {
                        callCount++
                        if (count === callCount) {
                            // Wait one render frame for animations to really complete before opening help to make sure geometry is calculated correctly
                            renderListener.enabled = true
                            count = 0
                            callCount = 0
                        }
                    }
                }

                Connections {
                    id: renderListener
                    target: mainWindow
                    onAfterRendering: {
                        enabled = false
                        Help.startHelpTour(helpMouse.tourToOpen)
                    }
                    enabled: false
                }
            }
        }
    }
}
