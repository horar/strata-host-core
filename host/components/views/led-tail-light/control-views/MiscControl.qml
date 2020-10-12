import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1400/900
    anchors.centerIn: parent
    height: parent.height
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width

    function toHex(d) {
        return  ("0"+(Number(d).toString(16))).slice(-2).toUpperCase()
    }

    Component.onCompleted: {
        Help.registerTarget(idVers1, "ON Semiconductor device identifier for the LED driver. The value is 0x43 for both NCV7684 and NCV7685.", 0, "miscHelp")
        Help.registerTarget(idVers2, "Version identifier for the LED driver. The values are 0x02 for the NCV7684 and 0x04 for the NCV7685.", 1, "miscHelp")
        Help.registerTarget(filterHelpContainer1, "Indicates an error with either odd or even LED channels. The NCV47822 load switches are being shorted to ground or experiencing an over current event.", 2, "miscHelp")
    }

    Item {
        id: filterHelpContainer1
        property point topLeft
        property point bottomRight
        width:  (oddContainer.width + evenContainer.width)
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = oddContainer.mapToItem(root, 0,  0)
            bottomRight = evenContainer.mapToItem(root, evenContainer.width, evenContainer.height)
        }
    }

    onWidthChanged: {
        filterHelpContainer1.update()
    }
    onHeightChanged: {
        filterHelpContainer1.update()
    }

    Connections {
        target: Help.utility
        onTour_runningChanged:{
            filterHelpContainer1.update()
        }
    }

    function setStatesForControls (theId, index){
        if(index !== null && index !== undefined)  {
            if(index === 0) {
                theId.enabled = true
                theId.opacity = 1.0
            }
            else if(index === 1) {
                theId.enabled = false
                theId.opacity = 1.0
            }
            else {
                theId.enabled = false
                theId.opacity = 0.5
            }
        }
    }

    Rectangle {
        width: parent.width/2
        height: parent.height/2
        anchors.centerIn: parent

        RowLayout {
            anchors.fill: parent


            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        SGAlignedLabel {
                            id: idVers1Label
                            //text: "ID_VERS_1"
                            target: idVers1
                            alignment: SGAlignedLabel.SideTopCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            SGInfoBox {
                                id: idVers1
                                height:  35 * ratioCalc
                                width: 50 * ratioCalc
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2

                            }

                            SGText{
                                id: idVers1Text
                                text: "0x"
                                anchors.right: idVers1.left
                                anchors.rightMargin: 10
                                anchors.verticalCenter: idVers1.verticalCenter
                                font.bold: true
                            }

                            property var misc_id_vers_1: platformInterface.misc_id_vers_1
                            onMisc_id_vers_1Changed: {
                                idVers1Label.text = misc_id_vers_1.caption
                                setStatesForControls(idVers1,misc_id_vers_1.states[0])
                                idVers1.text =  toHex(misc_id_vers_1.value)

                            }

                            property var misc_id_vers_1_caption: platformInterface.misc_id_vers_1_caption.caption
                            onMisc_id_vers_1_captionChanged: {
                                idVers1Label.text = misc_id_vers_1_caption
                            }

                            property var misc_id_vers_1_state: platformInterface.misc_id_vers_1_states.states
                            onMisc_id_vers_1_stateChanged: {
                                setStatesForControls(idVers1,misc_id_vers_1_state[0])
                            }

                            property var misc_id_vers_1_value: platformInterface.misc_id_vers_1_value.value
                            onMisc_id_vers_1_valueChanged: {
                                idVers1.text = toHex(misc_id_vers_1_value)
                            }

                        }
                    }
                    Rectangle {
                        id: oddContainer
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        SGAlignedLabel {
                            id: oddChannelErrorLabel
                            target: oddChannelError
                            alignment: SGAlignedLabel.SideTopCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold: true

                            SGStatusLight {
                                id: oddChannelError
                                width : 40

                            }

                            property var misc_odd_ch_error: platformInterface.misc_odd_ch_error
                            onMisc_odd_ch_errorChanged: {
                                oddChannelErrorLabel.text = misc_odd_ch_error.caption
                                setStatesForControls(oddChannelError,misc_odd_ch_error.states[0])

                                if(misc_odd_ch_error.value === true){
                                    if(!miscControl.visible){
                                        miscViewBadge.opacity = 1.0
                                    }
                                    oddChannelError.status = SGStatusLight.Red
                                }
                                else {
                                    if(!miscControl.visible){
                                        miscViewBadge.opacity = 0.0
                                    }
                                    oddChannelError.status = SGStatusLight.Off
                                }
                            }

                            property var misc_odd_ch_error_caption: platformInterface.misc_odd_ch_error_caption.caption
                            onMisc_odd_ch_error_captionChanged: {
                                oddChannelErrorLabel.text = misc_odd_ch_error_caption
                            }

                            property var misc_odd_ch_error_state: platformInterface.misc_odd_ch_error_states.states
                            onMisc_odd_ch_error_stateChanged: {
                                setStatesForControls(oddChannelError,misc_odd_ch_error_state[0])
                            }

                            property var misc_odd_ch_error_value: platformInterface.misc_odd_ch_error_value.value
                            onMisc_odd_ch_error_valueChanged: {
                                if(misc_odd_ch_error_value === true){
                                    if(!miscControl.visible){
                                        miscViewBadge.opacity = 1.0
                                    }
                                    oddChannelError.status = SGStatusLight.Red
                                }
                                else {
                                    if(!miscControl.visible){
                                        miscViewBadge.opacity = 0.0
                                    }
                                    oddChannelError.status = SGStatusLight.Off
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout {

                    anchors.fill: parent

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        SGAlignedLabel {
                            id: idVers2Label
                            target: idVers2
                            alignment: SGAlignedLabel.SideTopCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            SGInfoBox {
                                id: idVers2
                                height:  35 * ratioCalc
                                width: 50 * ratioCalc
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                            }

                            SGText{
                                id: idVers2Text
                                text: "0x"
                                anchors.right: idVers2.left
                                anchors.rightMargin: 10
                                anchors.verticalCenter: idVers2.verticalCenter
                                font.bold: true
                            }

                            property var misc_id_vers_2: platformInterface.misc_id_vers_2
                            onMisc_id_vers_2Changed: {
                                idVers2Label.text = misc_id_vers_2.caption
                                setStatesForControls(idVers2,misc_id_vers_2.states[0])
                                idVers2.text = toHex(misc_id_vers_2.value)

                            }

                            property var misc_id_vers_2_caption: platformInterface.misc_id_vers_2_caption.caption
                            onMisc_id_vers_2_captionChanged: {
                                idVers2Label.text = misc_id_vers_2_caption
                            }

                            property var misc_id_vers_2_state: platformInterface.misc_id_vers_2_states.states
                            onMisc_id_vers_2_stateChanged: {
                                setStatesForControls(idVers2,misc_id_vers_2_state[0])
                            }

                            property var misc_id_vers_2_value: platformInterface.misc_id_vers_2_value.value
                            onMisc_id_vers_2_valueChanged: {
                                idVers2.text = toHex(misc_id_vers_2_value)
                            }
                        }
                    }
                    Rectangle {
                        id: evenContainer
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        SGAlignedLabel {
                            id: evenChannelErrorLabel
                            target: evenChannelError
                            alignment: SGAlignedLabel.SideTopCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold: true
                            SGStatusLight {
                                id: evenChannelError
                                width : 40

                            }
                            property var misc_even_ch_error: platformInterface.misc_even_ch_error
                            onMisc_even_ch_errorChanged: {
                                evenChannelErrorLabel.text = misc_even_ch_error.caption
                                setStatesForControls(evenChannelError,misc_even_ch_error.states[0])
                                if(misc_even_ch_error.value === true){
                                    if(!miscControl.visible){
                                        miscViewBadge.opacity = 1.0
                                    }
                                    evenChannelError.status = SGStatusLight.Red
                                }
                                else {
                                    if(!miscControl.visible){
                                        miscViewBadge.opacity = 0.0
                                    }
                                    evenChannelError.status = SGStatusLight.Off
                                }

                            }

                            property var misc_even_ch_error_caption: platformInterface.misc_even_ch_error_caption.caption
                            onMisc_even_ch_error_captionChanged: {
                                evenChannelErrorLabel.text = misc_even_ch_error_caption
                            }

                            property var misc_even_ch_error_state: platformInterface.misc_even_ch_error_states.states
                            onMisc_even_ch_error_stateChanged: {
                                setStatesForControls(evenChannelError,misc_even_ch_error_state[0])
                            }

                            property var misc_even_ch_error_value: platformInterface.misc_even_ch_error_value.value
                            onMisc_even_ch_error_valueChanged: {
                                if(misc_even_ch_error_value === true){
                                    if(!miscControl.visible){
                                        miscViewBadge.opacity = 1.0
                                    }
                                    evenChannelError.status = SGStatusLight.Red
                                }
                                else {
                                    if(!miscControl.visible){
                                        miscViewBadge.opacity = 0.0
                                    }
                                    evenChannelError.status = SGStatusLight.Off
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
