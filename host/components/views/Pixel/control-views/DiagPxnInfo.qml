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

    property var read_pxn_status_info3: platformInterface.pxn_diag.b3
    onRead_pxn_status_info3Changed: {
        labelledInfoBox4.info = read_pxn_status_info3
    }

    property var read_pxn_status_info2: platformInterface.pxn_diag.b2
    onRead_pxn_status_info2Changed: {
        labelledInfoBox3.info = read_pxn_status_info2
    }

    property var read_pxn_status_info1: platformInterface.pxn_diag.b1
    onRead_pxn_status_info1Changed: {
        labelledInfoBox2.info = read_pxn_status_info1
    }

    property var read_pxn_status_info0: platformInterface.pxn_diag.b0
    onRead_pxn_status_info0Changed: {
        labelledInfoBox1.info = read_pxn_status_info0
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
            Layout.preferredWidth:parent.width/7.5
            Layout.preferredHeight: parent.height-50
            Layout.leftMargin: 50
            color:"transparent"
        }

        Rectangle{
            id: rec2
            Layout.preferredWidth:parent.width/2
            Layout.preferredHeight: parent.height-50
            Layout.leftMargin: 5
            color:"transparent"

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
                            Layout.preferredWidth:parent.width/5.5
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
                                    label: "b0:"
                                    info: "0"
                                }

                                SGLabelledInfoBox {
                                    id: labelledInfoBox2
                                    infoBoxWidth: 70
                                    label: "b1:"
                                    info: "0"
                                }

                                SGLabelledInfoBox {
                                    id: labelledInfoBox3
                                    infoBoxWidth: 70
                                    label: "b2:"
                                    info: "0"
                                }

                                SGLabelledInfoBox {
                                    id: labelledInfoBox4
                                    infoBoxWidth: 70
                                    label: "b3:"
                                    info: "0"
                                }
                            }
                        }

                        Rectangle{
                            id:rec215
                            Layout.preferredWidth:parent.width/5.5
                            Layout.fillHeight: true
                            Layout.leftMargin: 5
                            Layout.topMargin: 10
                            Layout.bottomMargin: 5
                            color:"transparent"
                        }

                        Rectangle{
                            id:rec216
                            Layout.preferredWidth:parent.width/5.5
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
                                id: segmentedButtons1
                                anchors.centerIn: parent

                                segmentedButtons: GridLayout {
                                    columnSpacing: 3

                                    SGSegmentedButton{
                                        text: qsTr("Pixel1")
                                        checked: true
                                        onClicked: {
                                            send_pxn_diag_cmd((segmentedButtons1.index+1),(segmentedButtons2.index+15))
                                            platformInterface.pxn1_diag = true
                                            platformInterface.pxn2_diag = false
                                            platformInterface.pxn3_diag = false
                                        }
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("Pixel2")
                                        onClicked: {
                                            send_pxn_diag_cmd((segmentedButtons1.index+1),(segmentedButtons2.index+15))
                                            platformInterface.pxn1_diag = false
                                            platformInterface.pxn2_diag = true
                                            platformInterface.pxn3_diag = false
                                        }
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("Pixel3")
                                        onClicked: {
                                            send_pxn_diag_cmd((segmentedButtons1.index+1),(segmentedButtons2.index+15))
                                            platformInterface.pxn1_diag = false
                                            platformInterface.pxn2_diag = false
                                            platformInterface.pxn3_diag = true
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSegmentedButtonStrip {
                                id: segmentedButtons2
                                anchors.centerIn: parent

                                segmentedButtons: GridLayout {
                                    columnSpacing: 4

                                    SGSegmentedButton{
                                        text: qsTr("0x0F")
                                        checked: true
                                        onClicked: {
                                            send_pxn_diag_cmd((segmentedButtons1.index+1),(segmentedButtons2.index+15))
                                        }
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("0x10")
                                        onClicked: {
                                            send_pxn_diag_cmd((segmentedButtons1.index+1),(segmentedButtons2.index+15))
                                        }
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("0x11")
                                        onClicked: {
                                            send_pxn_diag_cmd((segmentedButtons1.index+1),(segmentedButtons2.index+15))
                                        }
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("0x12")
                                        onClicked: {
                                            send_pxn_diag_cmd((segmentedButtons1.index+1),(segmentedButtons2.index+15))
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



