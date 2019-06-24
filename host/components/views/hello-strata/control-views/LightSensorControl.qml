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

    // UI state & notification
    property bool start: platformInterface.i2c_light_ui_start
    property bool active: platformInterface.i2c_light_ui_active
    property int time: platformInterface.i2c_light_ui_time
    property int gain: platformInterface.i2c_light_ui_gain
    property real sensitivity: platformInterface.i2c_light_ui_sensitivity
    property var lux: platformInterface.i2c_light_noti_lux
    property var light_intensity: platformInterface.i2c_light_noti_light_intensity

    onStartChanged: {
        startsw.checked = start
    }

    onActiveChanged: {
        activesw.checked = active
    }

    onTimeChanged: {
        timebox.currentIndex = time
    }

    onGainChanged: {
        gainbox.currentIndex = gain
    }

    onSensitivityChanged: {
        sgslider.value = sensitivity*100
    }

    onLuxChanged: {
        luxinfo.info = lux.value.toString()
    }

    onLight_intensityChanged: {
        gauge.value = light_intensity.value
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
                text: "<b>" + qsTr("Light Sensor") + "</b>"
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
                padding: defaultPadding
                spacing: 10

                Row {
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter

                    Column {
                        spacing: 10
                        anchors.verticalCenter: parent.verticalCenter
                        SGLabelledInfoBox {
                            id:luxinfo
                            label: "<b>" + "Lux (lx)" + "</b>"
                            labelLeft: false
                            info: "800"
                        }

                        Row {
                            spacing: 10
                            SGSwitch {
                                id:activesw
                                anchors.bottom: parent.bottom
                                switchHeight: 32
                                switchWidth: 67
                                labelLeft: false
                                checkedLabel: qsTr("Active")
                                uncheckedLabel: qsTr("Sleep")               
                                onCheckedChanged: {
                                    if (platformInterface.i2c_light_ui_active != checked) {
                                        platformInterface.i2c_light_active.update(checked)
                                        platformInterface.i2c_light_ui_active = checked
                                    }
                                }
                            }

                            SGComboBox {
                                id:timebox
                                label: "<b>" + qsTr("Integration Time") + "</b>"
                                anchors.bottom: parent.bottom
                                labelLeft: false
                                model: ["12.5ms", "100ms", "200ms", "Manual"]
                                comboBoxWidth: 100
                                onCurrentIndexChanged: {
                                    if (platformInterface.i2c_light_ui_time != currentIndex) {
                                        platformInterface.i2c_light_set_integration_time.update(currentText)
                                        platformInterface.i2c_light_ui_time = currentIndex
                                    }
                                }
                            }
                        }

                        Row {
                            spacing: 10

                            SGSwitch {
                                id:startsw
                                anchors.bottom: parent.bottom
                                switchHeight: 32
                                switchWidth: 67
                                labelLeft: false
                                checkedLabel: qsTr("Start")
                                uncheckedLabel: qsTr("Stop")
                                onCheckedChanged: {
                                    if (platformInterface.i2c_light_ui_start != checked) {
                                        platformInterface.i2c_light_start.update(checked)
                                        platformInterface.i2c_light_ui_start = checked
                                    }
                                }
                            }

                            SGComboBox {
                                id:gainbox
                                label: "<b>" + qsTr("Gain") + "</b>"
                                anchors.bottom: parent.bottom
                                labelLeft: false
                                model: ["0.25", "1", "2", "8"]
                                comboBoxWidth: 100
                                onCurrentIndexChanged: {
                                    if (platformInterface.i2c_light_ui_gain != currentIndex) {
                                        platformInterface.i2c_light_set_gain.update(parseInt(currentText))
                                        platformInterface.i2c_light_ui_gain = currentIndex
                                    }
                                }
                            }
                        }
                    }

                    SGCircularGauge {
                        id: gauge
                        width: Math.min(content.height,content.width)*0.5
                        height: Math.min(content.height,content.width)*0.5
                        unitLabel: "Light Intensity"
                        value: 100000
                        tickmarkStepSize: 50000
                        minimumValue: 0
                        maximumValue: 65535*8
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

                SGSlider {
                    id: sgslider
                    label:"<b>" + qsTr("Sensitivity") + "</b>"
                    textColor: "black"
                    labelLeft: false
                    width: root.width - 2*defaultPadding
                    stepSize: 0.01
                    from: 66.7
                    to: 150
                    startLabel: "66.7%"
                    endLabel: "150%"
                    toolTipDecimalPlaces: 2
                    onValueChanged: {
                        if (platformInterface.i2c_light_ui_sensitivity != value/100) {
                            platformInterface.i2c_light_set_sensitivity.update(value/100)
                            platformInterface.i2c_light_ui_sensitivity = value/100
                        }
                    }
                }
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
