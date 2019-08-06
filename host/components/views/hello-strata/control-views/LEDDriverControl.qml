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
    property real factor: Math.max(1,(hideHeader ? 0.8 : 1) * Math.min(root.height/minimumHeight,root.width/minimumWidth))

    property real lightSizeValue: 20*factor
    property real switchHeightValue: 20*factor
    property real switchWidthValue: 35*factor

    // UI state
    property bool y1: platformInterface.led_driver_ui_y1
    property bool y2: platformInterface.led_driver_ui_y2
    property bool y3: platformInterface.led_driver_ui_y3
    property bool y4: platformInterface.led_driver_ui_y4

    property bool r1: platformInterface.led_driver_ui_r1
    property bool r2: platformInterface.led_driver_ui_r2
    property bool r3: platformInterface.led_driver_ui_r3
    property bool r4: platformInterface.led_driver_ui_r4

    property bool b1: platformInterface.led_driver_ui_b1
    property bool b2: platformInterface.led_driver_ui_b2
    property bool b3: platformInterface.led_driver_ui_b3
    property bool b4: platformInterface.led_driver_ui_b4

    property bool g1: platformInterface.led_driver_ui_g1
    property bool g2: platformInterface.led_driver_ui_g2
    property bool g3: platformInterface.led_driver_ui_g3
    property bool g4: platformInterface.led_driver_ui_g4

    property int state: platformInterface.led_driver_ui_state
    property real freq0: platformInterface.led_driver_ui_freq0
    property real pwm0: platformInterface.led_driver_ui_pwm0
    property real freq1: platformInterface.led_driver_ui_freq1
    property real pwm1: platformInterface.led_driver_ui_pwm1

    onY1Changed: switch1.checked = y1
    onY2Changed: switch2.checked = y2
    onY3Changed: switch3.checked = y3
    onY4Changed: switch4.checked = y4

    onR1Changed: switch5.checked = r1
    onR2Changed: switch6.checked = r2
    onR3Changed: switch7.checked = r3
    onR4Changed: switch8.checked = r4

    onB1Changed: switch9.checked = b1
    onB2Changed: switch10.checked = b2
    onB3Changed: switch11.checked = b3
    onB4Changed: switch12.checked = b4

    onG1Changed: switch13.checked = g1
    onG2Changed: switch14.checked = g2
    onG3Changed: switch15.checked = g3
    onG4Changed: switch16.checked = g4

    onStateChanged: {
        if (state === 1) onstate.checked = true
        if (state === 2) blink0.checked = true
        if (state === 3) blink1.checked = true
    }

    onFreq0Changed: freqbox0.text = freq0.toString()
    onPwm0Changed: pwmbox0.text = (pwm0*100).toString()
    onFreq1Changed: freqbox1.text = freq1.toString()
    onPwm1Changed: pwmbox1.text = (pwm1*100).toString()

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

    ButtonGroup { id: radioGroup }

    ColumnLayout {
        id: container
        anchors.fill:parent
        spacing: 0

        RowLayout {
            id: header
            Layout.alignment: Qt.AlignTop

            Text {
                id: name
                text: "<b>" + qsTr("LED Driver") + "</b>"
                font.pixelSize: 14*factor
                color:"black"
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
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
            Layout.maximumWidth: hideHeader ? 0.8 * root.width : root.width - defaultPadding * 2
            Layout.alignment: Qt.AlignCenter

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5 * factor

                RowLayout {
                    id: ledcontrol
                    spacing: 100*factor
                    Layout.alignment: Qt.AlignLeft

                    GridLayout {
                        rowSpacing: 5*factor
                        columnSpacing: 5*factor
                        rows: 4
                        columns: 4

                        SGSwitch {
                            id: switch1
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_y1 = this.checked
                                platformInterface.set_led_driver.update(15,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch2
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_y2 = this.checked
                                platformInterface.set_led_driver.update(14,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch3
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_y3 = this.checked
                                platformInterface.set_led_driver.update(13,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch4
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_y4 = this.checked
                                platformInterface.set_led_driver.update(12,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch5
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_r1 = this.checked
                                platformInterface.set_led_driver.update(11,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch6
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_r2 = this.checked
                                platformInterface.set_led_driver.update(10,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch7
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_r3 = this.checked
                                platformInterface.set_led_driver.update(9,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch8
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_r4 = this.checked
                                platformInterface.set_led_driver.update(8,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch9
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_b1 = this.checked
                                platformInterface.set_led_driver.update(7,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch10
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_b2 = this.checked
                                platformInterface.set_led_driver.update(6,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch11
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_b3 = this.checked
                                platformInterface.set_led_driver.update(5,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch12
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_b4 = this.checked
                                platformInterface.set_led_driver.update(4,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch13
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_g1 = this.checked
                                platformInterface.set_led_driver.update(3,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch14
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_g2 = this.checked
                                platformInterface.set_led_driver.update(2,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch15
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_g3 = this.checked
                                platformInterface.set_led_driver.update(1,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch16
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onClicked: {
                                platformInterface.led_driver_ui_g4 = this.checked
                                platformInterface.set_led_driver.update(0,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }
                    }

                    GridLayout {
                        rowSpacing: 5*factor
                        columnSpacing: 5*factor
                        rows: 4
                        columns: 4

                        SGStatusLight {
                            id: light1
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch1.checked ? SGStatusLight.Yellow : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light2
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch2.checked ? SGStatusLight.Yellow : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light3
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch3.checked ? SGStatusLight.Yellow : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light4
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch4.checked ? SGStatusLight.Yellow : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light5
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch5.checked ? SGStatusLight.Red : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light6
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch6.checked ? SGStatusLight.Red : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light7
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch7.checked ? SGStatusLight.Red : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light8
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch8.checked ? SGStatusLight.Red : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light9
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch9.checked ? SGStatusLight.Blue : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light10
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch10.checked ? SGStatusLight.Blue : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light11
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch11.checked ? SGStatusLight.Blue : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light12
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch12.checked ? SGStatusLight.Blue : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light13
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch13.checked ? SGStatusLight.Green : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light14
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch14.checked ? SGStatusLight.Green : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light15
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch15.checked ? SGStatusLight.Green : SGStatusLight.Off
                        }

                        SGStatusLight {
                            id: light16
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                            status: switch16.checked ? SGStatusLight.Green : SGStatusLight.Off
                        }
                    }
                }

                GridLayout {
                    Layout.alignment: Qt.AlignLeft
                    columns: 4
                    rows: 3
                    columnSpacing: 10 * factor
                    rowSpacing: 5 * factor
                    RadioButton {
                        id: blink0
                        Layout.row: 0
                        Layout.column: 0
                        Layout.alignment: Qt.AlignBottom
                        Layout.bottomMargin: 5 * factor
                        text: "<b>" + qsTr("Blink 0") + "</b>"
                        ButtonGroup.group: radioGroup
                        indicator.implicitHeight: 20 * factor
                        indicator.implicitWidth: 20 * factor
                        padding: 0
                        font.pixelSize: 12 * factor
                        onClicked: platformInterface.led_driver_ui_state = 2
                    }
                    RadioButton {
                        id: blink1
                        Layout.row: 1
                        Layout.column: 0
                        Layout.alignment: Qt.AlignBottom
                        Layout.bottomMargin: 5 * factor
                        text: "<b>" + qsTr("Blink 1") + "</b>"
                        ButtonGroup.group: radioGroup
                        indicator.implicitHeight: 20 * factor
                        indicator.implicitWidth: 20 * factor
                        padding: 0
                        font.pixelSize: 12 * factor
                        onClicked: platformInterface.led_driver_ui_state = 3
                    }
                    RadioButton {
                        id: onstate
                        Layout.row: 2
                        Layout.column: 0
                        Layout.alignment: Qt.AlignBottom
                        Layout.bottomMargin: 5 * factor
                        text: "<b>" + qsTr("On") + "</b>"
                        ButtonGroup.group: radioGroup
                        indicator.implicitHeight: 20 * factor
                        indicator.implicitWidth: 20 * factor
                        padding: 0
                        font.pixelSize: 12 * factor
                        checked: true
                        onClicked: platformInterface.led_driver_ui_state = 1
                    }

                    SGAlignedLabel {
                        Layout.row: 0
                        Layout.column: 1
                        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                        target: freqbox0
                        text: "<b>" + qsTr("Frequency") + "</b>"
                        fontSizeMultiplier: factor
                        SGInfoBox {
                            id: freqbox0
                            readOnly: false
                            textColor: "black"
                            height: 30 * factor
                            width: 100 * factor
                            unit: "Hz"
                            placeholderText: "1 - 152"
                            validator: DoubleValidator {
                                bottom: 1
                                top: 152
                            }
                            fontSizeMultiplier: factor
                            onTextChanged: if (acceptableInput) platformInterface.led_driver_ui_freq0 = Number(text)
                        }
                    }
                    SGAlignedLabel {
                        Layout.row: 0
                        Layout.column: 2
                        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                        target: pwmbox0
                        text: "<b>" + "PWM" + "</b>"
                        fontSizeMultiplier: factor
                        SGInfoBox {
                            id:pwmbox0
                            readOnly: false
                            textColor: "black"
                            height: 30 * factor
                            width: 80 * factor
                            unit: "%"
                            placeholderText: "0 - 100"
                            validator: DoubleValidator {
                                bottom: 0
                                top: 100
                            }
                            fontSizeMultiplier: factor
                            onTextChanged: if (acceptableInput) platformInterface.led_driver_ui_pwm0 = Number(text)/100
                        }
                    }

                    Button {
                        id: applybtn0
                        Layout.row: 0
                        Layout.column: 3
                        Layout.preferredHeight: 30 * factor
                        Layout.preferredWidth: 80 * factor
                        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                        font.pixelSize: 12*factor
                        text: qsTr("Apply")
                        width: 75
                        onClicked: {
                            if (freqbox0.acceptableInput && pwmbox0.acceptableInput) {
                                platformInterface.set_led_driver_freq0.update(Number(freqbox0.text))
                                platformInterface.set_led_driver_duty0.update(Number(pwmbox0.text)/100)
                            }
                        }
                    }

                    SGAlignedLabel {
                        Layout.row: 1
                        Layout.column: 1
                        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                        target: freqbox1
                        text: "<b>" + qsTr("Frequency") + "</b>"
                        fontSizeMultiplier: factor
                        SGInfoBox {
                            id: freqbox1
                            readOnly: false
                            textColor: "black"
                            height: 30 * factor
                            width: 100 * factor
                            unit: "Hz"
                            placeholderText: "1 - 152"
                            validator: DoubleValidator {
                                bottom: 1
                                top: 152
                            }
                            fontSizeMultiplier: factor
                            onTextChanged: if (acceptableInput) platformInterface.led_driver_ui_freq1 = Number(text)
                        }
                    }

                    SGAlignedLabel {
                        Layout.row: 1
                        Layout.column: 2
                        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                        target: pwmbox1
                        text: "<b>" + "PWM" + "</b>"
                        fontSizeMultiplier: factor
                        SGInfoBox {
                            id:pwmbox1
                            readOnly: false
                            textColor: "black"
                            height: 30 * factor
                            width: 80 * factor
                            unit: "%"
                            placeholderText: "0 - 100"
                            validator: DoubleValidator {
                                bottom: 0
                                top: 100
                            }
                            fontSizeMultiplier: factor
                            onTextChanged: if (acceptableInput) platformInterface.led_driver_ui_pwm1 = Number(text)/100
                        }
                    }

                    Button {
                        id: applybtn1
                        Layout.row: 1
                        Layout.column: 3
                        Layout.preferredHeight: 30 * factor
                        Layout.preferredWidth: 80 * factor
                        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                        font.pixelSize: 12*factor
                        text: qsTr("Apply")
                        width: 75
                        onClicked: {
                            if (freqbox1.acceptableInput && pwmbox1.acceptableInput) {
                                platformInterface.set_led_driver_freq1.update(Number(freqbox1.text))
                                platformInterface.set_led_driver_duty1.update(Number(pwmbox1.text)/100)
                            }
                        }
                    }

                    Button {
                        id: resetbtn
                        Layout.row: 2
                        Layout.column: 1
                        Layout.preferredHeight: 30 * factor
                        Layout.preferredWidth: 80 * factor
                        Layout.topMargin: 20 * factor
                        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                        font.pixelSize: 12*factor
                        text: qsTr("Reset")
                        width: 75
                        onClicked: platformInterface.clear_led_driver.update()
                    }
                }
            }
        }
    }
}
