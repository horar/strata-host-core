import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

CustomControl {
    id: root
    title: qsTr("Light Sensor")

    // UI state & notification
    property bool start: platformInterface.i2c_light_ui_start
    property bool active: platformInterface.i2c_light_ui_active
    property string time: platformInterface.i2c_light_ui_time
    property string gain: platformInterface.i2c_light_ui_gain
    property real sensitivity: platformInterface.i2c_light_ui_sensitivity
    property var lux: platformInterface.i2c_light_noti_lux

    Component.onCompleted: {
        if (hideHeader) {
            Help.registerTarget(root, "None", 0, "helloStrata_LightSensor_Help")
        }
    }

    onStartChanged: {
        startsw.checked = start
    }

    onActiveChanged: {
        activesw.checked = active
    }

    onTimeChanged: {
        timebox.currentIndex = timebox.model.indexOf(time)
    }

    onGainChanged: {
        gainbox.currentIndex = gainbox.model.indexOf(gain)
    }

    onSensitivityChanged: {
        sgslider.value = sensitivity
    }

    onLuxChanged: {
        gauge.value = lux.value
    }

    contentItem: RowLayout {
        id: content
        anchors.fill:parent

        GridLayout {
            columns: 2
            rows: 3
            rowSpacing: 10 * factor
            columnSpacing: 10 * factor

            SGAlignedLabel {
                id: sgsliderLabel
                target: sgslider
                text:"<b>" + qsTr("Sensitivity (%)") + "</b>"
                fontSizeMultiplier: factor
                Layout.columnSpan: 2
                SGSlider {
                    id: sgslider
                    textColor: "black"
                    stepSize: 0.1
                    from: 66.7
                    to: 150
                    startLabel: "66.7%"
                    endLabel: "150%"
                    width: content.parent.maximumWidth * 0.5
                    fontSizeMultiplier: factor
                    onUserSet: {
                        platformInterface.i2c_light_ui_sensitivity = value
                        platformInterface.i2c_light_set_sensitivity.update(value)
                    }
                }
            }

            SGAlignedLabel {
                target: gainbox
                text: "<b>" + qsTr("Gain") + "</b>"
                fontSizeMultiplier: factor
                SGComboBox {
                    id:gainbox
                    model: ["0.25", "1", "2", "8"]
                    height: 30 * factor
                    width: 80 * factor
                    fontSizeMultiplier: factor
                    onActivated: {
                        platformInterface.i2c_light_ui_gain = parseFloat(currentText)
                        platformInterface.i2c_light_set_gain.update(parseFloat(currentText))
                    }
                }
            }

            SGAlignedLabel {
                target: timebox
                text: "<b>" + qsTr("Integration Time") + "</b>"
                fontSizeMultiplier: factor
                SGComboBox {
                    id:timebox
                    model: ["12.5ms", "100ms", "200ms", "Manual"]
                    height: 30 * factor
                    width: 90 * factor
                    fontSizeMultiplier: factor
                    onActivated: {
                        if (currentText !== "Manual") {
                            platformInterface.i2c_light_ui_start = false
                            platformInterface.i2c_light_start.update(false)
                        }
                        platformInterface.i2c_light_ui_time = currentText
                        platformInterface.i2c_light_set_integration_time.update(currentText)
                    }
                }
            }

            SGAlignedLabel {
                target: activesw
                text: "<b>" + qsTr("Status") + "</b>"
                fontSizeMultiplier: factor
                SGSwitch {
                    id:activesw
                    height: 30 * factor
                    width: 80 * factor
                    fontSizeMultiplier: factor
                    checkedLabel: qsTr("Active")
                    uncheckedLabel: qsTr("Sleep")
                    onClicked: {
                        if (!checked) {
                            if (platformInterface.i2c_light_ui_start) {
                                platformInterface.i2c_light_ui_start = false
                                platformInterface.i2c_light_start.update(false)
                            }
                        }
                        platformInterface.i2c_light_ui_active = checked
                        platformInterface.i2c_light_active.update(checked)
                    }
                }
            }

            SGAlignedLabel {
                target: startsw
                text: "<b>" + qsTr("Manual Integration") + "</b>"
                fontSizeMultiplier: factor
                SGSwitch {
                    id:startsw
                    height: 30 * factor
                    width: 80 * factor
                    fontSizeMultiplier: factor
                    checkedLabel: qsTr("Start")
                    uncheckedLabel: qsTr("Stop")
                    enabled: timebox.currentText === "Manual" && activesw.checked
                    onClicked: {
                        platformInterface.i2c_light_ui_start = checked
                        platformInterface.i2c_light_start.update(checked)
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.minimumHeight: 20
            Layout.minimumWidth: 20
            Layout.preferredHeight: Math.min(width,content.height)
            Layout.alignment: Qt.AlignCenter
            SGCircularGauge {
                id: gauge
                height: Math.min(parent.height, parent.width)
                width: Math.min(parent.height, parent.width)
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                unitText: "Lux\n(lx)"
                unitTextFontSizeMultiplier: factor
                value: 0
                tickmarkStepSize: 5000
                minimumValue: 0
                maximumValue: 65536
            }
        }
    }
}
