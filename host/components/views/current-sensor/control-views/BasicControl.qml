import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help

ColumnLayout {
    id: root
    anchors.fill: parent

    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    spacing: 10

    Text {
        id: platformName
        Layout.alignment: Qt.AlignHCenter
        text: "Current Sense"
        font.bold: true
        font.pixelSize: ratioCalc * 40
        topPadding: 20
    }


    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height/1.2
        Layout.alignment: Qt.AlignCenter

        RowLayout {
            anchors.fill:parent
            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "transparent"
                Text {
                    id: settings
                    text: "Settings"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    color: "#696969"
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        top: parent.top
                    }
                }

                Rectangle {
                    id: line1
                    height: 2
                    Layout.alignment: Qt.AlignCenter
                    width: parent.width
                    border.color: "lightgray"
                    radius: 2
                    anchors {
                        top: settings.bottom
                        topMargin: 7
                    }
                }

                ColumnLayout{
                    anchors {
                        top: line1.bottom
                        topMargin: 10
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        RowLayout{
                            anchors.fill:parent
                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGText {
                                    anchors.centerIn: parent
                                    text: "NCS333"
                                    font.bold: true
                                    fontSizeMultiplier: ratioCalc * 1.2
                                }
                            }

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGAlignedLabel {
                                    id: enable1Label
                                    target: enable1
                                    text: "<b>" + qsTr("Enable") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
                                    alignment: SGAlignedLabel.SideLeftCenter
                                    SGSwitch {
                                        id: enable1
                                        height: 35 * ratioCalc
                                        width: 95 * ratioCalc
                                        checkedLabel: "On"
                                        uncheckedLabel: "Off"
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        grooveColor: "#0cf"

                                    }
                                }

                            }

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGInfoBox {
                                    id: setting1Reading
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    width: 100 * ratioCalc
                                    unit: "<b>uA</b>"
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    anchors.centerIn: parent
                                }
                            }

                        }
                    }
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        RowLayout{
                            anchors.fill:parent
                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGText {
                                    anchors.centerIn: parent
                                    text: "NCS211R"
                                    font.bold: true
                                    fontSizeMultiplier: ratioCalc * 1.2
                                }
                            }

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGAlignedLabel {
                                    id: enable2Label
                                    target: enable2
                                    text: "<b>" + qsTr("Enable") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
                                    alignment: SGAlignedLabel.SideLeftCenter
                                    SGSwitch {
                                        id: enable2
                                        height: 35 * ratioCalc
                                        width: 95 * ratioCalc
                                        checkedLabel: "On"
                                        uncheckedLabel: "Off"
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        grooveColor: "#0cf"

                                    }
                                }

                            }

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGInfoBox {
                                    id: setting2Reading
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    width: 100 * ratioCalc
                                    unit: "<b>mA</b>"
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    anchors.centerIn: parent
                                }
                            }

                        }
                    }
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        RowLayout{
                            anchors.fill:parent
                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGText {
                                    anchors.centerIn: parent
                                    text: "NCS210R"
                                    font.bold: true
                                    fontSizeMultiplier: ratioCalc * 1.2
                                }
                            }

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGAlignedLabel {
                                    id: enable3Label
                                    target: enable3
                                    text: "<b>" + qsTr("Enable") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
                                    alignment: SGAlignedLabel.SideLeftCenter
                                    SGSwitch {
                                        id: enable3
                                        height: 35 * ratioCalc
                                        width: 95 * ratioCalc
                                        checkedLabel: "On"
                                        uncheckedLabel: "Off"
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        grooveColor: "#0cf"

                                    }
                                }

                            }

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGInfoBox {
                                    id: setting3Reading
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    width: 100 * ratioCalc
                                    unit: "<b>mA</b>"
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    anchors.centerIn: parent
                                }
                            }

                        }
                    }
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        RowLayout{
                            anchors.fill:parent
                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGText {
                                    anchors.centerIn: parent
                                    text: "NCS214R"
                                    font.bold: true
                                    fontSizeMultiplier: ratioCalc * 1.2
                                }
                            }

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGAlignedLabel {
                                    id: enable4Label
                                    target: enable4
                                    text: "<b>" + qsTr("Enable") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
                                    alignment: SGAlignedLabel.SideLeftCenter
                                    SGSwitch {
                                        id: enable4
                                        height: 35 * ratioCalc
                                        width: 95 * ratioCalc
                                        checkedLabel: "On"
                                        uncheckedLabel: "Off"
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        grooveColor: "#0cf"

                                    }
                                }

                            }

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGInfoBox {
                                    id: setting4Reading
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    width: 100 * ratioCalc
                                    unit: "<b>A</b>"
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    anchors.centerIn: parent
                                }
                            }

                        }
                    }
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        RowLayout{
                            anchors.fill:parent
                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGText {
                                    anchors.centerIn: parent
                                    text: "NCS213R"
                                    font.bold: true
                                    fontSizeMultiplier: ratioCalc * 1.2
                                }
                            }

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGAlignedLabel {
                                    id: enabl5Label
                                    target: enable5
                                    text: "<b>" + qsTr("Enable") + "</b>"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    anchors.centerIn: parent
                                    alignment: SGAlignedLabel.SideLeftCenter
                                    SGSwitch {
                                        id: enable5
                                        height: 35 * ratioCalc
                                        width: 95 * ratioCalc
                                        checkedLabel: "On"
                                        uncheckedLabel: "Off"
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        grooveColor: "#0cf"

                                    }
                                }

                            }

                            Rectangle{
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                SGInfoBox {
                                    id: setting5Reading
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                    width: 100 * ratioCalc
                                    unit: "<b>A</b>"
                                    boxColor: "lightgrey"
                                    boxFont.family: Fonts.digitalseven
                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }
                    Rectangle{
                        id: rpmtSliderContainer
                        Layout.fillHeight: true
                        Layout.fillWidth: true


                        SGAlignedLabel {
                            id: rmpLabel
                            target: rpmSlider
                            text: "RPM"
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            alignment: SGAlignedLabel.SideTopLeft
                            anchors.centerIn: parent

                            SGSlider {
                                id: rpmSlider
                                width: rpmtSliderContainer.width - rmpLabel.contentWidth - 60
                                live: false
                                from: 0
                                to: 100
                                stepSize: 1
                                fromText.text: "0"
                                toText.text: "100"
                                value: 15
                                inputBoxWidth: 100 * ratioCalc
                                fontSizeMultiplier: ratioCalc * 0.9
                                inputBox.validator: IntValidator {
                                    top: rpmSlider.to
                                    bottom: rpmSlider.from
                                }
                            }
                        }
                    }
                }
            }

            Rectangle{
                Layout.preferredHeight: parent.height/3
                Layout.fillWidth: true
                Text {
                    id: interrupt
                    text: "Interrupts"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    color: "#696969"
                    anchors.top: parent.top
                }

                Rectangle {
                    id: line2
                    height: 2
                    Layout.alignment: Qt.AlignCenter
                    width: parent.width
                    border.color: "lightgray"
                    radius: 2
                    anchors {
                        top: interrupt.bottom
                        topMargin: 7
                    }
                }

                ColumnLayout{
                    anchors {
                        top: line2.bottom
                        topMargin: 10
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    RowLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id:voltageStatusLabel
                                target: voltageStatusLight
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc
                                text: "Voltage Status"
                                font.bold: true

                                SGStatusLight {
                                    id: voltageStatusLight
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id: currentStatusLabel
                                target: currentStatusLight
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc
                                text: "Current Status"
                                font.bold: true

                                SGStatusLight {
                                    id: currentStatusLight
                                }
                            }
                        }
                    }
                    Rectangle{
                        id: maxLoadContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        SGAlignedLabel {
                            id: maxLoadLabel
                            target: maxLoadCurrent
                            font.bold: true
                            alignment: SGAlignedLabel.SideLeftCenter
                            fontSizeMultiplier: ratioCalc
                            text: "Max Load"
                            anchors.centerIn: parent

                            SGInfoBox {
                                id: maxLoadCurrent
                                width: 100 * ratioCalc
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                boxColor: "lightgrey"
                                boxFont.family: Fonts.digitalseven
                                unit: "<b>A</b>"

                            }
                        }
                    }

                }



            }
        }
    }





}
