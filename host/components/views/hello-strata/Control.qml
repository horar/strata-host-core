import QtQuick 2.9
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: controlNavigation  

    anchors.fill: parent

    property real minContentHeight: 688
    property real minContentWidth: 1024-rightBarWidth
    property real rightBarWidth: 80
    property real factor: Math.min(controlNavigation.height/minContentHeight,(controlNavigation.width-rightBarWidth)/minContentWidth)
    property real vFactor: Math.max(1,height/minContentHeight)
    property real hFactor: Math.max(1,(width-rightBarWidth)/minContentWidth)
    property alias currentTab: tabView.currentTab

    Component.onCompleted: {
        controlContainer.currentIndex = 0
        Help.registerTarget(thumbnailIcon, "Click on this icon to switch between grid view mode and tab view mode.", 0, "helloStrataHelp")
        Help.registerTarget(thumbnailIcon, "Go to tab view mode to see help tour for each tab", 3, "helloStrataHelp")
        platformInterface.get_all_states.update()
    }

    PlatformInterface {
        id: platformInterface
    }

    Rectangle {
        id: content
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: rightMenu.left
        }

        StackLayout {
            id: controlContainer
            height: controlNavigation.height
            width: controlNavigation.width-rightBarWidth
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            HelloStrataControl {
                minimumHeight: minContentHeight*1.245
                minimumWidth: minContentWidth*1.245

                onSignalPotentiometerToADCControl: {
                    controlContainer.currentIndex = 1
                    tabView.currentTab = 0
                }
                onSignalDACAndPWMToLEDControl: {
                    controlContainer.currentIndex = 1
                    tabView.currentTab = 1
                }
                onSignalPWMMotorControlControl: {
                    controlContainer.currentIndex = 1
                    tabView.currentTab = 2
                }
                onSignalPWMHeatGeneratorAndTempSensorControl: {
                    controlContainer.currentIndex = 1
                    tabView.currentTab = 3
                } 
                onSignalLightSensorControl: {
                    controlContainer.currentIndex = 1
                    tabView.currentTab = 4
                }
                onSignalPWMToFiltersControl: {
                    controlContainer.currentIndex = 1
                    tabView.currentTab = 5
                }
                onSignalLEDDriverControl: {
                    controlContainer.currentIndex = 1
                    tabView.currentTab = 6
                }
                onSignalMechanicalButtonsToInterruptsControl: {
                    controlContainer.currentIndex = 1
                    tabView.currentTab = 7
                }
            }

            HelloStrataControl_TabView {
                id:tabView
                minimumHeight: minContentHeight
                minimumWidth: minContentWidth
            }
        }
    }

    Rectangle {
        id: rightMenu
        width: rightBarWidth
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        MouseArea { // to remove focus in input box when click outside
            anchors.fill: parent
            preventStealing: true
            onClicked: focus = true
        }

        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: "lightgrey"
        }

        SGIcon {
            id: helpIcon
            anchors {
                right: parent.right
                top: parent.top
                margins: (rightBarWidth-helpIcon.width)/2
            }

            source: "control-views/question-circle-solid.svg"
            iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
            height: 40
            width: 40

            MouseArea {
                id: helpMouse
                anchors {
                    fill: helpIcon
                }
                onClicked: {
                    focus = true
                    if (controlContainer.currentIndex === 0) Help.startHelpTour("helloStrataHelp")
                    else {
                        switch (currentTab) {
                            case 0:
                                Help.startHelpTour("helloStrata_PotToADC_Help")
                                break;
                            case 1:
                                Help.startHelpTour("helloStrata_DACPWMToLED_Help")
                                break;
                            case 2:
                                Help.startHelpTour("helloStrata_PWMMotorControl_Help")
                                break;
                            case 3:
                                Help.startHelpTour("helloStrata_TempSensor_Help")
                                break;
                            case 4:
                                Help.startHelpTour("helloStrata_LightSensor_Help")
                                break;
                            case 5:
                                Help.startHelpTour("helloStrata_PWMToFilters_Help")
                                break;
                            case 6:
                                Help.startHelpTour("helloStrata_LEDDriver_Help")
                                break;
                            case 7:
                                Help.startHelpTour("helloStrata_ButtonsInterrupts_Help")
                        }
                    }
                }
                hoverEnabled: true
            }
        }

        SGIcon {
            id: thumbnailIcon
            anchors {
                right: parent.right
                top: helpIcon.bottom
                margins: (rightBarWidth-thumbnailIcon.width)/2
            }

            source: "control-views/thumbnail-view-icon.svg"
            iconColor: thumbnailMouse.containsMouse ? "lightgrey" : (controlContainer.currentIndex === 0 ? "green" : "grey")
            height: 40
            width: 40

            MouseArea {
                id: thumbnailMouse
                anchors {
                    fill: thumbnailIcon
                }
                onClicked: {
                    focus = true
                    controlContainer.currentIndex = 1-controlContainer.currentIndex
                }
                hoverEnabled: true
            }
        }
    }
}
