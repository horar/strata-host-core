import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help
import "Images"

CustomControl {
    id: root
    title: qsTr("Potentiometer to ADC")

    // UI state & notification
    property string mode:platformInterface.pot_ui_mode
    property var value: platformInterface.pot_noti

    Component.onCompleted: {
        if (!hideHeader) {
            Help.registerTarget(content.parent.btn, "Click on this button will switch to the corresponding tab in tab view mode.", 1, "helloStrataHelp")
        }
        else {
            Help.registerTarget(helpImage, "To increase the ADC reading from the potentiometer, turn the potentiometer knob counter clockwise.", 0, "helloStrata_PotToADC_Help")
            Help.registerTarget(sgswitch, "This switch will switch the units on the gauge between volts and bits of the ADC reading.", 1, "helloStrata_PotToADC_Help")
        }
    }

    onModeChanged: {
        sgswitch.checked = mode === "bits"
    }

    onValueChanged: {
        if (mode === "volts") {
            voltGauge.value = value.cmd_data
        }
        else {
            bitsGauge.value = value.cmd_data
        }
    }

    contentItem: GridLayout {
        id: content
        width: parent.width
        anchors.centerIn: parent
        columns: 2
        rows: 2
        columnSpacing: defaultMargin * factor
        rowSpacing: 0

        Item {
            id: switchContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumHeight: gauge.height * 0.5
            Layout.alignment: Qt.AlignCenter
            Layout.column: 0
            Layout.row: 0
            SGAlignedLabel {
                id: sgswitchLabel
                target: sgswitch
                text: "<b>Volts/Bits</b>"
                fontSizeMultiplier: factor
                anchors.centerIn: parent
                SGSwitch {
                    id: sgswitch
                    height: 30 * factor
                    fontSizeMultiplier: factor
                    checkedLabel: "Bits"
                    uncheckedLabel: "Volts"
                    onClicked: {
                        platformInterface.pot_ui_mode = checked ? "bits" : "volts"
                        platformInterface.pot_mode.update(checked ? "bits" : "volts")
                    }
                }
            }
        }
        Image {
            id: helpImage
            Layout.preferredHeight: gauge.height * 0.5
            Layout.preferredWidth: content.width - gauge.width - defaultMargin * factor
            Layout.alignment: Qt.AlignCenter
            Layout.column: 0
            Layout.row: 1
            fillMode: Image.PreserveAspectFit
            source: "Images/helpImage_potentiometer.png"
        }

        Item {
            id: gauge
            Layout.minimumHeight: 100
            Layout.minimumWidth: 100
            Layout.maximumHeight: width
            Layout.preferredHeight: Math.min(width, content.parent.maximumHeight)
            Layout.preferredWidth: (content.parent.maximumWidth - defaultMargin * factor) * 0.6
            Layout.column: 1
            Layout.rowSpan: 2
            SGCircularGauge {
                id: voltGauge
                visible: !sgswitch.checked
                anchors.fill: parent
                unitText: "V"
                unitTextFontSizeMultiplier: factor
                value: 1
                tickmarkStepSize: 0.5
                tickmarkDecimalPlaces: 2
                minimumValue: 0
                maximumValue: 3.3
            }
            SGCircularGauge {
                id: bitsGauge
                visible: sgswitch.checked
                anchors.fill: parent
                unitText: "Bits"
                unitTextFontSizeMultiplier: factor
                value: 0
                tickmarkStepSize: 512
                minimumValue: 0
                maximumValue: 4096
            }
        }
    }
}
