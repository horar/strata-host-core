import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id:root
    width: parent.width
    height: parent.height

    function send_pxn_diag_cmd(pix_ch,index){
        platformInterface.pxn_status_read.update(pix_ch,index)
    }

    function clear_all_sw_status_led(){
        sgStatusLight_sw12.status = "off"
        sgStatusLight_sw11.status = "off"
        sgStatusLight_sw10.status = "off"
        sgStatusLight_sw9.status = "off"
        sgStatusLight_sw8.status = "off"
        sgStatusLight_sw7.status = "off"
        sgStatusLight_sw6.status = "off"
        sgStatusLight_sw5.status = "off"
        sgStatusLight_sw4.status = "off"
        sgStatusLight_sw3.status = "off"
        sgStatusLight_sw2.status = "off"
        sgStatusLight_sw1.status = "off"
    }

    function clear_all_dig_status_led(){
        sgStatusLight_b19.status = "off"
        sgStatusLight_b18.status = "off"
        sgStatusLight_b17.status = "off"
        sgStatusLight_b16.status = "off"
        sgStatusLight_b15.status = "off"
        sgStatusLight_b14.status = "off"
        sgStatusLight_b13.status = "off"
        sgStatusLight_b12.status = "off"
        sgStatusLight_b11.status = "off"
        sgStatusLight_b10.status = "off"
        sgStatusLight_b9.status = "off"
        sgStatusLight_b8.status = "off"
        sgStatusLight_b7.status = "off"
        sgStatusLight_b6.status = "off"
        sgStatusLight_b4.status = "off"
        sgStatusLight_b3.status = "off"
        sgStatusLight_b2.status = "off"
        sgStatusLight_b1.status = "off"
        sgStatusLight_b0.status = "off"
    }

    property var check_pxn_crc_err: platformInterface.pxn_diag_16_1.pxn_crc_err
    onCheck_pxn_crc_errChanged: {
        labelledInfoBox1.info = check_pxn_crc_err
    }

    property var check_pxndiag10_b19: platformInterface.pxn_diag_16_1.otp_crc_fal0
    onCheck_pxndiag10_b19Changed: {
        if (check_pxndiag10_b19 === true){
            sgStatusLight_b19.status = "red"
        }else if (check_pxndiag10_b19 === false){
            sgStatusLight_b19.status = "green"
        }
    }

    property var check_pxndiag10_b18: platformInterface.pxn_diag_16_1.otp_crc_fal2
    onCheck_pxndiag10_b18Changed: {
        if (check_pxndiag10_b18 === true){
            sgStatusLight_b18.status = "red"
        }else if (check_pxndiag10_b18 === false){
            sgStatusLight_b18.status = "green"
        }
    }

    property var check_pxndiag10_b17: platformInterface.pxn_diag_16_1.timeout
    onCheck_pxndiag10_b17Changed: {
        if (check_pxndiag10_b17 === true){
            sgStatusLight_b17.status = "red"
        }else if (check_pxndiag10_b17 === false){
            sgStatusLight_b17.status = "green"
        }
    }

    property var check_pxndiag10_b16: platformInterface.pxn_diag_16_1.pxn_syn_err
    onCheck_pxndiag10_b16Changed: {
        if (check_pxndiag10_b16 === true){
            sgStatusLight_b16.status = "red"
        }else if (check_pxndiag10_b16 === false){
            sgStatusLight_b16.status = "green"
        }
    }

    property var check_pxndiag10_b15: platformInterface.pxn_diag_16_1.pxn_frm_err
    onCheck_pxndiag10_b15Changed: {
        if (check_pxndiag10_b15 === true){
            sgStatusLight_b15.status = "red"
        }else if (check_pxndiag10_b15 === false){
            sgStatusLight_b15.status = "green"
        }
    }

    property var check_pxndiag10_b14: platformInterface.pxn_diag_16_1.pxn_loc_err
    onCheck_pxndiag10_b14Changed: {
        if (check_pxndiag10_b14 === true){
            sgStatusLight_b14.status = "red"
        }else if (check_pxndiag10_b14 === false){
            sgStatusLight_b14.status = "green"
        }
    }

    property var check_pxndiag10_b13: platformInterface.pxn_diag_16_1.pxn_glob_err
    onCheck_pxndiag10_b13Changed: {
        if (check_pxndiag10_b13 === true){
            sgStatusLight_b13.status = "red"
        }else if (check_pxndiag10_b13 === false){
            sgStatusLight_b13.status = "green"
        }
    }

    property var check_pxndiag10_b12: platformInterface.pxn_diag_16_1.mapena_stat
    onCheck_pxndiag10_b12Changed: {
        if (check_pxndiag10_b12 === true){
            sgStatusLight_b12.status = "red"
        }else if (check_pxndiag10_b12 === false){
            sgStatusLight_b12.status = "green"
        }
    }

    property var check_pxndiag10_b11: platformInterface.pxn_diag_16_1.pwm_cnt_ovf
    onCheck_pxndiag10_b11Changed: {
        if (check_pxndiag10_b11 === true){
            sgStatusLight_b11.status = "red"
        }else if (check_pxndiag10_b11 === false){
            sgStatusLight_b11.status = "green"
        }
    }

    property var check_pxndiag10_b10: platformInterface.pxn_diag_16_0.gnd_loss
    onCheck_pxndiag10_b10Changed: {
        if (check_pxndiag10_b10 === true){
            sgStatusLight_b10.status = "red"
        }else if (check_pxndiag10_b10 === false){
            sgStatusLight_b10.status = "green"
        }
    }

    property var check_pxndiag10_b9: platformInterface.pxn_diag_16_0.vbb_low
    onCheck_pxndiag10_b9Changed: {
        if (check_pxndiag10_b9 === true){
            sgStatusLight_b9.status = "red"
        }else if (check_pxndiag10_b9 === false){
            sgStatusLight_b9.status = "green"
        }
    }

    property var check_pxndiag10_b8: platformInterface.pxn_diag_16_0.otp_zap_uv
    onCheck_pxndiag10_b8Changed: {
        if (check_pxndiag10_b8 === true){
            sgStatusLight_b8.status = "red"
        }else if (check_pxndiag10_b8 === false){
            sgStatusLight_b8.status = "green"
        }
    }

    property var check_pxndiag10_b7: platformInterface.pxn_diag_16_0.cap_uv
    onCheck_pxndiag10_b7Changed: {
        if (check_pxndiag10_b7 === true){
            sgStatusLight_b7.status = "red"
        }else if (check_pxndiag10_b7 === false){
            sgStatusLight_b7.status = "green"
        }
    }

    property var check_pxndiag10_b6: platformInterface.pxn_diag_16_0.hwr
    onCheck_pxndiag10_b6Changed: {
        if (check_pxndiag10_b6 === true){
            sgStatusLight_b6.status = "red"
        }else if (check_pxndiag10_b6 === false){
            sgStatusLight_b6.status = "green"
        }
    }

    property var check_pxndiag10_b4: platformInterface.pxn_diag_16_0.dmerr
    onCheck_pxndiag10_b4Changed: {
        if (check_pxndiag10_b4 === true){
            sgStatusLight_b4.status = "red"
        }else if (check_pxndiag10_b4 === false){
            sgStatusLight_b4.status = "green"
        }
    }

    property var check_pxndiag10_b3: platformInterface.pxn_diag_16_0.dmwarn
    onCheck_pxndiag10_b3Changed: {
        if (check_pxndiag10_b3 === true){
            sgStatusLight_b3.status = "red"
        }else if (check_pxndiag10_b3 === false){
            sgStatusLight_b3.status = "green"
        }
    }

    property var check_pxndiag10_b2: platformInterface.pxn_diag_16_0.gswerr
    onCheck_pxndiag10_b2Changed: {
        if (check_pxndiag10_b2 === true){
            sgStatusLight_b2.status = "red"
        }else if (check_pxndiag10_b2 === false){
            sgStatusLight_b2.status = "green"
        }
    }

    property var check_pxndiag10_b1: platformInterface.pxn_diag_16_0.tsd
    onCheck_pxndiag10_b1Changed: {
        if (check_pxndiag10_b1 === true){
            sgStatusLight_b1.status = "red"
        }else if (check_pxndiag10_b1 === false){
            sgStatusLight_b1.status = "green"
        }
    }

    property var check_pxndiag10_b0: platformInterface.pxn_diag_16_0.tw
    onCheck_pxndiag10_b0Changed: {
        if (check_pxndiag10_b0 === true){
            sgStatusLight_b0.status = "red"
        }else if (check_pxndiag10_b0 === false){
            sgStatusLight_b0.status = "green"
        }
    }

    property var read_pxn_status_info_sw12: platformInterface.pxn_diag_15_1.sw12
    onRead_pxn_status_info_sw12Changed: {
        if (read_pxn_status_info_sw12 === 0){
            sgStatusLight_sw12.status = "green"
        }else if (read_pxn_status_info_sw12 === 1){
            sgStatusLight_sw12.status = "red"
        }else if (read_pxn_status_info_sw12 === 2){
            sgStatusLight_sw12.status = "yellow"
        }else if (read_pxn_status_info_sw12 === 3){
            sgStatusLight_sw12.status = "orange"
        }
    }

    property var read_pxn_status_info_sw11: platformInterface.pxn_diag_15_1.sw11
    onRead_pxn_status_info_sw11Changed: {
        if (read_pxn_status_info_sw11 === 0){
            sgStatusLight_sw11.status = "green"
        }else if (read_pxn_status_info_sw11 === 1){
            sgStatusLight_sw11.status = "red"
        }else if (read_pxn_status_info_sw11 === 2){
            sgStatusLight_sw11.status = "yellow"
        }else if (read_pxn_status_info_sw11 === 3){
            sgStatusLight_sw11.status = "orange"
        }
    }

    property var read_pxn_status_info_sw10: platformInterface.pxn_diag_15_1.sw10
    onRead_pxn_status_info_sw10Changed: {
        if (read_pxn_status_info_sw10 === 0){
            sgStatusLight_sw10.status = "green"
        }else if (read_pxn_status_info_sw10 === 1){
            sgStatusLight_sw10.status = "red"
        }else if (read_pxn_status_info_sw10 === 2){
            sgStatusLight_sw10.status = "yellow"
        }else if (read_pxn_status_info_sw10 === 3){
            sgStatusLight_sw10.status = "orange"
        }

    }

    property var read_pxn_status_info_sw9: platformInterface.pxn_diag_15_1.sw9
    onRead_pxn_status_info_sw9Changed: {
        if (read_pxn_status_info_sw9 === 0){
            sgStatusLight_sw9.status = "green"
        }else if (read_pxn_status_info_sw9 === 1){
            sgStatusLight_sw9.status = "red"
        }else if (read_pxn_status_info_sw9 === 2){
            sgStatusLight_sw9.status = "yellow"
        }else if (read_pxn_status_info_sw9 === 3){
            sgStatusLight_sw9.status = "orange"
        }
    }

    property var read_pxn_status_info_sw8: platformInterface.pxn_diag_15_1.sw8
    onRead_pxn_status_info_sw8Changed: {
        if (read_pxn_status_info_sw8 === 0){
            sgStatusLight_sw8.status = "green"
        }else if (read_pxn_status_info_sw8 === 1){
            sgStatusLight_sw8.status = "red"
        }else if (read_pxn_status_info_sw8 === 2){
            sgStatusLight_sw8.status = "yellow"
        }else if (read_pxn_status_info_sw8 === 3){
            sgStatusLight_sw8.status = "orange"
        }
    }

    property var read_pxn_status_info_sw7: platformInterface.pxn_diag_15_1.sw7
    onRead_pxn_status_info_sw7Changed: {
        if (read_pxn_status_info_sw7 === 0){
            sgStatusLight_sw7.status = "green"
        }else if (read_pxn_status_info_sw7 === 1){
            sgStatusLight_sw7.status = "red"
        }else if (read_pxn_status_info_sw7 === 2){
            sgStatusLight_sw7.status = "yellow"
        }else if (read_pxn_status_info_sw7 === 3){
            sgStatusLight_sw7.status = "orange"
        }
    }

    property var read_pxn_status_info_sw6: platformInterface.pxn_diag_15_0.sw6
    onRead_pxn_status_info_sw6Changed: {
        if (read_pxn_status_info_sw6 === 0){
            sgStatusLight_sw6.status = "green"
        }else if (read_pxn_status_info_sw6 === 1){
            sgStatusLight_sw6.status = "red"
        }else if (read_pxn_status_info_sw6 === 2){
            sgStatusLight_sw6.status = "yellow"
        }else if (read_pxn_status_info_sw6 === 3){
            sgStatusLight_sw6.status = "orange"
        }
    }

    property var read_pxn_status_info_sw5: platformInterface.pxn_diag_15_0.sw5
    onRead_pxn_status_info_sw5Changed: {
        if (read_pxn_status_info_sw5 === 0){
            sgStatusLight_sw5.status = "green"
        }else if (read_pxn_status_info_sw5 === 1){
            sgStatusLight_sw5.status = "red"
        }else if (read_pxn_status_info_sw5 === 2){
            sgStatusLight_sw5.status = "yellow"
        }else if (read_pxn_status_info_sw5 === 3){
            sgStatusLight_sw5.status = "orange"
        }
    }

    property var read_pxn_status_info_sw4: platformInterface.pxn_diag_15_0.sw4
    onRead_pxn_status_info_sw4Changed: {
        if (read_pxn_status_info_sw4 === 0){
            sgStatusLight_sw4.status = "green"
        }else if (read_pxn_status_info_sw4 === 1){
            sgStatusLight_sw4.status = "red"
        }else if (read_pxn_status_info_sw4 === 2){
            sgStatusLight_sw4.status = "yellow"
        }else if (read_pxn_status_info_sw4 === 3){
            sgStatusLight_sw4.status = "orange"
        }
    }

    property var read_pxn_status_info_sw3: platformInterface.pxn_diag_15_0.sw3
    onRead_pxn_status_info_sw3Changed: {
        if (read_pxn_status_info_sw3 === 0){
            sgStatusLight_sw3.status = "green"
        }else if (read_pxn_status_info_sw3 === 1){
            sgStatusLight_sw3.status = "red"
        }else if (read_pxn_status_info_sw3 === 2){
            sgStatusLight_sw3.status = "yellow"
        }else if (read_pxn_status_info_sw3 === 3){
            sgStatusLight_sw3.status = "orange"
        }
    }

    property var read_pxn_status_info_sw2: platformInterface.pxn_diag_15_0.sw2
    onRead_pxn_status_info_sw2Changed: {
        if (read_pxn_status_info_sw2 === 0){
            sgStatusLight_sw2.status = "green"
        }else if (read_pxn_status_info_sw2 === 1){
            sgStatusLight_sw2.status = "red"
        }else if (read_pxn_status_info_sw2 === 2){
            sgStatusLight_sw2.status = "yellow"
        }else if (read_pxn_status_info_sw2 === 3){
            sgStatusLight_sw2.status = "orange"
        }
    }

    property var read_pxn_status_info_sw1: platformInterface.pxn_diag_15_0.sw1
    onRead_pxn_status_info_sw1Changed: {
        if (read_pxn_status_info_sw1 === 0){
            sgStatusLight_sw1.status = "green"
        }else if (read_pxn_status_info_sw1 === 1){
            sgStatusLight_sw1.status = "red"
        }else if (read_pxn_status_info_sw1 === 2){
            sgStatusLight_sw1.status = "yellow"
        }else if (read_pxn_status_info_sw1 === 3){
            sgStatusLight_sw1.status = "orange"
        }
    }

    property bool check_pxn1_diag_state: platformInterface.pxn1_diag
    onCheck_pxn1_diag_stateChanged: {
        if (check_pxn1_diag_state === true){
            sgStatusLight_led1.status = "green"
        }else {
            sgStatusLight_led1.status = "off"
        }
    }

    property bool check_pxn2_diag_state: platformInterface.pxn2_diag
    onCheck_pxn2_diag_stateChanged: {
        if (check_pxn2_diag_state === true) {
            sgStatusLight_led2.status = "green"
        }else{
            sgStatusLight_led2.status = "off"
        }
    }

    property bool check_pxn3_diag_state: platformInterface.pxn3_diag
    onCheck_pxn3_diag_stateChanged: {
        if (check_pxn3_diag_state === true) {
            sgStatusLight_led3.status = "green"
        }else {
            sgStatusLight_led3.status = "off"
        }
    }

    ColumnLayout{
        anchors.fill: parent

        Rectangle{
            id: space
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height/30
            color:"transparent"
        }

        Rectangle{
            id: rec0
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height*0.2
            color:"transparent"

            RowLayout{
                anchors.fill: parent
                anchors{
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                SGStatusLight{
                    id: sgStatusLight_sw1
                    label: "<b>SW1</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 40           // Default: 50
                    textColor: "black"      // Default: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight_sw2
                    label: "<b>SW2</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 40           // Default: 50
                    textColor: "black"      // Default: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight_sw3
                    label: "<b>SW3</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 40           // Default: 50
                    textColor: "black"      // Default: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight_sw4
                    label: "<b>SW4</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 40           // Default: 50
                    textColor: "black"      // Default: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight_sw5
                    label: "<b>SW5</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 40           // Default: 50
                    textColor: "black"      // Default: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight_sw6
                    label: "<b>SW6</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 40           // Default: 50
                    textColor: "black"      // Default: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight_sw7
                    label: "<b>SW7</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 40           // Default: 50
                    textColor: "black"      // Default: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight_sw8
                    label: "<b>SW8</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 40           // Default: 50
                    textColor: "black"      // Default: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight_sw9
                    label: "<b>SW9</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 40           // Default: 50
                    textColor: "black"      // Default: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight_sw10
                    label: "<b>SW10</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 40           // Default: 50
                    textColor: "black"      // Default: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight_sw11
                    label: "<b>SW11</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 40           // Default: 50
                    textColor: "black"      // Default: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight_sw12
                    label: "<b>SW12</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 40           // Default: 50
                    textColor: "black"      // Default: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }
            }
        }

        Rectangle{
            id: rec1
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height*0.6
            color:"transparent"

            RowLayout{
                anchors.fill:parent

                Rectangle{
                    id:rec10
                    Layout.fillHeight: true
                    Layout.preferredWidth:parent.width*0.1
                    color:"transparent"
                }

                Rectangle{
                    id:rec11
                    Layout.fillHeight: true
                    Layout.preferredWidth:parent.width*0.7
                    color:"transparent"

                    ColumnLayout{
                        anchors.fill:parent

                        Rectangle{
                            id:rec111
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color:"transparent"

                            RowLayout{
                                anchors.fill:parent
                                anchors{
                                    top: parent.top
                                    horizontalCenter: parent.horizontalCenter
                                    verticalCenter: parent.verticalCenter
                                }

                                Rectangle{
                                    id:rec1111
                                    Layout.preferredWidth:parent.width/8
                                    Layout.fillHeight: true
                                    Layout.leftMargin: 10
                                    Layout.topMargin: 10
                                    Layout.bottomMargin: 5
                                    color:"transparent"

                                    ColumnLayout{
                                        anchors.fill: parent
                                        anchors{
                                            top: parent.top
                                            horizontalCenter: parent.horizontalCenter
                                            verticalCenter: parent.verticalCenter
                                        }

                                        SGLabelledInfoBox {
                                            id: labelledInfoBox1
                                            infoBoxWidth: 125
                                            label: "PXN_CRC_ERR_CNT:"
                                            labelLeft: false
                                            info: "0"
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b19
                                            label: "<b>OTP_CRC_FAIL_BANK0</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b18
                                            label: "<b>OTP_CRC_FAIL_BANK2</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b17
                                            label: "<b>TIMEOUT</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }
                                    }
                                }

                                Rectangle{
                                    id:rec1112
                                    Layout.preferredWidth:parent.width/8
                                    Layout.fillHeight: true
                                    Layout.leftMargin: 10
                                    Layout.topMargin: 10
                                    Layout.bottomMargin: 5
                                    color:"transparent"

                                    ColumnLayout{
                                        anchors.fill: parent
                                        anchors{
                                            top: parent.top
                                            horizontalCenter: parent.horizontalCenter
                                            verticalCenter: parent.verticalCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b16
                                            label: "<b>PXN_SYNC_ERR</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b15
                                            label: "<b>PXN_FRAME_ERR</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b14
                                            label: "<b>PXN_LOCAL_COMM_ERR</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b13
                                            label: "<b>PXN_LOCAL_GLOBAL_ERR</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }
                                    }
                                }

                                Rectangle{
                                    id:rec1113
                                    Layout.preferredWidth:parent.width/8
                                    Layout.fillHeight: true
                                    Layout.leftMargin: 10
                                    Layout.topMargin: 10
                                    Layout.bottomMargin: 5
                                    color:"transparent"

                                    ColumnLayout{
                                        anchors.fill: parent
                                        anchors{
                                            top: parent.top
                                            horizontalCenter: parent.horizontalCenter
                                            verticalCenter: parent.verticalCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b12
                                            label: "<b>MAPENA_STATUS</b>" // Default: "" (if not entered, label will not appear) // 20201023 YI
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b11
                                            label: "<b>PWM_CNT_OVF</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b10
                                            label: "<b>GND_LOSS</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b9
                                            label: "<b>VBB_LOW</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }
                                    }
                                }

                                Rectangle{
                                    id:rec1114
                                    Layout.preferredWidth:parent.width/8
                                    Layout.fillHeight: true
                                    Layout.leftMargin: 10
                                    Layout.topMargin: 10
                                    Layout.bottomMargin: 5
                                    color:"transparent"

                                    ColumnLayout{
                                        anchors.fill: parent
                                        anchors{
                                            top: parent.top
                                            horizontalCenter: parent.horizontalCenter
                                            verticalCenter: parent.verticalCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b8
                                            label: "<b>OTP_ZAP_UV</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b7
                                            label: "<b>CAP_UV</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b6
                                            label: "<b>HWR</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b4
                                            label: "<b>DMERR</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }
                                    }
                                }

                                Rectangle{
                                    id:rec1115
                                    Layout.preferredWidth:parent.width/8
                                    Layout.fillHeight: true
                                    Layout.leftMargin: 10
                                    Layout.topMargin: 10
                                    Layout.bottomMargin: 5
                                    color:"transparent"

                                    ColumnLayout{
                                        anchors.fill: parent
                                        anchors{
                                            top: parent.top
                                            horizontalCenter: parent.horizontalCenter
                                            verticalCenter: parent.verticalCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b3
                                            label: "<b>DMWARN</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b2
                                            label: "<b>GSWERR</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b1
                                            label: "<b>TSD</b>" // Default: "" (if not entered, label will not appear)
                                            labelLeft: false        // Default: true
                                            lightSize: 40           // Default: 50
                                            textColor: "black"      // Default: "black"
                                            Layout.fillHeight: true
                                            Layout.alignment: Qt.AlignCenter
                                        }

                                        SGStatusLight{
                                            id: sgStatusLight_b0
                                            label: "<b>TW</b>" // Default: "" (if not entered, label will not appear)
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
                    }
                }


                Rectangle{
                    id:rec12
                    Layout.preferredWidth:parent.width*0.3
                    Layout.fillHeight: true
                    color:"transparent"

                    RowLayout{
                        anchors.fill: parent

                        Rectangle{
                            id:rec121
                            Layout.preferredWidth:parent.width*0.4
                            Layout.fillHeight: true
                            color:"transparent"

                            ColumnLayout{
                                anchors.fill: parent
                                anchors{
                                    top: parent.top
                                    horizontalCenter: parent.horizontalCenter
                                    verticalCenter: parent.verticalCenter
                                }

                                SGStatusLight{
                                    id: sgStatusLight_led1
                                    label: "<b>Pixel1</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 40           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight_led2
                                    label: "<b>Pixel2</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 40           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight_led3
                                    label: "<b>Pixel3</b>" // Default: "" (if not entered, label will not appear)
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
            }
        }


        Rectangle{
            id:rec2
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height*0.2
            color:"transparent"

            RowLayout{
                anchors.fill: parent

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    SGSegmentedButtonStrip {
                        id: segmentedButtons1
                        anchors.centerIn: parent

                        segmentedButtons: GridLayout {
                            columnSpacing: 3

                            SGSegmentedButton{
                                text: qsTr("Pixel1")
                                checked: true
                                onClicked: {
                                    send_pxn_diag_cmd(segmentedButtons1.index+1, 0)
                                    platformInterface.pxn1_diag = true
                                    platformInterface.pxn2_diag = false
                                    platformInterface.pxn3_diag = false
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("Pixel2")
                                onClicked: {
                                    send_pxn_diag_cmd(segmentedButtons1.index+1, 0)
                                    platformInterface.pxn1_diag = false
                                    platformInterface.pxn2_diag = true
                                    platformInterface.pxn3_diag = false
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("Pixel3")
                                onClicked: {
                                    send_pxn_diag_cmd(segmentedButtons1.index+1, 0)
                                    platformInterface.pxn1_diag = false
                                    platformInterface.pxn2_diag = false
                                    platformInterface.pxn3_diag = true
                                }
                            }
                        }
                    }
                }
            }
        }

        Component.onCompleted:  {
            Help.registerTarget(segmentedButtons1, "The diagonstic information of each Pixel IC will show when Pixel1 or Pixel2 or Pixel3 button pressed.", 0, "Help3")
            Help.registerTarget(sgStatusLight_led1, "Indicator shows which Pixel device infomration is displaying.", 1, "Help3")

        }
    }
}



