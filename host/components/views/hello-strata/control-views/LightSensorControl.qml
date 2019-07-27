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
                text: "<b>" + qsTr("Light Sensor") + "</b>"
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

        GridLayout {
            id: content
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumHeight: hideHeader ? parent.height * 0.8 : parent.height - defaultPadding * 2
            Layout.maximumWidth: hideHeader ? parent.width * 0.8 : parent.width - defaultPadding * 2
            Layout.alignment: Qt.AlignCenter
            columns: 3
            rows: 5
            columnSpacing: 10 * factor
            rowSpacing: 10 * factor

            SGAlignedLabel {
                target: luxinfo
                text: "<b>" + "Lux (lx)" + "</b>"
                Layout.row: 1
                Layout.columnSpan: 2
                SGInfoBox {
                    id:luxinfo
                    text: "0"
                }
            }

            SGSwitch {
                id:activesw
                Layout.preferredHeight: 32
                Layout.maximumHeight: 32
                Layout.maximumWidth: implicitWidth
                Layout.row: 2
                Layout.column: 0
                Layout.alignment: Qt.AlignBottom
                checkedLabel: qsTr("Active")
                uncheckedLabel: qsTr("Sleep")
                onClicked: {
                    platformInterface.i2c_light_active.update(checked)
                    platformInterface.i2c_light_ui_active = checked // need to remove
                }
            }

            SGAlignedLabel {
                target: timebox
                text: "<b>" + qsTr("Integration Time") + "</b>"
                Layout.row: 2
                Layout.column: 1
                SGComboBox {
                    id:timebox
                    model: ["12.5ms", "100ms", "200ms", "Manual"]
                    height: 32
                    onActivated: { // wait for pull request from David
                        platformInterface.i2c_light_set_integration_time.update(currentText)
                        platformInterface.i2c_light_ui_time = currentIndex // need to remove
                    }
                }
            }

            SGSwitch {
                id:startsw
                Layout.preferredHeight: 32
                Layout.maximumHeight: 32
                Layout.maximumWidth: implicitWidth
                Layout.row: 3
                Layout.column: 0
                Layout.alignment: Qt.AlignBottom
                checkedLabel: qsTr("Start")
                uncheckedLabel: qsTr("Stop")
                onClicked: {
                    platformInterface.i2c_light_start.update(checked)
                    platformInterface.i2c_light_ui_start = checked // need to remove
                }
            }

            SGAlignedLabel {
                target: gainbox
                text: "<b>" + qsTr("Gain") + "</b>"
                Layout.row: 3
                Layout.column: 1
                SGComboBox {
                    id:gainbox
                    model: ["0.25", "1", "2", "8"]
                    height: 32
                    onActivated: { // wait for pull request from David
                        platformInterface.i2c_light_set_gain.update(parseInt(currentText))
                        platformInterface.i2c_light_ui_gain = currentIndex // need to remove
                    }
                }
            }

            SGCircularGauge {
                id: gauge

                Rectangle {
                    anchors.fill: parent
                    opacity: 0.1
                    color: "red"
                }

                Layout.column: 2
                Layout.rowSpan: 4
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom
                unitText: "Light Intensity"
                value: 0
                tickmarkStepSize: 50000
                minimumValue: 0
                maximumValue: 65535*8
            }

            SGAlignedLabel {
                target: sgslider
                text:"<b>" + qsTr("Sensitivity") + "</b>"
                Layout.row: 4
                Layout.columnSpan: 3
                SGSlider {
                    id: sgslider
                    textColor: "black"
                    stepSize: 0.01
                    from: 66.7
                    to: 150
                    startLabel: "66.7%"
                    endLabel: "150%"
                    toolTipDecimalPlaces: 2
                    width: content.width
                    onUserSet: {
                        platformInterface.i2c_light_set_sensitivity.update(value/100)
                        platformInterface.i2c_light_ui_sensitivity = value/100 // need to remove
                    }
                }
            }
        }
    }
}
