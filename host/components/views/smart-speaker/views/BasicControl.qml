import QtQuick 2.10
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 0.9
import "../views/basic-partial-views"

Rectangle {
    id: root
    anchors.fill:parent
    color:"dimgrey"

    property string textColor: "white"
    property string secondaryTextColor: "grey"
    property string windowsDarkBlue: "#2d89ef"
    property string backgroundColor: "#FF2A2E31"
    property string transparentBackgroundColor: "#002A2E31"
    property string dividerColor: "#3E4042"
    property string switchGrooveColor:"dimgrey"
    property int leftSwitchMargin: 40
    property int rightInset: 50
    property int leftScrimOffset: 310
    property bool pulseColorsLinked: false

    property real widthRatio: root.width / 1200


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

    ScrollView {
        //this allows the view to scroll if the window gets smaller than the basicView's minimum size
        id: scrollView
        anchors {
            fill: root
        }

        Rectangle{
            //put the contents of the basicControl view inside a rectangle of fixed size so that
            //the contents can be scrolled when the window gets smaller
            id:scrollViewContentRect
            anchors.fill:parent
            implicitHeight: 900
            implicitWidth: 1300
            color:"transparent"


            Text{
                id:boardName
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:parent.top
                text:"Bluetooth Speaker"
                color:"white"
                font.pixelSize: 75
            }

            MixerView{
                id:mixerView
                height:500
                width:250
                anchors.left:parent.left
                anchors.leftMargin:150
                anchors.top:boardName.bottom
                anchors.topMargin:50

            }


            EqualizerView{
                id:eqView
                height:500
                width:660
                anchors.left:mixerView.right
                anchors.leftMargin:20
                anchors.top:boardName.bottom
                anchors.topMargin:50
            }

            SpeakerView{
                id:speakerView
                height:500
                width:200
                visible:false
                anchors.left:eqView.right
                anchors.leftMargin:20
                anchors.verticalCenter: eqView.verticalCenter

                coilTemperature: Math.round(platformInterface.request_usb_power_notification.input_voltage*100)/100;
                speakerResistance: "20"
                resonantFrequency: "20"
                qesValue: "20"
                qmsValue: "20"
                qtsValue: "20"
                rmsValue: "20"
                cmsValue: "20"
                }




            //bottom row

            BluetoothView{
                id:bluetoothView
                height:200
                width:200
                anchors.left: parent.left
                anchors.leftMargin: 250
                anchors.top: eqView.bottom
                anchors.topMargin:50
            }



            PlaybackControlView{
                id:playbackControlView
                height:100
                width:290
                anchors.left: bluetoothView.right
                anchors.leftMargin: 20
                anchors.verticalCenter: bluetoothView.verticalCenter
                visible:true

            }

            InputVoltageView{
                id:inputVoltageView
                height:200
                width:200
                anchors.left: playbackControlView.right
                anchors.leftMargin: 20
                anchors.verticalCenter: bluetoothView.verticalCenter

                analogAudioCurrent: {
                    if (platformInterface.audio_power.analog_audio_current === "0.0"){
                        return "0.00"
                     }
                      else
                        return Math.round(platformInterface.audio_power.analog_audio_current*100)/100;
                }
                digitalAudioCurrent:{
                    if (platformInterface.audio_power.digital_audio_current === "0.0")
                        return "0.00"
                      else
                        return Math.round(platformInterface.audio_power.digital_audio_current*100)/100;
                }

                audioVoltage: Math.round(platformInterface.audio_power.audio_voltage*10)/10;
            }

            PortInfo{
                id:portInfoView
                height:200
                anchors.left: playbackControlView.right
                anchors.leftMargin: 20
                anchors.verticalCenter: bluetoothView.verticalCenter
                visible:false

                property var periodicValues: platformInterface.request_usb_power_notification

                onPeriodicValuesChanged: {
                    var inputCurrent = platformInterface.request_usb_power_notification.input_current;
                    var outputCurrent = platformInterface.request_usb_power_notification.output_current;
                    var theInputPower = platformInterface.request_usb_power_notification.input_voltage * inputCurrent;
                    var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * outputCurrent;


                }


                outputVoltage:{
                    return Math.round (platformInterface.request_usb_power_notification.output_voltage * 100)/100;
                }
                inputVoltage:{
                    return Math.round(platformInterface.request_usb_power_notification.input_voltage*100)/100;
                }
                inputCurrent:{
                    return Math.round(platformInterface.request_usb_power_notification.input_current*100)/100;
                }
                outputCurrent:{
                    return Math.round(platformInterface.request_usb_power_notification.output_current)/100;
                }

                temperature:{
                    return Math.round(platformInterface.request_usb_power_notification.temperature*10)/10;
                }
            }


        }
    }

}
