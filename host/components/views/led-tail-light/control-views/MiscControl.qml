import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    Rectangle {
        width: parent.width/2
        height: parent.height/2
        anchors.centerIn: parent

        RowLayout {
            anchors.fill: parent

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        SGAlignedLabel {
                            id: idVers1Label
                            text: "ID_VERS_1"
                            target: idVers1
                            alignment: SGAlignedLabel.SideTopLeft
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            SGInfoBox {
                                id: idVers1
                                height:  35 * ratioCalc
                                width: 140 * ratioCalc
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                // unit: "<b>V</b>"
                                text: "0x43"
                                boxFont.family: Fonts.digitalseven
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        SGAlignedLabel {
                            id: oddChannelErrorLabel
                            target: oddChannelError
                            alignment: SGAlignedLabel.SideTopCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            text: "Odd Channel Error"
                            font.bold: true

                            SGStatusLight {
                                id: oddChannelError

                            }

                        }

                    }
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        SGAlignedLabel {
                            id: idVers2Label
                            text: "ID_VERS_2"
                            target: idVers2
                            alignment: SGAlignedLabel.SideTopLeft
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            SGInfoBox {
                                id: idVers2
                                height:  35 * ratioCalc
                                width: 140 * ratioCalc
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                // unit: "<b>V</b>"
                                text: "0x04"
                                boxFont.family: Fonts.digitalseven
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        SGAlignedLabel {
                            id: evenChannelErrorLabel
                            target: evenChannelError
                            alignment: SGAlignedLabel.SideTopCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            text: "Odd Channel Error"
                            font.bold: true

                            SGStatusLight {
                                id: evenChannelError

                            }

                        }

                    }
                }
            }
        }
    }
}
