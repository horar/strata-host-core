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
        if (state === 1) radiobtns.onstate.checked = true
        if (state === 2) radiobtns.blink0.checked = true
        if (state === 3) radiobtns.blink1.checked = true
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
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light1.status = this.checked ? SGStatusLight.Yellow : SGStatusLight.Off
                                platformInterface.led_driver_ui_y1 = this.checked
                                platformInterface.set_led_driver.update(15,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch2
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light2.status = this.checked ? SGStatusLight.Yellow : SGStatusLight.Off
                                platformInterface.led_driver_ui_y2 = this.checked
                                platformInterface.set_led_driver.update(14,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch3
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light3.status = this.checked ? SGStatusLight.Yellow : SGStatusLight.Off
                                platformInterface.led_driver_ui_y3 = this.checked
                                platformInterface.set_led_driver.update(13,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch4
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light4.status = this.checked ? SGStatusLight.Yellow : SGStatusLight.Off
                                platformInterface.led_driver_ui_y4 = this.checked
                                platformInterface.set_led_driver.update(12,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch5
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light5.status = this.checked ? SGStatusLight.Red : SGStatusLight.Off
                                platformInterface.led_driver_ui_r1 = this.checked
                                platformInterface.set_led_driver.update(11,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch6
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light6.status = this.checked ? SGStatusLight.Red : SGStatusLight.Off
                                platformInterface.led_driver_ui_r2 = this.checked
                                platformInterface.set_led_driver.update(10,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch7
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light7.status = this.checked ? SGStatusLight.Red : SGStatusLight.Off
                                platformInterface.led_driver_ui_r3 = this.checked
                                platformInterface.set_led_driver.update(9,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch8
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light8.status = this.checked ? SGStatusLight.Red : SGStatusLight.Off
                                platformInterface.led_driver_ui_r4 = this.checked
                                platformInterface.set_led_driver.update(8,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch9
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light9.status = this.checked ? SGStatusLight.Blue : SGStatusLight.Off
                                platformInterface.led_driver_ui_b1 = this.checked
                                platformInterface.set_led_driver.update(7,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch10
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light10.status = this.checked ? SGStatusLight.Blue : SGStatusLight.Off
                                platformInterface.led_driver_ui_b2 = this.checked
                                platformInterface.set_led_driver.update(6,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch11
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light11.status = this.checked ? SGStatusLight.Blue : SGStatusLight.Off
                                platformInterface.led_driver_ui_b3 = this.checked
                                platformInterface.set_led_driver.update(5,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch12
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light12.status = this.checked ? SGStatusLight.Blue : SGStatusLight.Off
                                platformInterface.led_driver_ui_b4 = this.checked
                                platformInterface.set_led_driver.update(4,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch13
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light13.status = this.checked ? SGStatusLight.Green : SGStatusLight.Off
                                platformInterface.led_driver_ui_g1 = this.checked
                                platformInterface.set_led_driver.update(3,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch14
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light14.status = this.checked ? SGStatusLight.Green : SGStatusLight.Off
                                platformInterface.led_driver_ui_g2 = this.checked
                                platformInterface.set_led_driver.update(2,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch15
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light15.status = this.checked ? SGStatusLight.Green : SGStatusLight.Off
                                platformInterface.led_driver_ui_g3 = this.checked
                                platformInterface.set_led_driver.update(1,this.checked ? platformInterface.led_driver_ui_state : 0)
                            }
                        }

                        SGSwitch {
                            id: switch16
                            Layout.preferredHeight: switchHeightValue
                            Layout.preferredWidth: switchWidthValue
                            onCheckedChanged: {
                                light16.status = this.checked ? SGStatusLight.Green : SGStatusLight.Off
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
                        }

                        SGStatusLight {
                            id: light2
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light3
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light4
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light5
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light6
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light7
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light8
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light9
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light10
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light11
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light12
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light13
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light14
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light15
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }

                        SGStatusLight {
                            id: light16
                            Layout.preferredHeight: lightSizeValue
                            Layout.preferredWidth: lightSizeValue
                        }
                    }
                }

                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    SGRadioButtonContainer {
                        id: radiobtns
                        anchors.bottom: parent.bottom
                        columnSpacing: 10
                        rowSpacing: 30
                        columns: 1
                        property alias blink0: blink0
                        property alias blink1: blink1
                        property alias onstate: onstate

                        SGRadioButton {
                            id: blink0
                            text: "<b>" + qsTr("Blink 0") + "</b>"
                            onCheckedChanged: {
                                if (checked) platformInterface.led_driver_ui_state = 2
                            }
                        }
                        SGRadioButton {
                            id: blink1
                            text: "<b>" + qsTr("Blink 1") + "</b>"
                            onCheckedChanged:  {
                                if (checked) platformInterface.led_driver_ui_state = 3
                            }
                        }
                        SGRadioButton {
                            id: onstate
                            text: "<b>" + qsTr("On") + "</b>"
                            checked: true
                            onCheckedChanged: {
                                if (checked) platformInterface.led_driver_ui_state = 1
                            }
                        }
                    }

                    Column {
                        spacing: 10
                        Row {
                            spacing: 30
                            SGInfoBox {
                                id: freqbox0
                                readOnly: false
                                //label: "<b>" + qsTr("Frequency") + "</b>"
                                textColor: "black"
                                //labelLeft: false
                                width: 100
                                unit: "kHz"
                                placeholderText: "0.0001 - 1000"
                                validator: DoubleValidator {
                                    bottom: 0.0001
                                    top: 1000
                                }
                                anchors.bottom: parent.bottom
                                onTextChanged: platformInterface.led_driver_ui_freq0 = Number(text)
                            }

                            SGInfoBox {
                                id:pwmbox0
                                readOnly: false
                                //label: "<b>" + "PWM" + "</b>"
                                textColor: "black"
                                //labelLeft: false
                                width: 60
                                unit: "%"
                                placeholderText: "0 - 100"
                                validator: DoubleValidator {
                                    bottom: 0
                                    top: 100
                                }
                                anchors.bottom: parent.bottom
                                onTextChanged: platformInterface.led_driver_ui_pwm0 = Number(text)/100
                            }

                            Button {
                                id: applybtn0
                                text: qsTr("Apply")
                                width: 75
                                anchors.bottom: parent.bottom
                                onClicked: {
                                    if (freqbox0.acceptableInput)
                                        platformInterface.set_led_driver_freq0.update(Number(freqbox0.text))
                                    if (pwmbox0.acceptableInput)
                                        platformInterface.set_led_driver_duty0.update(Number(pwmbox0.text)/100)
                                }
                            }
                        }

                        Row {
                            spacing: 30
                            SGInfoBox {
                                id: freqbox1
                                readOnly: false
                                //label: "<b>" + qsTr("Frequency") + "</b>"
                                textColor: "black"
                                //labelLeft: false
                                width: 100
                                unit: "kHz"
                                placeholderText: "0.0001 - 1000"
                                validator: DoubleValidator {
                                    bottom: 0.0001
                                    top: 1000
                                }
                                anchors.bottom: parent.bottom
                                onTextChanged: platformInterface.led_driver_ui_freq1 = Number(text)
                            }

                            SGInfoBox {
                                id:pwmbox1
                                readOnly: false
                                //label: "<b>" + "PWM" + "</b>"
                                textColor: "black"
                                //labelLeft: false
                                width: 60
                                unit: "%"
                                placeholderText: "0 - 100"
                                validator: DoubleValidator {
                                    bottom: 0
                                    top: 100
                                }
                                anchors.bottom: parent.bottom
                                onTextChanged: platformInterface.led_driver_ui_pwm1 = Number(text)/100
                            }

                            Button {
                                id: applybtn1
                                text: qsTr("Apply")
                                width: 75
                                anchors.bottom: parent.bottom
                                onClicked: {
                                    if (freqbox1.acceptableInput)
                                        platformInterface.set_led_driver_freq1.update(Number(freqbox1.text))
                                    if (pwmbox1.acceptableInput)
                                        platformInterface.set_led_driver_duty1.update(Number(pwmbox1.text)/100)
                                }
                            }
                        }
                        Button {
                            id: resetbtn
                            text: qsTr("Reset")
                            width: 75
                            anchors.right: parent.right
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
                                platformInterface.led_driver_ui_pwm0 = 0.5
                                platformInterface.led_driver_ui_pwm1 = 0.5
                            }
                        }
                    }
                }
            }
        }
    }
}
