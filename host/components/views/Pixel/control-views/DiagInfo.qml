import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id:root
    width: parent.width
    height: parent.height

    property var read_boost_diag_status: platformInterface.diag1_boost.status
    onRead_boost_diag_statusChanged: {
        if (read_boost_diag_status === "OK"){
            platformInterface.boost_diag_read.update(2)
        }
    }

    property var check_boost_diag_hwr: platformInterface.diag1_boost.hwr
    onCheck_boost_diag_hwrChanged: {
        if (check_boost_diag_hwr === true){
            sgStatusLight111.status = "red"
        } else if (check_boost_diag_hwr === false){
            sgStatusLight111.status = "green"
        } else {
            sgStatusLight111.status = "off"
        }
    }

    property var check_boost_diag_boost1_status: platformInterface.diag1_boost.boost1_status
    onCheck_boost_diag_boost1_statusChanged: {
        if (check_boost_diag_boost1_status === true){
            sgStatusLight112.status = "green"
        }else {
            sgStatusLight112.status = "off"
        }
    }

    property var check_boost_diag_boost2_status: platformInterface.diag1_boost.boost2_status
    onCheck_boost_diag_boost2_statusChanged: {
        if (check_boost_diag_boost2_status === true){
            sgStatusLight113.status = "green"
        }else {
            sgStatusLight113.status = "off"
        }
    }

    property var check_boost_diag_boost_ov: platformInterface.diag1_boost.boost_ov
    onCheck_boost_diag_boost_ovChanged: {
        if (check_boost_diag_boost_ov === true){
            sgStatusLight114.status = "red"
        } else if (check_boost_diag_boost_ov === false){
            sgStatusLight114.status = "green"
        } else {
            sgStatusLight114.status = "off"
        }
    }

    property var check_boost_diag_temp_out: platformInterface.diag1_boost.temp_out
    onCheck_boost_diag_temp_outChanged: {
        if (check_boost_diag_temp_out === true){
            sgStatusLight115.status = "red"
        } else if (check_boost_diag_temp_out === false){
            sgStatusLight115.status = "green"
        } else {
            sgStatusLight115.status = "off"
        }
    }

    property var check_boost_diag_spierr: platformInterface.diag1_boost.spierr
    onCheck_boost_diag_spierrChanged: {
        if (check_boost_diag_spierr === true){
            sgStatusLight116.status = "red"
        } else if (check_boost_diag_spierr === false){
            sgStatusLight116.status = "green"
        } else {
            sgStatusLight116.status = "off"
        }
    }

    property var check_boost_diag_tsd: platformInterface.diag1_boost.tsd
    onCheck_boost_diag_tsdChanged: {
        if (check_boost_diag_tsd === true){
            sgStatusLight121.status = "red"
        } else if (check_boost_diag_tsd === false){
            sgStatusLight121.status = "green"
        } else {
            sgStatusLight121.status = "off"
        }
    }

    property var check_boost_diag_tw: platformInterface.diag1_boost.tw
    onCheck_boost_diag_twChanged: {
        if (check_boost_diag_tw === true){
            sgStatusLight122.status = "red"
        } else if (check_boost_diag_tw === false){
            sgStatusLight122.status = "green"
        } else {
            sgStatusLight122.status = "off"
        }
    }

    property var check_boost_diag_enable1_status: platformInterface.diag2_boost.enable1_status
    onCheck_boost_diag_enable1_statusChanged: {
        if (check_boost_diag_enable1_status === true){
            sgStatusLight123.status = "green"
        }else {
            sgStatusLight123.status = "off"
        }
    }

    property var check_boost_diag_enable2_status: platformInterface.diag2_boost.enable2_status
    onCheck_boost_diag_enable2_statusChanged: {
        if (check_boost_diag_enable2_status === true){
            sgStatusLight124.status = "green"
        }else {
            sgStatusLight124.status = "off"
        }
    }

    property var check_boost_diag_vdrive_nok: platformInterface.diag2_boost.vdrive_nok
    onCheck_boost_diag_vdrive_nokChanged: {
        if (check_boost_diag_vdrive_nok === true){
            sgStatusLight125.status = "red"
        } else if (check_boost_diag_vdrive_nok === false){
            sgStatusLight125.status = "green"
        } else {
            sgStatusLight125.status = "off"
        }
    }

    property var check_boost_diag_vbstdiv_uv: platformInterface.diag2_boost.vbstdiv_uv
    onCheck_boost_diag_vbstdiv_uvChanged: {
        if (check_boost_diag_vbstdiv_uv === true){
            sgStatusLight126.status = "red"
        } else if (check_boost_diag_vbstdiv_uv === false){
            sgStatusLight126.status = "green"
        } else {
            sgStatusLight126.status = "off"
        }

    }

    property var read_buck_diag_status: platformInterface.diag1_buck.status
    onRead_buck_diag_statusChanged: {
        if (read_buck_diag_status === "OK") {
            if (platformInterface.buck1_diag === true){
                platformInterface.buck_diag_read.update(1,2)
            }else if (platformInterface.buck2_diag === true){
                platformInterface.buck_diag_read.update(2,2)
            }else if (platformInterface.buck3_diag === true){
                platformInterface.buck_diag_read.update(3,2)
            }
        }
    }

    property var check_buck_diag_openled1: platformInterface.diag1_buck.openled1
    onCheck_buck_diag_openled1Changed: {
        if (check_buck_diag_openled1 === true){
            sgStatusLight211.status = "red"
        }else if (check_buck_diag_openled1 === false){
            sgStatusLight211.status = "green"
        }else {
            sgStatusLight211.status = "off"
        }
    }

    property var check_buck_diag_shortled1: platformInterface.diag1_buck.shortled1
    onCheck_buck_diag_shortled1Changed: {
        if (check_buck_diag_shortled1 === true){
            sgStatusLight212.status = "red"
        }else if (check_buck_diag_shortled1 === false){
            sgStatusLight212.status = "green"
        }else {
            sgStatusLight212.status = "off"
        }
    }

    property var check_buck_diag_ocled1: platformInterface.diag1_buck.ocled1
    onCheck_buck_diag_ocled1Changed: {
        if (check_buck_diag_ocled1 === true){
            sgStatusLight213.status = "red"
        }else if (check_buck_diag_ocled1 === false){
            sgStatusLight213.status = "green"
        }else {
            sgStatusLight213.status = "off"
        }
    }

    property var check_buck_diag_openled2: platformInterface.diag1_buck.openled2
    onCheck_buck_diag_openled2Changed: {
        if (check_buck_diag_openled2 === true){
            sgStatusLight214.status = "red"
        }else if (check_buck_diag_openled2 === false){
            sgStatusLight214.status = "green"
        }else {
            sgStatusLight214.status = "off"
        }
    }

    property var check_buck_diag_shortled2: platformInterface.diag1_buck.shortled2
    onCheck_buck_diag_shortled2Changed: {
        if (check_buck_diag_shortled2 === true){
            sgStatusLight215.status = "red"
        }else if (check_buck_diag_shortled2 === false){
            sgStatusLight215.status = "green"
        }else {
            sgStatusLight215.status = "off"
        }
    }

    property var check_buck_diag_ocled2: platformInterface.diag1_buck.ocled2
    onCheck_buck_diag_ocled2Changed: {
        if (check_buck_diag_ocled2 === true){
            sgStatusLight216.status = "red"
        }else if (check_buck_diag_ocled2 === false){
            sgStatusLight216.status = "green"
        }else {
            sgStatusLight216.status = "off"
        }
    }

    property var check_buck_diag_hwr: platformInterface.diag2_buck.hwr
    onCheck_buck_diag_hwrChanged: {
        if (check_buck_diag_hwr === true){
            sgStatusLight221.status = "red"
        }else if (check_buck_diag_hwr === false){
            sgStatusLight221.status = "green"
        }else {
            sgStatusLight221.status = "off"
        }
    }

    property var check_buck_diag_led1val: platformInterface.diag2_buck.led1val
    onCheck_buck_diag_led1valChanged: {
        if (check_buck_diag_led1val === true){
            sgStatusLight222.status = "green"
        }else {
            sgStatusLight222.status = "off"
        }
    }

    property var check_buck_diag_led2val: platformInterface.diag2_buck.led2val
    onCheck_buck_diag_led2valChanged: {
        if (check_buck_diag_led2val === true){
            sgStatusLight223.status = "green"
        }else {
            sgStatusLight223.status = "off"
        }
    }

    property var check_buck_diag_spierr: platformInterface.diag2_buck.spierr
    onCheck_buck_diag_spierrChanged: {
        if (check_buck_diag_spierr === true){
            sgStatusLight224.status = "red"
        }else if (check_buck_diag_spierr === false){
            sgStatusLight224.status = "green"
        }else {
            sgStatusLight224.status = "off"
        }
    }

    property var check_buck_diag_tsd: platformInterface.diag2_buck.tsd
    onCheck_buck_diag_tsdChanged: {
        if (check_buck_diag_tsd === true){
            sgStatusLight225.status = "red"
        }else if (check_buck_diag_tsd === false){
            sgStatusLight225.status = "green"
        }else {
            sgStatusLight225.status = "off"
        }
    }

    property var check_buck_diag_tw: platformInterface.diag2_buck.tw
    onCheck_buck_diag_twChanged: {
        if (check_buck_diag_tw === true){
            sgStatusLight226.status = "red"
        }else if (check_buck_diag_tw === false){
            sgStatusLight226.status = "green"
        }else {
            sgStatusLight226.status = "off"
        }
    }

    property var read_diag1_device_info: platformInterface.diag1_buck.device
    onRead_diag1_device_infoChanged: {
        if (read_diag1_device_info === 1){
            sgStatusLight131.status = "green"
            sgStatusLight132.status = "off"
            sgStatusLight133.status = "off"
        }else if (read_diag1_device_info === 2){
            sgStatusLight131.status = "off"
            sgStatusLight132.status = "green"
            sgStatusLight133.status = "off"
        }else if (read_diag1_device_info === 3){
            sgStatusLight131.status = "off"
            sgStatusLight132.status = "off"
            sgStatusLight133.status = "green"
        }else {
            sgStatusLight131.status = "off"
            sgStatusLight132.status = "off"
            sgStatusLight133.status = "off"
        }
    }

    property var read_diag2_device_info: platformInterface.diag2_buck.device
    onRead_diag2_device_infoChanged: {
        if (read_diag2_device_info === 1){
            sgStatusLight131.status = "green"
            sgStatusLight132.status = "off"
            sgStatusLight133.status = "off"
        }else if (read_diag2_device_info === 2){
            sgStatusLight131.status = "off"
            sgStatusLight132.status = "green"
            sgStatusLight133.status = "off"
        }else if (read_diag2_device_info === 3){
            sgStatusLight131.status = "off"
            sgStatusLight132.status = "off"
            sgStatusLight133.status = "green"
        }else {
            sgStatusLight131.status = "off"
            sgStatusLight132.status = "off"
            sgStatusLight133.status = "off"
        }
    }


    RowLayout{
        anchors.fill: parent

        Rectangle{
            id: rec1
            Layout.preferredWidth:parent.width/2.5
            Layout.preferredHeight: parent.height-50
            Layout.leftMargin: 50
            color:"transparent"

            Text {
                text: "Boost Diagnostic"
                font.pixelSize: 20
                color:"black"
                anchors.fill:parent
                horizontalAlignment: Text.AlignHCenter
            }

            ColumnLayout{
                anchors.fill:parent

                Rectangle{
                    id:rec11
                    Layout.preferredWidth:parent.width/1.05
                    Layout.preferredHeight: parent.height/1.15-50
                    Layout.rightMargin: 10
                    Layout.leftMargin: 10
                    Layout.topMargin: 10
                    Layout.bottomMargin: 5
                    color:"transparent"

                    RowLayout{
                        anchors.fill:parent
                        anchors{
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }

                        Rectangle{
                            id:rec111
                            Layout.preferredWidth:parent.width/3.5
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

                                // Boost diag information1

                                SGStatusLight{
                                    id: sgStatusLight111
                                    label: "<b>HWR</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight112
                                    label: "<b>BOOST1_STATUS</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight113
                                    label: "<b>BOOST2_STATUS</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight114
                                    label: "<b>BOOST_OV</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight115
                                    label: "<b>TEMP_OUT</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight116
                                    label: "<b>SPIERR</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }
                            }
                        }

                        Rectangle{
                            id:rec112
                            Layout.preferredWidth:parent.width/3.5
                            Layout.fillHeight: true
                            Layout.leftMargin: 5
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

                                // Boost diag information2

                                SGStatusLight{
                                    id: sgStatusLight121
                                    label: "<b>TSD</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight122
                                    label: "<b>TW</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight123
                                    label: "<b>ENABLE1_STATUS</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight124
                                    label: "<b>ENABLE2_STATUS</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight125
                                    label: "<b>VDRIVE_NOK</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight126
                                    label: "<b>VBSTDIV_UV</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }
                            }
                        }
                    }
                }

                Rectangle{
                    id:rec12
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/12
                    Layout.rightMargin: 10
                    Layout.leftMargin: 10
                    Layout.topMargin: 5
                    Layout.bottomMargin: 10
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
                                    columnSpacing: 1

                                    SGSegmentedButton{
                                        text: qsTr("Boost")
                                        onClicked: {
                                            platformInterface.boost_diag_read.update(1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle{
            id: rec2
            Layout.preferredWidth:parent.width/2
            Layout.preferredHeight: parent.height-50
            Layout.leftMargin: 5
            color:"transparent"

            Text {
                text: "Buck Diagnostic"
                font.pixelSize: 20
                color:"black"
                anchors.fill:parent
                horizontalAlignment: Text.AlignHCenter
            }

            ColumnLayout{
                anchors.fill:parent

                Rectangle{
                    id:rec21
                    Layout.preferredWidth:parent.width/1.05
                    Layout.preferredHeight: parent.height/1.15-50
                    Layout.rightMargin: 10
                    Layout.leftMargin: 10
                    Layout.topMargin: 10
                    Layout.bottomMargin: 5
                    color:"transparent"

                    RowLayout{
                        anchors.fill:parent
                        anchors{
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }

                        Rectangle{
                            id:rec211
                            Layout.preferredWidth:parent.width/3.5
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

                                // Boost diag information1

                                SGStatusLight{
                                    id: sgStatusLight211
                                    label: "<b>OPENLED1</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight212
                                    label: "<b>SHORTLED1</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight213
                                    label: "<b>OCLED1</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight214
                                    label: "<b>OPENLED2</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight215
                                    label: "<b>SHORTLED2</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight216
                                    label: "<b>OCLED2</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }
                            }
                        }

                        Rectangle{
                            id:rec212
                            Layout.preferredWidth:parent.width/3.5
                            Layout.fillHeight: true
                            Layout.leftMargin: 5
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

                                // Boost diag information2

                                SGStatusLight{
                                    id: sgStatusLight221
                                    label: "<b>HWR</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight222
                                    label: "<b>LED1VAL</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight223
                                    label: "<b>LED2VAL</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight224
                                    label: "<b>SPIERR</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight225
                                    label: "<b>TSD</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight226
                                    label: "<b>TW</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }
                            }
                        }


                        Rectangle{
                            id:rec213
                            Layout.preferredWidth:parent.width/3.5
                            Layout.fillHeight: true
                            Layout.leftMargin: 5
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

                                // Boost diag information2

                                SGStatusLight{
                                    id: sgStatusLight131
                                    label: "<b>BUCK1</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight132
                                    label: "<b>BUCK2</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight133
                                    label: "<b>BUCK3</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }
                            }
                        }
                    }
                }

                Rectangle{
                    id:rec22
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/12
                    Layout.rightMargin: 10
                    Layout.leftMargin: 10
                    Layout.topMargin: 5
                    Layout.bottomMargin: 10
                    color:"transparent"

                    RowLayout{
                        anchors.fill: parent

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSegmentedButtonStrip {
                                id: segmentedButtons2
                                anchors.centerIn: parent

                                segmentedButtons: GridLayout {
                                    columnSpacing: 3

                                    SGSegmentedButton{
                                        text: qsTr("Buck1")
                                        onClicked: {
                                            platformInterface.buck1_diag = true
                                            platformInterface.buck2_diag = false
                                            platformInterface.buck3_diag = false
                                            platformInterface.buck_diag_read.update(1,1)
                                        }
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("Buck2")
                                        onClicked: {
                                            platformInterface.buck1_diag = false
                                            platformInterface.buck2_diag = true
                                            platformInterface.buck3_diag = false
                                            platformInterface.buck_diag_read.update(2,1)
                                        }
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("Buck3")
                                        onClicked: {
                                            platformInterface.buck1_diag = false
                                            platformInterface.buck2_diag = false
                                            platformInterface.buck3_diag = true
                                            platformInterface.buck_diag_read.update(3,1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Component.onCompleted:  {
            Help.registerTarget(segmentedButtons1, "The diagonstic information of boost IC will show when Boost button pressed.", 0, "Help5")
            Help.registerTarget(segmentedButtons2, "The diagonstic information of each buck IC will show when Buck1 or Buck2 or Buck3 button pressed.", 1, "Help5")
            Help.registerTarget(sgStatusLight131, "Indicator shows which buck device infomration is displaying.", 2, "Help5")
        }
    }
}



