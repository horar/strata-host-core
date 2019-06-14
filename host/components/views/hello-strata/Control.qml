import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: controlNavigation  
    anchors {
        fill: parent
    }

    Component.onCompleted: {
        controlContainer.currentIndex = 1
    }

    property var minContentHeight: 660+20
    property var minContentWidth: 850+20
    property var rightBarWidth: 80
    property var factor: Math.min(controlNavigation.height/minContentHeight,(controlNavigation.width-rightBarWidth)/minContentWidth)

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
            height: minContentHeight*factor
            width: minContentWidth*factor
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            HelloStrataControl {
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
                    // Make sure view is set to Basic before starting tour
                    controlContainer.currentIndex = 0
                    Help.startHelpTour("controlHelp")
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
                    controlContainer.currentIndex = 1-controlContainer.currentIndex
                }
                hoverEnabled: true
            }
        }
    }
}
