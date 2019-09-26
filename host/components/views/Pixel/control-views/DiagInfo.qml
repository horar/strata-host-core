import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id:diaginfo
    width: parent.width
    height: parent.height

    //    Component.onCompleted: {

    //    }

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
                            Layout.preferredWidth:parent.width/2.25
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
                            Layout.preferredWidth:parent.width/2.25
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
                                id: segmentedButtons
                                anchors.centerIn: parent

                                segmentedButtons: GridLayout {
                                    columnSpacing: 1

                                    SGSegmentedButton{
                                        text: qsTr("Boost")
                                        checked: true  // Sets default checked button when exclusive
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
            Layout.preferredWidth:parent.width/2.5
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
                            Layout.preferredWidth:parent.width/2.25
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
                            Layout.preferredWidth:parent.width/2.25
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
                                        checked: true  // Sets default checked button when exclusive
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("Buck2")
                                    }

                                    SGSegmentedButton{
                                        text: qsTr("Buck3")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        //        Component.onCompleted:  {
        //            Help.registerTarget(sgSwitch1, "Boost Enable control switch, All sliders and siwtches will be able to control after Boost Enable switch is ON, if OFF all switched and sliders will be disabled.", 0, "Help1")
        //            Help.registerTarget(sgSlider1, "Boost set point voltage select.", 2, "Help1")
        //            Help.registerTarget(sgStatusLight1, "LED indicator for Boost Enable, LED green if Boost Enable is ON.", 1, "Help1")
        //            Help.registerTarget(sgSwitch2, "Buck1 to 6 Enable control swith.", 3, "Help1")
        //            Help.registerTarget(sgSlider2, "Buck1 o 6 current setting", 5, "Help1")
        //            Help.registerTarget(sgStatusLight2, "LED indicator for Buck Enable, LED green if Buck1 to 6 Enable switch is ON", 4, "Help1")
        //            Help.registerTarget(sgSlider8, "Buck4 to 6 dimming control, 0 - 100 [%], slider is avairable when Buck Enable switch is ON", 6, "Help1")
        //        }

    }
}



