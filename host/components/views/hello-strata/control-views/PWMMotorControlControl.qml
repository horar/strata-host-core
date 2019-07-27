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

        RowLayout {
            id: header
            Layout.preferredHeight: Math.max(name.height, btn.height)
            Layout.fillWidth: true
            Layout.margins: defaultMargin

            Text {
                id: name
                text: "<b>" + qsTr("PWM Motor Control") + "</b>"
                font.pixelSize: 14*factor
                color:"black"
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                wrapMode: Text.WordWrap
            }

            Button {
                id: btn
                text: qsTr("Maximize")
                Layout.preferredHeight: btnText.contentHeight+6*factor
                Layout.preferredWidth: btnText.contentWidth+20*factor
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

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

        ColumnLayout {
            id: content
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: hideHeader ? parent.width/2 : parent.width - defaultPadding * 2
            Layout.alignment: Qt.AlignCenter
            spacing: 10 * factor

            SGAlignedLabel {
                target: pwmslider
                text:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
                SGSlider {
                    id: pwmslider
                    textColor: "black"
                    stepSize: 0.01
                    from: 0
                    to: 100
                    startLabel: "0"
                    endLabel: "100 %"
                    toolTipDecimalPlaces: 2
                    width: content.width
                    onUserSet: {
                        platformInterface.pwm_mot_set_duty.update(value/100)
                        platformInterface.pwm_mot_ui_duty = value/100 // need to remove
                    }
                }
            }

            RowLayout {
                spacing: defaultPadding
                SGAlignedLabel {
                    target: combobox
                    text: "<b>" + qsTr("Direction") + "</b>"
                    SGComboBox {
                        id: combobox
                        model: [qsTr("Forward"), qsTr("Reverse")]
                        height: 32
                        onActivated: { // wait for pull request from David
                            platformInterface.pwm_mot_set_direction.update(model[index] === "Forward")
                            platformInterface.pwm_mot_ui_forward = model[index] === "Forward" // need to remove
                        }
                    }
                }

                Button {
                    id: brakebtn
                    text: qsTr("Brake")
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignBottom
                    onPressed: platformInterface.pwm_mot_brake.update(true)
                    onReleased: platformInterface.pwm_mot_brake.update(false)
                }

                SGAlignedLabel {
                    target: toggleswitch
                    text: "<b>" + qsTr("Motor Enable") + "</b>"
                    SGSwitch {
                        id: toggleswitch
                        height: 32
                        checkedLabel: qsTr("On")
                        uncheckedLabel: qsTr("Off")
                        anchors.bottom: parent.bottom
                        onClicked: {
                            platformInterface.pwm_mot_enable.update(checked === true)
                            platformInterface.pwm_mot_ui_enable = checked // need to remove
                        }
                    }
                }
            }
        }
    }
}
