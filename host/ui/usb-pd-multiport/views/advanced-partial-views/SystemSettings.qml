import QtQuick 2.9
import QtQuick.Layouts 1.3
import "qrc:/sgwidgets"

Item {
    id: root
    height: 275
    width: parent.width
    anchors {
        left: parent.left
    }

    Item {
        id: leftColumn
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/2

        Item {
            id: margins1
            anchors {
                fill: parent
                margins: 15
            }

            SGSegmentedButtonStrip {
                id: dataConfig
                label: "Data Configuration:"
                activeColor: "#666"
                inactiveColor: "#dddddd"
                textColor: "#666"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25
                anchors {
                    left: margins1.left
                    leftMargin: 72
                }

                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    SGSegmentedButton{
                        text: qsTr("Charge Only")
                        checked: true  // Sets default checked button when exclusive
                    }

                    SGSegmentedButton{
                        text: qsTr("Something Else")
                    }
                }
            }


            SGSegmentedButtonStrip {
                id: powerNegotiation
                label: "Power Negotiation:"
                activeColor: "#666"
                inactiveColor: "#dddddd"
                textColor: "#666"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25
                anchors {
                    top: dataConfig.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 75
                }

                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    SGSegmentedButton{
                        text: qsTr("Dynamic")
                        checked: true  // Sets default checked button when exclusive
                    }

                    SGSegmentedButton{
                        text: qsTr("FCFS")
                    }

                    SGSegmentedButton{
                        text: qsTr("Priority")
                    }
                }
            }

            SGDivider {
                id: leftDiv1
                anchors {
                    top: powerNegotiation.bottom
                    topMargin: 10
                }
            }

            SGSegmentedButtonStrip {
                id: sleepMode
                label: "Sleep Mode:"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25
                anchors {
                    top: leftDiv1.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 20
                }

                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    SGSegmentedButton{
                        text: qsTr("Manual")
                        checked: true  // Sets default checked button when exclusive
                    }

                    SGSegmentedButton{
                        text: qsTr("Automatic")
                        onCheckedChanged: {
                            if (checked) {
                                manualSleep.enabled = false
                            } else {
                                manualSleep.enabled = true
                            }

                        }
                    }
                }
            }

            SGSegmentedButtonStrip {
                id: manualSleep
                label: "Manual Sleep:"
                textColor: "#666"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25
                anchors {
                    top: sleepMode.top
                    left: sleepMode.right
                    leftMargin: 50
                }

                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    SGSegmentedButton{
                        text: qsTr("ON")
                        checked: true  // Sets default checked button when exclusive
                    }

                    SGSegmentedButton{
                        text: qsTr("OFF")
                    }
                }
            }

            SGDivider {
                id: leftDiv2
                anchors {
                    top: sleepMode.bottom
                    topMargin: 10
                }
            }

            SGSegmentedButtonStrip {
                id: faultProtection
                anchors {
                    top: leftDiv2.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 89
                }
                label: "Fault Protection:"
                textColor: "#666"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25

                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    SGSegmentedButton{
                        text: qsTr("Shutdown")
                        checked: true  // Sets default checked button when exclusive
                    }

                    SGSegmentedButton{
                        text: qsTr("Retry")
                    }

                    SGSegmentedButton{
                        text: qsTr("None")
                    }
                }
            }

            SGSlider {
                id: inputFault
                label: "Fault when input below:"
                anchors {
                    left: margins1.left
                    leftMargin: 45
                    top: faultProtection.bottom
                    topMargin: 10
                    right: inputFaultInput.left
                    rightMargin: 10
                }
                from: 0
                to: 32
                startLabel: "0V"
                endLabel: "32V"
                value: 0
            }

            SGSubmitInfoBox {
                id: inputFaultInput
                buttonVisible: false
                anchors {
                    verticalCenter: inputFault.verticalCenter
                    right: parent.right
                }
                input: inputFault.value.toFixed(0)
                onApplied: inputFault.value = value
            }

            SGSlider {
                id: tempFault
                label: "Fault when temperature above:"
                anchors {
                    left: parent.left
                    top: inputFault.bottom
                    topMargin: 10
                    right: tempFaultInput.left
                    rightMargin: 10
                }
                from: 25
                to: 200
                startLabel: "25°C"
                endLabel: "200°C"
                value: 25
            }

            SGSubmitInfoBox {
                id: tempFaultInput
                buttonVisible: false
                anchors {
                    verticalCenter: tempFault.verticalCenter
                    right: parent.right
                }
                input: tempFault.value.toFixed(0)
                onApplied: tempFault.value = value
            }
        }

        SGLayoutDivider {
            position: "right"
        }
    }

    Item {
        id: rightColumn
        anchors {
            left: leftColumn.right
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }


        Item {
            id: margins2
            anchors {
                fill: parent
                margins: 15
            }

            Text {
                id: inputFoldback
                text: "<b>Input Foldback:</b>"
                font {
                    pixelSize: 16
                }
            }

            SGSwitch {
                id: inputFoldbackSwitch
                anchors {
                    right: parent.right
                    verticalCenter: inputFoldback.verticalCenter
                }
                checkedLabel: "On"
                uncheckedLabel: "Off"
                switchHeight: 20
                switchWidth: 46
            }

            SGSlider {
                id: foldbackLimit
                label: "Limit below:"
                value: 0
                anchors {
                    left: parent.left
                    leftMargin: 61
                    top: inputFoldback.bottom
                    topMargin: 10
                    right: foldbackLimitInput.left
                    rightMargin: 10
                }
                from: 0
                to: 32
                startLabel: "0V"
                endLabel: "32V"
            }

            SGSubmitInfoBox {
                id: foldbackLimitInput
                buttonVisible: false
                anchors {
                    verticalCenter: foldbackLimit.verticalCenter
                    right: parent.right
                }
                input: foldbackLimit.value.toFixed(0)
                onApplied: foldbackLimit.value = value
            }

            SGComboBox {
                id: limitOutput
                label: "Limit output power to:"
                model: ["45 W","stuff"]
                anchors {
                    left: parent.left
                    top: foldbackLimit.bottom
                    topMargin: 10
                }
            }

            SGDivider {
                id: div1
                anchors {
                    top: limitOutput.bottom
                    topMargin: 15
                }
            }

            Text {
                id: tempFoldback
                text: "<b>Temperature Foldback:</b>"
                font {
                    pixelSize: 16
                }
                anchors {
                    top: div1.bottom
                    topMargin: 15
                }
            }

            SGSwitch {
                id: tempFoldbackSwitch
                anchors {
                    right: parent.right
                    verticalCenter: tempFoldback.verticalCenter
                }
                checkedLabel: "On"
                uncheckedLabel: "Off"
                switchHeight: 20
                switchWidth: 46
            }

            SGSlider {
                id: foldbackTemp
                label: "Limit above:"
                anchors {
                    left: parent.left
                    leftMargin: 60
                    top: tempFoldback.bottom
                    topMargin: 10
                    right: foldbackTempInput.left
                    rightMargin: 10
                }
                from: 25
                to: 200
                startLabel: "25°C"
                endLabel: "200°C"
                value: 25
            }

            SGSubmitInfoBox {
                id: foldbackTempInput
                buttonVisible: false
                anchors {
                    verticalCenter: foldbackTemp.verticalCenter
                    right: parent.right
                }
                input: foldbackTemp.value.toFixed(0)
                onApplied: foldbackTemp.value = value
            }

            SGComboBox {
                id: limitOutput2
                label: "Limit output power to:"
                model: ["45 W","stuff"]
                anchors {
                    left: parent.left
                    top: foldbackTemp.bottom
                    topMargin: 10
                }
            }
        }
    }
}
