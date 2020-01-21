import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id:root
    width: parent.width
    height: parent.height

    function send_pxn_diag_cmd(pix_ch, dig_num){
        platformInterface.pxn_status_read.update(pix_ch,dig_num)
    }

    property var read_pxn_status_info_sw12: platformInterface.pxn_diag_15_1.sw12
    onRead_pxn_status_info_sw12Changed: {
        labelledInfoBox12.info = read_pxn_status_info_sw12
    }

    property var read_pxn_status_info_sw11: platformInterface.pxn_diag_15_1.sw11
    onRead_pxn_status_info_sw11Changed: {
        labelledInfoBox11.info = read_pxn_status_info_sw11
    }

    property var read_pxn_status_info_sw10: platformInterface.pxn_diag_15_1.sw10
    onRead_pxn_status_info_sw10Changed: {
        labelledInfoBox10.info = read_pxn_status_info_sw10
    }

    property var read_pxn_status_info_sw9: platformInterface.pxn_diag_15_1.sw9
    onRead_pxn_status_info_sw9Changed: {
        labelledInfoBox9.info = read_pxn_status_info_sw9
    }

    property var read_pxn_status_info_sw8: platformInterface.pxn_diag_15_1.sw8
    onRead_pxn_status_info_sw8Changed: {
        labelledInfoBox8.info = read_pxn_status_info_sw8
    }

    property var read_pxn_status_info_sw7: platformInterface.pxn_diag_15_1.sw7
    onRead_pxn_status_info_sw7Changed: {
        labelledInfoBox7.info = read_pxn_status_info_sw7
    }

    property var read_pxn_status_info_sw6: platformInterface.pxn_diag_15_0.sw6
    onRead_pxn_status_info_sw6Changed: {
        labelledInfoBox6.info = read_pxn_status_info_sw6
    }

    property var read_pxn_status_info_sw5: platformInterface.pxn_diag_15_0.sw5
    onRead_pxn_status_info_sw5Changed: {
        labelledInfoBox5.info = read_pxn_status_info_sw5
    }

    property var read_pxn_status_info_sw4: platformInterface.pxn_diag_15_0.sw4
    onRead_pxn_status_info_sw4Changed: {
        labelledInfoBox4.info = read_pxn_status_info_sw4
    }

    property var read_pxn_status_info_sw3: platformInterface.pxn_diag_15_0.sw3
    onRead_pxn_status_info_sw3Changed: {
        labelledInfoBox3.info = read_pxn_status_info_sw3
    }

    property var read_pxn_status_info_sw2: platformInterface.pxn_diag_15_0.sw2
    onRead_pxn_status_info_sw2Changed: {
        labelledInfoBox2.info = read_pxn_status_info_sw2
    }

    property var read_pxn_status_info_sw1: platformInterface.pxn_diag_15_0.sw1
    onRead_pxn_status_info_sw1Changed: {
        labelledInfoBox1.info = read_pxn_status_info_sw1
    }


    property bool check_pxn1_diag_state: platformInterface.pxn1_diag
    onCheck_pxn1_diag_stateChanged: {
        if (check_pxn1_diag_state === true){
            sgStatusLight0.status = "green"
        }else {
            sgStatusLight0.status = "off"
        }
    }

    property bool check_pxn2_diag_state: platformInterface.pxn2_diag
    onCheck_pxn2_diag_stateChanged: {
        if (check_pxn2_diag_state === true) {
            sgStatusLight1.status = "green"
        }else{
            sgStatusLight1.status = "off"
        }
    }

    property bool check_pxn3_diag_state: platformInterface.pxn3_diag
    onCheck_pxn3_diag_stateChanged: {
        if (check_pxn3_diag_state === true) {
            sgStatusLight2.status = "green"
        }else {
            sgStatusLight2.status = "off"
        }
    }

    RowLayout{
        anchors.fill: parent

        Rectangle{
            id: rec1
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height-50
            color:"transparent"

            ColumnLayout{
                anchors.fill:parent

                Rectangle{
                    id:rec11
                    Layout.fillWidth: true
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
                                    infoBoxWidth: 70
                                    label: "SW1:"
                                    labelLeft: false
                                    info: "0"
                                }

                                SGLabelledInfoBox {
                                    id: labelledInfoBox2
                                    infoBoxWidth: 70
                                    label: "SW2:"
                                    labelLeft: false
                                    info: "0"
                                }
                            }
                        }

                        Rectangle{
                            id:rec112
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
                                    id: labelledInfoBox3
                                    infoBoxWidth: 70
                                    label: "SW3:"
                                    labelLeft: false
                                    info: "0"
                                }

                                SGLabelledInfoBox {
                                    id: labelledInfoBox4
                                    infoBoxWidth: 70
                                    label: "SW4:"
                                    labelLeft: false
                                    info: "0"
                                }
                            }
                        }

                        Rectangle{
                            id:rec113
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
                                    id: labelledInfoBox5
                                    infoBoxWidth: 70
                                    label: "SW5:"
                                    labelLeft: false
                                    info: "0"
                                }

                                SGLabelledInfoBox {
                                    id: labelledInfoBox6
                                    infoBoxWidth: 70
                                    label: "SW6:"
                                    labelLeft: false
                                    info: "0"
                                }
                            }
                        }

                        Rectangle{
                            id:rec114
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
                                    id: labelledInfoBox7
                                    infoBoxWidth: 70
                                    label: "SW7:"
                                    labelLeft: false
                                    info: "0"
                                }

                                SGLabelledInfoBox {
                                    id: labelledInfoBox8
                                    infoBoxWidth: 70
                                    label: "SW8:"
                                    labelLeft: false
                                    info: "0"
                                }
                            }
                        }

                        Rectangle{
                            id:rec115
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
                                    id: labelledInfoBox9
                                    infoBoxWidth: 70
                                    label: "SW9:"
                                    labelLeft: false
                                    info: "0"
                                }

                                SGLabelledInfoBox {
                                    id: labelledInfoBox10
                                    infoBoxWidth: 70
                                    label: "SW10:"
                                    labelLeft: false
                                    info: "0"
                                }
                            }
                        }

                        Rectangle{
                            id:rec116
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
                                    id: labelledInfoBox11
                                    infoBoxWidth: 70
                                    label: "SW11:"
                                    labelLeft: false
                                    info: "0"
                                }

                                SGLabelledInfoBox {
                                    id: labelledInfoBox12
                                    infoBoxWidth: 70
                                    label: "SW12:"
                                    labelLeft: false
                                    info: "0"
                                }
                            }
                        }


                        Rectangle{
                            id:rec117
                            Layout.preferredWidth:parent.width/8
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

                                SGStatusLight{
                                    id: sgStatusLight0
                                    label: "<b>Pixel1</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight1
                                    label: "<b>Pixel2</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight2
                                    label: "<b>Pixel3</b>" // Default: "" (if not entered, label will not appear)
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
                    color:"blue"

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
                                            send_pxn_diag_cmd((segmentedButtons1.index+1),15)
                                            platformInterface.pxn1_diag = true
                                            platformInterface.pxn2_diag = false
                                            platformInterface.pxn3_diag = false
                                        }
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("Pixel2")
                                        onClicked: {
                                            send_pxn_diag_cmd((segmentedButtons1.index+1),15)
                                            platformInterface.pxn1_diag = false
                                            platformInterface.pxn2_diag = true
                                            platformInterface.pxn3_diag = false
                                        }
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("Pixel3")
                                        onClicked: {
                                            send_pxn_diag_cmd((segmentedButtons1.index+1),15)
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
            }
        }

        Component.onCompleted:  {
            Help.registerTarget(segmentedButtons2, "The diagonstic information of each Pixel IC will show when Pixel1 or Pixel2 or Pixel3 button pressed.", 0, "Help5")
            Help.registerTarget(sgStatusLight0, "Indicator shows which Pixel device infomration is displaying.", 1, "Help5")

        }
    }
}



