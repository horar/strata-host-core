import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/motor-vortex/sgwidgets"
import "qrc:/views/motor-vortex/Control.js" as MotorControl
Rectangle {
    id: controlNavigation
    anchors {
        fill: parent
    }

    PlatformInterface {
        id: platformInterface
    }


    TabBar {
        id: navTabs
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        TabButton {
            id: basicButton
            text: qsTr("Basic")
            onClicked: {
                if (controlContainer.currentIndex === 1){
                    basicView.motorSpeedSliderValue = advanceView.motorSpeedSliderValue
                } else {
                    basicView.motorSpeedSliderValue = faeView.motorSpeedSliderValue
                }
                controlContainer.currentIndex = 0
            }
        }

        TabButton {
            id: advancedButton
            text: qsTr("Advanced")
            onClicked: {
                if(controlContainer.currentIndex === 0) {
                    advanceView.motorSpeedSliderValue = basicView.motorSpeedSliderValue
                }
                else {
                    advanceView.motorSpeedSliderValue = faeView.motorSpeedSliderValue
                    advanceView.rampRateSliderValue = faeView.rampRateSliderValue
                    advanceView.phaseAngle = faeView.phaseAngle
                    advanceView.ledSlider = faeView.ledSlider
                    advanceView.singleLEDSlider = faeView.singleLEDSlider
                    advanceView.ledPulseSlider = faeView.ledPulseSlider
                }
                controlContainer.currentIndex = 1
            }
        }

        TabButton {
            id: faeButton
            text: qsTr("FAE Only")
            onClicked: {
                if(controlContainer.currentIndex === 0) {
                    faeView.motorSpeedSliderValue = basicView.motorSpeedSliderValue
                }
                else {
                    faeView.motorSpeedSliderValue = advanceView.motorSpeedSliderValue
                    faeView.rampRateSliderValue = advanceView.rampRateSliderValue
                    faeView.phaseAngle = advanceView.phaseAngle
                    faeView.ledSlider = advanceView.ledSlider
                    faeView.singleLEDSlider = advanceView.singleLEDSlider
                    faeView.ledPulseSlider = advanceView.ledPulseSlider
                }
                controlContainer.currentIndex = 2
            }
            background: Rectangle {
                color: faeButton.down ? "#eeeeee" : faeButton.checked ? "white" : "tomato"
            }
        }
    }

    SwipeView {
        id: controlContainer

        currentIndex: 0
        interactive: false
        anchors {
            top: navTabs.bottom
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }

        Item {
            id: basicControl
            BasicControl {id: basicView }
        }

        Item {
            id: advancedControl
            AdvancedControl {id: advanceView }
        }

        Item {
            id: faeControl
            FAEControl {id : faeView }
        }
    }

    Image {
        id: flipButton
        source:"./images/icons/infoIcon.svg"
        anchors { bottom: parent.bottom; right: parent.right }
        height: 40; width:40
    }

    MouseArea {
        width: flipButton.width; height: flipButton.height
        anchors { fill: flipButton }
        visible: true
        z: 20
        onClicked: {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
}
