import QtQuick 2.9
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import tech.strata.sgwidgets 0.9
import tech.strata.sgwidgets 1.0 as Widget10
import "control-views"

Widget10.SGResponsiveScrollView {
    id: root

    property alias currentTab: tabs.currentIndex
    property real factor: Math.max(1,Math.min(root.height/root.minimumHeight,root.width/root.minimumWidth))

    onCurrentTabChanged: {
        tabBar.index = currentTab
    }

    Rectangle {
        id: container
        anchors.fill: parent
        parent: root.contentItem

        MouseArea { // to remove focus in input box when click outside
            anchors.fill: parent
            preventStealing: true
            onClicked: focus = true
        }

        SGSegmentedButtonStrip {
            id: tabBar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10

            radius: 4
            buttonHeight: 30*factor
            visible: true

            segmentedButtons: GridLayout {
                columnSpacing: 1
                SGSegmentedButton {
                    id: tab0
                    text: qsTr("Potentiometer \n To ADC")
                    checked: true
                    onClicked: {
                        tabs.currentIndex = 0
                    }
                }

                SGSegmentedButton {
                    id: tab1
                    text: qsTr("PWM Heat Generator & \n I2C Temp Sensor")
                    onClicked: {
                        tabs.currentIndex = 1
                    }
                }

                SGSegmentedButton {
                    id: tab2
                    text: qsTr("Flitered PWM \n To LED Current")
                    onClicked: {
                        tabs.currentIndex = 2
                    }
                }

                SGSegmentedButton {
                    id: tab3
                    text: qsTr("I2C Light \n Sensor")
                    onClicked: {
                        tabs.currentIndex = 3
                    }
                }

                SGSegmentedButton {
                    id: tab4
                    text: qsTr("I2C LED \n Driver")
                    onClicked: {
                        tabs.currentIndex = 4
                    }
                }

                SGSegmentedButton {
                    id: tab5
                    text: qsTr("PWM Motor \n Control")
                    onClicked: {
                        tabs.currentIndex = 5
                    }
                }

                SGSegmentedButton {
                    id: tab6
                    text: qsTr("Button \n to Interrupt")
                    onClicked: {
                        tabs.currentIndex = 6
                    }
                }
            }
        }

        Item {
            id: content
            height: parent.height - tabBar.height
            width: parent.width
            anchors {
                top: tabBar.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            StackLayout {
                id: tabs
                anchors.fill: parent

                PotentiometerToADCControl {
                    minimumHeight: (root.minimumHeight - 30)/2
                    minimumWidth: root.minimumWidth/2
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))

                    hideHeader: true
                }

                PWMHeatGeneratorAndTempSensorControl {
                    minimumHeight: (root.minimumHeight - 30)/2
                    minimumWidth: root.minimumWidth/2
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))

                    hideHeader: true
                }

                PWMToFiltersControl {
                    minimumHeight: (root.minimumHeight - 30)/2
                    minimumWidth: root.minimumWidth/2
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))

                    hideHeader: true

                }

                LightSensorControl {
                    minimumHeight: (root.minimumHeight - 30)/2
                    minimumWidth: root.minimumWidth/2
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))

                    hideHeader: true
                }

                LEDDriverControl {
                    minimumHeight: (root.minimumHeight - 30)/2
                    minimumWidth: root.minimumWidth/2
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                    hideHeader: true
                }

                PWMMotorControlControl {
                    minimumHeight: (root.minimumHeight - 30)/2
                    minimumWidth: root.minimumWidth/2
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))
                    hideHeader: true
                }

                MechanicalButtonsToInterruptsControl {
                    minimumHeight: (root.minimumHeight - 30)/2
                    minimumWidth: root.minimumWidth/2
                    Layout.preferredHeight: Math.min(parent.height, this.minimumHeight/this.minimumWidth*parent.width)
                    Layout.preferredWidth: Math.min(parent.width, parent.height/(this.minimumHeight/this.minimumWidth))

                    hideHeader: true
                }
            }
        }
    }
}
