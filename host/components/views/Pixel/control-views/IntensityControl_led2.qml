import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import tech.strata.sgwidgets 0.9

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    width: parent.width
    height: parent.height

    function reset_gui_state2_state(){
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

        sw21.checked = false
        sw22.checked = false
        sw23.checked = false
        sw24.checked = false
        sw25.checked = false
        sw26.checked = false
        sw27.checked = false
        sw28.checked = false
        sw29.checked = false
        sw210.checked = false
        sw211.checked = false
        sw212.checked = false
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

        sw21.enabled = false
        sw22.enabled = false
        sw23.enabled = false
        sw24.enabled = false
        sw25.enabled = false
        sw26.enabled = false
        sw27.enabled = false
        sw28.enabled = false
        sw29.enabled = false
        sw210.enabled = false
        sw211.enabled = false
        sw212.enabled = false

        sw21.checked = false
        sw22.checked = false
        sw23.checked = false
        sw24.checked = false
        sw25.checked = false
        sw26.checked = false
        sw27.checked = false
        sw28.checked = false
        sw29.checked = false
        sw210.checked = false
        sw211.checked = false
        sw212.checked = false
    }

    function set_gui_state2_init(){
        sw21.enabled = true
        sw22.enabled = true
        sw23.enabled = true
        sw24.enabled = true
        sw25.enabled = true
        sw26.enabled = true
        sw27.enabled = true
        sw28.enabled = true
        sw29.enabled = true
        sw210.enabled = true
        sw211.enabled = true
        sw212.enabled = true

        sw21.checked = false
        sw22.checked = false
        sw23.checked = false
        sw24.checked = false
        sw25.checked = false
        sw26.checked = false
        sw27.checked = false
        sw28.checked = false
        sw29.checked = false
        sw210.checked = false
        sw211.checked = false
        sw212.checked = false
    }

    property bool check_clear_intensity_slider_led2: platformInterface.clear_intensity_slider_led2
    onCheck_clear_intensity_slider_led2Changed: {
        if (check_clear_intensity_slider_led2 === true){
            reset_gui_state2_state()
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
                height:parent.height/2
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
                    switchLabelSize: parent.width/75
                    switchWidth: parent.width/25
                    switchHeight: parent.height/4

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: false

                    onToggled: {
                        if(checked)
                        {
                            sliderStatus = true
                            slider_label_opacity = 1.0
                        }
                        else {
                            slider_label_opacity = 0.5
                            sliderStatus = false
                        }
                    }
                    onSlider_valueChanged: {
                        if(slider_value >= 0){
                            platformInterface.pxn_datasend.update(2,1,(slider_value*100).toFixed(1))
                        }// to change the order of value, change toFixed value
                    }

                }

                Pixelcontrol {
                    id:sw22
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D2"
                    switchLabelSize: parent.width/75
                    switchWidth: parent.width/25
                    switchHeight: parent.height/4

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: false

                    onToggled: {
                        if(checked)
                        {
                            sliderStatus = true
                            slider_label_opacity = 1.0
                        }
                        else {
                            slider_label_opacity = 0.5
                            sliderStatus = false
                        }
                    }
                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,2,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                    }

                }

                Pixelcontrol {
                    id:sw23
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D3"
                    switchLabelSize: parent.width/75
                    switchWidth: parent.width/25
                    switchHeight: parent.height/4

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: false

                    onToggled: {
                        if(checked)
                        {
                            sliderStatus = true
                            slider_label_opacity = 1.0
                        }
                        else {
                            slider_label_opacity = 0.5
                            sliderStatus = false
                        }
                    }
                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,3,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                    }

                }

                Pixelcontrol {
                    id:sw24
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D4"
                    switchLabelSize: parent.width/75
                    switchWidth: parent.width/25
                    switchHeight: parent.height/4

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: false

                    onToggled: {
                        if(checked)
                        {
                            sliderStatus = true
                            slider_label_opacity = 1.0
                        }
                        else {
                            slider_label_opacity = 0.5
                            sliderStatus = false
                        }
                    }
                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,4,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                    }

                }

                Pixelcontrol {
                    id:sw25
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D5"
                    switchLabelSize: parent.width/75
                    switchWidth: parent.width/25
                    switchHeight: parent.height/4

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: false

                    onToggled: {
                        if(checked)
                        {
                            sliderStatus = true
                            slider_label_opacity = 1.0
                        }
                        else {
                            slider_label_opacity = 0.5
                            sliderStatus = false
                        }
                    }
                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,5,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                    }

                }

                Pixelcontrol {
                    id:sw26
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D6"
                    switchLabelSize: parent.width/75
                    switchWidth: parent.width/25
                    switchHeight: parent.height/4

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: false

                    onToggled: {
                        if(checked)
                        {
                            sliderStatus = true
                            slider_label_opacity = 1.0
                        }
                        else {
                            slider_label_opacity = 0.5
                            sliderStatus = false
                        }
                    }
                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,6,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                    }

                }

                Pixelcontrol {
                    id:sw27
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D7"
                    switchLabelSize: parent.width/75
                    switchWidth: parent.width/25
                    switchHeight: parent.height/4

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: false

                    onToggled: {
                        if(checked)
                        {
                            sliderStatus = true
                            slider_label_opacity = 1.0
                        }
                        else {
                            slider_label_opacity = 0.5
                            sliderStatus = false
                        }
                    }
                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,7,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                    }

                }

                Pixelcontrol {
                    id:sw28
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D8"
                    switchLabelSize: parent.width/75
                    switchWidth: parent.width/25
                    switchHeight: parent.height/4

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: false

                    onToggled: {
                        if(checked)
                        {
                            sliderStatus = true
                            slider_label_opacity = 1.0
                        }
                        else {
                            slider_label_opacity = 0.5
                            sliderStatus = false
                        }
                    }
                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,8,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                    }

                }

                Pixelcontrol {
                    id:sw29
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D9"
                    switchLabelSize: parent.width/75
                    switchWidth: parent.width/25
                    switchHeight: parent.height/4

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: false

                    onToggled: {
                        if(checked)
                        {
                            sliderStatus = true
                            slider_label_opacity = 1.0
                        }
                        else {
                            slider_label_opacity = 0.5
                            sliderStatus = false
                        }
                    }
                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,9,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                    }

                }

                Pixelcontrol {
                    id:sw210
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D10"
                    switchLabelSize: parent.width/75
                    switchWidth: parent.width/25
                    switchHeight: parent.height/4

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: false

                    onToggled: {
                        if(checked)
                        {
                            sliderStatus = true
                            slider_label_opacity = 1.0
                        }
                        else {
                            slider_label_opacity = 0.5
                            sliderStatus = false
                        }
                    }
                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,10,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                    }

                }

                Pixelcontrol {
                    id:sw211
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D11"
                    switchLabelSize: parent.width/75
                    switchWidth: parent.width/25
                    switchHeight: parent.height/4

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: false

                    onToggled: {
                        if(checked)
                        {
                            sliderStatus = true
                            slider_label_opacity = 1.0
                        }
                        else {
                            slider_label_opacity = 0.5
                            sliderStatus = false
                        }
                    }
                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,11,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                    }

                }

                Pixelcontrol {
                    id:sw212
                    sliderHeight: parent.height
                    sliderWidth: 10
                    infoBoxWidth: parent.width/15
                    infoBoxHeight: parent.height/4
                    label: "D12"
                    switchLabelSize: parent.width/75
                    switchWidth: parent.width/25
                    switchHeight: parent.height/4

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: false

                    onToggled: {
                        if(checked)
                        {
                            sliderStatus = true
                            slider_label_opacity = 1.0
                        }
                        else {
                            slider_label_opacity = 0.5
                            sliderStatus = false
                        }
                    }
                    onSlider_valueChanged: {
                        platformInterface.pxn_datasend.update(2,12,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                    }
                }
            }
        }
    }
}
