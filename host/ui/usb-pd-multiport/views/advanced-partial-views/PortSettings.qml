import QtQuick 2.9
import "qrc:/sgwidgets"

Item {
    id: root
    height: 400
    anchors {
        left: parent.left
        right: parent.right
    }

    Item {
        id: controlMargins
        anchors {
            fill: parent
            margins: 20
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

        Rectangle {
            id: div1
            height: 1
            width: parent.width
            color: "#ddd"
            anchors {
                top: currentLimit.bottom
                topMargin: 20
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
                topMargin: 20
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


        Rectangle {
            id: div2
            height: 1
            width: parent.width
            color: "#ddd"
            anchors {
                top: bias.bottom
                topMargin: 20
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
                topMargin: 20
            }
        }
    }
}
