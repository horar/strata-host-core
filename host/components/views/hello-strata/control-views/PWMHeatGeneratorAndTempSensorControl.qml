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
    property real factor: (hideHeader ? 0.8 : 1) * Math.min(root.height/minimumHeight,root.width/minimumWidth)

    // UI state & notification
    property real duty: platformInterface.i2c_temp_ui_duty
    property var alert: platformInterface.i2c_temp_noti_alert
    property var tempValue: platformInterface.i2c_temp_noti_value

    onDutyChanged: {
        pwmslider.value = duty*100
    }

    onAlertChanged: {
        alertLED.status = alert.value ? SGStatusLight.Red : SGStatusLight.Off
    }

    onTempValueChanged: {
        gauge.value = tempValue.value
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
            Layout.margins: defaultMargin
            Layout.alignment: Qt.AlignTop

            Text {
                id: name
                text: "<b>" + qsTr("PWM Heat Generator") + "</b>"
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

        RowLayout {
            id: content
            Layout.leftMargin: defaultMargin
            Layout.rightMargin: defaultMargin
            Layout.maximumWidth: (hideHeader ? 0.8 : 1) * parent.width - defaultPadding * 2
            Layout.alignment: Qt.AlignCenter
            spacing: 10 * factor

            ColumnLayout {
                id: leftContent
                spacing: defaultPadding
                Layout.fillWidth: true
                Layout.maximumWidth: (hideHeader ? 0.8 : 1) * root.width * 0.5
                Layout.alignment: Qt.AlignCenter
                SGAlignedLabel {
                    id: sliderLabel
                    target: pwmslider
                    text:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
                    fontSizeMultiplier: factor
                    SGSlider {
                        id: pwmslider
                        textColor: "black"
                        stepSize: 0.01
                        from: 0
                        to: 100
                        startLabel: "0"
                        endLabel: "100 %"
                        toolTipDecimalPlaces: 2
                        width: leftContent.width
                        fontSizeMultiplier: factor
                        onUserSet: {
                            platformInterface.i2c_temp_ui_duty = value/100
                            platformInterface.i2c_temp_set_duty.update(value/100)
                        }
                    }
                }

                SGAlignedLabel {
                    target: alertLED
                    text: "<b>" + qsTr("OS/ALERT") + "</b>"
                    Layout.alignment: Qt.AlignHCenter
                    fontSizeMultiplier: factor
                    alignment: SGAlignedLabel.SideTopCenter
                    SGStatusLight {
                        id: alertLED
                        width: 40 * factor
                    }
                }
            }

            SGCircularGauge {
                id: gauge
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(width, root.height - header.height - 2 * defaultMargin)
                Layout.alignment: Qt.AlignCenter
                unitText: "°C"
                value: 30
                tickmarkStepSize: 10
                minimumValue: -55
                maximumValue: 125
            }
        }
    }
}
