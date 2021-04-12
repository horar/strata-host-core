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
        sw21.sliderStatus = false
        sw22.sliderStatus = false
        sw23.sliderStatus = false
        sw24.sliderStatus = false
        sw25.sliderStatus = false
        sw26.sliderStatus = false
        sw27.sliderStatus = false
        sw28.sliderStatus = false
        sw29.sliderStatus = false
        sw210.sliderStatus = false
        sw211.sliderStatus = false
        sw212.sliderStatus = false

        sw21.slider_label_opacity = 0.5
        sw22.slider_label_opacity = 0.5
        sw23.slider_label_opacity = 0.5
        sw24.slider_label_opacity = 0.5
        sw25.slider_label_opacity = 0.5
        sw26.slider_label_opacity = 0.5
        sw27.slider_label_opacity = 0.5
        sw28.slider_label_opacity = 0.5
        sw29.slider_label_opacity = 0.5
        sw210.slider_label_opacity = 0.5
        sw211.slider_label_opacity = 0.5
        sw212.slider_label_opacity = 0.5

    }

    function reset_gui_slider_state2(){

        sw21.slider_set_initial_value = 0
        sw22.slider_set_initial_value = 0
        sw23.slider_set_initial_value = 0
        sw24.slider_set_initial_value = 0
        sw25.slider_set_initial_value = 0
        sw26.slider_set_initial_value = 0
        sw27.slider_set_initial_value = 0
        sw28.slider_set_initial_value = 0
        sw29.slider_set_initial_value = 0
        sw210.slider_set_initial_value = 0
        sw211.slider_set_initial_value = 0
        sw212.slider_set_initial_value = 0

    }

    function reset_gui_state2_init(){

        sw21.slider_set_initial_value = 0
        sw22.slider_set_initial_value = 0
        sw23.slider_set_initial_value = 0
        sw24.slider_set_initial_value = 0
        sw25.slider_set_initial_value = 0
        sw26.slider_set_initial_value = 0
        sw27.slider_set_initial_value = 0
        sw28.slider_set_initial_value = 0
        sw29.slider_set_initial_value = 0
        sw210.slider_set_initial_value = 0
        sw211.slider_set_initial_value = 0
        sw212.slider_set_initial_value = 0

        sw21.sliderStatus = false
        sw22.sliderStatus = false
        sw23.sliderStatus = false
        sw24.sliderStatus = false
        sw25.sliderStatus = false
        sw26.sliderStatus = false
        sw27.sliderStatus = false
        sw28.sliderStatus = false
        sw29.sliderStatus = false
        sw210.sliderStatus = false
        sw211.sliderStatus = false
        sw212.sliderStatus = false

        sw21.slider_label_opacity = 0.5
        sw22.slider_label_opacity = 0.5
        sw23.slider_label_opacity = 0.5
        sw24.slider_label_opacity = 0.5
        sw25.slider_label_opacity = 0.5
        sw26.slider_label_opacity = 0.5
        sw27.slider_label_opacity = 0.5
        sw28.slider_label_opacity = 0.5
        sw29.slider_label_opacity = 0.5
        sw210.slider_label_opacity = 0.5
        sw211.slider_label_opacity = 0.5
        sw212.slider_label_opacity = 0.5

    }

    function set_gui_state2_init(){

        sw21.sliderStatus = true
        sw22.sliderStatus = true
        sw23.sliderStatus = true
        sw24.sliderStatus = true
        sw25.sliderStatus = true
        sw26.sliderStatus = true
        sw27.sliderStatus = true
        sw28.sliderStatus = true
        sw29.sliderStatus = true
        sw210.sliderStatus = true
        sw211.sliderStatus = true
        sw212.sliderStatus = true

        sw21.slider_label_opacity = 1.0
        sw22.slider_label_opacity = 1.0
        sw23.slider_label_opacity = 1.0
        sw24.slider_label_opacity = 1.0
        sw25.slider_label_opacity = 1.0
        sw26.slider_label_opacity = 1.0
        sw27.slider_label_opacity = 1.0
        sw28.slider_label_opacity = 1.0
        sw29.slider_label_opacity = 1.0
        sw210.slider_label_opacity = 1.0
        sw211.slider_label_opacity = 1.0
        sw212.slider_label_opacity = 1.0

    }

    property bool check_clear_intensity_slider_led2: platformInterface.clear_intensity_slider_led2
    onCheck_clear_intensity_slider_led2Changed: {
        if (check_clear_intensity_slider_led2 === true){
            reset_gui_slider_state2()
        }
    }

    property bool auto_addr_sw_state2: platformInterface.auto_addr_enable_state
    onAuto_addr_sw_state2Changed: {
        if(auto_addr_sw_state2 === false){
            reset_gui_state2_init()
        }else {
            set_gui_state2_init()
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
                    id:sw21
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D1"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,1,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw22
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D2"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,2,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw23
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D3"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,3,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw24
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D4"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,4,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw25
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D5"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,5,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw26
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D6"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,6,(slider_value*100).toFixed(1))
                    }

                }

                Pixelcontrol {
                    id:sw27
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D7"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                   onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,7,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw28
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D8"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,8,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw29
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D9"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,9,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw210
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D10"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,10,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw211
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D11"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,11,(slider_value*100).toFixed(1))
                    }
                }

                Pixelcontrol {
                    id:sw212
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D12"

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: true

                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,12,(slider_value*100).toFixed(1))
                    }
                }
            }
        }
    }
}
