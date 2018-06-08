import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "qrc:/sgwidgets"

Window {
    visible: true
    width: 1200
    height: 765
    title: qsTr("Advanced Motor Control")

    Rectangle {
        id: leftSide
        width: 600
        height: 500 //765
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
                horizontalCenter: vInGraph.horizontalCenter
            }
        }

        SGLabelledInfoBox{
            id: speedBox
            label: "Current Speed:"
            info: "4050 rpm"
            infoBoxWidth: 80
            anchors {
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
        height: 500 //765
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
            height: 160
            color: "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: buttonContainer.bottom
                topMargin: 20
            }

            Item {
                id: slidersText
                width: 80
                anchors {
                    top: speedControlContainer.top
                    left: speedControlContainer.left
                    leftMargin: 20
                }

                Text{
                    id: targetSpeedTitle
                    text: "Target Speed:"
                    anchors {
                        top: slidersText.top
                        topMargin: 10
                    }
                }

                Text{
                    id: rampRateTitle
                    text: "Ramp Rate:"
                    anchors {
                        top: targetSpeedTitle.bottom
                        topMargin: 20
                    }
                }
            }

            Item {
                id: speedSliders
                width: childrenRect.width
                height: childrenRect.height
                anchors {
                    left: slidersText.right
                    top: speedControlContainer.top
                    leftMargin: 10
                    rightMargin: 20
                }

                SGSlider {
                    id: targetSpeedSlider
                    width: 350
                    minimumValue: 1500
                    maximumValue: speedSafetyButton.checked ? 5500 : 10000
                    endLabel: speedSafetyButton.checked? maximumValue : "<font color='red''>"+ maximumValue +"</font>"
                    startLabel: minimumValue
                }

                SGSlider {
                    id: rampRateSlider
                    width: 350
                    minimumValue: 0
                    maximumValue: 10
                    endLabel: maximumValue
                    startLabel: minimumValue
                    anchors {
                        top: targetSpeedSlider.bottom
                        topMargin: 20
                    }
                }
            }

            Item {
                id: speedSafety
                width: childrenRect.width
                anchors {
                    top: speedSliders.bottom
                    topMargin: 20
                    horizontalCenter: speedControlContainer.horizontalCenter
                }

                Button {
                    id: speedSafetyButton
                    anchors {
                        left: speedSafety.left
                    }
                    text: checked ? qsTr("Safety Limits On") : qsTr("Safety Limits Off")
                    checkable: true
                    checked: true
                }

                Text {
                    id: speedWarning
                    text: "<font color='red'><strong>Warning:</strong></font> Changing the direction of the pump will damage the pump. To access this feature, contact STRATA Team."
                    width: 300
                    wrapMode: Text.WordWrap
                    anchors {
                        left: speedSafetyButton.right
                        leftMargin: 20
                    }
                }
            }
        }

        Rectangle {
            id: driveModeContainer
            width: 500
            height: 120
            color: "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: speedControlContainer.bottom
                topMargin: 20
            }

            Item {
                id: driveModeControlRow
                width: childrenRect.width
                height: childrenRect.height
                anchors {
                    horizontalCenter: driveModeContainer.horizontalCenter
                }

                Text {
                    width: contentWidth
                    id: driveModeTitle
                    text: qsTr("Drive Mode:")
                    anchors {
                        verticalCenter: driveModeRadios.verticalCenter
                    }
                }

                SGRadioButton {
                    id: driveModeRadios
                    model: radioModel1
                    anchors {
                        left: driveModeTitle.right
                    }
                    exclusive: true
                    orientation: Qt.Horizontal
                    backgroundColor: driveModeContainer.color

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
            }

            Item {
                id: phaseAngleRow
                width: childrenRect.width
                height: childrenRect.height
                anchors {
                    top: driveModeControlRow.bottom
                    topMargin: 20
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
                    anchors {
                        left: phaseAngleTitle.right
                        leftMargin: 20
                    }
                }
            }
        }

        Rectangle {
            id: directionControlContainer
            width: 500
            height: 120
            color: "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: driveModeContainer.bottom
                topMargin: 20
            }

            Item {
                id: directionControlRow
                width: childrenRect.width
                height: childrenRect.height
                anchors {
                    horizontalCenter: directionControlContainer.horizontalCenter
                }

                Text {
                    width: contentWidth
                    id: directionTitle
                    text: qsTr("Direction:")
                    anchors {
                        verticalCenter: directionRadios.verticalCenter
                    }
                }

                SGRadioButton {
                    id: directionRadios
                    model: radioModel
                    anchors {
                        left: directionTitle.right
                    }

                    // Optional Configuration:
                    exclusive: true             // Default: true (modifies exclusivity of the checked property)
                    orientation: Qt.Horizontal  // Default: Qt.vertical
                    backgroundColor: directionControlContainer.color

                    Connections {
                        target: directionSafetyButton
                        onCheckedChanged: {
                            for (var i=0; i<radioModel.count; i++){
                                if (radioModel.get(i).name === "Reverse"){
                                    radioModel.get(i).disabled = !radioModel.get(i).disabled;
                                }
                            }
                        }
                    }

                    ListModel {
                        id: radioModel

                        ListElement {
                            name: "Forward"
                            checked: true
                        }

                        ListElement {
                            name: "Reverse"
                            disabled: true
                        }
                    }
                }
            }

            Item {
                id: directionSafety
                width: childrenRect.width
                anchors {
                    top: directionControlRow.bottom
                    topMargin: 20
                    horizontalCenter: directionControlContainer.horizontalCenter
                }

                Button {
                    id: directionSafetyButton
                    anchors {
                        left: directionSafety.left
                    }
                    text: checked ? qsTr("Direction Limits On") : qsTr("Direction Limits Off")
                    checkable: true
                    checked: true
                }

                Text {
                    id: directionWarning
                    text: "<font color='red'><strong>Warning:</strong></font> No safety limits may damage the demo setup"
                    width: 200
                    wrapMode: Text.WordWrap
                    anchors {
                        left: directionSafetyButton.right
                        leftMargin: 20
                    }
                }
            }
        }
    }
}
