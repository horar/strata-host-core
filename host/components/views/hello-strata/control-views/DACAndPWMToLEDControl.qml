import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

SGResponsiveScrollView {
    id: root

    minimumHeight: 660*0.4
    minimumWidth: 850/3

    signal zoom

    property var defaultMargin: 20
    property var defaultPadding: 20
    property var factor: Math.min(root.height/minimumHeight,root.width/minimumWidth)

    Rectangle {
        id: container
        parent: root.contentItem
        anchors.fill:parent
        border {
            width: 1
            color: "lightgrey"
        }

        Item {
            id: header
            anchors {
                top:parent.top
                left:parent.left
                right:parent.right
            }
            height: Math.max(name.height,btn.height)

            Text {
                id: name
                text: "<b>" + qsTr("DAC and PWM to LED") + "</b>"
                font.pixelSize: 14*factor
                color:"black"
                anchors.left: parent.left
                padding: defaultPadding

                width: parent.width - btn.width - defaultPadding
                wrapMode: Text.WordWrap
            }

            Button {
                id: btn
                text: qsTr("Zoom")
                anchors {
                    top: parent.top
                    right: parent.right
                    margins: defaultMargin
                }

                height: btnText.contentHeight+6*factor
                width: btnText.contentWidth+20*factor

                contentItem: Text {
                    id: btnText
                    text: btn.text
                    font.pixelSize: 10*factor
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: zoom()
            }
        }

        Item {
            id: content
            anchors {
                top:header.bottom
                bottom: parent.bottom
                left:parent.left
                right:parent.right
            }

            Column {
                spacing: 10
                width: parent.width
                padding: defaultPadding

                SGSlider {
                    label:"<b>DAC</b>"
                    textColor: "black"
                    labelLeft: false
                    width: parent.width-2*defaultPadding
                    stepSize: 0.001
                    from: 0
                    to: 3.3
                    startLabel: "0"
                    endLabel: "3.3 V"
                    toolTipDecimalPlaces: 3
                    onValueChanged: platformInterface.setDacLed.update(value)
                }

                SGSlider {
                    label:"<b>PWM</b>"
                    textColor: "black"
                    labelLeft: false
                    width: parent.width-2*defaultPadding
                    stepSize: 0.01
                    from: 0
                    to: 100
                    startLabel: "0"
                    endLabel: "100 %"
                    toolTipDecimalPlaces: 2
                    onValueChanged: platformInterface.setPwmLedDuty.update(value/100)
                }

                SGSubmitInfoBox {
                    label: "<b>" + qsTr("Frequency of the PWM") + "</b>"
                    textColor: "black"
                    labelLeft: false
                    infoBoxWidth: 100
                    showButton: true
                    buttonText: qsTr("Apply")
                    unit: "Hz"
                    placeholderText: "0.1 - 1000000"
                    validator: DoubleValidator {
                        bottom: 0.1
                        top: 1000000
                    }
                    onApplied: platformInterface.setPwmLedFreq.update(value)
                }

                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
