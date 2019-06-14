import QtQuick 2.9
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

SGResponsiveScrollView {
    id: root

    minimumHeight: 660+20
    minimumWidth: 850+20+40

    property alias currentTab: tabs.currentIndex
    property var factor: Math.max(1,Math.min(root.height/root.minimumHeight,root.width/root.minimumWidth))

    onCurrentTabChanged: {
        tabBar.index = currentTab
    }

    Rectangle {
        id: container
        parent: root.contentItem
        anchors.fill: parent

        SGSegmentedButtonStrip {
            id: tabBar
            radius: 4
            buttonHeight: 30*factor
            visible: true
            anchors.horizontalCenter: parent.horizontalCenter

            segmentedButtons: GridLayout {
                columnSpacing: 1
                SGSegmentedButton {
                    id: tab0
                    text: qsTr("Potentiometer")
                    checked: true
                    onClicked: {
                        tabs.currentIndex = 0
                    }
                }
                SGSegmentedButton {
                    id: tab1
                    text: qsTr("DAC & PWM LED")
                    onClicked: {
                        tabs.currentIndex = 1
                    }
                }
                SGSegmentedButton {
                    id: tab2
                    text: qsTr("PWM Motor Control")
                    onClicked: {
                        tabs.currentIndex = 2
                    }
                }
                SGSegmentedButton {
                    id: tab3
                    text: qsTr("PWM Heat Generator")
                    onClicked: {
                        tabs.currentIndex = 3
                    }
                }
                SGSegmentedButton {
                    id: tab4
                    text: qsTr("Light Sensor")
                    onClicked: {
                        tabs.currentIndex = 4
                    }
                }
                SGSegmentedButton {
                    id: tab5
                    text: qsTr("PWM Filters")
                    onClicked: {
                        tabs.currentIndex = 5
                    }
                }
                SGSegmentedButton {
                    id: tab6
                    text: qsTr("LED Driver")
                    onClicked: {
                        tabs.currentIndex = 6
                    }
                }
                SGSegmentedButton {
                    id: tab7
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
                    hideHeader: true
                }

                DACAndPWMToLEDControl {
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                    hideHeader: true
                }

                PWMMotorControlControl {
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                    hideHeader: true
                }

                PWMHeatGeneratorAndTempSensorControl {
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                    hideHeader: true
                }

                LightSensorControl {
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                    hideHeader: true
                }

                PWMToFiltersControl {
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                    hideHeader: true
                }

                LEDDriverControl {
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                    hideHeader: true
                }

                MechanicalButtonsToInterruptsControl {
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                    hideHeader: true
                }
            }
        }
    }
}
