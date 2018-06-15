import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/motor-vortex/sgwidgets"

Rectangle {
    id: advancedControl
    anchors {
        fill: parent
    }
    
    Rectangle {
        id: leftSide
        width: 600
        height: childrenRect.height
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        
        SGLabelledInfoBox {
            id: vInBox
            label: "Vin:"
            info: "12.3v"
            infoBoxWidth: 80
            anchors {
                top: leftSide.top
                horizontalCenter: vInGraph.horizontalCenter
            }
        }
        
        SGLabelledInfoBox {
            id: speedBox
            label: "Current Speed:"
            info: "4050 rpm"
            infoBoxWidth: 80
            anchors {
                top: leftSide.top
                horizontalCenter: speedGraph.horizontalCenter
            }
        }
        
        SGGraph{
            id: vInGraph
            width: 300
            height: 300
            anchors {
                top: vInBox.bottom
            }
            showOptions: false
            xAxisTitle: "Seconds"
            yAxisTitle: "Voltage"
        }
        
        SGGraph{
            id: speedGraph
            width: 300
            height: 300
            anchors {
                top: vInBox.bottom
                left: vInGraph.right
            }
            showOptions: false
            xAxisTitle: "Seconds"
            yAxisTitle: "RPM"
        }
        
        SGStatusListBox {
            id: faultBox
            title: "Faults:"
            anchors {
                top: speedGraph.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: 500
            height: 200
        }
    }
    
    Rectangle {
        id: rightSide
        width: 600
        height: childrenRect.height
        anchors {
            left: leftSide.right
            verticalCenter: parent.verticalCenter
        }
        
        Item {
            id: buttonContainer
            width: childrenRect.width
            height: childrenRect.height
            anchors {
                horizontalCenter: rightSide.horizontalCenter
            }
            
            Button {
                id: startStopButton
                text: checked ? qsTr("Stop Motor") : qsTr("Start Motor")
                checkable: true
                background: Rectangle {
                    color: startStopButton.checked ? "red" : "lightgreen"
                    implicitWidth: 100
                    implicitHeight: 40
                }
            }
            
            Button {
                id: resetButton
                anchors {
                    left: startStopButton.right
                    leftMargin: 20
                }
                text: qsTr("Reset")
            }
        }
        
        Rectangle {
            id: speedControlContainer
            width: 500
            height: childrenRect.height + 20
            color: "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: buttonContainer.bottom
                topMargin: 20
            }
            
            SGSlider {
                id: targetSpeedSlider
                label: "Target Speed:"
                width: 350
                minimumValue: 1500
                maximumValue: 5500
                endLabel: maximumValue
                startLabel: minimumValue
                anchors {
                    top: speedControlContainer.top
                    topMargin: 10
                    left: speedControlContainer.left
                    leftMargin: 10
                    right: speedControlContainer.right
                    rightMargin: 10
                }

                MouseArea {
                    id: targetSpeedSliderHover
                    anchors { fill: targetSpeedSlider.children[0] }
                    hoverEnabled: true
                }

                SGToolTipPopup {
                    id: sgToolTipPopup

                    showOn: targetSpeedSliderHover.containsMouse
                    anchors {
                        bottom: targetSpeedSliderHover.top
                        horizontalCenter: targetSpeedSliderHover.horizontalCenter
                    }
                    color: "#0ce"   // Default: "#00ccee"

                    content: Text {
                        text: qsTr("To change values or remove safety\nlimits, contact your FAE.")
                        color: "white"
                    }
                }
            }

            SGSlider {
                id: rampRateSlider
                label: "Ramp Rate:"
                width: 350
                value: 5
                minimumValue: 0
                maximumValue: 10
                endLabel: maximumValue
                startLabel: minimumValue
                anchors {
                    top: targetSpeedSlider.bottom
                    topMargin: 10
                    left: speedControlContainer.left
                    leftMargin: 10
                    right: speedControlContainer.right
                    rightMargin: 10
                }
            }
        }

        Rectangle {
            id: driveModeContainer
            width: 500
            height: childrenRect.height + 10 // 10 for bottom margin
            color: "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: speedControlContainer.bottom
                topMargin: 20
            }

            SGRadioButton {
                id: driveModeRadios
                model: radioModel1
                label: "Drive Mode:"
                anchors {
                    horizontalCenter: driveModeContainer.horizontalCenter
                    top: driveModeContainer.top
                }
                exclusive: true
                orientation: Qt.Horizontal

                ListModel {
                    id: radioModel1

                    ListElement {
                        name: "Trapezoidal"
                        checked: true
                    }

                    ListElement {
                        name: "Pseudo-Sinusoidal"
                    }
                }
            }

            Item {
                id: phaseAngleRow
                width: childrenRect.width
                height: childrenRect.height
                anchors {
                    top: driveModeRadios.bottom
                    horizontalCenter: driveModeContainer.horizontalCenter
                }

                Text {
                    width: contentWidth
                    id: phaseAngleTitle
                    text: qsTr("Phase Angle:")
                    anchors {
                        verticalCenter: driveModeCombo.verticalCenter
                    }
                }

                ComboBox{
                    id: driveModeCombo
                    model: ["7 Degrees", "14 Degrees"]
                    anchors {
                        top: phaseAngleRow.top
                        left: phaseAngleTitle.right
                        leftMargin: 20
                    }
                }
            }
        }

        Rectangle {
            id: directionControlContainer
            width: 500
            height: childrenRect.height + 20 - directionToolTip.height
            color: "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: driveModeContainer.bottom
                topMargin: 20
            }

            SGRadioButton {
                id: directionRadios
                model: radioModel
                label: "Direction:"
                anchors {
                    horizontalCenter: directionControlContainer.horizontalCenter
                    top: directionControlContainer.top
                    topMargin: 10
                }

                // Optional Configuration:
                exclusive: true             // Default: true (modifies exclusivity of the checked property)
                orientation: Qt.Horizontal  // Default: Qt.vertical

                ListModel {
                    id: radioModel

                    ListElement {
                        name: "Forward"
                        checked: true
                        disabled: true
                    }

                    ListElement {
                        name: "Reverse"
                        disabled: true
                    }
                }
            }

            MouseArea {
                id: directionRadiosHover
                anchors { fill: directionRadios }
                hoverEnabled: true
            }

            SGToolTipPopup {
                id: directionToolTip

                showOn: directionRadiosHover.containsMouse
                anchors {
                    bottom: directionRadiosHover.top
                    horizontalCenter: directionRadiosHover.horizontalCenter
                }
                color: "#0ce"   // Default: "#00ccee"

                content: Text {
                    text: qsTr("Reversing direction will damage setup.\nTo remove safety limits, contact your FAE.")
                    color: "white"
                }
            }
        }
    }
}

