import QtQuick 2.9
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

SGResponsiveScrollView {
    id: root

    minimumHeight: 690
    minimumWidth: 950

    signal signalPotentiometerToADCControl
    signal signalPWMHeatGeneratorAndTempSensorControl
    signal signalPWMToFiltersControl
    signal signalDACAndPWMToLEDControl
    signal signalPWMMotorControlControl
    signal signalLightSensorControl
    signal signalLEDDriverControl
    signal signalMechanicalButtonsToInterruptsControl

    SGSegmentedButtonStrip {
        id: tabBar
        radius: 4
        buttonHeight: 45
        visible: true

        segmentedButtons: GridLayout {
            columnSpacing: 1
            SGSegmentedButton {
                text: qsTr("Potentiometer")
                checked: true
                onClicked: {
                    tabs.currentIndex = 0
                }
            }
            SGSegmentedButton {
                text: qsTr("DAC and PWM LED")
                onClicked: {
                    tabs.currentIndex = 1
                }
            }
            SGSegmentedButton {
                text: qsTr("PWM Motor Control")
                onClicked: {
                    tabs.currentIndex = 2
                }
            }
            SGSegmentedButton {
                text: qsTr("PWM Heat Generator")
                onClicked: {
                    tabs.currentIndex = 3
                }
            }
            SGSegmentedButton {
                text: qsTr("Light Sensor")
                onClicked: {
                    tabs.currentIndex = 4
                }
            }
            SGSegmentedButton {
                text: qsTr("PWM Filters")
                onClicked: {
                    tabs.currentIndex = 5
                }
            }
            SGSegmentedButton {
                text: qsTr("LED Driver")
                onClicked: {
                    tabs.currentIndex = 6
                }
            }
            SGSegmentedButton {
                text: qsTr("Mechanical Buttons")
                onClicked: {
                    tabs.currentIndex = 7
                }
            }
        }
    }

    Item {
        id: content
        anchors {
            top: tabBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: parent.height - tabBar.height
        width: parent.width

        StackLayout {
            id: tabs
            anchors.fill: parent
            PotentiometerToADCControl {
                Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                onZoom: signalPotentiometerToADCControl()
            }

            DACAndPWMToLEDControl {
                Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                onZoom: signalDACAndPWMToLEDControl()
            }

            PWMMotorControlControl {
                Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                onZoom: signalPWMMotorControlControl()
            }

            PWMHeatGeneratorAndTempSensorControl {
                Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                onZoom: signalPWMHeatGeneratorAndTempSensorControl()
            }

            LightSensorControl {
                Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                onZoom: signalLightSensorControl()
            }

            PWMToFiltersControl {
                Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                onZoom: signalPWMToFiltersControl()
            }

            LEDDriverControl {
                Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                onZoom: signalLEDDriverControl()
            }

            MechanicalButtonsToInterruptsControl {
                Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                onZoom: signalMechanicalButtonsToInterruptsControl()
            }
        }
    }
}
