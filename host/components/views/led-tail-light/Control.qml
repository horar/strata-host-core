import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }

    PlatformInterface {
        id: platformInterface
    }

    Component.onCompleted: {
        platformInterface.mode.update("Car Demo")
    }

    TabBar {
        id: navTabs
        anchors {
            top: controlNavigation.top
            left: controlNavigation.left
            right: controlNavigation.right
        }

        TabButton {
            id: carDemoButton
            text: qsTr("Car Demo Mode")
            onClicked: {
                platformInterface.mode.update("Car Demo")
                carDemoMode.visible = true
                ledControl.visible = false
                powerControl.visible = false
                sAMOPTControl.visible = false
                miscControl.visible = false
            }
        }

        TabButton {
            id: ledControlButton
            text: qsTr("LED Control")
            onClicked: {
                platformInterface.mode.update("LED Driver")
                carDemoMode.visible = false
                ledControl.visible = true
                powerControl.visible = false
                sAMOPTControl.visible = false
                miscControl.visible = false
            }
        }

        TabButton {
            id: powerControlButton
            text: qsTr("Power")
            onClicked: {
                carDemoMode.visible = false
                ledControl.visible = false
                powerControl.visible = true
                sAMOPTControl.visible = false
                miscControl.visible = false
            }
        }

        TabButton {
            id: samOptControlButton
            text: qsTr("SAM,OTP,And CRC")
            onClicked: {
                carDemoMode.visible = false
                ledControl.visible = false
                powerControl.visible = false
                sAMOPTControl.visible = true
                miscControl.visible = false
            }
        }

        TabButton {
            id: miscControlButton
            text: qsTr("Miscellaneous")
            onClicked: {
                carDemoMode.visible = false
                ledControl.visible = false
                powerControl.visible = false
                sAMOPTControl.visible = false
                miscControl.visible = true
            }
        }
    }

    Item {
        id: controlContainer
        anchors {
            top: navTabs.bottom
            bottom: controlNavigation.bottom
            right: controlNavigation.right
            left: controlNavigation.left
        }

        CarDemoControl{
            id: carDemoMode
            visible: true
        }

        LEDControl {
            id: ledControl
            visible: false
        }

        PowerControl {
            id: powerControl
            visible: false
        }

        SAMOPTControl {
            id: sAMOPTControl
            visible: false
        }

        MiscControl {
            id: miscControl
            visible: false
        }

    }

    //    SGIcon {
    //        id: helpIcon
    //        anchors {
    //            right: controlContainer.right
    //            top: controlContainer.top
    //            margins: 20
    //        }
    //        source: "control-views/question-circle-solid.svg"
    //        iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
    //        height: 40
    //        width: 40

    //        MouseArea {
    //            id: helpMouse
    //            anchors {
    //                fill: helpIcon
    //            }
    //            onClicked: {
    //                // Make sure view is set to Basic before starting tour
    //                controlContainer.currentIndex = 0
    //                carDemoMode.clicked()
    //                Help.startHelpTour("controlHelp")
    //            }
    //            hoverEnabled: true
    //        }
    //    }
}
