import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help
import "Images"

Rectangle {
    id: root

    property real minimumHeight
    property real minimumWidth

    signal zoom

    property real defaultMargin: 20
    property real defaultPadding: 20
    property real factor: Math.max(1,(hideHeader ? 0.6 : 1) * Math.min(root.height/minimumHeight,root.width/minimumWidth))

    // UI state & notification
    property string mode:platformInterface.pot_ui_mode
    property var value: platformInterface.pot_noti

    Component.onCompleted: {
        if (!hideHeader) {
            Help.registerTarget(btn, "Click on this button will switch to the corresponding tab in tab view mode.", 1, "helloStrataHelp")
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
        if (mode === "volts") voltGauge.value = value.cmd_data
        else bitsGauge.value = value.cmd_data
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
            Layout.alignment: Qt.AlignTop

            Text {
                id: name
                text: "<b>" + qsTr("Potentiometer to ADC") + "</b>"
                font.pixelSize: 14*factor
                color:"black"
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
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

        GridLayout {
            id: content
            Layout.maximumWidth: hideHeader ? 0.6 * root.width : root.width - defaultPadding * 2
            Layout.alignment: Qt.AlignCenter
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
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumHeight: gauge.height * 0.5
                Layout.alignment: Qt.AlignCenter
                Layout.bottomMargin: 20 * factor
                Layout.column: 0
                Layout.row: 1
                fillMode: Image.PreserveAspectFit
                source: "Images/helpImage_potentiometer.png"
            }

            Item {
                id: gauge
                Layout.minimumHeight: 100
                Layout.minimumWidth: 100
                Layout.preferredHeight: Math.min(width, container.height - header.height)
                Layout.preferredWidth: ((hideHeader ? 0.6 * root.width : root.width - defaultPadding * 2) - defaultMargin * factor) * 0.6
                Layout.column: 1
                Layout .rowSpan: 2
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
}
