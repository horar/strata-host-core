import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import "qrc:/js/help_layout_manager.js" as Help

ColumnLayout {
    id: root

    property double outputCurrentLoadValue: 0
    property double dcdcBuckVoltageValue: 0
    Text {
        Layout.alignment: Qt.AlignCenter
        text: "LDO Charge Pump"
        font.pixelSize: 30
    }
    RowLayout {
        Layout.preferredWidth: parent.width
        Item {
            Layout.preferredHeight: 65
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignHCenter
            Label {
                anchors {
                    top: powerGoodLight.bottom
                    horizontalCenter: powerGoodLight.horizontalCenter
                }

                text: "<b>Power Good</b>"
            }
            SGStatusLight {
                id: powerGoodLight
                width: 50
                height: 50
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }

                status: platformInterface.int_vin_vr_pg.value ? SGStatusLight.Green : SGStatusLight.Red
            }
        }

        Item {
            Layout.preferredHeight: 65
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignHCenter
            Label {
                anchors {
                    top: chargePumpOnLight.bottom
                    horizontalCenter: chargePumpOnLight.horizontalCenter
                }

                text: "<b>Charge Pump On</b>"
            }
            SGStatusLight {
                id: chargePumpOnLight
                width: 50
                height: 50
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }

                status: platformInterface.int_cp_on.value ? SGStatusLight.Green : SGStatusLight.Red
            }
        }
        Item {
            Layout.preferredHeight: 65
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignHCenter
            Label {
                anchors {
                    top: ro_mcuLight.bottom
                    horizontalCenter: ro_mcuLight.horizontalCenter
                }

                text: "<b>RO_MCU</b>"
            }
            SGStatusLight {
                id: ro_mcuLight
                width: 50
                height: 50
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }

                status: platformInterface.int_ro_mcu.value ? SGStatusLight.Green : SGStatusLight.Red
            }
        }
        Item {
            Layout.preferredHeight: 65
            Layout.preferredWidth: 50
            Layout.alignment: Qt.AlignHCenter
            Label {
                anchors {
                    top: osAlertLight.bottom
                    horizontalCenter: osAlertLight.horizontalCenter
                }

                text: "<b>OS/ALERT</b>"
            }
            SGStatusLight {
                id: osAlertLight
                width: 50
                height: 50
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }

                status: platformInterface.int_os_alert.value ? SGStatusLight.Green : SGStatusLight.Red
            }
        }
    }
    RowLayout {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: parent.height / 2
        SGCircularGauge {
            id: tempGauge
            Layout.fillHeight: true
            Layout.fillWidth: true

            value: platformInterface.telemetry.temperature
            Label {
                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.height / 2.5
                }

                text: "<b>Board Temp (C)</b>"
            }

        }
        SGCircularGauge {
            id: powerLossGauge
            Layout.fillHeight: true
            Layout.fillWidth: true

            value: platformInterface.telemetry.ploss
            Label {
                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.height / 2.5
                }

                text: "<b>Power Loss (W)</b>"
            }
        }
    }
    RowLayout {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: parent.height / 3
        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 2
            Layout.leftMargin: 25
            Layout.alignment: Qt.AlignCenter
            ColumnLayout {
                width: parent.width - 25
                height: parent.height - 30
                spacing: 15
                RowLayout {
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: parent.height / 4
                    Item {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 80
                        Layout.alignment: Qt.AlignHCenter

                        Label {
                            anchors {
                                bottom: enableSwitch.top
                                horizontalCenter: enableSwitch.horizontalCenter
                            }
                            text: "<b>Enable SW</b>"
                        }
                        SGSwitch {
                            id: enableSwitch
                            height: 30
                            width: 80

                            checked: false
                            onCheckedChanged: {
                                if(checked === true){
                                    platformInterface.enable_sw.update(1)
                                }
                                else{
                                    platformInterface.enable_sw.update(0)
                                }
                            }
                        }
                    }
                    Item {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 80
                        Layout.alignment: Qt.AlignHCenter

                        Label {
                            anchors {
                                bottom: enableLDO.top
                                horizontalCenter: enableLDO.horizontalCenter
                            }
                            text: "<b>Enable LDO</b>"
                        }
                        SGSwitch {
                            id: enableLDO
                            height: 30
                            width: 80

                            checked: false
                            onCheckedChanged: {
                                if(checked === true){
                                    platformInterface.enable_ldo.update(1)
                                }
                                else{
                                    platformInterface.enable_ldo.update(0)
                                }
                            }
                        }
                    }

                    Item {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 80
                        Layout.alignment: Qt.AlignHCenter

                        Label {
                            anchors {
                                bottom: loadSwitch.top
                                horizontalCenter: loadSwitch.horizontalCenter
                            }
                            text: "<b>On Board Load</b>"
                        }
                        SGSwitch {
                            id: loadSwitch
                            height: 30
                            width: 80

                            checked: false
                            onCheckedChanged: {
                                if(checked === true){
                                    platformInterface.enable_vin_vr.update(1)
                                }
                                else{
                                    platformInterface.enable_vin_vr.update(0)
                                }
                            }
                        }
                    }
                }
                Item {
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: parent.height / 4
                    Layout.alignment: Qt.AlignHCenter
                    Label {
                        anchors {
                            bottom: outputCurrentLoadSlider.top
                            left: outputCurrentLoadSlider.left
                        }

                        text: "<b>Output Current Load</b>"
                    }
                    SGSlider {
                        id: outputCurrentLoadSlider
                        width: parent.width

                        from: 0
                        to: 500
                        stepSize: 0.01
                        fromText.text: "0mA"
                        toText.text: "500mA"
                        value: 0
                        onValueChanged: {
                            outputCurrentLoadValue = (value / 500.0)
                            platformInterface.vdac_iout.update(parseFloat(outputCurrentLoadValue.toFixed(2)))
                        }
                    }
                }

                Item {
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: parent.height / 4
                    Layout.alignment: Qt.AlignHCenter
                    Label {
                        anchors {
                            bottom: buckVoltageSlider.top
                            left: buckVoltageSlider.left
                        }

                        text: "<b>DCDC Buck Input Voltage Control</b>"
                    }
                    SGSlider {
                        id: buckVoltageSlider
                        width: parent.width

                        from: 2.5
                        to: 15
                        stepSize: 0.01
                        fromText.text: "2.5V"
                        toText.text: "15V"
                        value: 12
                        onValueChanged: {
                            dcdcBuckVoltageValue = (value / 15.0)
                            platformInterface.vdac_vin.update(parseFloat(dcdcBuckVoltageValue.toFixed(2)))
                        }
                    }
                }
                Item {
                    Layout.preferredWidth: parent.width / 2
                    Layout.preferredHeight: 30
                    Layout.alignment: Qt.AlignHCenter
                    Label {
                        anchors {
                            bottom: ldoInputComboBox.top
                            left: ldoInputComboBox.left
                        }
                        text: "<b>LDO Input</b>"
                    }
                    SGComboBox {
                        id: ldoInputComboBox
                        width: parent.width
                        height: 30

                        model: ["Bypass Input Regulator", "DCDC Buck Input Regulator"]
                    }
                }

            }
        }
        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignCenter
            Layout.margins: 10
            GridLayout {
                width: parent.width - 25
                height: parent.height - 30
                rows: 2
                columns: 3
                Item {
                    Layout.preferredHeight: 60
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignCenter
                    Label {
                        anchors {
                            bottom: vinvr.top
                            left: vinvr.left
                        }
                        text: "<b>VIN_VR</b>"
                    }
                    SGInfoBox {
                        id: vinvr
                        height: parent.height / 2
                        width: parent.width

                        unit: "<b>V</b>"
                        text: platformInterface.telemetry.vin_vr
                    }
                }
                Item {
                    Layout.preferredHeight: 60
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignCenter
                    Label {
                        anchors {
                            bottom: vin.top
                            left: vin.left
                        }
                        text: "<b>VIN</b>"
                    }
                    SGInfoBox {
                        id: vin
                        height: parent.height / 2
                        width: parent.width

                        unit: "<b>V</b>"
                        text: platformInterface.telemetry.vin
                    }
                }
                Item {
                    Layout.preferredHeight: 60
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignCenter
                    Label {
                        anchors {
                            bottom: inputCurrent.top
                            left: inputCurrent.left
                        }
                        text: "<b>Input Current</b>"
                    }
                    SGInfoBox {
                        id: inputCurrent
                        height: parent.height / 2
                        width: parent.width

                        unit: "<b>mA</b>"
                        text: platformInterface.telemetry.iin
                    }
                }
                Item {
                    Layout.preferredHeight: 60
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignCenter
                    Label {
                        anchors {
                            bottom: vcp.top
                            left: vcp.left
                        }
                        text: "<b>VCP</b>"
                    }
                    SGInfoBox {
                        id: vcp
                        height: parent.height / 2
                        width: parent.width

                        unit: "<b>V</b>"
                        text: platformInterface.telemetry.vcp
                    }
                }
                Item {
                    Layout.preferredHeight: 60
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignCenter
                    Label {
                        anchors {
                            bottom: voutvr.top
                            left: voutvr.left
                        }
                        text: "<b>VOUT_VR</b>"
                    }
                    SGInfoBox {
                        id: voutvr
                        height: parent.height / 2
                        width: parent.width

                        unit: "<b>V</b>"
                        text: platformInterface.telemetry.vout
                    }
                }
                Item {
                    Layout.preferredHeight: 60
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignCenter
                    Label {
                        anchors {
                            bottom: outputCurrent.top
                            left: outputCurrent.left
                        }
                        text: "<b>Output Current</b>"
                    }
                    SGInfoBox {
                        id: outputCurrent
                        height: parent.height / 2
                        width: parent.width

                        unit: "<b>mA</b>"
                        text: platformInterface.telemetry.iout
                    }
                }
            }
        }
    }
}



