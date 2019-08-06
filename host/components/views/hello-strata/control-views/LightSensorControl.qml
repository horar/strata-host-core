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
    property real factor: Math.max(1,(hideHeader ? 0.8 : 1) * Math.min(root.height/minimumHeight,root.width/minimumWidth))

    // UI state & notification
    property bool start: platformInterface.i2c_light_ui_start
    property bool active: platformInterface.i2c_light_ui_active
    property string time: platformInterface.i2c_light_ui_time
    property real gain: platformInterface.i2c_light_ui_gain
    property real sensitivity: platformInterface.i2c_light_ui_sensitivity
    property var lux: platformInterface.i2c_light_noti_lux

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
        gainbox.currentIndex = gainbox.model.indexOf(gain.toString())
    }

    onSensitivityChanged: {
        sgslider.value = sensitivity*100
    }

    onLuxChanged: {
        luxinfo.text = lux.value.toString()
        gauge.value = lux.value
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
                text: "<b>" + qsTr("Light Sensor") + "</b>"
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

        ColumnLayout {
            id: content
            Layout.maximumWidth: hideHeader ? 0.8 * root.width : root.width - defaultPadding * 2
            Layout.bottomMargin: defaultMargin * factor
            Layout.alignment: Qt.AlignCenter

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10 * factor
                GridLayout {
                    columns: 2
                    rows: 3
                    rowSpacing: 10 * factor
                    columnSpacing: 10 * factor

                    SGAlignedLabel {
                        target: luxinfo
                        text: "<b>" + "Lux (lx)" + "</b>"
                        fontSizeMultiplier: factor
                        Layout.row: 0
                        Layout.column: 1
                        SGInfoBox {
                            id:luxinfo
                            text: "0"
                            fontSizeMultiplier: factor
                            height: 30 * factor
                            width: 90 * factor
                        }
                    }

                    SGSwitch {
                        id:activesw
                        Layout.preferredHeight: 30 * factor
                        Layout.preferredWidth: 80 * factor
                        Layout.row: 1
                        Layout.column: 0
                        Layout.alignment: Qt.AlignBottom
                        fontSizeMultiplier: factor
                        checkedLabel: qsTr("Active")
                        uncheckedLabel: qsTr("Sleep")
                        onClicked: {
                            platformInterface.i2c_light_ui_active = checked
                            platformInterface.i2c_light_active.update(checked)
                        }
                    }

                    SGAlignedLabel {
                        target: timebox
                        text: "<b>" + qsTr("Integration Time") + "</b>"
                        fontSizeMultiplier: factor
                        Layout.row: 1
                        Layout.column: 1
                        SGComboBox {
                            id:timebox
                            model: ["12.5ms", "100ms", "200ms", "Manual"]
                            height: 30 * factor
                            width: 90 * factor
                            fontSizeMultiplier: factor
                            onActivated: {
                                platformInterface.i2c_light_ui_time = currentText
                                platformInterface.i2c_light_set_integration_time.update(currentText)
                            }
                        }
                    }

                    SGSwitch {
                        id:startsw
                        Layout.preferredHeight: 30 * factor
                        Layout.preferredWidth: 80 * factor
                        Layout.row: 2
                        Layout.column: 0
                        Layout.alignment: Qt.AlignBottom
                        fontSizeMultiplier: factor
                        checkedLabel: qsTr("Start")
                        uncheckedLabel: qsTr("Stop")
                        onClicked: {
                            platformInterface.i2c_light_ui_start = checked
                            platformInterface.i2c_light_start.update(checked)
                        }
                    }

                    SGAlignedLabel {
                        target: gainbox
                        text: "<b>" + qsTr("Gain") + "</b>"
                        fontSizeMultiplier: factor
                        Layout.row: 2
                        Layout.column: 1
                        SGComboBox {
                            id:gainbox
                            model: ["0.25", "1", "2", "8"]
                            height: 30 * factor
                            width: 90 * factor
                            fontSizeMultiplier: factor
                            onActivated: {
                                platformInterface.i2c_light_ui_gain = parseFloat(currentText)
                                platformInterface.i2c_light_set_gain.update(parseFloat(currentText))
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.maximumHeight: width
                    Layout.maximumWidth: (hideHeader ? 0.8 * root.width : root.width - defaultPadding * 2) * 0.5
                    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                    SGCircularGauge {
                        id: gauge
                        height: Math.min(parent.height, parent.width)
                        width: Math.min(parent.height, parent.width)
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        unitText: "Light Intensity"
                        value: 0
                        tickmarkStepSize: 5000
                        minimumValue: 0
                        maximumValue: 65536
                    }
                }
            }

            SGAlignedLabel {
                target: sgslider
                text:"<b>" + qsTr("Sensitivity") + "</b>"
                fontSizeMultiplier: factor
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
                    fontSizeMultiplier: factor
                    onUserSet: {
                        platformInterface.i2c_light_ui_sensitivity = value/100
                        platformInterface.i2c_light_set_sensitivity.update(value/100)
                    }
                }
            }
        }
    }
}
