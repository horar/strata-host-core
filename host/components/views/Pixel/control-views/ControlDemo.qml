import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import tech.strata.sgwidgets 0.9

import "qrc:/js/help_layout_manager.js" as Help

Rectangle {

    id: controldemo
//    anchors.fill: parent
    width: parent.width
    height: parent.height
    color:"black"

    function send_demo_state(mode_state, led_num_state, intensity_state, time_state){
        platformInterface.pxn_demo_setting.update(mode_state,led_num_state,time_state,intensity_state)
    }

//    function send_demo_state(demo_mode_state, demo_lednum_state, demo_time_state, demo_intensity_state){
//        platformInterface.pxn_demo_mode.update(demo_mode_state)
//        platformInterface.pxn_demo_lednum.update(demo_lednum_state)
//        platformInterface.pxn_demo_time.update(demo_time_state)
//        platformInterface.pxn_demo_intensity.update(demo_intensity_state)

//    }

    Rectangle{
        id:title
        width: parent.width/3
        height: parent.height/11
        anchors{
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        color:"black"
        Text {
            text: "Pixel Dimming Control - Demo"
            font.pixelSize: 25
            anchors.fill:parent
            color: "white"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    RowLayout{
        anchors.fill: parent
        anchors.top: title.bottom

        Rectangle{
            Layout.preferredWidth: parent.width/2.5
            Layout.preferredHeight: parent.height-250
            color: "black"

            ColumnLayout{
                anchors.fill: parent

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "black"

                    SGSegmentedButtonStrip{
                        id: segmentedButtons1
                        anchors.centerIn: parent

                        label: "Pxel Pattern:"          // Default: "" (will not appear if not entered)
                        labelLeft: false                // Default: true (true: label on left, false: label on top)
                        textColor: "white"              // Default: "white"
                        activeTextColor: "#C400FE"        // Default: "white"
                        activeColor: "#999"             // Default: "#999"
                        inactiveColor: "dimgray"           // Default: "#ddd"

                        segmentedButtons: GridLayout {

                            columnSpacing: 2

                            SGSegmentedButton{
                                text: qsTr("Star")
                                checked: true  // Sets default checked button when exclusive
                                onClicked: {
                                    send_demo_state(1,(segmentedButtons2.index+1),sgSlider1.value,sgSlider2.value)
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("Curtain")
                                onClicked: {
                                    send_demo_state(2,(segmentedButtons2.index+1),sgSlider1.value,sgSlider2.value)
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("B.Hall")
                                onClicked: {
                                    send_demo_state(3,(segmentedButtons2.index+1),sgSlider1.value,sgSlider2.value)
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("Mix")
                                onClicked: {
                                    send_demo_state(4,(segmentedButtons2.index+1),sgSlider1.value,sgSlider2.value)
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("Off")
                                onClicked: {
                                    send_demo_state(5,(segmentedButtons2.index+1),sgSlider1.value,sgSlider2.value)
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "black"

                    SGSegmentedButtonStrip{
                        id: segmentedButtons2
                        anchors.centerIn: parent

                        label: "Pxel bit:"                 // Default: "" (will not appear if not entered)
                        labelLeft: false                // Default: true (true: label on left, false: label on top)
                        textColor: "white"              // Default: "white"
                        activeTextColor: "#C400FE"        // Default: "white"
                        activeColor: "#999"             // Default: "#999"
                        inactiveColor: "dimgray"           // Default: "#ddd"


                        segmentedButtons: GridLayout {
                            columnSpacing: 2

                            SGSegmentedButton{
                                text: qsTr("1")
                                checked: true  // Sets default checked button when exclusive
                                onClicked: {
                                    send_demo_state((segmentedButtons1.index+1),1,sgSlider1.value,sgSlider2.value)
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("2")
                                onClicked: {
                                    send_demo_state((segmentedButtons1.index+1),2,sgSlider1.value,sgSlider2.value)
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("3")
                                onClicked: {
                                    send_demo_state((segmentedButtons1.index+1),3,sgSlider1.value,sgSlider2.value)
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("4")
                                onClicked: {
                                    send_demo_state((segmentedButtons1.index+1),4,sgSlider1.value,sgSlider2.value)
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("5")
                                onClicked: {
                                    send_demo_state((segmentedButtons1.index+1),5,sgSlider1.value,sgSlider2.value)
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "black"
                    SGSlideCustomize{
                        id:sgSlider1
                        anchors.centerIn: parent
                        label: "<b>Transition Time (sec)</b>"          // Default: "" (if not entered, label will not appear)
                        textColor: "white"           // Default: "black"
                        labelLeft: false             // Default: true
                        Layout.fillHeight: true
                        width: parent.width/2
                        stepSize: 0.05                // Default: 1.0
                        value: 1                  // Default: average of from and to
                        from: 0.05                      // Default: 0.0
                        to: 2.0                    // Default: 100.0
                        startLabel: "0.05"              // Default: from
                        endLabel: "2.0"            // Default: to
                        showToolTip: false            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "#C400FE"    // Default: "#888888"
                        live: false                  // Default: false (will only send valueChanged signal when slider is released)
                        labelTopAligned: false       // Default: false (only applies to label on left of slider, decides vertical centering of label)
                        inputBox: true               // Default: true

                        onSlider_valueChanged: {
                            send_demo_state((segmentedButtons1.index+1),(segmentedButtons2.index + 1),sgSlider1.value,sgSlider2.value)
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "black"
                    SGSlideCustomize{
                        id:sgSlider2
                        anchors.centerIn: parent
                        label: "<b>Intensity (%)</b>"          // Default: "" (if not entered, label will not appear)
                        textColor: "white"           // Default: "black"
                        labelLeft: false             // Default: true
                        Layout.fillHeight: true
                        width: parent.width/2
                        stepSize: 1                // Default: 1.0
                        value: 50                  // Default: average of from and to
                        from: 0                      // Default: 0.0
                        to: 100                    // Default: 100.0
                        startLabel: "0"              // Default: from
                        endLabel: "100"            // Default: to
                        showToolTip: false            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "#C400FE"// Default: "#888888"
                        live: false                  // Default: false (will only send valueChanged signal when slider is released)
                        labelTopAligned: false       // Default: false (only applies to label on left of slider, decides vertical centering of label)
                        inputBox: true               // Default: true

                        onSlider_valueChanged: {
                            send_demo_state((segmentedButtons1.index+1),(segmentedButtons2.index + 1),sgSlider1.value,sgSlider2.value)
                        }
                    }
                }

            }
        }


        Rectangle{
            id:rec2
            Layout.preferredWidth: parent.width/2.6
            Layout.preferredHeight: parent.height/2
            color: "transparent"
//            color: "black"

            RowLayout{
                id: array1
                width: parent.width
                height:parent.height/3
                spacing: 2


                Text {
                    text: "Array-1"
                    font.pixelSize:15
                    color: "white"
                    Layout.alignment: Qt.AlignCenter
                }

                SGStatusLight{
                    id: sgStatusLight11
                    label: "<b>D1:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30        // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight12
                    label: "<b>D2:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight13
                    label: "<b>D3:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight14
                    label: "<b>D4:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight15
                    label: "<b>D5:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight16
                    label: "<b>D6:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight17
                    label: "<b>D7:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight18
                    label: "<b>D8:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight19
                    label: "<b>D9:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight1A
                    label: "<b>D10:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight1B
                    label: "<b>D11:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight1C
                    label: "<b>D12:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            RowLayout{
                id: array2
                width: parent.width
                height:parent.height/3
                spacing: 2


                anchors.top: array1.bottom

                Text {
                    text: "Array-2"
                    font.pixelSize:15
                    color: "white"
                    Layout.alignment: Qt.AlignCenter
                }

                SGStatusLight{
                    id: sgStatusLight21
                    label: "<b>D1:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30        // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight22
                    label: "<b>D2:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight23
                    label: "<b>D3:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight24
                    label: "<b>D4:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight25
                    label: "<b>D5:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight26
                    label: "<b>D6:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight27
                    label: "<b>D7:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight28
                    label: "<b>D8:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight29
                    label: "<b>D9:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight2A
                    label: "<b>10:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight2B
                    label: "<b>D11:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight2C
                    label: "<b>D12:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }
            }


            RowLayout{
                id: array3
                width: parent.width
                height:parent.height/3
                spacing: 2

                anchors.top: array2.bottom

                Text {
                    text: "Array-3"
                    font.pixelSize:15
                    color: "white"
                    Layout.alignment: Qt.AlignCenter
                }

                SGStatusLight{
                    id: sgStatusLight31
                    label: "<b>D1:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30        // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight32
                    label: "<b>D2:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight33
                    label: "<b>D3:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight34
                    label: "<b>D4:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight35
                    label: "<b>D5:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight36
                    label: "<b>D6:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight37
                    label: "<b>D7:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight38
                    label: "<b>D8:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight39
                    label: "<b>D9:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight3A
                    label: "<b>D10:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight3B
                    label: "<b>D11:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }

                SGStatusLight{
                    id: sgStatusLight3C
                    label: "<b>D12:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: false        // Default: true
                    lightSize: 30          // Default: 50
                    textColor: "white"      // Default: "black"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

    }
}
