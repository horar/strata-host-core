import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root

    property real minimumHeight
    property real minimumWidth

    signal zoom

    property real defaultMargin: 20
    property real defaultPadding: 20
    property real factor: Math.min(root.height/minimumHeight,root.width/minimumWidth)

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

    property int blink_state: platformInterface.led_driver_ui_blink_state
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

    onBlink_stateChanged: {
        if (blink_state === 0) {
            radiobtns.radioButtons.blink0.checked = true
            freqbox.value = freq0
            pwmbox.value = pwm0
        }
        else {
            radiobtns.radioButtons.blink1.checked = true
            freqbox.value = freq1
            pwmbox.value = pwm1
        }
    }

    onFreq0Changed: if (blink_state === 0) freqbox.value = freq0
    onPwm0Changed: if (blink_state === 0) pwmbox.value = pwm0
    onFreq1Changed: if (blink_state === 1) freqbox.value = freq1
    onPwm1Changed: if (blink_state === 1) pwmbox.value = pwm1

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
                text: "<b>" + qsTr("LED Driver") + "</b>"
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
                spacing: 30*factor
                width: parent.width
                padding: defaultPadding
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    id: ledcontrol
                    spacing: 30*factor
                    anchors.horizontalCenter: parent.horizontalCenter

                    GridLayout {
                        rowSpacing: 5*factor
                        columnSpacing: 5*factor
                        rows: 4
                        columns: 4

                        SGSwitch {
                            id: switch1
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light1.status = this.checked ? "yellow" : "off"
                                platformInterface.led_driver_ui_y1 = this.checked
                                platformInterface.set_led_driver.update(0,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch2
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light2.status = this.checked ? "yellow" : "off"
                                platformInterface.led_driver_ui_y2 = this.checked
                                platformInterface.set_led_driver.update(1,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch3
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light3.status = this.checked ? "yellow" : "off"
                                platformInterface.led_driver_ui_y3 = this.checked
                                platformInterface.set_led_driver.update(2,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch4
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light4.status = this.checked ? "yellow" : "off"
                                platformInterface.led_driver_ui_y4 = this.checked
                                platformInterface.set_led_driver.update(3,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch5
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light5.status = this.checked ? "red" : "off"
                                platformInterface.led_driver_ui_r1 = this.checked
                                platformInterface.set_led_driver.update(4,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch6
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light6.status = this.checked ? "red" : "off"
                                platformInterface.led_driver_ui_r2 = this.checked
                                platformInterface.set_led_driver.update(5,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch7
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light7.status = this.checked ? "red" : "off"
                                platformInterface.led_driver_ui_r3 = this.checked
                                platformInterface.set_led_driver.update(6,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch8
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light8.status = this.checked ? "red" : "off"
                                platformInterface.led_driver_ui_r4 = this.checked
                                platformInterface.set_led_driver.update(7,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch9
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light9.status = this.checked ? "blue" : "off"
                                platformInterface.led_driver_ui_b1 = this.checked
                                platformInterface.set_led_driver.update(8,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch10
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light10.status = this.checked ? "blue" : "off"
                                platformInterface.led_driver_ui_b2 = this.checked
                                platformInterface.set_led_driver.update(9,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch11
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light11.status = this.checked ? "blue" : "off"
                                platformInterface.led_driver_ui_b3 = this.checked
                                platformInterface.set_led_driver.update(10,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch12
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light12.status = this.checked ? "blue" : "off"
                                platformInterface.led_driver_ui_b4 = this.checked
                                platformInterface.set_led_driver.update(11,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch13
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light13.status = this.checked ? "green" : "off"
                                platformInterface.led_driver_ui_g1 = this.checked
                                platformInterface.set_led_driver.update(12,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch14
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light14.status = this.checked ? "green" : "off"
                                platformInterface.led_driver_ui_g2 = this.checked
                                platformInterface.set_led_driver.update(13,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch15
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light15.status = this.checked ? "green" : "off"
                                platformInterface.led_driver_ui_g3 = this.checked
                                platformInterface.set_led_driver.update(14,this.checked ? 1 : 0)
                            }
                        }

                        SGSwitch {
                            id: switch16
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: {
                                light16.status = this.checked ? "green" : "off"
                                platformInterface.led_driver_ui_g4 = this.checked
                                platformInterface.set_led_driver.update(15,this.checked ? 1 : 0)
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
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light2
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light3
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light4
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light5
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light6
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light7
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light8
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light9
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light10
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light11
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light12
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light13
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light14
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light15
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light16
                            lightSize: lightSizeValue
                        }
                    }
                }

                Column {
                    spacing: 20
                    anchors.left: ledcontrol.left
                    Row {
                        spacing: 30
                        SGRadioButtonContainer {
                            id: radiobtns
                            radioGroup: GridLayout {
                                columnSpacing: 10
                                rowSpacing: 10
                                columns: 1
                                property alias blink0: blink0
                                property alias blink1: blink1
                                SGRadioButton {
                                    id: blink0
                                    text: "<b>" + qsTr("Blink 0") + "</b>"
                                    checked: true
                                    onCheckedChanged: {
                                        if (checked) platformInterface.led_driver_ui_blink_state = 0
                                    }
                                }
                                SGRadioButton {
                                    id: blink1
                                    text: "<b>" + qsTr("Blink 1") + "</b>"
                                    onCheckedChanged:  {
                                        if (checked) platformInterface.led_driver_ui_blink_state = 1
                                    }
                                }
                            }
                            anchors.bottom: parent.bottom
                        }

                        SGSubmitInfoBox {
                            id: freqbox
                            label: "<b>" + qsTr("Frequency") + "</b>"
                            textColor: "black"
                            labelLeft: false
                            infoBoxWidth: 100
                            showButton: false
                            unit: "kHz"
                            placeholderText: "0.0001 - 1000"
                            validator: DoubleValidator {
                                bottom: 0.0001
                                top: 1000
                            }
                            anchors.bottom: parent.bottom
                            onValueChanged: {
                                if (blink_state === 0) platformInterface.led_driver_ui_freq0 = value
                                else platformInterface.led_driver_ui_freq1 = value
                            }
                        }

                        SGSubmitInfoBox {
                            id:pwmbox
                            label: "<b>" + "PWM" + "</b>"
                            textColor: "black"
                            labelLeft: false
                            infoBoxWidth: 60
                            showButton: false
                            unit: "%"
                            placeholderText: "0 - 100"
                            validator: DoubleValidator {
                                bottom: 0
                                top: 100
                            }
                            anchors.bottom: parent.bottom
                            onValueChanged: {
                                if (blink_state === 0) platformInterface.led_driver_ui_pwm0 = value
                                else platformInterface.led_driver_ui_pwm1 = value
                            }
                        }
                    }

                    Row {
                        spacing: 20
                        Button {
                            id: applybtn
                            text: qsTr("Apply")
                            anchors.bottom: parent.bottom
                            onClicked: {
                                if (blink_state === 0) {
                                    if (freqbox.textInput.acceptableInput)
                                        platformInterface.set_led_driver_freq0.update(freqbox.value)
                                    if (pwmbox.textInput.acceptableInput)
                                        platformInterface.set_led_driver_duty0.update(pwmbox.value)
                                }
                                else {
                                    if (freqbox.textInput.acceptableInput)
                                        platformInterface.set_led_driver_freq1.update(freqbox.value)
                                    if (pwmbox.textInput.acceptableInput)
                                        platformInterface.set_led_driver_duty1.update(pwmbox.value)
                                }
                            }
                        }

                        Button {
                            id: resetbtn
                            text: qsTr("Reset")
                            anchors.bottom: parent.bottom
                            onClicked: {
                                switch1.checked = false
                                switch2.checked = false
                                switch3.checked = false
                                switch4.checked = false
                                switch5.checked = false
                                switch6.checked = false
                                switch7.checked = false
                                switch8.checked = false
                                switch9.checked = false
                                switch10.checked = false
                                switch11.checked = false
                                switch12.checked = false
                                switch13.checked = false
                                switch14.checked = false
                                switch15.checked = false
                                switch16.checked = false
                                platformInterface.led_driver_ui_blink_state = 0
                                platformInterface.led_driver_ui_freq0 = 1
                                platformInterface.led_driver_ui_freq1 = 1
                                platformInterface.led_driver_ui_pwm0 = 50
                                platformInterface.led_driver_ui_pwm1 = 50
                            }
                        }
                    }
                }
            }
        }
    }
}
