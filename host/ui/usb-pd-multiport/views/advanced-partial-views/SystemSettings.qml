import QtQuick 2.9
import QtQuick.Layouts 1.3
import "qrc:/sgwidgets"

Item {
    id: root
    height: parent.height
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
                activeColorTop: "#666"
                activeColorBottom: "#666"
                inactiveColorTop: "#dddddd"
                inactiveColorBottom: "#dddddd"
                textColor: "#666"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25

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
                id: faultProtection
                anchors {
                    top: dataConfig.bottom
                    topMargin: 10
                }
                label: "Fault Protection:"
                activeColorTop: "#666"
                activeColorBottom: "#666"
                inactiveColorTop: "#dddddd"
                inactiveColorBottom: "#dddddd"
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
                label: "Fault when input falls below:"
                anchors {
                    left: parent.left
                    top: faultProtection.bottom
                    topMargin: 10
                    right: inputFaultInput.left
                    rightMargin: 10
                }
            }

            SGSubmitInfoBox {
                id: inputFaultInput
                buttonVisible: false
                anchors {
                    verticalCenter: inputFault.verticalCenter
                    right: parent.right
                }
            }

            SGSlider {
                id: tempFault
                label: "Fault when temperature reaches:"
                anchors {
                    left: parent.left
                    top: inputFault.bottom
                    topMargin: 10
                    right: tempFaultInput.left
                    rightMargin: 10
                }
            }

            SGSubmitInfoBox {
                id: tempFaultInput
                buttonVisible: false
                anchors {
                    verticalCenter: tempFault.verticalCenter
                    right: parent.right
                }
            }


            SGSegmentedButtonStrip {
                id: powerNegotiation
                label: "Power Negotiation:"
                activeColorTop: "#666"
                activeColorBottom: "#666"
                inactiveColorTop: "#dddddd"
                inactiveColorBottom: "#dddddd"
                textColor: "#666"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25
                anchors {
                    top: tempFault.bottom
                    topMargin: 10
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

            SGSegmentedButtonStrip {
                id: sleepMode
                label: "Sleep Mode:"
                activeColorTop: "#666"
                activeColorBottom: "#666"
                inactiveColorTop: "#dddddd"
                inactiveColorBottom: "#dddddd"
                textColor: "#666"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25
                anchors {
                    top: powerNegotiation.bottom
                    topMargin: 10
                }

                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    SGSegmentedButton{
                        text: qsTr("Manual")
                        checked: true  // Sets default checked button when exclusive
                    }

                    SGSegmentedButton{
                        text: qsTr("Automatic")
                    }
                }
            }

            SGSegmentedButtonStrip {
                id: manualSleep
                label: "Manual Sleep:"
                activeColorTop: "#666"
                activeColorBottom: "#666"
                inactiveColorTop: "#dddddd"
                inactiveColorBottom: "#dddddd"
                textColor: "#666"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25
                anchors {
                    top: sleepMode.bottom
                    topMargin: 10
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
                label: "Start limiting at:"
                anchors {
                    left: parent.left
                    top: inputFoldback.bottom
                    topMargin: 10
                    right: foldbackLimitInput.left
                    rightMargin: 10
                }
            }

            SGSubmitInfoBox {
                id: foldbackLimitInput
                buttonVisible: false
                anchors {
                    verticalCenter: foldbackLimit.verticalCenter
                    right: parent.right
                }
            }

            SGComboBox {
                id: limitOutput
                label: "Limit board output to:"
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
                label: "When board temperature reaches:"
                anchors {
                    left: parent.left
                    top: tempFoldback.bottom
                    topMargin: 10
                    right: foldbackTempInput.left
                    rightMargin: 10
                }
            }

            SGSubmitInfoBox {
                id: foldbackTempInput
                buttonVisible: false
                anchors {
                    verticalCenter: foldbackTemp.verticalCenter
                    right: parent.right
                }
            }

            SGComboBox {
                id: limitOutput2
                label: "Limit board output to:"
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
