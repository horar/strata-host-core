import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import "qrc:/js/help_layout_manager.js" as Help

ColumnLayout {
    spacing: 5
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: "1A-Switcher"
        font.pixelSize: 50
    }
    RowLayout {
        id: mainRow
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height / 2
        Layout.alignment: Qt.AlignCenter
        spacing: 2
        SGCircularGauge{
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.height

            tickmarkStepSize: 10
            minimumValue: 0
            maximumValue: 150
            value: platformInterface.telemetry.temperature
            Label {
                anchors {
                    bottom: enableSwitch.top
                    left: enableSwitch.left
                }

                text: "<b>Enable</b>"
            }
            SGSwitch{
                id: enableSwitch
                width: 65
                height: 30
                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.height / 3
                }

                checked: true
                onCheckedChanged: {
                    checked ? platformInterface.set_enable.update("on") : platformInterface.set_enable.update("off")
                }
            }
        }
        GridLayout {
            Layout.preferredWidth: 250
            Layout.preferredHeight: parent.height / 3

            rows: 3
            columns: 2
            Item {
                Layout.preferredHeight: 60
                Layout.preferredWidth: 80
                Layout.alignment: Qt.AlignCenter
                Label {
                    text: "<b>VIN_CONN</b>"
                    anchors {
                        bottom: vin_conn.top
                        left: vin_conn.left
                    }
                }
                SGInfoBox {
                    id: vin_conn
                    height: parent.height / 2
                    width: parent.width
                    unit: "<b>V</b>"
                    text: platformInterface.status.vin_conn
                }
            }
            Item {
                Layout.preferredHeight: 60
                Layout.preferredWidth: 80
                Layout.alignment: Qt.AlignCenter
                Label {
                    text: "<b>VIN</b>"
                    anchors {
                        bottom: vin.top
                        left: vin.left
                    }
                }
                SGInfoBox {
                    id: vin
                    height: parent.height / 2
                    width: parent.width
                    unit: "V"
                    text: platformInterface.status.vin
                }
            }
            Item {
                Layout.preferredHeight: 60
                Layout.preferredWidth: 80
                Layout.alignment: Qt.AlignCenter
                Label {
                    text: "<b>Input Current</b>"
                    anchors {
                        bottom: inputCurrent.top
                        left: inputCurrent.left
                    }
                }
                SGInfoBox {
                    id: inputCurrent
                    height: parent.height / 2
                    width: parent.width
                    unit: "<b>V</b>"

                }
            }
            Item {
                Layout.preferredHeight: 60
                Layout.preferredWidth: 80
                Layout.alignment: Qt.AlignCenter
                Label {
                    text: "<b>VOUT_LED</b>"
                    anchors {
                        bottom: voutLED.top
                        left: voutLED.left
                    }
                }
                SGInfoBox {
                    id: voutLED
                    height: parent.height / 2
                    width: parent.width
                    unit: "<b>V</b>"
                }
            }
            Item {
                Layout.preferredHeight: 60
                Layout.preferredWidth: 80
                Layout.alignment: Qt.AlignCenter
                Label {
                    text: "<b>CS Current</b>"
                    anchors {
                        bottom: csCurrent.top
                        left: csCurrent.left
                    }
                }
                SGInfoBox {
                    id: csCurrent
                    height: parent.height / 2
                    width: parent.width
                    unit: "<b>mA</b>"
                }
            }
            Item {
                Layout.preferredHeight: 60
                Layout.preferredWidth: 80
                Layout.alignment: Qt.AlignCenter
            }
        }
    }
    SGSlider{
        Layout.preferredWidth: mainRow.width
        Layout.alignment: Qt.AlignHCenter

        from: 0
        to: 1
        stepSize: 0.01
        startLabel: "0%"
        endLabel: "100%"
        onValueChanged: {
            platformInterface.set_dim_en_duty.update(value)
        }
        Label {
            text: "DIM#/EN Positive Duty Cycle"
            anchors {
                bottom: parent.top
                left: parent.left
            }
        }
    }
    SGSlider{
        Layout.preferredWidth: mainRow.width
        Layout.alignment: Qt.AlignHCenter

        from: 0
        to: 20
        stepSize: 0.01
        value: 10
        startLabel: "0.1kHz"
        endLabel: "20kHz"
        onValueChanged: {
            platformInterface.set_dim_en_frequency.update(value)
        }
        Label {
            text: "DIM#/EN Frequency"
            anchors {
                bottom: parent.top
                left: parent.left
            }
        }
    }
    SGComboBox{
        Label {
            text: "LED Configuration"
            anchors {
                bottom: parent.top
                left: parent.left
            }
        }
        Layout.preferredWidth: mainRow.width / 2
        Layout.alignment: Qt.AlignHCenter
        model: ["1 LED","2 LED","3 LED", "EXTERNAL LED's"]
        onCurrentTextChanged: {
            platformInterface.set_led.update(currentText)
        }
    }
}



