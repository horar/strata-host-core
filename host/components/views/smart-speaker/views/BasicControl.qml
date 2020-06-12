import QtQuick 2.10
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 0.9 as Widget09
import "../views/basic-partial-views"

Widget09.SGResponsiveScrollView {
    id: root

    minimumHeight: 900
    minimumWidth: 1300

    property string borderColor: "#002C74"
    property string backgroundColor: "#91ABE1"
    property string hightlightColor: "#F8BB2C"

    Rectangle {
        id: container
        parent: root.contentItem
        color:borderColor
        anchors {
            fill: parent
        }

        Rectangle{
            id:deviceBackground
            color:backgroundColor
            radius:10
            height:(7*parent.height)/16
            anchors.left:parent.left
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.top:parent.top
            anchors.topMargin: 12
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 12
        }

        //----------------------------------------------------------------------------------------
        //                      Views
        //----------------------------------------------------------------------------------------



        Text{
            id:boardName
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin: 10
            text:"Voice User Interface"
            color:"black"
            font.pixelSize: 75
        }

        Row{
            id:mixerRow
            anchors.top:boardName.bottom
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            MixerView{
                id:mixerView
                height:500
                width:150
            }


            EqualizerView{
                id:eqView
                height:500
                width:660
            }
        }

        //bottom row
        Row{
            anchors.top:mixerRow.bottom
            anchors.topMargin: 30
            anchors.left: mixerRow.left
            spacing: 20

            PlaybackControlView{
                id:playbackControlView
                height:100
                width:250
            }

            BluetoothView{
                id:bluetoothView
                height:100
                width:270
            }

            AmplifierView{
                id:amplifierView
                height:100
                width:270
            }


            //            InputVoltageView{
            //                id:inputVoltageView
            //                height:200
            //                width:200
            //                anchors.left: playbackControlView.right
            //                anchors.leftMargin: 20
            //                anchors.verticalCenter: bluetoothView.verticalCenter
            //                visible:false

            //                analogAudioCurrent: {
            //                    if (platformInterface.audio_power.analog_audio_current === "0.0"){
            //                        return "0.00"
            //                     }
            //                      else
            //                        return Math.round(platformInterface.audio_power.analog_audio_current*100)/100;
            //                }
            //                digitalAudioCurrent:{
            //                    if (platformInterface.audio_power.digital_audio_current === "0.0")
            //                        return "0.00"
            //                      else
            //                        return Math.round(platformInterface.audio_power.digital_audio_current*100)/100;
            //                }

            //                audioVoltage: Math.round(platformInterface.audio_power.audio_voltage*10)/10;

            //                temperature: Math.round(platformInterface.audio_power.board_temperature);
            //            }

            //            PortInfo{
            //                id:portInfoView
            //                height:200
            //                anchors.left: playbackControlView.right
            //                anchors.leftMargin: 20
            //                anchors.verticalCenter: bluetoothView.verticalCenter
            //                visible:false

            //                property var periodicValues: platformInterface.request_usb_power_notification

            //                onPeriodicValuesChanged: {
            //                    var inputCurrent = platformInterface.request_usb_power_notification.input_current;
            //                    var outputCurrent = platformInterface.request_usb_power_notification.output_current;
            //                    var theInputPower = platformInterface.request_usb_power_notification.input_voltage * inputCurrent;
            //                    var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * outputCurrent;


            //                }


            //                outputVoltage:{
            //                    return Math.round (platformInterface.request_usb_power_notification.output_voltage * 100)/100;
            //                }
            //                inputVoltage:{
            //                    return Math.round(platformInterface.request_usb_power_notification.input_voltage*100)/100;
            //                }
            //                inputCurrent:{
            //                    return Math.round(platformInterface.request_usb_power_notification.input_current*100)/100;
            //                }
            //                outputCurrent:{
            //                    return Math.round(platformInterface.request_usb_power_notification.output_current)/100;
            //                }

            //                temperature:{
            //                    return Math.round(platformInterface.request_usb_power_notification.temperature*10)/10;
            //                }
            //            }
        }




    }
}

