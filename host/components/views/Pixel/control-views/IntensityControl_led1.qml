import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import tech.strata.sgwidgets 0.9

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    width: parent.width

    Component.onCompleted:  {
        sw11.sliderStatus = false
        sw12.sliderStatus = false
        sw13.sliderStatus = false
        sw14.sliderStatus = false
        sw15.sliderStatus = false
        sw16.sliderStatus = false
        sw17.sliderStatus = false
        sw18.sliderStatus = false
        sw19.sliderStatus = false
        sw110.sliderStatus = false
        sw111.sliderStatus = false
        sw112.sliderStatus = false

        sw11.slider_label_opacity = 0.5
        sw12.slider_label_opacity = 0.5
        sw13.slider_label_opacity = 0.5
        sw14.slider_label_opacity = 0.5
        sw15.slider_label_opacity = 0.5
        sw16.slider_label_opacity = 0.5
        sw17.slider_label_opacity = 0.5
        sw18.slider_label_opacity = 0.5
        sw19.slider_label_opacity = 0.5
        sw110.slider_label_opacity = 0.5
        sw111.slider_label_opacity = 0.5
        sw112.slider_label_opacity = 0.5
    }

    function reset_gui_slider_state1(){

        sw11.slider_set_initial_value = 0
        sw12.slider_set_initial_value = 0
        sw13.slider_set_initial_value = 0
        sw14.slider_set_initial_value = 0
        sw15.slider_set_initial_value = 0
        sw16.slider_set_initial_value = 0
        sw17.slider_set_initial_value = 0
        sw18.slider_set_initial_value = 0
        sw19.slider_set_initial_value = 0
        sw110.slider_set_initial_value = 0
        sw111.slider_set_initial_value = 0
        sw112.slider_set_initial_value = 0

    }

    function reset_gui_state1_init(){

        sw11.slider_set_initial_value = 0
        sw12.slider_set_initial_value = 0
        sw13.slider_set_initial_value = 0
        sw14.slider_set_initial_value = 0
        sw15.slider_set_initial_value = 0
        sw16.slider_set_initial_value = 0
        sw17.slider_set_initial_value = 0
        sw18.slider_set_initial_value = 0
        sw19.slider_set_initial_value = 0
        sw110.slider_set_initial_value = 0
        sw111.slider_set_initial_value = 0
        sw112.slider_set_initial_value = 0

        sw11.sliderStatus = false
        sw12.sliderStatus = false
        sw13.sliderStatus = false
        sw14.sliderStatus = false
        sw15.sliderStatus = false
        sw16.sliderStatus = false
        sw17.sliderStatus = false
        sw18.sliderStatus = false
        sw19.sliderStatus = false
        sw110.sliderStatus = false
        sw111.sliderStatus = false
        sw112.sliderStatus = false

        sw11.slider_label_opacity = 0.5
        sw12.slider_label_opacity = 0.5
        sw13.slider_label_opacity = 0.5
        sw14.slider_label_opacity = 0.5
        sw15.slider_label_opacity = 0.5
        sw16.slider_label_opacity = 0.5
        sw17.slider_label_opacity = 0.5
        sw18.slider_label_opacity = 0.5
        sw19.slider_label_opacity = 0.5
        sw110.slider_label_opacity = 0.5
        sw111.slider_label_opacity = 0.5
        sw112.slider_label_opacity = 0.5

    }

    function set_gui_state1_init(){

        sw11.sliderStatus = true
        sw12.sliderStatus = true
        sw13.sliderStatus = true
        sw14.sliderStatus = true
        sw15.sliderStatus = true
        sw16.sliderStatus = true
        sw17.sliderStatus = true
        sw18.sliderStatus = true
        sw19.sliderStatus = true
        sw110.sliderStatus = true
        sw111.sliderStatus = true
        sw112.sliderStatus = true

        sw11.slider_label_opacity = 1.0
        sw12.slider_label_opacity = 1.0
        sw13.slider_label_opacity = 1.0
        sw14.slider_label_opacity = 1.0
        sw15.slider_label_opacity = 1.0
        sw16.slider_label_opacity = 1.0
        sw17.slider_label_opacity = 1.0
        sw18.slider_label_opacity = 1.0
        sw19.slider_label_opacity = 1.0
        sw110.slider_label_opacity = 1.0
        sw111.slider_label_opacity = 1.0
        sw112.slider_label_opacity = 1.0

    }

    property bool check_clear_intensity_slider_led1: platformInterface.clear_intensity_slider_led1
    onCheck_clear_intensity_slider_led1Changed: {
        if (check_clear_intensity_slider_led1 === true){
            reset_gui_slider_state1()
        }
    }

    property bool auto_addr_sw_state1: platformInterface.auto_addr_enable_state
    onAuto_addr_sw_state1Changed: {
        if(auto_addr_sw_state1 === false){
            reset_gui_state1_init()
        }else {
            set_gui_state1_init()
        }
    }

    RowLayout{
        anchors.fill: parent

        Rectangle{
            Layout.preferredWidth: parent.width/1.02
            Layout.preferredHeight: parent.height-100
            color: "transparent"
            Layout.leftMargin: 10
            Layout.rightMargin: 10

            RowLayout{
                width: parent.width
                height:parent.height*0.7
                anchors{
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }

                Pixelcontrol {
                    id:sw11
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D1"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(1,1,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw12
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D2"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(1,2,(slider_value*100).toFixed(1))
                    }

                }

                Pixelcontrol {
                    id:sw13
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D3"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(1,3,(slider_value*100).toFixed(1))
                    }

                }

                Pixelcontrol {
                    id:sw14
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D4"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(1,4,(slider_value*100).toFixed(1))
                    }

                }

                Pixelcontrol {
                    id:sw15
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D5"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(1,5,(slider_value*100).toFixed(1))
                    }

                }

                Pixelcontrol {
                    id:sw16
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D6"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(1,6,(slider_value*100).toFixed(1))
                    }

                }

                Pixelcontrol {
                    id:sw17
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D7"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(1,7,(slider_value*100).toFixed(1))
                    }

                }

                Pixelcontrol {
                    id:sw18
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D8"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(1,8,(slider_value*100).toFixed(1))
                    }

                }

                Pixelcontrol {
                    id:sw19
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D9"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(1,9,(slider_value*100).toFixed(1))
                    }

                }

                Pixelcontrol {
                    id:sw110
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D10"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(1,10,(slider_value*100).toFixed(1))
                    }

                }

                Pixelcontrol {
                    id:sw111
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D11"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(1,11,(slider_value*100).toFixed(1))
                    }

                }

                Pixelcontrol {
                    id:sw112
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D12"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(1,12,(slider_value*100).toFixed(1))
                    }
                }
            }
        }

        Component.onCompleted:  {
            Help.registerTarget(sw11, "Intensity control slider, slider is enabled after Enable button is turned on, and slider is disabled after Enable button is turned off, the dimming data will be sent when slider is released by mouse.", 2, "Help1")
        }

    }
}
