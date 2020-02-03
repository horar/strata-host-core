import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import tech.strata.sgwidgets 0.9

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    width: parent.width
    height: parent.height

    Component.onCompleted:  {
        sw31.sliderStatus = false
        sw32.sliderStatus = false
        sw33.sliderStatus = false
        sw34.sliderStatus = false
        sw35.sliderStatus = false
        sw36.sliderStatus = false
        sw37.sliderStatus = false
        sw38.sliderStatus = false
        sw39.sliderStatus = false
        sw310.sliderStatus = false
        sw311.sliderStatus = false
        sw312.sliderStatus = false

        sw31.slider_label_opacity = 0.5
        sw32.slider_label_opacity = 0.5
        sw33.slider_label_opacity = 0.5
        sw34.slider_label_opacity = 0.5
        sw35.slider_label_opacity = 0.5
        sw36.slider_label_opacity = 0.5
        sw37.slider_label_opacity = 0.5
        sw38.slider_label_opacity = 0.5
        sw39.slider_label_opacity = 0.5
        sw310.slider_label_opacity = 0.5
        sw311.slider_label_opacity = 0.5
        sw312.slider_label_opacity = 0.5
    }

    function reset_gui_slider_state3(){

        sw31.slider_set_initial_value = 0
        sw32.slider_set_initial_value = 0
        sw33.slider_set_initial_value = 0
        sw34.slider_set_initial_value = 0
        sw35.slider_set_initial_value = 0
        sw36.slider_set_initial_value = 0
        sw37.slider_set_initial_value = 0
        sw38.slider_set_initial_value = 0
        sw39.slider_set_initial_value = 0
        sw310.slider_set_initial_value = 0
        sw311.slider_set_initial_value = 0
        sw312.slider_set_initial_value = 0

    }

    function reset_gui_state3_init(){

        sw31.slider_set_initial_value = 0
        sw32.slider_set_initial_value = 0
        sw33.slider_set_initial_value = 0
        sw34.slider_set_initial_value = 0
        sw35.slider_set_initial_value = 0
        sw36.slider_set_initial_value = 0
        sw37.slider_set_initial_value = 0
        sw38.slider_set_initial_value = 0
        sw39.slider_set_initial_value = 0
        sw310.slider_set_initial_value = 0
        sw311.slider_set_initial_value = 0
        sw312.slider_set_initial_value = 0

        sw31.sliderStatus = false
        sw32.sliderStatus = false
        sw33.sliderStatus = false
        sw34.sliderStatus = false
        sw35.sliderStatus = false
        sw36.sliderStatus = false
        sw37.sliderStatus = false
        sw38.sliderStatus = false
        sw39.sliderStatus = false
        sw310.sliderStatus = false
        sw311.sliderStatus = false
        sw312.sliderStatus = false

        sw31.slider_label_opacity = 0.5
        sw32.slider_label_opacity = 0.5
        sw33.slider_label_opacity = 0.5
        sw34.slider_label_opacity = 0.5
        sw35.slider_label_opacity = 0.5
        sw36.slider_label_opacity = 0.5
        sw37.slider_label_opacity = 0.5
        sw38.slider_label_opacity = 0.5
        sw39.slider_label_opacity = 0.5
        sw310.slider_label_opacity = 0.5
        sw311.slider_label_opacity = 0.5
        sw312.slider_label_opacity = 0.5

    }

    function set_gui_state3_init(){

        sw31.sliderStatus = true
        sw32.sliderStatus = true
        sw33.sliderStatus = true
        sw34.sliderStatus = true
        sw35.sliderStatus = true
        sw36.sliderStatus = true
        sw37.sliderStatus = true
        sw38.sliderStatus = true
        sw39.sliderStatus = true
        sw310.sliderStatus = true
        sw311.sliderStatus = true
        sw312.sliderStatus = true

        sw31.slider_label_opacity = 1.0
        sw32.slider_label_opacity = 1.0
        sw33.slider_label_opacity = 1.0
        sw34.slider_label_opacity = 1.0
        sw35.slider_label_opacity = 1.0
        sw36.slider_label_opacity = 1.0
        sw37.slider_label_opacity = 1.0
        sw38.slider_label_opacity = 1.0
        sw39.slider_label_opacity = 1.0
        sw310.slider_label_opacity = 1.0
        sw311.slider_label_opacity = 1.0
        sw312.slider_label_opacity = 1.0

    }

    property bool check_clear_intensity_slider_led3: platformInterface.clear_intensity_slider_led3
    onCheck_clear_intensity_slider_led3Changed: {
        if (check_clear_intensity_slider_led3 === true){
            reset_gui_slider_state3()
        }
    }

    property bool auto_addr_sw_state3: platformInterface.auto_addr_enable_state
    onAuto_addr_sw_state3Changed: {
        if(auto_addr_sw_state3 === false){
            reset_gui_state3_init()
        }else {
            set_gui_state3_init()
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
                    id:sw31
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D1"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(3,1,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw32
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D2"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(3,2,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw33
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D3"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(3,3,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw34
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D4"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(3,4,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw35
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D5"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(3,5,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw36
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D6"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(3,6,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw37
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D7"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(3,7,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw38
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D8"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(3,8,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw39
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D9"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(3,9,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw310
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D10"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(3,10,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw311
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D11"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(3,11,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw312
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D12"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(3,12,(slider_value*100).toFixed(1))
                    }
                }
            }
        }
    }
}
