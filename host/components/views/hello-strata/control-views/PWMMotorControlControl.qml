import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 0.9

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root

    property real minimumHeight
    property real minimumWidth

    signal zoom

    property real defaultMargin: 20
    property real defaultPadding: 20
    property real factor: Math.min(root.height/minimumHeight,root.width/minimumWidth)

    // UI state
    property real duty: platformInterface.pwm_mot_ui_duty
    property bool forward: platformInterface.pwm_mot_ui_forward
    property bool enable: platformInterface.pwm_mot_ui_enable

    onDutyChanged: {
        pwmslider.value = duty*100
    }

    onForwardChanged: {
        combobox.currentIndex = forward ? 0 : 1
    }

    onEnableChanged: {
        toggleswitch.checked = enable
    }

    // hide in tab view
    property bool hideHeader: false
    onHideHeaderChanged: {
        if (hideHeader) {
            header.visible = false
            content.anchors.top = container.top
            container.border.width = 0
        }
        else {
            header.visible = true
            content.anchors.top = header.bottom
            container.border.width = 1
        }
    }

    Rectangle {
        id: container
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
                text: qsTr("Maximize")
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
                    label:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
                    textColor: "black"
                    labelLeft: false
                    width: parent.width-2*defaultPadding
                    stepSize: 0.01
                    from: 0
                    to: 100
                    startLabel: "0"
                    endLabel: "100 %"
                    toolTipDecimalPlaces: 2
                    onValueChanged: {
                        if (platformInterface.pwm_mot_ui_duty !== value/100) {
                            platformInterface.pwm_mot_set_duty.update(value/100)
                            platformInterface.pwm_mot_ui_duty = value/100
                        }
                    }
                }

                Row {
                    spacing: defaultPadding
                    SGComboBox {
                        id: combobox
                        label: "<b>" + qsTr("Direction") + "</b>"
                        labelLeft: false
                        model: [qsTr("Forward"), qsTr("Reverse")]
                        anchors.bottom: parent.bottom
                        onCurrentTextChanged: {
                            if (platformInterface.pwm_mot_ui_forward !== (currentText === "Forward")) {
                                platformInterface.pwm_mot_set_direction.update(currentText === "Forward")
                                platformInterface.pwm_mot_ui_forward = currentText === "Forward"
                            }
                        }
                    }

                    Button {
                        id: brakebtn
                        text: qsTr("Brake")
                        anchors.bottom: parent.bottom
                        onPressed: platformInterface.pwm_mot_brake.update(true)
                        onReleased: platformInterface.pwm_mot_brake.update(false)
                    }

                    SGSwitch {
                        id: toggleswitch
                        label: "<b>" + qsTr("Motor Enable") + "</b>"
                        labelLeft: false
                        switchHeight: 32
                        switchWidth: 65
                        checkedLabel: qsTr("On")
                        uncheckedLabel: qsTr("Off")
                        anchors.bottom: parent.bottom
                        onCheckedChanged: {
                            if (platformInterface.pwm_mot_ui_enable !== checked) {
                                platformInterface.pwm_mot_enable.update(checked === true)
                                platformInterface.pwm_mot_ui_enable = checked
                            }
                        }
                    }
                }

                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
