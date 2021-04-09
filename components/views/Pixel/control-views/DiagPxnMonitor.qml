import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id:root
    width: parent.width
    height: parent.height

    function send_pxn_diag_cmd2(pix_ch,index){
        platformInterface.pxn_status_read.update(pix_ch,index)
    }

    function clear_all_gauge_status(){
        sgCircularGauge01.value = 0
        sgCircularGauge11.value = 0
        sgCircularGauge02.value = 0
        sgCircularGauge12.value = 0
    }

    property var read_vdd: platformInterface.pxn_diag_1718.vdd
    onRead_vddChanged: {
        sgCircularGauge01.value = read_vdd
    }

    property var read_temp: platformInterface.pxn_diag_1718.temp
    onRead_tempChanged: {
        sgCircularGauge11.value = read_temp
    }

    property var read_vled: platformInterface.pxn_diag_1718.vled
    onRead_vledChanged: {
        sgCircularGauge02.value = read_vled
    }

    property var read_vbb: platformInterface.pxn_diag_1718.vbb
    onRead_vbbChanged: {
        sgCircularGauge12.value = read_vbb
    }

    ColumnLayout{
        anchors.fill:parent

        Rectangle{
            id:rec0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 30
            Layout.leftMargin: 30
            color:"transparent"

            RowLayout{
                anchors.fill: parent

                Rectangle{
                    id: rec10
                    Layout.preferredWidth:parent.width*0.1
                    Layout.fillHeight: true
                    color: "transparent"
                }

                Rectangle{
                    id: rec11
                    Layout.preferredWidth:parent.width*0.3
                    Layout.fillHeight: true
                    color: "transparent"

                    ColumnLayout{
                        anchors.fill: parent
                        anchors{
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter:parent.verticalCenter
                        }

                        Text {
                            text: "VDD"
                            font {
                                pixelSize: 15
                            }
                            color:"black"
                        }

                        SGCircularGauge {
                            id: sgCircularGauge01
                            minimumValue: 0.0
                            maximumValue: 5.0
                            tickmarkStepSize: 1.0
                            gaugeRearColor: "#ddd"                  // Default: "#ddd"(background color that gets filled in by gauge)
                            centerColor: "black"
                            outerColor: "#999"
                            gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                            gaugeFrontColor2: Qt.rgba(1,0,0,1)
                            unitLabel: "Volts"                        // Default: "RPM"
                            value: 0.0
                        }

                        Text {
                            text: "VLED"
                            font {
                                pixelSize: 15
                            }
                            color:"black"
                        }

                        SGCircularGauge {
                            id: sgCircularGauge02
                            minimumValue: 0
                            maximumValue: 60
                            tickmarkStepSize: 10
                            gaugeRearColor: "#ddd"                  // Default: "#ddd"(background color that gets filled in by gauge)
                            centerColor: "black"
                            outerColor: "#999"
                            gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                            gaugeFrontColor2: Qt.rgba(1,0,0,1)
                            unitLabel: "Volts"                        // Default: "RPM"
                            value: 0.0
                        }
                    }
                }

                Rectangle{
                    id: rec12
                    Layout.preferredWidth: parent.width*0.2
                    Layout.fillHeight: true
                    color: "transparent"

                    ColumnLayout{
                        anchors.fill: parent
                        anchors{
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter:parent.verticalCenter
                        }

                        Text {
                            text: "TEMP"
                            font {
                                pixelSize: 15
                            }
                            color:"black"
                        }

                        SGCircularGauge {
                            id: sgCircularGauge11
                            minimumValue: 0
                            maximumValue: 150
                            tickmarkStepSize: 10
                            gaugeRearColor: "#ddd"                  // Default: "#ddd"(background color that gets filled in by gauge)
                            centerColor: "black"
                            outerColor: "#999"
                            gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                            gaugeFrontColor2: Qt.rgba(1,0,0,1)
                            unitLabel: "Degree C"                        // Default: "RPM"
                            value: 0.0
                        }

                        Text {
                            text: "VBB"
                            font {
                                pixelSize: 15
                            }
                            color:"black"
                        }

                        SGCircularGauge {
                            id: sgCircularGauge12
                            minimumValue: 0
                            maximumValue: 24
                            tickmarkStepSize: 4
                            gaugeRearColor: "#ddd"                  // Default: "#ddd"(background color that gets filled in by gauge)
                            centerColor: "black"
                            outerColor: "#999"
                            gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                            gaugeFrontColor2: Qt.rgba(1,0,0,1)
                            unitLabel: "Volts"                        // Default: "RPM"
                            value: 0.0
                        }
                    }
                }
                Rectangle{
                    id: rec13
                    Layout.preferredWidth:parent.width*0.1
                    Layout.fillHeight: true
                    color: "transparent"
                }
            }
        }

        Rectangle{
            id:rec1
            Layout.preferredWidth: parent.width/1.05
            Layout.preferredHeight: parent.height/18
            Layout.leftMargin: 30
            color:"transparent"

            RowLayout{
                anchors.fill: parent
                Layout.preferredWidth: parent.width/4.5
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter

                SGSegmentedButtonStrip {
                    id: segmentedButtons1
                    Layout.alignment: Qt.AlignCenter

                    segmentedButtons: GridLayout {
                        columnSpacing: 3

                        SGSegmentedButton{
                            text: qsTr("Pixel1")
                            onClicked: {
                                send_pxn_diag_cmd2(segmentedButtons1.index+1, 1)
                            }
                        }

                        SGSegmentedButton{
                            text: qsTr("Pixel2")
                            onClicked: {
                                send_pxn_diag_cmd2(segmentedButtons1.index+1, 1)
                            }
                        }

                        SGSegmentedButton{
                            text: qsTr("Pixel3")
                            onClicked: {
                                send_pxn_diag_cmd2(segmentedButtons1.index+1, 1)
                            }
                        }
                    }
                }
            }
        }
    }
}

