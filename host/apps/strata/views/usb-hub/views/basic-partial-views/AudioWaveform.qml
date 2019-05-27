import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {

    property var sample1Value
    property var sample2Value
    property var sample3Value
    property var sample4Value
    property var sample5Value
    property var sample6Value
    property var sample7Value
    property var sample8Value
    property var sample9Value
    property var sample10Value
    property var sample11Value
    property var sample12Value
    property var sample13Value
    property var sample14Value
    property var sample15Value
    property var sample16Value
    property int audioSampleInterval: 100
    property int audioSampleTransitionSpeed:50

    property bool audioPlaying: platformInterface.audio_active_notification.audio_active

    Component.onCompleted:{
        //set some initial values so the waveform is seen (but not animated) when opened
        sample1Value = Math.random();
        sample2Value = Math.random();
        sample3Value = Math.random();
        sample4Value = Math.random();
        sample5Value = Math.random();
        sample6Value = Math.random();
        sample7Value = Math.random();
        sample8Value = Math.random();
        sample9Value = Math.random();
        sample10Value = Math.random();
        sample11Value = Math.random();
        sample12Value = Math.random();
        sample13Value = Math.random();
        sample14Value = Math.random();
        sample15Value = Math.random();
        sample16Value = Math.random();
        //console.log("initial audio values are:",sample1Value,sample2Value,sample3Value,sample4Value,sample5Value,sample6Value,sample7Value,sample8Value,sample9Value,sample10Value,sample11Value,sample12Value,sample13Value,sample14Value,sample15Value,sample16Value)
    }

    Timer{
        //generate sample data to drive the audio graph when a
        //device is connected. This is for testing, and will be removed when real audio data is available
        id:audioDataTimer
        interval: audioSampleInterval
        repeat: true
        running:audioPlaying
        onTriggered: {
            sample16Value = sample15Value;
            sample15Value = sample14Value;
            sample14Value = sample13Value;
            sample13Value = sample12Value;
            sample12Value = sample11Value;
            sample11Value = sample10Value;
            sample10Value = sample9Value;
            sample9Value = sample8Value;
            sample8Value = sample7Value;
            sample7Value = sample6Value;
            sample6Value = sample5Value;
            sample5Value = sample4Value;
            sample4Value = sample3Value;
            sample3Value = sample2Value;
            sample2Value = sample1Value;
            if (audioPlaying)
                sample1Value = Math.random() * platformInterface.audio_volume_notification.volume;  //scale by the volume (0-1)
              else
                sample1Value = 0;
            //console.log("timer. Value =",sample1Value)
         }

    }

    Row{
        anchors.fill:parent

        AudioSample{
            id:sample1
            value: sample1Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample2
            value: sample2Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample3
            value: sample3Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample4
            value: sample4Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample5
            value: sample5Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample6
            value: sample6Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample7
            value: sample7Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample8
            value: sample8Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample9
            value: sample9Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample10
            value: sample10Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample11
            value: sample11Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample12
            value: sample12Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample13
            value: sample13Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample143
            value: sample14Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample15
            value: sample15Value
            width:parent.width/16
            height:parent.height
        }
        AudioSample{
            id:sample16
            value: sample16Value
            width:parent.width/16
            height:parent.height
        }
    }
}
