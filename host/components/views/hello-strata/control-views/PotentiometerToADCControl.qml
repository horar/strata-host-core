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
    property real factor: Math.min(root.height/minimumHeight,root.width/minimumWidth)

    // UI state & notification
    property string mode:platformInterface.pot_ui_mode
    property var value: platformInterface.pot_noti

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

        RowLayout {
            id: header
            Layout.preferredHeight: Math.max(name.height, btn.height)
            Layout.fillWidth: true
            Layout.margins: defaultMargin

            Text {
                id: name
                text: "<b>" + qsTr("Potentiometer") + "</b>"
                font.pixelSize: 14*factor
                color:"black"
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                wrapMode: Text.WordWrap
            }

            Button {
                id: btn
                text: qsTr("Maximize")
                Layout.preferredHeight: btnText.contentHeight+6*factor
                Layout.preferredWidth: btnText.contentWidth+20*factor
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

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

        RowLayout {
            id: content
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: parent.width * 0.8
            Layout.alignment: Qt.AlignCenter
            spacing: 50 * factor

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumWidth: parent.width * 0.25
                SGAlignedLabel {
                    target: sgswitch
                    text: "<b>Volts/Bits</b>"
                    fontSizeMultiplier: factor
                    anchors.centerIn: parent
                    SGSwitch {
                        id: sgswitch
                        height: 32 * factor
                        fontSizeMultiplier: factor
                        checkedLabel: "Bits"
                        uncheckedLabel: "Volts"
                        onClicked: {
                            platformInterface.pot_mode.update(checked ? "bits" : "volts")
                            platformInterface.pot_ui_mode = checked ? "bits" : "volts" // need remove
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumWidth: parent.width * 0.75
                SGCircularGauge {
                    id: voltGauge
                    visible: !sgswitch.checked
                    anchors.fill: parent
                    unitText: "V"
                    value: 1
                    tickmarkStepSize: 0.5
                    minimumValue: 0
                    maximumValue: 3.3
                }
                SGCircularGauge {
                    id: bitsGauge
                    visible: sgswitch.checked
                    anchors.fill: parent
                    unitText: "Bits"
                    value: 0
                    tickmarkStepSize: 512
                    minimumValue: 0
                    maximumValue: 4096
                }
            }
        }
    }
}
