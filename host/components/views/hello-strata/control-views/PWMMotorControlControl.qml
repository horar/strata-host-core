import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

SGResponsiveScrollView {
    id: root

    minimumHeight: 660*0.3
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
                text: "<b>" + qsTr("PWM Motor Control") + "</b>"
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
                spacing: defaultPadding
                width: parent.width
                padding: defaultPadding

                SGSlider {
                    id: pwmslider
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
                    onValueChanged: platformInterface.driveMotor.update(value/100, combobox.currentText === "Forward")
                }

                Row {
                    spacing: defaultPadding
                    SGComboBox {
                        id: combobox
                        label: "<b>" + qsTr("Direction") + "</b>"
                        labelLeft: false
                        model: [qsTr("Forward"), qsTr("Reverse")]
                        anchors.bottom: parent.bottom
                        onCurrentTextChanged: platformInterface.driveMotor.update(pwmslider.value/100, currentText === "Forward")
                    }

                    Button {
                        id: brakebtn
                        text: qsTr("Brake")
                        anchors.bottom: parent.bottom
                        onPressed: platformInterface.brakeMotor.update(true)
                        onReleased: platformInterface.brakeMotor.update(false)
                    }

                    SGSwitch {
                        id: toggleswitch
                        checkedLabel: qsTr("On")
                        uncheckedLabel: qsTr("Off")
                        anchors.bottom: parent.bottom
                        onCheckedChanged: platformInterface.enableMotor.update(checked === true)
                    }
                }

                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
