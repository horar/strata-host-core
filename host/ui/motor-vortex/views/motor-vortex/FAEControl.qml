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

        SGLabelledInfoBox{
            id: vInBox
            label: "Vin:"
            info: "12.3v"
            infoBoxWidth: 80
            anchors {
                top: leftSide.top
                horizontalCenter: vInGraph.horizontalCenter
            }
        }

        SGLabelledInfoBox{
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
                Component.onCompleted: console.log(height + " " + width)
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
                    maximumValue: speedSafetyButton.checked ? 5500 : 10000
                    endLabel: speedSafetyButton.checked? maximumValue : "<font color='red''>"+ maximumValue +"</font>"
                    startLabel: minimumValue
                    anchors {
                        top: speedControlContainer.top
                        topMargin: 10
                        left: speedControlContainer.left
                        leftMargin: 10
                        right: speedControlContainer.right
                        rightMargin: 10
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

            Item {
                id: speedSafety
                height: childrenRect.height
                anchors {
                    top: rampRateSlider.bottom
                    topMargin: 20
                    left: speedControlContainer.left
                    leftMargin: 10
                    right: speedControlContainer.right
                    rightMargin: 10
                }

                Button {
                    id: speedSafetyButton
                    width: 120
                    anchors {
                        left: speedSafety.left
                    }
                    text: checked ? qsTr("Safety Limits On") : qsTr("Safety Limits Off")
                    checkable: true
                    checked: true
                }

                Text {
                    id: speedWarning
                    text: "<font color='red'><strong>Warning:</strong></font> Turning off safety limits may damage the demo setup"
                    wrapMode: Text.WordWrap
                    anchors {
                        left: speedSafetyButton.right
                        leftMargin: 20
                        right: speedSafety.right
                        verticalCenter: speedSafetyButton.verticalCenter
                    }
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
            height: childrenRect.height + 20
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

                Connections {
                    target: directionSafetyButton
                    onCheckedChanged: {
                        for (var i=0; i<radioModel.count; i++){
                            radioModel.get(i).disabled = !radioModel.get(i).disabled;
                        }
                    }
                }

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

            Item {
                id: directionSafety
                height: childrenRect.height
                anchors {
                    top: directionRadios.bottom
                    topMargin: 10
                    left: directionControlContainer.left
                    leftMargin: 10
                    right: directionControlContainer.right
                    rightMargin: 10
                }

                Button {
                    id: directionSafetyButton
                    width: 140
                    anchors {
                        left: directionSafety.left
                    }
                    text: checked ? qsTr("Direction Limits On") : qsTr("Direction Limits Off")
                    checkable: true
                    checked: true
                }

                Text {
                    id: directionWarning
                    text: "<font color='red'><strong>Warning:</strong></font> Changing the direction of the pump will damage the pump. To access this feature, contact STRATA Team."
                    wrapMode: Text.WordWrap
                    anchors {
                        left: directionSafetyButton.right
                        leftMargin: 20
                        right: directionSafety.right
                        verticalCenter: directionSafetyButton.verticalCenter
                    }
                }
            }
        }
    }
}

