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
    DemoPattern1 {
        id:demoLEDPattern1
    }
    DemoPattern2 {
        id:demoLEDPattern2
    }
    DemoPattern3 {
        id:demoLEDPattern3
    }
    DemoPattern4 {
        id:demoLEDPattern4
    }
    DemoPattern5 {
        id:demoLEDPattern5
    }
    DemoPattern6 {
        id:demoLEDPattern6
    }
    DemoPattern7 {
        id:demoLEDPattern7
    }

    property var check_demo_finish: platformInterface.demo_state.status
    onCheck_demo_finishChanged: {
        if (check_demo_finish === "finished"){
            handlar_start_control()
        }
    }

    property var check_curatin_position: platformInterface.curtain.position
    onCheck_curatin_positionChanged: {
        if(check_curatin_position === 1){
            demoLEDPattern1.led_all_off()
            demoLEDPattern6.position_1()
        }else if(check_curatin_position === 2){
            demoLEDPattern1.led_all_off()
            demoLEDPattern6.position_2()
        }else if(check_curatin_position === 3){
            demoLEDPattern1.led_all_off()
            demoLEDPattern6.position_3()
        }else if(check_curatin_position === 4){
            demoLEDPattern1.led_all_off()
            demoLEDPattern6.position_4()
        }else if(check_curatin_position === 5){
            demoLEDPattern1.led_all_off()
            demoLEDPattern6.position_5()
        }else if(check_curatin_position === 6){
            demoLEDPattern1.led_all_off()
            demoLEDPattern6.position_6()
        }else if(check_curatin_position === 7){
            demoLEDPattern1.led_all_off()
            demoLEDPattern6.position_7()
        }else if(check_curatin_position === 8){
            demoLEDPattern1.led_all_off()
            demoLEDPattern6.position_8()
        }else if(check_curatin_position === 9){
            demoLEDPattern1.led_all_off()
            demoLEDPattern6.position_9()
        }else if(check_curatin_position === 10){
            demoLEDPattern1.led_all_off()
            demoLEDPattern6.position_10()
        }else if(check_curatin_position === 11){
            demoLEDPattern1.led_all_off()
            demoLEDPattern6.position_11()
        }else if(check_curatin_position === 12){
            demoLEDPattern1.led_all_off()
            demoLEDPattern6.position_12()
        }
    }

    property var check_bhall_position: platformInterface.bhall.position
    onCheck_bhall_positionChanged: {
        if (check_bhall_position === 1){
            demoLEDPattern7.bhposition_1()
        }else if (check_bhall_position === 2){
            demoLEDPattern7.bhposition_2()
        }else if (check_bhall_position === 3){
            demoLEDPattern7.bhposition_3()
        }else if (check_bhall_position === 4){
            demoLEDPattern7.bhposition_4()
        }else if (check_bhall_position === 5){
            demoLEDPattern7.bhposition_5()
        }else if (check_bhall_position === 6){
            demoLEDPattern7.bhposition_6()
        }else if (check_bhall_position === 7){
            demoLEDPattern7.bhposition_7()
        }else if (check_bhall_position === 8){
            demoLEDPattern7.bhposition_8()
        }else if (check_bhall_position === 9){
            demoLEDPattern7.bhposition_9()
        }else if (check_bhall_position === 10){
            demoLEDPattern7.bhposition_10()
        }
    }

    property bool check_handlar_start_state: platformInterface.handler_start
    onCheck_handlar_start_stateChanged: {
        if (check_handlar_start_state === true){
            platformInterface.start_peroidic_hdl.update()
        } else if (check_handlar_start_state === false){
            platformInterface.stop_peroidic_hdl.update()
        }
    }

    property var led_state: platformInterface.demo_led_state.led
    onLed_stateChanged: {
        if (platformInterface.star_demo === true && platformInterface.demo_led_num_1 === true){
            demoLEDPattern1.led_all_off()
            demoLEDPattern1.demo_star1(led_state)
        } else if (platformInterface.star_demo === true && platformInterface.demo_led_num_2 === true){
            demoLEDPattern1.led_all_off()
            demoLEDPattern1.demo_star2(led_state)
        } else if (platformInterface.star_demo === true && platformInterface.demo_led_num_3 === true){
            demoLEDPattern1.led_all_off()
            demoLEDPattern1.demo_star3(led_state)
        } else if (platformInterface.star_demo === true && platformInterface.demo_led_num_4 === true){
            demoLEDPattern1.led_all_off()
            demoLEDPattern1.demo_star4(led_state)
        } else if (platformInterface.star_demo === true && platformInterface.demo_led_num_5 === true){
            demoLEDPattern1.led_all_off()
            demoLEDPattern1.demo_star5(led_state)
        }

        if (platformInterface.curtain_demo === true && platformInterface.demo_led_num_1 === true){
            demoLEDPattern2.led_all_off()
            demoLEDPattern2.demo_cirtain1(led_state)
        } else if (platformInterface.curtain_demo === true && platformInterface.demo_led_num_2 === true){
            demoLEDPattern2.led_all_off()
            demoLEDPattern2.demo_cirtain2(led_state)
        } else if (platformInterface.curtain_demo === true && platformInterface.demo_led_num_3 === true){
            demoLEDPattern2.led_all_off()
            demoLEDPattern2.demo_cirtain3(led_state)
        } else if (platformInterface.curtain_demo === true && platformInterface.demo_led_num_4 === true){
            demoLEDPattern2.led_all_off()
            demoLEDPattern2.demo_cirtain4(led_state)
        } else if (platformInterface.curtain_demo === true && platformInterface.demo_led_num_5 === true){
            demoLEDPattern2.led_all_off()
            demoLEDPattern2.demo_cirtain5(led_state)
        }

        if (platformInterface.bhall_demo === true && platformInterface.demo_led_num_1 === true){
            demoLEDPattern3.led_all_on()
            demoLEDPattern3.demo_bhall1(led_state)
        } else if (platformInterface.bhall_demo === true && platformInterface.demo_led_num_2 === true){
            demoLEDPattern3.led_all_on()
            demoLEDPattern3.demo_bhall2(led_state)
        } else if (platformInterface.bhall_demo === true && platformInterface.demo_led_num_3 === true){
            demoLEDPattern3.led_all_on()
            demoLEDPattern3.demo_bhall3(led_state)
        } else if (platformInterface.bhall_demo === true && platformInterface.demo_led_num_4 === true){
            demoLEDPattern3.led_all_on()
            demoLEDPattern3.demo_bhall4(led_state)
        } else if (platformInterface.bhall_demo === true && platformInterface.demo_led_num_5 === true){
            demoLEDPattern3.led_all_on()
            demoLEDPattern3.demo_bhall5(led_state)
        }

        if (platformInterface.mix_demo === true && platformInterface.demo_led_num_1 === true){
            demoLEDPattern4.led1_all_off()
            demoLEDPattern4.led2_all_on()
            demoLEDPattern4.led3_all_off()
            demoLEDPattern4.demo_mix1(led_state)
        } else if (platformInterface.mix_demo === true && platformInterface.demo_led_num_2 === true){
            demoLEDPattern4.led1_all_off()
            demoLEDPattern4.led2_all_on()
            demoLEDPattern4.led3_all_off()
            demoLEDPattern4.demo_mix2(led_state)
        } else if (platformInterface.mix_demo === true && platformInterface.demo_led_num_3 === true){
            demoLEDPattern4.led1_all_off()
            demoLEDPattern4.led2_all_on()
            demoLEDPattern4.led3_all_off()
            demoLEDPattern4.demo_mix3(led_state)
        } else if (platformInterface.mix_demo === true && platformInterface.demo_led_num_4 === true){
            demoLEDPattern4.led1_all_off()
            demoLEDPattern4.led2_all_on()
            demoLEDPattern4.led3_all_off()
            demoLEDPattern4.demo_mix4(led_state)
        } else if (platformInterface.mix_demo === true && platformInterface.demo_led_num_5 === true){
            demoLEDPattern4.led1_all_off()
            demoLEDPattern4.led2_all_on()
            demoLEDPattern4.led3_all_off()
            demoLEDPattern4.demo_mix5(led_state)
        }
    }

    function send_demo_state(mode_state, led_num_state, repeat_state, time_state, intensity_state){
        platformInterface.pxn_demo_setting.update(mode_state,led_num_state,repeat_state,time_state,intensity_state)
    }

    function set_all_led_state(dim_var){
        var dim = dim_var.toFixed(0)

        platformInterface.pxn_datasend_all.update((100-dim_var).toFixed(1))
        if (0 <= dim && dim < 30){
            demoLEDPattern5.state1()
        }
        else if (30 <= dim && dim < 60){
            demoLEDPattern5.state2()
        }
        else if (60 <= dim){
            demoLEDPattern5.state3()
        }
    }

    function set_hall_position(hall_var){
        var set_hall_Val = hall_var.toFixed(0)
        platformInterface.pxn_bhall_position.update(set_hall_Val)
    }

    function set_led_bar_state(bar_val){
        var set_bar_Val = bar_val.toFixed(0)
        platformInterface.pxn_led_position.update(set_bar_Val)
    }

    function handlar_start_control(){
        if (platformInterface.handler_start != true){
            platformInterface.handler_start = true
        }
    }

    function handlar_stop_control(){
        platformInterface.handler_start = false
    }

    // for LED color control
    // LED String 1
    property string check_demo_led11_color: platformInterface.demo_led11_color
    onCheck_demo_led11_colorChanged: {
        sgStatusLight11.status = check_demo_led11_color
    }

    property string check_demo_led12_color: platformInterface.demo_led12_color
    onCheck_demo_led12_colorChanged: {
        sgStatusLight12.status = check_demo_led12_color
    }

    property string check_demo_led13_color: platformInterface.demo_led13_color
    onCheck_demo_led13_colorChanged: {
        sgStatusLight13.status = check_demo_led13_color
    }

    property string check_demo_led14_color: platformInterface.demo_led14_color
    onCheck_demo_led14_colorChanged: {
        sgStatusLight14.status = check_demo_led14_color
    }

    property string check_demo_led15_color: platformInterface.demo_led15_color
    onCheck_demo_led15_colorChanged: {
        sgStatusLight15.status = check_demo_led15_color
    }

    property string check_demo_led16_color: platformInterface.demo_led16_color
    onCheck_demo_led16_colorChanged: {
        sgStatusLight16.status = check_demo_led16_color
    }

    property string check_demo_led17_color: platformInterface.demo_led17_color
    onCheck_demo_led17_colorChanged: {
        sgStatusLight17.status = check_demo_led17_color
    }

    property string check_demo_led18_color: platformInterface.demo_led18_color
    onCheck_demo_led18_colorChanged: {
        sgStatusLight18.status = check_demo_led18_color
    }

    property string check_demo_led19_color: platformInterface.demo_led19_color
    onCheck_demo_led19_colorChanged: {
        sgStatusLight19.status = check_demo_led19_color
    }

    property string check_demo_led1A_color: platformInterface.demo_led1A_color
    onCheck_demo_led1A_colorChanged: {
        sgStatusLight1A.status = check_demo_led1A_color
    }

    property string check_demo_led1B_color: platformInterface.demo_led1B_color
    onCheck_demo_led1B_colorChanged: {
        sgStatusLight1B.status = check_demo_led1B_color
    }

    property string check_demo_led1C_color: platformInterface.demo_led1C_color
    onCheck_demo_led1C_colorChanged: {
        sgStatusLight1C.status = check_demo_led1C_color
    }

    // LED String 2
    property string check_demo_led21_color: platformInterface.demo_led21_color
    onCheck_demo_led21_colorChanged: {
        sgStatusLight21.status = check_demo_led21_color
    }

    property string check_demo_led22_color: platformInterface.demo_led22_color
    onCheck_demo_led22_colorChanged: {
        sgStatusLight22.status = check_demo_led22_color
    }

    property string check_demo_led23_color: platformInterface.demo_led23_color
    onCheck_demo_led23_colorChanged: {
        sgStatusLight23.status = check_demo_led23_color
    }

    property string check_demo_led24_color: platformInterface.demo_led24_color
    onCheck_demo_led24_colorChanged: {
        sgStatusLight24.status = check_demo_led24_color
    }

    property string check_demo_led25_color: platformInterface.demo_led25_color
    onCheck_demo_led25_colorChanged: {
        sgStatusLight25.status = check_demo_led25_color
    }

    property string check_demo_led26_color: platformInterface.demo_led26_color
    onCheck_demo_led26_colorChanged: {
        sgStatusLight26.status = check_demo_led26_color
    }

    property string check_demo_led27_color: platformInterface.demo_led27_color
    onCheck_demo_led27_colorChanged: {
        sgStatusLight27.status = check_demo_led27_color
    }

    property string check_demo_led28_color: platformInterface.demo_led28_color
    onCheck_demo_led28_colorChanged: {
        sgStatusLight28.status = check_demo_led28_color
    }

    property string check_demo_led29_color: platformInterface.demo_led29_color
    onCheck_demo_led29_colorChanged: {
        sgStatusLight29.status = check_demo_led29_color
    }

    property string check_demo_led2A_color: platformInterface.demo_led2A_color
    onCheck_demo_led2A_colorChanged: {
        sgStatusLight2A.status = check_demo_led2A_color
    }

    property string check_demo_led2B_color: platformInterface.demo_led2B_color
    onCheck_demo_led2B_colorChanged: {
        sgStatusLight2B.status = check_demo_led2B_color
    }

    property string check_demo_led2C_color: platformInterface.demo_led2C_color
    onCheck_demo_led2C_colorChanged: {
        sgStatusLight2C.status = check_demo_led2C_color
    }

    // LED String 3
    property string check_demo_led31_color: platformInterface.demo_led31_color
    onCheck_demo_led31_colorChanged: {
        sgStatusLight31.status = check_demo_led31_color
    }

    property string check_demo_led32_color: platformInterface.demo_led32_color
    onCheck_demo_led32_colorChanged: {
        sgStatusLight32.status = check_demo_led32_color
    }

    property string check_demo_led33_color: platformInterface.demo_led33_color
    onCheck_demo_led33_colorChanged: {
        sgStatusLight33.status = check_demo_led33_color
    }

    property string check_demo_led34_color: platformInterface.demo_led34_color
    onCheck_demo_led34_colorChanged: {
        sgStatusLight34.status = check_demo_led34_color
    }

    property string check_demo_led35_color: platformInterface.demo_led35_color
    onCheck_demo_led35_colorChanged: {
        sgStatusLight35.status = check_demo_led35_color
    }

    property string check_demo_led36_color: platformInterface.demo_led36_color
    onCheck_demo_led36_colorChanged: {
        sgStatusLight36.status = check_demo_led36_color
    }

    property string check_demo_led37_color: platformInterface.demo_led37_color
    onCheck_demo_led37_colorChanged: {
        sgStatusLight37.status = check_demo_led37_color
    }

    property string check_demo_led38_color: platformInterface.demo_led38_color
    onCheck_demo_led38_colorChanged: {
        sgStatusLight38.status = check_demo_led38_color
    }

    property string check_demo_led39_color: platformInterface.demo_led39_color
    onCheck_demo_led39_colorChanged: {
        sgStatusLight39.status = check_demo_led39_color
    }

    property string check_demo_led3A_color: platformInterface.demo_led3A_color
    onCheck_demo_led3A_colorChanged: {
        sgStatusLight3A.status = check_demo_led3A_color
    }

    property string check_demo_led3B_color: platformInterface.demo_led3B_color
    onCheck_demo_led3B_colorChanged: {
        sgStatusLight3B.status = check_demo_led3B_color
    }

    property string check_demo_led3C_color: platformInterface.demo_led3C_color
    onCheck_demo_led3C_colorChanged: {
        sgStatusLight3C.status = check_demo_led3C_color
    }

    // end of led color control

