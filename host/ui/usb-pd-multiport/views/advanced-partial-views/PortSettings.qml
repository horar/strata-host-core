import QtQuick 2.9
import QtQuick.Layouts 1.3
import "qrc:/sgwidgets"

Item {
    id: root
    height: parent.height
    anchors {
        left: parent.left
        right: parent.right
    }

    Item {
        id: controlMargins
        anchors {
            fill: parent
            margins: 15
        }

        SGComboBox {
            id: maxPowerOutput
            label: "Max Power Output:"
            model: ["100 W", "example", "example"]
            anchors {
                left: parent.left
                top: parent.top
            }
        }

        SGSlider {
            id: currentLimit
            label: "Current Limit:"
            anchors {
                left: parent.left
                top: maxPowerOutput.bottom
                topMargin: 10
                right: currentLimitInput.left
                rightMargin: 10
            }

        }

        SGSubmitInfoBox {
            id: currentLimitInput
            buttonVisible: false
            anchors {
                verticalCenter: currentLimit.verticalCenter
                right: parent.right
            }
        }

        SGDivider {
            id: div1
            anchors {
                top: currentLimit.bottom
                topMargin: 15
            }
        }

        Text {
            id: cableCompensation
            text: "<b>Cable Compensation:</b>"
            font {
                pixelSize: 16
            }
            anchors {
                top: div1.bottom
                topMargin: 15
            }
        }

        SGSlider {
            id: increment
            label: "For every increment of:"
            anchors {
                left: parent.left
                top: cableCompensation.bottom
                topMargin: 10
                right: incrementInput.left
                rightMargin: 10
            }

        }

        SGSubmitInfoBox {
            id: incrementInput
            buttonVisible: false
            anchors {
                verticalCenter: increment.verticalCenter
                right: parent.right
            }
        }

        SGSlider {
            id: bias
            label: "Bias output by:"
            anchors {
                left: parent.left
                top: increment.bottom
                topMargin: 10
                right: biasInput.left
                rightMargin: 10
            }

        }

        SGSubmitInfoBox {
            id: biasInput
            buttonVisible: false
            anchors {
                verticalCenter: bias.verticalCenter
                right: parent.right
            }
        }


        SGDivider {
            id: div2
            height: 1
            anchors {
                top: bias.bottom
                topMargin: 15
            }
        }

        Text {
            id: advertisedVoltages
            text: "<b>Advertised Voltages:</b>"
            font {
                pixelSize: 16
            }
            anchors {
                top: div2.bottom
                topMargin: 15
            }
        }

        SGSegmentedButtonStrip {
            id: faultProtection
            anchors {
                left: advertisedVoltages.right
                leftMargin: 10
                verticalCenter: advertisedVoltages.verticalCenter
            }
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
                    text: qsTr("5V, 3A")
                }

                SGSegmentedButton{
                    text: qsTr("7V, 3A")
                }

                SGSegmentedButton{
                    text: qsTr("8V, 3A")
                }

                SGSegmentedButton{
                    text: qsTr("9V, 3A")
                    enabled: false
                }

                SGSegmentedButton{
                    text: qsTr("12V, 3A")
                    enabled: false
                }

                SGSegmentedButton{
                    text: qsTr("15V, 3A")
                    enabled: false
                }

                SGSegmentedButton{
                    text: qsTr("20V, 3A")
                    enabled: false
                }
            }
        }
    }
}
