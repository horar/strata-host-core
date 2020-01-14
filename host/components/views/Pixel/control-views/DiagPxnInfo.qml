import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id:root
    width: parent.width
    height: parent.height

    property var read_pxn_status_info2: platformInterface.pxn_diag.status2
    onRead_pxn_status_info2Changed: {
        labelledInfoBox1.info = read_pxn_status_info2
    }

    property var read_pxn_status_info1: platformInterface.pxn_diag.status1
    onRead_pxn_status_info1Changed: {
        labelledInfoBox2.info = read_pxn_status_info1
    }

    property var read_pxn_status_info0: platformInterface.pxn_diag.status0
    onRead_pxn_status_info0Changed: {
        labelledInfoBox3.info = read_pxn_status_info0
    }

    property var read_pxn_status_info: platformInterface.pxn_diag.pxn
    onRead_pxn_status_infoChanged: {
        if (read_pxn_status_info === 1){
            sgStatusLight131.status = "green"
            sgStatusLight132.status = "off"
            sgStatusLight133.status = "off"
        }else if (read_pxn_status_info === 2){
            sgStatusLight131.status = "off"
            sgStatusLight132.status = "green"
            sgStatusLight133.status = "off"
        }else if (read_pxn_status_info === 3){
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


                                SGLabelledInfoBox {
                                    id: labelledInfoBox1
                                    infoBoxWidth: 70
                                    label: "status2:"
                                    info: "0"
                                }

                                SGLabelledInfoBox {
                                    id: labelledInfoBox2
                                    infoBoxWidth: 70
                                    label: "status1:"
                                    info: "0"
                                }

                                SGLabelledInfoBox {
                                    id: labelledInfoBox3
                                    infoBoxWidth: 70
                                    label: "status0:"
                                    info: "0"
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
                                    label: "<b>Pixel1</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight132
                                    label: "<b>Pixel2</b>" // Default: "" (if not entered, label will not appear)
                                    labelLeft: false        // Default: true
                                    lightSize: 50           // Default: 50
                                    textColor: "black"      // Default: "black"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter

                                }

                                SGStatusLight{
                                    id: sgStatusLight133
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
                                id: segmentedButtons2
                                anchors.centerIn: parent

                                segmentedButtons: GridLayout {
                                    columnSpacing: 3

                                    SGSegmentedButton{
                                        text: qsTr("Pixel1")
                                        onClicked: {
                                            platformInterface.pxn_status_read.update(1,0)
                                        }
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("Pixel2")
                                        onClicked: {
                                            platformInterface.pxn_status_read.update(2,0)
                                        }
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("Pixel3")
                                        onClicked: {
                                            platformInterface.pxn_status_read.update(3,0)
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
            Help.registerTarget(sgStatusLight131, "Indicator shows which Pixel device infomration is displaying.", 1, "Help5")

        }
    }
}



