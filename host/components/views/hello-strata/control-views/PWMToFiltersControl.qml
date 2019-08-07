import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

Rectangle {
    id: root

    clip:true

    property real minimumHeight
    property real minimumWidth

    signal zoom

    property real defaultMargin: 20
    property real defaultPadding: 20
    property real factor: Math.max(1,(hideHeader ? 0.8 : 1) * Math.min(root.height/minimumHeight,root.width/minimumWidth))

    // UI state & notification
    property string rc_mode: platformInterface.pwm_fil_ui_rc_mode
    property string lc_mode: platformInterface.pwm_fil_ui_lc_mode
    property real duty: platformInterface.pwm_fil_ui_duty
    property real freq: platformInterface.pwm_fil_ui_freq
    property var rc_out: platformInterface.pwm_fil_noti_rc_out
    property var lc_out: platformInterface.pwm_fil_noti_lc_out

    Component.onCompleted: {
        if (hideHeader) {
            Help.registerTarget(sgslider, "This slider will set the duty cycle of the PWM signal going to the filters.", 0, "helloStrata_PWMToFilters_Help")
            Help.registerTarget(freqbox, "The entry box sets the frequency. A frequency larger than 100kHz is recommended. Hit 'enter' or 'tab' to set the register.", 1, "helloStrata_PWMToFilters_Help")
            Help.registerTarget(rcsw, "This switch will switch the units on the gauge between volts and bits of the ADC reading.", 2, "helloStrata_PWMToFilters_Help")
            Help.registerTarget(lcsw, "This switch will switch the units on the gauge between volts and bits of the ADC reading.", 3, "helloStrata_PWMToFilters_Help")
        }
    }

    onRc_modeChanged: {
        rcsw.checked = rc_mode === "bits"
    }

    onLc_modeChanged: {
        lcsw.checked = lc_mode === "bits"
    }

    onDutyChanged: {
        sgslider.value = duty
    }

    onFreqChanged: {
        freqbox.text = freq.toString()
    }

    onRc_outChanged: {
        if (rc_mode === "volts") {
            rcVoltsGauge.value = rc_out.rc_out
        }
        else {
            rcBitsGauge.value = rc_out.rc_out
        }
    }

    onLc_outChanged: {
        if (lc_mode === "volts") {
            lcVoltsGauge.value = lc_out.lc_out
        }
        else {
            lcBitsGauge.value = lc_out.lc_out
        }
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
                text: "<b>" + qsTr("PWM to Filters") + "</b>"
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

        ColumnLayout {
            id: content
            Layout.maximumWidth: hideHeader ? 0.8 * root.width : root.width - defaultPadding * 2
            Layout.alignment: Qt.AlignCenter
            spacing: 5 * factor

            RowLayout {
                SGAlignedLabel {
                    target: rcsw
                    text: "<b>RC_OUT</b>"
                    fontSizeMultiplier: factor
                    SGSwitch {
                        id: rcsw
                        height: 25 * factor
                        fontSizeMultiplier: factor
                        checkedLabel: "Bits"
                        uncheckedLabel: "Volts"
                        onClicked: {
                            platformInterface.pwm_fil_ui_rc_mode = checked ? "bits" : "volts"
                            platformInterface.pwm_fil_set_rc_out_mode.update(checked ? "bits" : "volts")
                        }
                    }
                }

                Item {
                    id: rcGauge
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.minimumHeight: 60
                    Layout.minimumWidth: 60
                    Layout.maximumHeight: width
                    SGCircularGauge {
                        id: rcVoltsGauge
                        visible: !rcsw.checked
                        anchors.fill: parent
                        unitText: "V"
                        unitTextFontSizeMultiplier: factor
                        value: 1
                        tickmarkStepSize: 0.5
                        tickmarkDecimalPlaces: 2
                        minimumValue: 0
                        maximumValue: 3.3
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    SGCircularGauge {
                        id: rcBitsGauge
                        visible: rcsw.checked
                        anchors.fill: parent
                        unitText: "Bits"
                        unitTextFontSizeMultiplier: factor
                        value: 0
                        tickmarkStepSize: 512
                        minimumValue: 0
                        maximumValue: 4096
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.maximumHeight: Math.max(rcGauge.height,lcGauge.height)
                    Layout.preferredWidth: 1
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 20 * factor
                    Layout.rightMargin: 20 * factor
                    color: "lightgrey"
                }

                SGAlignedLabel {
                    target: lcsw
                    text: "<b>LC_OUT</b>"
                    fontSizeMultiplier: factor
                    SGSwitch {
                        id: lcsw
                        height: 25 * factor
                        fontSizeMultiplier: factor
                        checkedLabel: "Bits"
                        uncheckedLabel: "Volts"
                        onClicked: {
                            platformInterface.pwm_fil_ui_lc_mode = checked ? "bits" : "volts"
                            platformInterface.pwm_fil_set_lc_out_mode.update(checked ? "bits" : "volts")
                        }
                    }
                }

                Item {
                    id: lcGauge
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.minimumHeight: 60
                    Layout.minimumWidth: 60
                    Layout.maximumHeight: width
                    SGCircularGauge {
                        id: lcVoltsGauge
                        visible: !lcsw.checked
                        anchors.fill: parent
                        unitText: "V"
                        unitTextFontSizeMultiplier: factor
                        value: 1
                        tickmarkStepSize: 0.5
                        tickmarkDecimalPlaces: 2
                        minimumValue: 0
                        maximumValue: 3.3
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    SGCircularGauge {
                        id: lcBitsGauge
                        visible: lcsw.checked
                        anchors.fill: parent
                        unitText: "Bits"
                        unitTextFontSizeMultiplier: factor
                        value: 0
                        tickmarkStepSize: 512
                        minimumValue: 0
                        maximumValue: 4096
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            SGAlignedLabel {
                target: sgslider
                text:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
                fontSizeMultiplier: factor
                SGSlider {
                    id: sgslider
                    textColor: "black"
                    stepSize: 0.01
                    from: 0
                    to: 100
                    startLabel: "0"
                    endLabel: "100 %"
                    toolTipDecimalPlaces: 2
                    width: content.width
                    fontSizeMultiplier: factor
                    onUserSet: {
                        platformInterface.pwm_fil_ui_duty = value
                        platformInterface.pwm_fil_set_duty.update(value/100)
                    }
                }
            }

            SGAlignedLabel {
                target: freqbox
                text: "<b>" + qsTr("PWM Frequency") + "</b>"
                fontSizeMultiplier: factor
                alignment: SGAlignedLabel.SideLeftCenter
                Layout.bottomMargin: 10 * factor
                SGInfoBox {
                    id: freqbox
                    readOnly: false
                    textColor: "black"
                    height: 30 * factor
                    width: 130 * factor
                    unit: "kHz"
                    text: root.freq.toString()
                    fontSizeMultiplier: factor
                    placeholderText: "0.0001 - 1000"
                    validator: DoubleValidator {
                        bottom: 0.0001
                        top: 1000
                    }
                    onEditingFinished: {
                        if (acceptableInput) {
                            platformInterface.pwm_fil_ui_freq = Number(text)
                            platformInterface.pwm_fil_set_freq.update(Number(text))
                        }
                    }
                    onAccepted: platformInterface.pwm_fil_set_freq.update(Number(text))
                    KeyNavigation.tab: root
                }
            }
        }
    }
}
