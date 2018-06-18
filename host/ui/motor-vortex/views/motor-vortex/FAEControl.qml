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
        id: warningBox
        color: "red"
        anchors {
            bottom: leftSide.top
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 20
        }
        width: warningText.contentWidth + 120
        height: warningText.contentHeight + 40

        Text {
            id: warningText
            anchors {
                centerIn: parent
            }
            text: "<b>Restricted Access:</b> ON Semi Employees Only"
            font.pointSize: 18
            color: "white"
        }

        Text {
            id: warningIcon1
            anchors {
                right: warningText.left
                verticalCenter: warningText.verticalCenter
                rightMargin: 10
            }
            text: "\ue80e"
            font.family: icons.name
            font.pointSize: 50
            color: "white"
        }

        Text {
            id: warningIcon2
            anchors {
                left: warningText.right
                verticalCenter: warningText.verticalCenter
                leftMargin: 10
            }
            text: "\ue80e"
            font.family: icons.name
            font.pointSize: 50
            color: "white"
        }

        FontLoader {
            id: icons
            source: "sgwidgets/fonts/sgicons.ttf"
        }

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
            id: ssButtonContainer
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
            color: speedSafetyButton.checked ? "#ffb4aa" : "#eeeeee"
            anchors {
                horizontalCenter: rightSide.horizontalCenter
                top: ssButtonContainer.bottom
                topMargin: 20
            }

            SGSlider {
                id: targetSpeedSlider
                label: "Target Speed:"
                width: 350
                minimumValue: speedSafetyButton.checked ? 0 : 1500
                maximumValue: speedSafetyButton.checked ? 10000 : 5500
                endLabel: speedSafetyButton.checked? "<font color='red'><b>"+ maximumValue +"</b></font>" : maximumValue
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
                    width: 160
                    anchors {
                        left: speedSafety.left
                    }
                    text: checked ? "Turn Safety Limits On" : "<font color='red'><b>Turn Safety Limits Off</b></font>"
                    checkable: true
                    onClicked: if (checked) speedPopup.open()
                }

                Text {
                    id: speedWarning
                    text: "<font color='red'><strong>Warning:</strong></font> The demo setup can be damaged by running past the safety limits"
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
            color: directionSafetyButton.checked ? "#ffb4aa" : "#eeeeee"
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
                    width: 185
                    anchors {
                        left: directionSafety.left
                    }
                    text: checked ? "Turn Direction Lock On" : "<font color='red'><b>Turn Direction Lock Off</b></font>"
                    checkable: true
                    checked: false
                    onClicked: if (checked) directionPopup.open()
                }

                Text {
                    id: directionWarning
                    text: "<font color='red'><strong>Warning:</strong></font> Changing the direction of the motor will damage the pump."
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

    Dialog {
        id: speedPopup
        x: Math.round((advancedControl.width - width) / 2)
        y: Math.round((advancedControl.height - height) / 2)
        width: 350
        height: speedPopupText.height + footer.height + padding * 2
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        padding: 20
        background: Rectangle {
            border.width: 0
        }
        standardButtons: Dialog.Ok | Dialog.Cancel
        onRejected: { speedSafetyButton.checked = false }

        Text {
            id: speedPopupText
            width: speedPopup.width - speedPopup.padding * 2
            height: contentHeight
            wrapMode: Text.WordWrap
            text: "<font color='red'><strong>Warning:</strong></font> The demo setup may be damaged if run beyond the safety limits. Are you sure you'd like to turn off the limits?"
        }
    }

    Dialog {
        id: directionPopup
        x: Math.round((advancedControl.width - width) / 2)
        y: Math.round((advancedControl.height - height) / 2)
        width: 350
        height: directionPopupText.height + footer.height + padding * 2
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        padding: 20
        background: Rectangle {
            border.width: 0
        }
        standardButtons: Dialog.Ok | Dialog.Cancel
        onRejected: { directionSafetyButton.checked = false }

        Text {
            id: directionPopupText
            width: directionPopup.width - directionPopup.padding * 2
            height: contentHeight
            wrapMode: Text.WordWrap
            text: "<font color='red'><strong>Warning:</strong></font> The pump will be damaged if run in reverse. Are you sure you'd like to turn off the direction lock?"
        }
    }
}

