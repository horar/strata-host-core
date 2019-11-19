import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Rectangle {
    id: outerRectangle
    anchors {
        fill: parent
    }
    color:motorControllerPurple

    property color motorControllerBrown: "#522b29"
    property color motorControllerTeal: "#3788FB"
    property color motorControllerBlue: "#51D6FF"
    property color motorControllerGrey: "#8D8D8D"
    property color motorControllerPurple: "#A06B9A"

    PlatformInterface {
        id: platformInterface
    }

    Component.onCompleted: {
        platformInterface.refresh.send();
    }

    Rectangle{
        id:controlNavigation
        color:motorControllerGrey
        radius: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.right:parent.right
        anchors.rightMargin: 10
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 10


        SGSegmentedButtonStrip {
            id: brushStepperSelector
            labelLeft: false
            anchors.top: parent.top
            anchors.topMargin: 25
            anchors.horizontalCenter: parent.horizontalCenter
            textColor: "#666"
            activeTextColor: "white"
            radius: 4
            buttonHeight: 50
            exclusive: true
            buttonImplicitWidth: 200

            segmentedButtons: GridLayout {
                columnSpacing: 2
                rowSpacing: 2

                MCSegmentedButton{
                    text: qsTr("brush")
                    activeColor: "dimgrey"
                    inactiveColor: "gainsboro"
                    textColor: "black"
                    textActiveColor: "white"
                    checked: true
                    textSize:36
                    onClicked: controlContainer.currentIndex = 0
                }

                MCSegmentedButton{
                    text: qsTr("stepper")
                    activeColor: "dimgrey"
                    inactiveColor: "gainsboro"
                    textColor: "black"
                    textActiveColor: "white"
                    textSize:36
                    onClicked: controlContainer.currentIndex = 1
                }
            }
        }


        StackLayout {
            id: controlContainer
            anchors {
                top: brushStepperSelector.bottom
                topMargin: 20
                bottom: controlNavigation.bottom
                right: controlNavigation.right
                left: controlNavigation.left
            }

            BrushControl {
                id: brush
            }

            StepperControl {
                id: stepper
            }
        }

    }


        DebugMenu {
            // See description in control-views/DebugMenu.qml
            anchors {
                right: outerRectangle.right
                bottom: outerRectangle.bottom
            }
        }
}
