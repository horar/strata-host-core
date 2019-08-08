import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

Rectangle {
    id: root

    property real minimumHeight
    property real minimumWidth

    signal zoom

    property real defaultMargin: 20
    property real defaultPadding: 20
    property real factor: Math.max(1,(hideHeader ? 0.6 : 1) * Math.min(root.height/minimumHeight,root.width/minimumWidth))

    // UI state
    property real duty: platformInterface.pwm_mot_ui_duty
    property string control: platformInterface.pwm_mot_ui_control
    property bool enable: platformInterface.pwm_mot_ui_enable

    Component.onCompleted: {
        if (hideHeader) {
            Help.registerTarget(root, "None", 0, "helloStrata_PWMMotorControl_Help")
        }
    }

    onDutyChanged: {
        pwmslider.value = duty
    }

    onControlChanged: {
        combobox.currentIndex = combobox.model.indexOf(control)
    }

    onEnableChanged: {
        toggleswitch.checked = enable
    }

    // hide in tab view
    property bool hideHeader: false
    onHideHeaderChanged: {
        if (hideHeader) {
            header.visible = false
            border.width = 0
        }
        else {
            header.visible = true
            border.width = 1
        }
    }

    border {
        width: 1
        color: "lightgrey"
    }

    ColumnLayout {
        id: container
        anchors.fill:parent
        spacing: 0

        RowLayout {
            id: header
            Layout.alignment: Qt.AlignTop

            Text {
                id: name
                text: "<b>" + qsTr("PWM Motor Control") + "</b>"
                font.pixelSize: 14*factor
                color:"black"
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.margins: defaultMargin * factor
                wrapMode: Text.WordWrap
            }

            Button {
                id: btn
                text: qsTr("Maximize")
                Layout.preferredHeight: btnText.contentHeight+6*factor
                Layout.preferredWidth: btnText.contentWidth+20*factor
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.margins: defaultMargin * factor

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
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: hideHeader ? 0.6 * root.width : root.width - defaultPadding * 2
            Layout.alignment: Qt.AlignCenter
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10 * factor
                SGAlignedLabel {
                    target: pwmslider
                    text:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
                    fontSizeMultiplier: factor
                    SGSlider {
                        id: pwmslider
                        textColor: "black"
                        stepSize: 1
                        from: 0
                        to: 100
                        startLabel: "0"
                        endLabel: "100 %"
                        width: content.width
                        fontSizeMultiplier: factor
                        onUserSet: {
                            platformInterface.pwm_mot_ui_duty = value
                            platformInterface.pwm_mot_set_duty.update(value/100)
                        }
                    }
                }

                RowLayout {
                    spacing: defaultPadding * factor
                    SGAlignedLabel {
                        target: combobox
                        text: "<b>" + qsTr("Motor Control") + "</b>"
                        fontSizeMultiplier: factor
                        SGComboBox {
                            id: combobox
                            model: [qsTr("Forward"), qsTr("Brake"), qsTr("Reverse")]
                            height: 30 * factor
                            fontSizeMultiplier: factor
                            onActivated: {
                                platformInterface.pwm_mot_ui_control = model[index]
                                platformInterface.pwm_mot_set_control.update(model[index])
                            }
                        }
                    }

                    SGAlignedLabel {
                        target: toggleswitch
                        text: "<b>" + qsTr("Motor Enable") + "</b>"
                        fontSizeMultiplier: factor
                        SGSwitch {
                            id: toggleswitch
                            height: 30 * factor
                            checkedLabel: qsTr("On")
                            uncheckedLabel: qsTr("Off")
                            anchors.bottom: parent.bottom
                            fontSizeMultiplier: factor
                            onClicked: {
                                platformInterface.pwm_mot_ui_enable = checked
                                platformInterface.pwm_mot_enable.update(checked === true)
                            }
                        }
                    }
                }
            }
        }
    }
}
