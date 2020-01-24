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

    function clear_all_gauge1_status(){
        sgCircularGauge11.value = 0
        sgCircularGauge21.value = 0
        sgCircularGauge31.value = 0
    }

    function clear_all_gauge2_status(){
        sgCircularGauge12.value = 0
        sgCircularGauge22.value = 0
        sgCircularGauge32.value = 0
    }

    property var check_pxndiag17_crc: platformInterface.pxn_diag_17_2.crc
    onCheck_pxndiag17_crcChanged: {
        if (check_pxndiag17_crc === true){
            sgStatusLight_17_crc.status = "red"
            clear_all_gauge1_status()
        }else if (check_pxndiag17_crc === false){
            sgStatusLight_17_crc.status = "green"
        }
    }

    property var check_pxndiag18_crc: platformInterface.pxn_diag_18_2.crc
    onCheck_pxndiag18_crcChanged: {
        if (check_pxndiag18_crc === true){
            sgStatusLight_18_crc.status = "red"
            clear_all_gauge2_status()
        }else if (check_pxndiag18_crc === false){
            sgStatusLight_18_crc.status = "green"

        }
    }

    property var read_adcs_res: platformInterface.pxn_diag_17_1.adcs_res
    onRead_adcs_resChanged: {
        sgCircularGauge11.value = read_adcs_res
    }

    property var read_vdd_res: platformInterface.pxn_diag_17_1.vdd_res
    onRead_vdd_resChanged: {
        sgCircularGauge21.value = read_vdd_res
    }

    property var read_temp_res: platformInterface.pxn_diag_17_1.temp_res
    onRead_temp_resChanged: {
        sgCircularGauge31.value = read_temp_res
    }

    property var read_tsd_code: platformInterface.pxn_diag_18_1.tsd_code
    onRead_tsd_codeChanged: {
        sgCircularGauge12.value = read_tsd_code
    }

    property var read_vled_res: platformInterface.pxn_diag_18_1.vled_res
    onRead_vled_resChanged: {
        sgCircularGauge22.value = read_vled_res
    }

    property var read_vbb_res: platformInterface.pxn_diag_18_1.vbb_res
    onRead_vbb_resChanged: {
        sgCircularGauge32.value = read_vbb_res
    }

    ColumnLayout{
        anchors.fill:parent

        Rectangle{
            id:rec0
            Layout.preferredWidth:parent.width/1.05
            Layout.preferredHeight: parent.height/1.2
            Layout.leftMargin: 30
            color:"transparent"

            RowLayout{
                anchors.fill: parent

                Rectangle{
                    id: rec11
                    Layout.preferredWidth:parent.width/3.5
                    Layout.preferredHeight: parent.height
                    color: "transparent"

                    ColumnLayout{
                        anchors.fill: parent
                        anchors{
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter:parent.verticalCenter
                        }

                        Text {
                            text: "ADCX_RES"
                            font {
                                pixelSize: 15
                            }
                            color:"black"
                        }

                        SGCircularGauge {
                            id: sgCircularGauge11
                            minimumValue: 0
                            maximumValue: 100
                            tickmarkStepSize: 10
                            gaugeRearColor: "#ddd"                  // Default: "#ddd"(background color that gets filled in by gauge)
                            centerColor: "black"
                            outerColor: "#999"
                            gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                            gaugeFrontColor2: Qt.rgba(1,0,0,1)
                            unitLabel: "Volts"                        // Default: "RPM"
                            value: 0.0
                        }

                        Text {
                            text: "TSD_CODE"
                            font {
                                pixelSize: 15
                            }
                            color:"black"
                        }

                        SGCircularGauge {
                            id: sgCircularGauge12
                            minimumValue: 0
                            maximumValue: 100
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
                    Layout.preferredWidth:parent.width/3.5
                    Layout.preferredHeight: parent.height
                    color: "transparent"

                    ColumnLayout{
                        anchors.fill: parent
                        anchors{
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter:parent.verticalCenter
                        }

                        Text {
                            text: "VDD_RES"
                            font {
                                pixelSize: 15
                            }
                            color:"black"
                        }

                        SGCircularGauge {
                            id: sgCircularGauge21
                            minimumValue: 0
                            maximumValue: 100
                            tickmarkStepSize: 10
                            gaugeRearColor: "#ddd"                  // Default: "#ddd"(background color that gets filled in by gauge)
                            centerColor: "black"
                            outerColor: "#999"
                            gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                            gaugeFrontColor2: Qt.rgba(1,0,0,1)
                            unitLabel: "Volts"                        // Default: "RPM"
                            value: 0.0
                        }

                        Text {
                            text: "VLED_RES"
                            font {
                                pixelSize: 15
                            }
                            color:"black"
                        }

                        SGCircularGauge {
                            id: sgCircularGauge22
                            minimumValue: 0
                            maximumValue: 100
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
                    id: rec13
                    Layout.preferredWidth:parent.width/3.5
                    Layout.preferredHeight: parent.height
                    color: "transparent"

                    ColumnLayout{
                        anchors.fill: parent
                        anchors{
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter:parent.verticalCenter
                        }

                        Text {
                            text: "TEMP_RES"
                            font {
                                pixelSize: 15
                            }
                            color:"black"
                        }

                        SGCircularGauge {
                            id: sgCircularGauge31
                            minimumValue: 0
                            maximumValue: 100
                            tickmarkStepSize: 10
                            gaugeRearColor: "#ddd"                  // Default: "#ddd"(background color that gets filled in by gauge)
                            centerColor: "black"
                            outerColor: "#999"
                            gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                            gaugeFrontColor2: Qt.rgba(1,0,0,1)
                            unitLabel: "Volts"                        // Default: "RPM"
                            value: 0.0
                        }

                        Text {
                            text: "VBB_RES"
                            font {
                                pixelSize: 15
                            }
                            color:"black"
                        }

                        SGCircularGauge {
                            id: sgCircularGauge32
                            minimumValue: 0
                            maximumValue: 100
                            tickmarkStepSize: 10
                            gaugeRearColor: "#ddd"                  // Default: "#ddd"(background color that gets filled in by gauge)
                            centerColor: "black"
                            outerColor: "#999"
                            gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                            gaugeFrontColor2: Qt.rgba(1,0,0,1)
                            unitLabel: "Degree C"                        // Default: "RPM"
                            value: 0.0
                        }
                    }
                }

                Rectangle{
                    id: rec14
                    Layout.preferredWidth:parent.width/8
                    Layout.preferredHeight: parent.height
                    color: "transparent"

                    ColumnLayout{
                        anchors.fill: parent
                        anchors{
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter:parent.verticalCenter
                        }

                        Rectangle{
                            Layout.fillWidth:true
                            Layout.preferredHeight: parent.height/3
                            color: "transparent"
                        }

                        SGStatusLight{
                            id: sgStatusLight_17_crc
                            label: "<b>0x11_RX_CRC_ERR</b>" // Default: "" (if not entered, label will not appear)
                            labelLeft: false        // Default: true
                            lightSize: 40           // Default: 50
                            textColor: "black"      // Default: "black"
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignCenter

                        }

                        SGStatusLight{
                            id: sgStatusLight_18_crc
                            label: "<b>0x12_RX_CRC_ERR</b>" // Default: "" (if not entered, label will not appear)
                            labelLeft: false        // Default: true
                            lightSize: 40           // Default: 50
                            textColor: "black"      // Default: "black"
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignCenter

                        }
                    }
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
                                platformInterface.pxn1_diag = true
                                platformInterface.pxn2_diag = false
                                platformInterface.pxn3_diag = false
                                send_pxn_diag_cmd2(segmentedButtons1.index+1, 1)
                            }
                        }

                        SGSegmentedButton{
                            text: qsTr("Pixel2")
                            onClicked: {
                                platformInterface.pxn1_diag = false
                                platformInterface.pxn2_diag = true
                                platformInterface.pxn3_diag = false
                                send_pxn_diag_cmd2(segmentedButtons1.index+1, 1)
                            }
                        }

                        SGSegmentedButton{
                            text: qsTr("Pixel3")
                            onClicked: {
                                platformInterface.pxn1_diag = false
                                platformInterface.pxn2_diag = false
                                platformInterface.pxn3_diag = true
                                send_pxn_diag_cmd2(segmentedButtons1.index+1, 1)
                            }
                        }
                    }
                }
            }
        }
    }
}

