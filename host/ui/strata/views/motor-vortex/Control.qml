import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/motor-vortex/sgwidgets"

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

    ScrollView {
        anchors {
            top: navTabs.bottom
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }

        onWidthChanged: {
            if (width < 1200) {
                ScrollBar.horizontal.policy = ScrollBar.AlwaysOn
            } else {
                ScrollBar.horizontal.policy = ScrollBar.AlwaysOff
            }
        }

        onHeightChanged: {
            if (height < 725) {
                ScrollBar.vertical.policy = ScrollBar.AlwaysOn
            } else {
                ScrollBar.vertical.policy = ScrollBar.AlwaysOff
            }
        }

        Flickable {
            id: controlContainer

            property int currentIndex: 0

            onCurrentIndexChanged: {
                switch (currentIndex){
                case 0:
                    basicView.visible = true
                    advanceView.visible = false
                    faeView.visible = false
                    break;
                case 1:
                    basicView.visible = false
                    advanceView.visible = true
                    faeView.visible = false
                    break;
                case 2:
                    basicView.visible = false
                    advanceView.visible = false
                    faeView.visible = true
                    break;
                }
            }

            boundsBehavior: Flickable.StopAtBounds
            contentWidth: 1200
            contentHeight: 725
            anchors {
                fill: parent
            }
            clip: true

            BasicControl {
                id: basicView
                visible: true
            }

            AdvancedControl {
                id: advanceView
                visible: false
                property alias basicView: basicView
            }

            FAEControl {
                id : faeView
                visible: false
                property alias basicView: basicView
            }
        }
    }
}
