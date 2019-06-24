import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 0.9

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root

    clip:true

    property real minimumHeight
    property real minimumWidth

    signal zoom

    property real defaultMargin: 20
    property real defaultPadding: 20
    property real factor: Math.min(root.height/minimumHeight,root.width/minimumWidth)

    // UI state & notification
    property string rc_mode: platformInterface.pwm_fil_ui_rc_mode
    property string lc_mode: platformInterface.pwm_fil_ui_lc_mode
    property real duty: platformInterface.pwm_fil_ui_duty
    property real freq: platformInterface.pwm_fil_ui_freq
    property var rc_out: platformInterface.pwm_fil_noti_rc_out
    property var lc_out: platformInterface.pwm_fil_noti_lc_out

    onRc_modeChanged: {
        rcsw.checked = rc_mode === "bits"
    }

    onLc_modeChanged: {
        lcsw.checked = lc_mode === "bits"
    }

    onDutyChanged: {
        sgslider.value = duty*100
    }

    onFreqChanged: {
        freqbox.value = freq
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
                text: "<b>" + qsTr("PWM Filters") + "</b>"
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
                spacing: 5
                width: parent.width
                padding: defaultPadding

                Row {
                    spacing: 20
                    Column {
                        spacing: 5
                        Item {
                            width: Math.min(content.height,content.width)*0.4
                            height: Math.min(content.height,content.width)*0.4
                            SGCircularGauge {
                                id: rcVoltsGauge
                                visible: true
                                anchors.fill: parent
                                unitLabel: "V"
                                value: 1
                                tickmarkStepSize: 0.5
                                minimumValue: 0
                                maximumValue: 3.3
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            SGCircularGauge {
                                id: rcBitsGauge
                                visible: false
                                anchors.fill: parent
                                unitLabel: "Bits"
                                value: 0
                                tickmarkStepSize: 512
                                minimumValue: 0
                                maximumValue: 4096
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                        SGSwitch {
                            id: rcsw
                            label: "RC_OUT"
                            checkedLabel: "Bits"
                            uncheckedLabel: "Volts"
                            switchHeight: 20
                            switchWidth: 50
                            onCheckedChanged: {
                                if (this.checked) {
                                    if (platformInterface.pwm_fil_ui_rc_mode !== "bits") {
                                        platformInterface.pwm_fil_set_rc_out_mode.update("bits")
                                        platformInterface.pwm_fil_ui_rc_mode = "bits"
                                    }
                                    rcBitsGauge.visible = true
                                    rcVoltsGauge.visible = false
                                }
                                else {
                                    if (platformInterface.pwm_fil_ui_rc_mode !== "volts") {
                                        platformInterface.pwm_fil_set_rc_out_mode.update("volts")
                                        platformInterface.pwm_fil_ui_rc_mode = "volts"
                                    }
                                    rcVoltsGauge.visible = true
                                    rcBitsGauge.visible = false
                                }
                            }
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    Column {
                        spacing: 5
                        Item {
                            width: Math.min(content.height,content.width)*0.4
                            height: Math.min(content.height,content.width)*0.4
                            SGCircularGauge {
                                id: lcVoltsGauge
                                visible: true
                                anchors.fill: parent
                                unitLabel: "V"
                                value: 1
                                tickmarkStepSize: 0.5
                                minimumValue: 0
                                maximumValue: 3.3
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            SGCircularGauge {
                                id: lcBitsGauge
                                visible: false
                                anchors.fill: parent
                                unitLabel: "Bits"
                                value: 0
                                tickmarkStepSize: 512
                                minimumValue: 0
                                maximumValue: 4096
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                        SGSwitch {
                            id: lcsw
                            label: "LC_OUT"
                            checkedLabel: "Bits"
                            uncheckedLabel: "Volts"
                            switchHeight: 20
                            switchWidth: 50
                            onCheckedChanged: {
                                if (this.checked) {
                                    if (platformInterface.pwm_fil_ui_lc_mode !== "bits") {
                                        platformInterface.pwm_fil_set_lc_out_mode.update("bits")
                                        platformInterface.pwm_fil_ui_lc_mode = "bits"
                                    }
                                    lcBitsGauge.visible = true
                                    lcVoltsGauge.visible = false
                                }
                                else {
                                    if (platformInterface.pwm_fil_ui_lc_mode !== "volts") {
                                        platformInterface.pwm_fil_set_lc_out_mode.update("volts")
                                        platformInterface.pwm_fil_ui_lc_mode = "volts"
                                    }
                                    lcVoltsGauge.visible = true
                                    lcBitsGauge.visible = false
                                }
                            }
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                SGSlider {
                    id: sgslider
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
                        if (platformInterface.pwm_fil_ui_duty !== value/100) {
                            platformInterface.pwm_fil_set_duty.update(value/100)
                            platformInterface.pwm_fil_ui_duty = value/100
                        }
                    }
                }

                SGSubmitInfoBox {
                    id: freqbox
                    label: "<b>" + qsTr("PWM Frequency") + "</b>"
                    textColor: "black"
                    labelLeft: true
                    infoBoxWidth: 100
                    showButton: true
                    buttonText: qsTr("Apply")
                    unit: "kHz"
                    value: "1"
                    placeholderText: "0.0001 - 1000"
                    validator: DoubleValidator {
                        bottom: 0.0001
                        top: 1000
                    }
                    onValueChanged: {
                        if (platformInterface.pwm_fil_ui_freq !== value)
                            platformInterface.pwm_fil_ui_freq = value
                    }
                    onApplied: platformInterface.pwm_fil_set_freq.update(value)
                }

                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
