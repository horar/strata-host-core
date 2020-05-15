import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    anchors.centerIn: parent
    height: parent.height
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width


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
                            alignment: SGAlignedLabel.SideTopLeft
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            SGInfoBox {
                                id: idVers1
                                height:  35 * ratioCalc
                                width: 140 * ratioCalc
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                boxFont.family: Fonts.digitalseven
                            }

                            property var misc_id_vers_1: platformInterface.misc_id_vers_1
                            onMisc_id_vers_1Changed: {
                                idVers1Label.text = misc_id_vers_1.caption
                                if(misc_id_vers_1.state === "enabled"){
                                    idVers1.opacity = 1.0
                                    idVers1.enabled = true
                                }
                                else if (misc_id_vers_1.state === "disabled") {
                                    idVers1.opacity = 1.0
                                    idVers1.enabled = false
                                }
                                else {
                                    idVers1.opacity = 0.5
                                    idVers1.enabled = false
                                }
                                idVers1.text = misc_id_vers_1.value

                            }

                            property var misc_id_vers_1_caption: platformInterface.misc_id_vers_1_caption.caption
                            onMisc_id_vers_1_captionChanged: {
                                idVers1Label.text = misc_id_vers_1_caption
                            }

                            property var misc_id_vers_1_state: platformInterface.misc_id_vers_1_state.state
                            onMisc_id_vers_1_stateChanged: {
                                if(misc_id_vers_1_state === "enabled"){
                                    idVers1.opacity = 1.0
                                    idVers1.enabled = true
                                }
                                else if (misc_id_vers_1_state === "disabled") {
                                    idVers1.opacity = 1.0
                                    idVers1.enabled = false
                                }
                                else {
                                    idVers1.opacity = 0.5
                                    idVers1.enabled = false
                                }
                            }

                            property var misc_id_vers_1_value: platformInterface.misc_id_vers_1_value.value
                            onMisc_id_vers_1_valueChanged: {
                                idVers1.text = misc_id_vers_1_value
                            }

                        }
                    }
                    Rectangle {
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

                            }

                            property var misc_odd_ch_error: platformInterface.misc_odd_ch_error
                            onMisc_odd_ch_errorChanged: {
                                oddChannelErrorLabel.text = misc_odd_ch_error.caption
                                if(misc_odd_ch_error.state === "enabled"){
                                    oddChannelError.opacity = 1.0
                                    oddChannelError.enabled = true
                                }
                                else if (misc_odd_ch_error.state === "disabled") {
                                    oddChannelError.opacity = 1.0
                                    oddChannelError.enabled = false
                                }
                                else {
                                    oddChannelError.opacity = 0.5
                                    oddChannelError.enabled = false
                                }
                                if(misc_odd_ch_error.value === true){
                                    oddChannelError.status = SGStatusLight.Red
                                }
                                else oddChannelError.status = SGStatusLight.Off
                            }

                            property var misc_odd_ch_error_caption: platformInterface.misc_odd_ch_error_caption.caption
                            onMisc_odd_ch_error_captionChanged: {
                                oddChannelErrorLabel.text = misc_odd_ch_error_caption
                            }

                            property var misc_odd_ch_error_state: platformInterface.misc_odd_ch_error_state.state
                            onMisc_odd_ch_error_stateChanged: {
                                if(misc_odd_ch_error_state === "enabled"){
                                    oddChannelError.opacity = 1.0
                                    oddChannelError.enabled = true
                                }
                                else if (misc_odd_ch_error_state === "disabled") {
                                    oddChannelError.opacity = 1.0
                                    oddChannelError.enabled = false
                                }
                                else {
                                    oddChannelError.opacity = 0.5
                                    oddChannelError.enabled = false
                                }
                            }

                            property var misc_odd_ch_error_value: platformInterface.misc_odd_ch_error_value.value
                            onMisc_odd_ch_error_valueChanged: {
                                if(misc_odd_ch_error_value === true){
                                    oddChannelError.status = SGStatusLight.Red
                                }
                                else oddChannelError.status = SGStatusLight.Off
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
                            // text: "ID_VERS_2"
                            target: idVers2
                            alignment: SGAlignedLabel.SideTopLeft
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            font.bold : true
                            SGInfoBox {
                                id: idVers2
                                height:  35 * ratioCalc
                                width: 140 * ratioCalc
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                // unit: "<b>V</b>"
                                // text: "0x04"
                                boxFont.family: Fonts.digitalseven
                            }

                            property var misc_id_vers_2: platformInterface.misc_id_vers_2
                            onMisc_id_vers_2Changed: {
                                idVers2Label.text = misc_id_vers_2.caption
                                if(misc_id_vers_2.state === "enabled"){
                                    idVers2.opacity = 1.0
                                    idVers2.enabled = true
                                }
                                else if (misc_id_vers_2.state === "disabled") {
                                    idVers2.opacity = 1.0
                                    idVers2.enabled = false
                                }
                                else {
                                    idVers2.opacity = 0.5
                                    idVers2.enabled = false
                                }
                                idVers2.text = misc_id_vers_2.value

                            }

                            property var misc_id_vers_2_caption: platformInterface.misc_id_vers_2_caption.caption
                            onMisc_id_vers_2_captionChanged: {
                                idVers2Label.text = misc_id_vers_2_caption
                            }

                            property var misc_id_vers_2_state: platformInterface.misc_id_vers_2_state.state
                            onMisc_id_vers_2_stateChanged: {
                                if(misc_id_vers_2_state === "enabled"){
                                    idVers2.opacity = 1.0
                                    idVers2.enabled = true
                                }
                                else if (misc_id_vers_2_state === "disabled") {
                                    idVers2.opacity = 1.0
                                    idVers2.enabled = false
                                }
                                else {
                                    idVers2.opacity = 0.5
                                    idVers2.enabled = false
                                }
                            }

                            property var misc_id_vers_2_value: platformInterface.misc_id_vers_2_value.value
                            onMisc_id_vers_2_valueChanged: {
                                idVers2.text = misc_id_vers_2_value
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        SGAlignedLabel {
                            id: evenChannelErrorLabel
                            target: evenChannelError
                            alignment: SGAlignedLabel.SideTopCenter
                            anchors.centerIn: parent
                            fontSizeMultiplier: ratioCalc * 1.2
                            //text: "Odd Channel Error"
                            font.bold: true

                            SGStatusLight {
                                id: evenChannelError

                            }

                            property var misc_even_ch_error: platformInterface.misc_even_ch_error
                            onMisc_even_ch_errorChanged: {
                                evenChannelErrorLabel.text = misc_even_ch_error.caption
                                if(misc_even_ch_error.state === "enabled"){
                                    evenChannelError.opacity = 1.0
                                    evenChannelError.enabled = true
                                }
                                else if (misc_even_ch_error.state === "disabled") {
                                    evenChannelError.opacity = 1.0
                                    evenChannelError.enabled = false
                                }
                                else {
                                    evenChannelError.opacity = 0.5
                                    evenChannelError.enabled = false
                                }
                                if(misc_even_ch_error.value === true){
                                    evenChannelError.status = SGStatusLight.Red
                                }
                                else evenChannelError.status = SGStatusLight.Off

                            }

                            property var misc_even_ch_error_caption: platformInterface.misc_even_ch_error_caption.caption
                            onMisc_even_ch_error_captionChanged: {
                                evenChannelErrorLabel.text = misc_even_ch_error_caption
                            }

                            property var misc_even_ch_error_state: platformInterface.misc_even_ch_error_state.state
                            onMisc_even_ch_error_stateChanged: {
                                if(misc_even_ch_error_state === "enabled"){
                                    evenChannelError.opacity = 1.0
                                    evenChannelError.enabled = true
                                }
                                else if (misc_even_ch_error_state === "disabled") {
                                    evenChannelError.opacity = 1.0
                                    evenChannelError.enabled = false
                                }
                                else {
                                    evenChannelError.opacity = 0.5
                                    evenChannelError.enabled = false
                                }
                            }

                            property var misc_even_ch_error_value: platformInterface.misc_even_ch_error_value.value
                            onMisc_even_ch_error_valueChanged: {
                                if(misc_even_ch_error_value === true){
                                    evenChannelError.status = SGStatusLight.Red
                                }
                                else evenChannelError.status = SGStatusLight.Off
                            }

                        }

                    }
                }
            }
        }
    }
}