//    Rectangle{
//        id:title
//        width: parent.width/3
//        height: parent.height/11
//        anchors{
//            top: parent.top
//            horizontalCenter: parent.horizontalCenter
//        }
//        color:"black"
//        Text {
//            text: "Pixel Dimming Control - Demo"
//            font.pixelSize: 25
//            anchors.fill:parent
//            color: "white"
//            horizontalAlignment: Text.AlignHCenter
//        }
//    }

    RowLayout{
        anchors.fill: parent
//        anchors.top: title.bottom

        Rectangle{
            Layout.preferredWidth: parent.width/2.5
            Layout.preferredHeight: parent.height-50
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
//                        activeTextColor: "#C400FE"        // Default: "white"
                        activeTextColor: "green"        // Default: "white"
                        activeColor: "#999"             // Default: "#999"
                        inactiveColor: "dimgray"           // Default: "#ddd"

                        segmentedButtons: GridLayout {

                            columnSpacing: 2

                            SGSegmentedButton{
                                text: qsTr("Star")
                                checked: true  // Sets default checked button when exclusive
                                onClicked: {
                                    handlar_start_control()
                                    platformInterface.star_demo = true
                                    platformInterface.curtain_demo = false
                                    platformInterface.bhall_demo = false
                                    platformInterface.mix_demo = false
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("Curtain")
                                onClicked: {
                                    handlar_start_control()
                                    platformInterface.star_demo = false
                                    platformInterface.curtain_demo = true
                                    platformInterface.bhall_demo = false
                                    platformInterface.mix_demo = false
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("B.Hall")
                                onClicked: {
                                    handlar_start_control()
                                    platformInterface.star_demo = false
                                    platformInterface.curtain_demo = false
                                    platformInterface.bhall_demo = true
                                    platformInterface.mix_demo = false
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("Mix")
                                onClicked: {
                                    handlar_start_control()
                                    platformInterface.star_demo = false
                                    platformInterface.curtain_demo = false
                                    platformInterface.bhall_demo = false
                                    platformInterface.mix_demo = true
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
//                        activeTextColor: "#C400FE"        // Default: "white"
                        activeTextColor: "green"        // Default: "white"
                        activeColor: "#999"             // Default: "#999"
                        inactiveColor: "dimgray"           // Default: "#ddd"


                        segmentedButtons: GridLayout {
                            columnSpacing: 2

                            SGSegmentedButton{
                                text: qsTr("1")
                                checked: true  // Sets default checked button when exclusive
                                onClicked: {
                                    handlar_start_control()
                                    platformInterface.demo_led_num_1 = true
                                    platformInterface.demo_led_num_2 = false
                                    platformInterface.demo_led_num_3 = false
                                    platformInterface.demo_led_num_4 = false
                                    platformInterface.demo_led_num_5 = false
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("2")
                                onClicked: {
                                    handlar_start_control()
                                    platformInterface.demo_led_num_1 = false
                                    platformInterface.demo_led_num_2 = true
                                    platformInterface.demo_led_num_3 = false
                                    platformInterface.demo_led_num_4 = false
                                    platformInterface.demo_led_num_5 = false
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("3")
                                onClicked: {
                                    handlar_start_control()
                                    platformInterface.demo_led_num_1 = false
                                    platformInterface.demo_led_num_2 = false
                                    platformInterface.demo_led_num_3 = true
                                    platformInterface.demo_led_num_4 = false
                                    platformInterface.demo_led_num_5 = false
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("4")
                                onClicked: {
                                    handlar_start_control()
                                    platformInterface.demo_led_num_1 = false
                                    platformInterface.demo_led_num_2 = false
                                    platformInterface.demo_led_num_3 = false
                                    platformInterface.demo_led_num_4 = true
                                    platformInterface.demo_led_num_5 = false
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("5")
                                onClicked: {
                                    handlar_start_control()
                                    platformInterface.demo_led_num_1 = false
                                    platformInterface.demo_led_num_2 = false
                                    platformInterface.demo_led_num_3 = false
                                    platformInterface.demo_led_num_4 = false
                                    platformInterface.demo_led_num_5 = true
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
                        id: segmentedButtons3
                        anchors.centerIn: parent

                        label: "Demo repeat counts:"                 // Default: "" (will not appear if not entered)
                        labelLeft: false                // Default: true (true: label on left, false: label on top)
                        textColor: "white"              // Default: "white"
//                        activeTextColor: "#C400FE"        // Default: "white"
                        activeTextColor: "green"        // Default: "white"
                        activeColor: "#999"             // Default: "#999"
                        inactiveColor: "dimgray"           // Default: "#ddd"


                        segmentedButtons: GridLayout {
                            columnSpacing: 2

                            SGSegmentedButton{
                                text: qsTr("3")
                                checked: true  // Sets default checked button when exclusive
                                onClicked: {
//                                    handlar_stop_control()
                                    platformInterface.demo_count_1 = true
                                    platformInterface.demo_count_2 = false
                                    platformInterface.demo_count_3 = false
                                    platformInterface.demo_count_4 = false
                                    platformInterface.demo_count_5 = false
                                    send_demo_state((segmentedButtons1.index+1),(segmentedButtons2.index+1),(segmentedButtons3.index+3),sgSlider1.value,(100-sgSlider2.value))
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("4")
                                onClicked: {
//                                    handlar_stop_control()
                                    platformInterface.demo_count_1 = false
                                    platformInterface.demo_count_2 = true
                                    platformInterface.demo_count_3 = false
                                    platformInterface.demo_count_4 = false
                                    platformInterface.demo_count_5 = false
                                    send_demo_state((segmentedButtons1.index+1),(segmentedButtons2.index+1),(segmentedButtons3.index+3),sgSlider1.value,(100-sgSlider2.value))
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("5")
                                onClicked: {
//                                    handlar_stop_control()
                                    platformInterface.demo_count_1 = false
                                    platformInterface.demo_count_2 = false
                                    platformInterface.demo_count_3 = true
                                    platformInterface.demo_count_4 = false
                                    platformInterface.demo_count_5 = false
                                    send_demo_state((segmentedButtons1.index+1),(segmentedButtons2.index+1),(segmentedButtons3.index+3),sgSlider1.value,(100-sgSlider2.value))
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("6")
                                onClicked: {
//                                    handlar_stop_control()
                                    platformInterface.demo_count_1 = false
                                    platformInterface.demo_count_2 = false
                                    platformInterface.demo_count_3 = false
                                    platformInterface.demo_count_4 = true
                                    platformInterface.demo_count_5 = false
                                    send_demo_state((segmentedButtons1.index+1),(segmentedButtons2.index+1),(segmentedButtons3.index+3),sgSlider1.value,(100-sgSlider2.value))
                                }
                            }

                            SGSegmentedButton{
                                text: qsTr("7")
                                onClicked: {
//                                    handlar_stop_control()
                                    platformInterface.demo_count_1 = false
                                    platformInterface.demo_count_2 = false
                                    platformInterface.demo_count_3 = false
                                    platformInterface.demo_count_4 = false
                                    platformInterface.demo_count_5 = true
                                    send_demo_state((segmentedButtons1.index+1),(segmentedButtons2.index+1),(segmentedButtons3.index+3),sgSlider1.value,(100-sgSlider2.value))
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
                        label: "<b>Transition Time (mSec)</b>"          // Default: "" (if not entered, label will not appear)
                        textColor: "white"           // Default: "black"
                        labelLeft: false             // Default: true
                        Layout.fillHeight: true
                        width: parent.width/2
                        stepSize: 1                // Default: 1.0
                        value: 50                        // Default: average of from and to
                        from: 1                      // Default: 0.0
                        to: 100                    // Default: 100.0
                        startLabel: "1"              // Default: from
                        endLabel: "100"            // Default: to
                        showToolTip: false            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
//                        grooveFillColor: "#C400FE"    // Default: "#888888"
                        grooveFillColor: "green"    // Default: "#888888"
                        live: false                  // Default: false (will only send valueChanged signal when slider is released)
                        labelTopAligned: false       // Default: false (only applies to label on left of slider, decides vertical centering of label)
                        inputBox: true               // Default: true

                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "black"
                    SGSlideCustomize{
                        id:sgSlider2
                        anchors.centerIn: parent
                        label: "<b>Demo pattern Intensity (%)</b>"          // Default: "" (if not entered, label will not appear)
                        textColor: "white"           // Default: "black"
                        labelLeft: false             // Default: true
                        Layout.fillHeight: true
                        width: parent.width/2
                        stepSize: 1                // Default: 1.0
                        value: 100                  // Default: average of from and to
                        from: 0                      // Default: 0.0
                        to: 100                    // Default: 100.0
                        startLabel: "0"              // Default: from
                        endLabel: "100"            // Default: to
                        showToolTip: false            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "green"// Default: "#888888"
//                        grooveFillColor: "#C400FE"// Default: "#888888"
                        live: false                  // Default: false (will only send valueChanged signal when slider is released)
                        labelTopAligned: false       // Default: false (only applies to label on left of slider, decides vertical centering of label)
                        inputBox: true               // Default: true

                    }
                }
            }
        }


        Rectangle{
            id:rec2
            Layout.preferredWidth: parent.width/1.8
            Layout.preferredHeight: parent.height/1.2
            color: "black"
            //            color: "black"

            RowLayout{
                id: array1
                width: parent.width
                height:parent.height/6
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
                height:parent.height/6
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
                height:parent.height/6
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

            RowLayout{
                id: array4
                width: parent.width
                height:parent.height/6
                spacing: 2

                anchors.top: array3.bottom

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    SGSlideCustomize{
                        id:sgSlider3
                        anchors.centerIn: parent
                        label: "<b>ALL LED Intensity Control</b>"          // Default: "" (if not entered, label will not appear)
                        textColor: "white"           // Default: "black"
                        labelLeft: false             // Default: true
                        Layout.fillHeight: true
                        width: parent.width/2
                        stepSize: 0.1                // Default: 1.0
                        value: 100                        // Default: average of from and to
                        from: 0                      // Default: 0.0
                        to: 100                    // Default: 100.0
                        startLabel: "0"              // Default: from
                        endLabel: "100"            // Default: to
                        showToolTip: false            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "red"    // Default: "#888888"
                        live: false                  // Default: false (will only send valueChanged signal when slider is released)
                        labelTopAligned: false       // Default: false (only applies to label on left of slider, decides vertical centering of label)
                        inputBox: true               // Default: true

                        onSlider_valueChanged: {
                            set_all_led_state(sgSlider3.value)
                            handlar_stop_control()
                        }
                    }
                }
            }

            RowLayout{
                id: array5
                width: parent.width
                height:parent.height/6
                spacing: 2

                anchors.top: array4.bottom

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    SGSlideCustomize{
                        id:sgSlider4
                        anchors.centerIn: parent
                        label: "<b>Curtain Control</b>"          // Default: "" (if not entered, label will not appear)
                        textColor: "white"           // Default: "black"
                        labelLeft: false             // Default: true
                        Layout.fillHeight: true
                        width: parent.width/2
                        stepSize: 0.1                // Default: 1.0
                        value: 0                        // Default: average of from and to
                        from: 1                      // Default: 0.0
                        to: 12                    // Default: 100.0
                        startLabel: "Left"              // Default: from
                        endLabel: "Right"            // Default: to
                        showToolTip: false            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "red"    // Default: "#888888"
                        live: false                  // Default: false (will only send valueChanged signal when slider is released)
                        labelTopAligned: false       // Default: false (only applies to label on left of slider, decides vertical centering of label)
                        inputBox: false               // Default: true

                        onSlider_valueChanged: {
                            set_led_bar_state(sgSlider4.value)
                            handlar_stop_control()
                        }
                    }
                }
            }

            RowLayout{
                id: array6
                width: parent.width
                height:parent.height/7
                spacing: 2

                anchors.top: array5.bottom

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    SGSlideCustomize{
                        id:sgSlider5
                        anchors.centerIn: parent
                        label: "<b>Black Hall Control</b>"          // Default: "" (if not entered, label will not appear)
                        textColor: "white"           // Default: "black"
                        labelLeft: false             // Default: true
                        Layout.fillHeight: true
                        width: parent.width/2
                        stepSize: 0.1                // Default: 1.0
                        value: 5                        // Default: average of from and to
                        from: 1                      // Default: 0.0
                        to: 10                    // Default: 100.0
                        startLabel: "Left"              // Default: from
                        endLabel: "Right"            // Default: to
                        showToolTip: false            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "red"    // Default: "#888888"
                        live: false                  // Default: false (will only send valueChanged signal when slider is released)
                        labelTopAligned: false       // Default: false (only applies to label on left of slider, decides vertical centering of label)
                        inputBox: false               // Default: true

                        onSlider_valueChanged: {
                            set_hall_position(sgSlider5.value)
                            handlar_stop_control()
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted:  {
        Help.registerTarget(segmentedButtons1, "LED demo pattern select. The demo pattern are showing LED indicator at right side on GUI.", 0, "Help3")
        Help.registerTarget(rec2, "The demo patterns are displaying when Pixel Pattern, Pixel bit are selected.", 1, "Help3")
        Help.registerTarget(segmentedButtons2, "Pixel bit selects how many LED turn ON or OFF on demo mode.", 2, "Help3")
        Help.registerTarget(sgSlider1, "Change transition time (LED ON->OFF or OFF->ON time) on demo mode.", 3, "Help3")
        Help.registerTarget(sgSlider2, "Change LED Intensity on demo mode.", 4, "Help3")
        Help.registerTarget(segmentedButtons3, "Demo reppeat counts defins the repeat counts of demo pattern. The demo will start after repeat counts select", 5, "Help3")
        Help.registerTarget(sgSlider3, "ALL LED Intensity Control can control intensity of all LED.", 6, "Help3")
        Help.registerTarget(sgSlider4, "Curtain Control can control LED ON and OFF position on curtain demo.", 7, "Help3")
        Help.registerTarget(sgSlider5, "Black Hall Control can control Hall position on Black Hall demo.", 8, "Help3")

    }

}
