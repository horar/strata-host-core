import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "qrc:/js/help_layout_manager.js" as Help
import "Images"
import tech.strata.sgwidgets 1.0

CustomControl {
    id: root
    title: qsTr("Potentiometer to ADC")

    Component.onCompleted: {
        if (!hideHeader) {
            Help.registerTarget(content.parent.btn, "Click this button to switch to the corresponding tab in tab view mode.", 1, "helloStrataHelp")
        }
        else {
            Help.registerTarget(helpImage, "To increase the ADC reading from the potentiometer, turn the potentiometer knob clockwise.", 0, "helloStrata_PotToADC_Help")
            Help.registerTarget(sgswitchLabel, "This switch will switch the units on the gauge between volts and bits of the ADC reading.", 1, "helloStrata_PotToADC_Help")
        }
    }

    property var read_adc_volts: platformInterface.pot.volts
    onRead_adc_voltsChanged: {
        voltGauge.value = read_adc_volts
    }

    property var read_adc_bits: platformInterface.pot.bits
    onRead_adc_bitsChanged: {
        bitsGauge.value = read_adc_bits
    }

    property string pot_mode: platformInterface.pot_switch_state
    onPot_modeChanged:{
        if(pot_mode != undefined) {
            if(pot_mode === "on") {
                sgswitch.checked = true
            }
            else sgswitch.checked = false
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
                anchors.centerIn: parent

                target: sgswitch
                text: "<b>Volts/Bits</b>"
                fontSizeMultiplier: factor
                SGSwitch {
                    id: sgswitch
                    height: 30 * factor
                    fontSizeMultiplier: factor
                    checkedLabel: "Bits"
                    uncheckedLabel: "Volts"
                    onToggled: {
                        if(checked)
                            platformInterface.pot_switch_state = "on"
                        else platformInterface.pot_switch_state = "off"
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
                anchors.fill: parent
                visible: !sgswitch.checked
                unitText: "V"
                unitTextFontSizeMultiplier: factor + 1
                value: 1
                tickmarkStepSize: 0.2
                tickmarkDecimalPlaces: 2
                minimumValue: 0
                maximumValue: 2
            }
            SGCircularGauge {
                id: bitsGauge
                anchors.fill: parent
                visible: sgswitch.checked
                unitText: "Bits"
                unitTextFontSizeMultiplier: factor + 1
                value: 0
                tickmarkStepSize: 512
                minimumValue: 0
                maximumValue: 4096
            }
        }
    }
}
