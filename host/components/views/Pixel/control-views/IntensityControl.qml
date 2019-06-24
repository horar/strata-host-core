import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import tech.strata.sgwidgets 0.9

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: intensitycontrol
    anchors.fill: parent

    property var auto_addr_status: platformInterface.auto_addressing.state
    onAuto_addr_statusChanged: {

        if(auto_addr_status === "config_OK") {
            sgStatusLight.status = "green"
            sgSwitch.enabled = true
            sw11.enabled = true
            sw12.enabled = true
            sw13.enabled = true
            sw14.enabled = true
            sw15.enabled = true
            sw16.enabled = true
            sw17.enabled = true
            sw18.enabled = true
            sw19.enabled = true
            sw110.enabled = true
            sw111.enabled = true
            sw112.enabled = true
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
            sw31.enabled = true
            sw32.enabled = true
            sw33.enabled = true
            sw34.enabled = true
            sw35.enabled = true
            sw36.enabled = true
            sw37.enabled = true
            sw38.enabled = true
            sw39.enabled = true
            sw310.enabled = true
            sw311.enabled = true
            sw312.enabled = true


        }else if (auto_addr_status === "config_NG"){
            sgStatusLight.status = "red"
        }else
            sgStatusLight.status = "off"
    }

    // set initial velue on UI after startup
    Component.onCompleted: {
        sw11.slider_value = 1
        sw12.slider_value = 1
        sw13.slider_value = 1
        sw14.slider_value = 1
        sw15.slider_value = 1
        sw16.slider_value = 1
        sw17.slider_value = 1
        sw18.slider_value = 1
        sw19.slider_value = 1
        sw110.slider_value = 1
        sw111.slider_value = 1
        sw112.slider_value = 1
        sw21.slider_value = 1
        sw22.slider_value = 1
        sw23.slider_value = 1
        sw24.slider_value = 1
        sw25.slider_value = 1
        sw26.slider_value = 1
        sw27.slider_value = 1
        sw28.slider_value = 1
        sw29.slider_value = 1
        sw210.slider_value = 1
        sw211.slider_value = 1
        sw212.slider_value = 1
        sw31.slider_value = 1
        sw32.slider_value = 1
        sw33.slider_value = 1
        sw34.slider_value = 1
        sw35.slider_value = 1
        sw36.slider_value = 1
        sw37.slider_value = 1
        sw38.slider_value = 1
        sw39.slider_value = 1
        sw310.slider_value = 1
        sw311.slider_value = 1
        sw312.slider_value = 1
    }

    Rectangle{
        id:title
        width: parent.width/3
        height: parent.height/11
        anchors{
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        color:"transparent"
        Text {
            text: "Pixel Dimming Control"
            font.pixelSize: 25
            anchors.fill:parent
            color: "black"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    RowLayout{
        anchors.fill: parent
        anchors.top: title.bottom
        Rectangle{
            //            Layout.preferredWidth: parent.width/1.8
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height-130
            color: "transparent"

            Rectangle{
                id:top
                width: parent.width
                height: parent.height/3
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 10

                RowLayout
                {
                    width: parent.width
                    height:parent.height/2.5


                    Pixelcontrol {
                        id:sw11
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
                                slider_value = 0

                            }
                        }
                        onMoved: {
                            platformInterface.pxn_datasend.update(1,1,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw12
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(1,2,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw13
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(1,3,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw14
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(1,4,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw15
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(1,5,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw16
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(1,6,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw17
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(1,7,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw18
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(1,8,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw19
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(1,9,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw110
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(1,10,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw111
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(1,11,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw112
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(1,12,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }
                }
            }

            Rectangle{
                id:middle
                width: parent.width
                height: parent.height/3
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.top: top.bottom


                RowLayout{

                    width: parent.width
                    height:parent.height/2.5
                    spacing: 2

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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(2,1,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(2,12,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                }


            }

            Rectangle{
                id: secondLast
                width: parent.width
                height: parent.height/3
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.top: middle.bottom


                RowLayout{

                    width: parent.width
                    height:parent.height/2.5
                    spacing: 2

                    Pixelcontrol {
                        id:sw31
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(3,1,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw32
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(3,2,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw33
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(3,3,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw34
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(3,4,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw35
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(3,5,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw36
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(3,6,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw37
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(3,7,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw38
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(3,8,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw39
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(3,9,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw310
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(3,10,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw311
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(3,11,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }

                    }

                    Pixelcontrol {
                        id:sw312
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
                                slider_value = 0
                            }
                        }

                        onMoved: {
                            platformInterface.pxn_datasend.update(3,12,(slider_value*100).toFixed(1))    // to change the order of value, change toFixed value
                        }
                    }
                }
            }

            Rectangle{
                id: last
                width: parent.width/3
                height: parent.height/4
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.top: secondLast.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                RowLayout{

                    width: parent.width/4
                    height:parent.height/4
                    spacing: 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    SGSwitch {
                        id: sgSwitch
                        label: "Auto addressing ON"
                        Layout.alignment: Qt.AlignCenter

                        onToggled: {
                            if(checked) {
                                platformInterface.pxn_autoaddr.update(1)

                                platformInterface.boost_enable_state = true
                                platformInterface.boost_led_state = true

                                platformInterface.buck1_enable_state = true
                                platformInterface.buck1_led_state = true

                                platformInterface.buck2_enable_state = true
                                platformInterface.buck2_led_state = true

                                platformInterface.buck3_enable_state = true
                                platformInterface.buck3_led_state = true

                                sgSwitch.enabled = false
                                sw11.enabled = false
                                sw12.enabled = false
                                sw13.enabled = false
                                sw14.enabled = false
                                sw15.enabled = false
                                sw16.enabled = false
                                sw17.enabled = false
                                sw18.enabled = false
                                sw19.enabled = false
                                sw110.enabled = false
                                sw111.enabled = false
                                sw112.enabled = false
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
                                sw31.enabled = false
                                sw32.enabled = false
                                sw33.enabled = false
                                sw34.enabled = false
                                sw35.enabled = false
                                sw36.enabled = false
                                sw37.enabled = false
                                sw38.enabled = false
                                sw39.enabled = false
                                sw310.enabled = false
                                sw311.enabled = false
                                sw312.enabled = false
                            } else {

                                sgStatusLight.status = "off"

                                sw11.slider_value = 1
                                sw12.slider_value = 1
                                sw13.slider_value = 1
                                sw14.slider_value = 1
                                sw15.slider_value = 1
                                sw16.slider_value = 1
                                sw17.slider_value = 1
                                sw18.slider_value = 1
                                sw19.slider_value = 1
                                sw110.slider_value = 1
                                sw111.slider_value = 1
                                sw112.slider_value = 1
                                sw21.slider_value = 1
                                sw22.slider_value = 1
                                sw23.slider_value = 1
                                sw24.slider_value = 1
                                sw25.slider_value = 1
                                sw26.slider_value = 1
                                sw27.slider_value = 1
                                sw28.slider_value = 1
                                sw29.slider_value = 1
                                sw210.slider_value = 1
                                sw211.slider_value = 1
                                sw212.slider_value = 1
                                sw31.slider_value = 1
                                sw32.slider_value = 1
                                sw33.slider_value = 1
                                sw34.slider_value = 1
                                sw35.slider_value = 1
                                sw36.slider_value = 1
                                sw37.slider_value = 1
                                sw38.slider_value = 1
                                sw39.slider_value = 1
                                sw310.slider_value = 1
                                sw311.slider_value = 1
                                sw312.slider_value = 1

                                sw11.enabled = false
                                sw12.enabled = false
                                sw13.enabled = false
                                sw14.enabled = false
                                sw15.enabled = false
                                sw16.enabled = false
                                sw17.enabled = false
                                sw18.enabled = false
                                sw19.enabled = false
                                sw110.enabled = false
                                sw111.enabled = false
                                sw112.enabled = false
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
                                sw31.enabled = false
                                sw32.enabled = false
                                sw33.enabled = false
                                sw34.enabled = false
                                sw35.enabled = false
                                sw36.enabled = false
                                sw37.enabled = false
                                sw38.enabled = false
                                sw39.enabled = false
                                sw310.enabled = false
                                sw311.enabled = false
                                sw312.enabled = false

                                sw11.checked = false
                                sw12.checked = false
                                sw13.checked = false
                                sw14.checked = false
                                sw15.checked = false
                                sw16.checked = false
                                sw17.checked = false
                                sw18.checked = false
                                sw19.checked = false
                                sw110.checked = false
                                sw111.checked = false
                                sw112.checked = false
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
                                sw31.checked = false
                                sw32.checked = false
                                sw33.checked = false
                                sw34.checked = false
                                sw35.checked = false
                                sw36.checked = false
                                sw37.checked = false
                                sw38.checked = false
                                sw39.checked = false
                                sw310.checked = false
                                sw311.checked = false
                                sw312.checked = false

                            }
                        }
                    }
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        color: "transparent"

                        SGStatusLight {
                            id: sgStatusLight
                            status: "off"           // Default: "off" (other options: "green", "yellow", "orange", "red")
                            anchors.centerIn: parent
                            lightSize: 50
                        }
                    }
                }
            }
        }
    }
}


