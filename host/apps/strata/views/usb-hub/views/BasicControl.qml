import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.3
import "qrc:/views/usb-hub/sgwidgets"
import "qrc:/views/usb-hub/views/basic-partial-views"

Item {
    id: root

    property bool debugLayout: false
    property real ratioCalc: root.width / 1200

    //default values
    //these are used to restore animation times after an immediate change, which happens without the animation
    property int defaultBasicToAdvancedTransitionTime: 700
    property int defaultBasicToAdvancedTelemetryAnimationTime: 700
    property int defaultAdvancedToBasicTransitionTime: 700
    property int defaultAdvancedToBasicTelemetryAnimationTime: 700
    property int defaultAdvancedToBasicAdvancedControlsAnimationTime: 700
    property int defaultAdvancedToBasicAnimationPauseTime: 1400
    property int defaultAdvancedControlBuildInTime: 500

    //basic to advanced animation times
    property int basicToAdvancedTransitionTime: defaultBasicToAdvancedTransitionTime
    property int basicToAdvancedTelemetryAnimationTime: defaultBasicToAdvancedTelemetryAnimationTime

    //advanced to basic animation times
    property int advancedToBasicTransitionTime: defaultAdvancedToBasicTransitionTime
    property int advancedToBasicTelemetryAnimationTime: defaultAdvancedToBasicTelemetryAnimationTime
    property int advancedToBasicAdvancedControlsAnimationTime: defaultAdvancedToBasicAdvancedControlsAnimationTime
    property int advancedToBasicAnimationPauseTime: defaultAdvancedToBasicAnimationPauseTime
    property int advancedControlBuildInTime: defaultAdvancedControlBuildInTime

    property int portLeftRightMargin: 7

    property int basicPortWidth: 160
    property int advancedPortWidth: 240

    property int basicDeviceWidth: 160
    property int advancedDeviceWidth: 240

    property int basicThinPortWidth: 170
    property int advancedThinPortWidth: 170

    property int basicPortHeight: 344

    //these can eventually be removed
    property int advancedUSBAPortHeight: 240
    property int advancedAudioPortHeight: 157
    property int advancedDisplayPortPortHeight: 157

    property int basicTopMargin: 95
    property int advancedTopMargin: 10

    //since the transition to advanced view has a series of animations that run in sequence,
    //and since there
    property bool upstreamPortReadyToTransitionToAdvanced: false
    onUpstreamPortReadyToTransitionToAdvancedChanged: upstreamPortTransitionToAdvancedProc()
    property bool port1ReadyToTransitionToAdvanced:false
    onPort1ReadyToTransitionToAdvancedChanged: port1TransitionToAdvancedProc()
    property bool port2ReadyToTransitionToAdvanced:false
    onPort2ReadyToTransitionToAdvancedChanged: port2TransitionToAdvancedProc()
    property bool port3ReadyToTransitionToAdvanced:false
    onPort3ReadyToTransitionToAdvancedChanged: port3TransitionToAdvancedProc()
    property bool port4ReadyToTransitionToAdvanced:false
    onPort4ReadyToTransitionToAdvancedChanged: port4TransitionToAdvancedProc()
    property bool audioPortReadyToTransitionToAdvanced:false
    onAudioPortReadyToTransitionToAdvancedChanged: audioPortTransitionToAdvancedProc()
    property bool displayPortReadyToTransitionToAdvanced:false
    onDisplayPortReadyToTransitionToAdvancedChanged: displayPortTransitionToAdvancedProc()
    property bool devicesReadyToTransitionToAdvanced:false
    onDevicesReadyToTransitionToAdvancedChanged: devicesTransitionToAdvancedProc()

    property bool port2ReadyToTransitionToBasic:false
    onPort2ReadyToTransitionToBasicChanged: port2TransitionToBasicProc()
    property bool port1ReadyToTransitionToBasic:false
    onPort1ReadyToTransitionToBasicChanged: port1TransitionToBasicProc()
    property bool upstreamPortReadyToTransitionToBasic:false
    onUpstreamPortReadyToTransitionToBasicChanged: upstreamPortTransitionToBasicProc()

    anchors.fill:parent



    //called when switching to advanced view from the system tab
    //it should execute an immediate switch to the advanced view, not an animated transition
    function transitionImmediatelyToAdvancedView(){
        basicToAdvancedTransitionTime= 1
        basicToAdvancedTelemetryAnimationTime= 1
        advancedControlBuildInTime = 1

        transitionToAdvancedView();
    }

    //called upon completion of the switch to advanced animation
    function toAdvancedAnimationFinished(){

        //in order to do the transition immedately, the animation speed was changed.
        //if that was the case, then reset the transition speed here.
        //this should really be done using some sort of default value, not a constant
        basicToAdvancedTransitionTime= defaultBasicToAdvancedTransitionTime;
        basicToAdvancedTelemetryAnimationTime= defaultBasicToAdvancedTelemetryAnimationTime;
        advancedControlBuildInTime = defaultAdvancedControlBuildInTime;
    }

    function transitionToAdvancedView(){
        portsAndBackgroundToAdvanced.start()

        upstreamPort.prepareToTransitionToAdvancedView();
        port1.prepareToTransitionToAdvancedView();
        port2.prepareToTransitionToAdvancedView();
        port3.prepareToTransitionToAdvancedView();

        audioPort.transitionToAdvancedView();
        displayPort.transitionToAdvancedView();
    }

    SequentialAnimation{
        id:portsAndBackgroundToAdvanced

        ParallelAnimation{
            id: backgroundToAdvanced
            running: false

            PropertyAnimation{
                target:deviceBackground
                property: "anchors.topMargin"
                to:(root.height)/32
                duration: basicToAdvancedTransitionTime
            }

            PropertyAnimation{
                target:deviceBackground
                property: "height"
                to: (23*parent.height)/32
                duration: basicToAdvancedTransitionTime
            }

            onStopped:{

                displayPort.anchors.left = port3.right;
                displayPort.anchors.leftMargin = port4.width + 7;

                audioPort.anchors.left = undefined;
                audioPort.anchors.left = port3.right;
                audioPort.anchors.leftMargin = port4.width + displayPort.width + 7 + 7;
            }
        }

        ParallelAnimation{
            //here the heights and positions of the USB-A, Audio and Video ports are adjusted
            //note that we're not breaking anchors here, just changing margins, so it will be easier to
            //reset pieces into the original locations later.
            id:adjustRightThreePortHeightsAndPositions

            PropertyAnimation{
                //usb-A port
                target:port4
                property: "width"
                to: advancedThinPortWidth
                duration: basicToAdvancedTransitionTime
            }

            PropertyAnimation{
                //usb-A port
                target:port4
                property: "anchors.bottomMargin"
                to: (14*parent.height)/32
                duration: basicToAdvancedTransitionTime
            }


            PropertyAnimation{
                target:audioPort
                property: "width"
                to: advancedThinPortWidth
                duration: basicToAdvancedTransitionTime
            }
            PropertyAnimation{
                target:audioPort
                property: "anchors.topMargin"
                to:  (9.25*parent.height)/32
                duration: basicToAdvancedTransitionTime
            }
            PropertyAnimation{
                target:audioPort
                property: "anchors.bottomMargin"
                to: (7*parent.height)/32
                duration: basicToAdvancedTransitionTime
            }

            PropertyAnimation{
                target:displayPort
                property: "width"
                to: advancedThinPortWidth
                duration: basicToAdvancedTransitionTime
            }
            PropertyAnimation{
                target:displayPort
                property: "anchors.topMargin"
                to:(16.25*parent.height)/32
                duration: basicToAdvancedTransitionTime
            }


        }

        ParallelAnimation{
            //widen the upstream port to the advanced width.
            //alter the left margin of the displayPort and audioPort views to make it look as if they're
            //stuck in place as the upstream port is widened.
            id:upstreamPortToAdvanced

            PropertyAnimation{
                target:upstreamPort
                property: "width"
                to: advancedPortWidth
                duration: basicToAdvancedTransitionTime
            }

            PropertyAnimation{
                target:displayPort
                property: "anchors.leftMargin"
                to: displayPort.anchors.leftMargin - (advancedPortWidth - basicPortWidth + portLeftRightMargin)
                duration: basicToAdvancedTransitionTime
            }

            //I thought the audio port would have to be animated as well, but it turns out it doesn't
            //as it's left side is tied to the displayport, so it moves left with that.

        }

        ParallelAnimation{
            id:port1ToAdvanced

            PropertyAction{
                target:root;
                property:"upstreamPortReadyToTransitionToAdvanced";
                value: "true"
            }

            PropertyAnimation{
                target:port1
                property: "width"
                to: advancedPortWidth
                duration: basicToAdvancedTransitionTime
            }

            PropertyAnimation{
                target:displayPort
                property: "anchors.leftMargin"
                //I think the left margin isn't updated by the time this animation starts, so I have to double the
                //delta here
                to: displayPort.anchors.leftMargin - 2*(advancedPortWidth - basicPortWidth + (1.2*portLeftRightMargin))
                duration: basicToAdvancedTransitionTime
            }


        }

        ParallelAnimation{
            id:port2ToAdvanced

            PropertyAction{
                target:root;
                property:"port1ReadyToTransitionToAdvanced";
                value: "true"
            }

            PropertyAnimation{
                target:port2
                property: "width"
                to: advancedPortWidth
                duration: basicToAdvancedTransitionTime
            }


            PropertyAnimation{
                target:audioPort
                property: "anchors.leftMargin"
                to: audioPort.anchors.leftMargin - (advancedPortWidth - basicPortWidth + portLeftRightMargin)
                duration: basicToAdvancedTransitionTime
            }

        }

        ParallelAnimation{
            id:port3ToAdvanced

            PropertyAction{
                target:root;
                property:"port2ReadyToTransitionToAdvanced";
                value: "true"
            }

            PropertyAnimation{
                target:port3
                property: "width"
                to: advancedPortWidth
                duration: basicToAdvancedTransitionTime
            }

            PropertyAnimation{
                target:audioPort
                property: "anchors.leftMargin"
                to: audioPort.anchors.leftMargin - 2*(advancedPortWidth - basicPortWidth + (1.2*portLeftRightMargin))
                duration: basicToAdvancedTransitionTime
            }

        }

        ParallelAnimation{
            id:port4ToAdvanced

            PropertyAction{
                target:root;
                property:"port3ReadyToTransitionToAdvanced";
                value: "true"
            }

        }

        ParallelAnimation{
            id:smallPortsToAdvanced

            PropertyAction{
                target:root;
                property:"port4ReadyToTransitionToAdvanced";
                value: "true"
            }
            PropertyAction{
                target:root;
                property:"audioPortReadyToTransitionToAdvanced";
                value: "true"
            }
            PropertyAction{
                target:root;
                property:"displayPortReadyToTransitionToAdvanced";
                value: "true"
            }
            PropertyAction{
                target:root;
                property:"devicesReadyToTransitionToAdvanced";
                value: "true"
            }

        }

        onStopped:{
            //reset the variables controlling the port animations here.
            upstreamPortReadyToTransitionToAdvanced = false;
            port1ReadyToTransitionToAdvanced = false;
            port2ReadyToTransitionToAdvanced = false;
            port3ReadyToTransitionToAdvanced = false;
            port4ReadyToTransitionToAdvanced = false;
            audioPortReadyToTransitionToAdvanced = false;
            displayPortReadyToTransitionToAdvanced = false;
            devicesReadyToTransitionToAdvanced = false;
        }
    }  //end sequential animation


    //functions to trigger the transition of controls within a PortInfo
    //these are handled outside the sequential animation, as there's no way to trigger
    //a function from within a larger animation, as onStopped isn't called for child animations
    function upstreamPortTransitionToAdvancedProc(){
        if (upstreamPortReadyToTransitionToAdvanced == true)
            upstreamPort.transitionToAdvancedView()
    }

    function port1TransitionToAdvancedProc(){
        if (port1ReadyToTransitionToAdvanced == true)
            port1.transitionToAdvancedView()
    }

    function port2TransitionToAdvancedProc(){
        if (port2ReadyToTransitionToAdvanced == true)
            port2.transitionToAdvancedView()
    }

    function port3TransitionToAdvancedProc(){
        if (port3ReadyToTransitionToAdvanced == true)
            port3.transitionToAdvancedView()
    }

    function port4TransitionToAdvancedProc(){
        if (port4ReadyToTransitionToAdvanced == true)
            port4.transitionToAdvancedView()
    }

    function audioPortTransitionToAdvancedProc(){
        if (audioPortReadyToTransitionToAdvanced == true)
            audioPort.transitionToAdvancedView()
    }

    function displayPortTransitionToAdvancedProc(){
        if (displayPortReadyToTransitionToAdvanced == true)
            displayPort.transitionToAdvancedView()
    }

    function devicesTransitionToAdvancedProc(){
        if (devicesReadyToTransitionToAdvanced == true)
            devicesToAdvanced.start()
    }


    //--------------------------------------------------------------------
    //  Device Animations
    //--------------------------------------------------------------------
    ParallelAnimation{
        id: devicesToAdvanced
        PropertyAnimation{
            target: upstreamDevice
            property: "width"
            to: advancedDeviceWidth
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: port1Device
            property: "width"
            to: advancedDeviceWidth
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: port2Device
            property: "width"
            to: advancedDeviceWidth
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: port3Device
            property: "width"
            to: advancedDeviceWidth
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: upstreamDevice
            property: "anchors.topMargin"
            to: advancedTopMargin
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: port1Device
            property: "anchors.topMargin"
            to: advancedTopMargin
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: port2Device
            property: "anchors.topMargin"
            to: advancedTopMargin
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: port3Device
            property: "anchors.topMargin"
            to: advancedTopMargin
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: port4Device
            property: "anchors.topMargin"
            to: advancedTopMargin
            duration: basicToAdvancedTransitionTime
        }

        PropertyAnimation{
            target: port4Device
            property: "opacity"
            to: 0
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: videoIcon
            property: "opacity"
            to: 0
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: audioIcon
            property: "opacity"
            to: 0
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: upstreamAnimation
            property: "opacity"
            to: 0
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: port1Animation
            property: "opacity"
            to: 0
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: port2Animation
            property: "opacity"
            to: 0
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: port3Animation
            property: "opacity"
            to: 0
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: port4Animation
            property: "opacity"
            to: 0
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: displayPortAnimation
            property: "opacity"
            to: 0
            duration: basicToAdvancedTransitionTime
        }
        PropertyAnimation{
            target: audioAnimation
            property: "opacity"
            to: 0
            duration: basicToAdvancedTransitionTime
        }

        onStopped:{
            toAdvancedAnimationFinished();
        }

    }

    //----------------------------------------------------------------------------------------
    //                      Animation to Basic View
    //----------------------------------------------------------------------------------------

    //this is the function called when switching to basic from the system view
    function transitionImmediatelyToBasicView(){
        advancedToBasicTransitionTime = 1
        advancedToBasicTelemetryAnimationTime = 1
        advancedToBasicAdvancedControlsAnimationTime = 1
        advancedToBasicAnimationPauseTime = 1

        transitionToBasicView();
    }

    //called upon completion of the switch to basic animation
    function toBasicAnimationFinished(){
        advancedToBasicTransitionTime = defaultAdvancedToBasicTransitionTime        //reset transition times if needed
        advancedToBasicTelemetryAnimationTime = defaultAdvancedToBasicTelemetryAnimationTime
        advancedToBasicAdvancedControlsAnimationTime = defaultAdvancedToBasicAdvancedControlsAnimationTime
        advancedToBasicAnimationPauseTime = defaultAdvancedToBasicAnimationPauseTime

        //reset anchors that are undone to failitate the transition to advanced view
        displayPort.anchors.left = port4.right;
        displayPort.anchors.leftMargin = portLeftRightMargin;

        audioPort.anchors.left = displayPort.right;
        audioPort.anchors.leftMargin = portLeftRightMargin;
    }

    function transitionToBasicView(){

        port3.prepareToTransitionToBasicView();

        audioPort.transitionToBasicView();
        displayPort.transitionToBasicView();
        port4.transitionToBasicView();

        transitionViewsToBasic.start()

    }

    SequentialAnimation{
        id:transitionViewsToBasic

        //give the port 3 time to transition its subviews
        PauseAnimation{
            duration:port3.portConnected ? advancedToBasicAnimationPauseTime : 1
        }

        ParallelAnimation{
            PropertyAction{
                target:root;
                property:"port2ReadyToTransitionToBasic";
                value: "true"
            }
        }

        //first, make port 3 narrower, which should pull port4 left as it shrinks
        ParallelAnimation{
            id: adjustPort3Width
            running: false

            PropertyAnimation{
                target:port3
                property: "width"
                to: basicPortWidth
                duration: advancedToBasicTransitionTime
            }

            PropertyAnimation{
                //usb-A port
                target:port4
                property: "width"
                to: basicPortWidth
                duration: advancedToBasicTransitionTime
            }
            //at the same time, the audio and displayport views should
            //stay pinned right

            PropertyAnimation{
                target:audioPort
                property: "anchors.leftMargin"
                to: audioPort.anchors.leftMargin
                duration: advancedToBasicTransitionTime
            }

            PropertyAnimation{
                target:displayPort
                property: "anchors.leftMargin"
                to: displayPort.anchors.leftMargin + (advancedPortWidth - basicPortWidth + (1.2*portLeftRightMargin))
                duration: advancedToBasicTransitionTime
            }
        }

        //give the ports time to transition their subviews
        PauseAnimation{
            duration:port2.portConnected ? advancedToBasicAnimationPauseTime : 1
        }

        //do the same for port 2, pulling along the audioPort
        ParallelAnimation{
            id: adjustPort2Width
            running: false

            PropertyAnimation{
                target:port2
                property: "width"
                to: basicPortWidth
                duration: advancedToBasicTransitionTime
            }



            PropertyAnimation{
                target:audioPort
                property: "anchors.leftMargin"
                to: audioPort.anchors.leftMargin
                duration: advancedToBasicTransitionTime
            }

            PropertyAnimation{
                target:displayPort
                property: "anchors.leftMargin"
                to: displayPort.anchors.leftMargin + 2*(advancedPortWidth - basicPortWidth + (1.2*portLeftRightMargin))
                duration: advancedToBasicTransitionTime
            }

            PropertyAction{
                target:root;
                property:"port1ReadyToTransitionToBasic";
                value: "true"
            }

        }

        //give the ports time to transition their subviews
        PauseAnimation{
            duration:port1.portConnected ? advancedToBasicAnimationPauseTime : 1
        }

        //do the same for port 1, pulling along the audioPort
        ParallelAnimation{
            id: adjustPort1Width
            running: false

            PropertyAnimation{
                target:port1
                property: "width"
                to: basicPortWidth
                duration: advancedToBasicTransitionTime
            }

            PropertyAnimation{
                target:displayPort
                property: "width"
                to: basicPortWidth
                duration: advancedToBasicTransitionTime
            }


            PropertyAnimation{
                target:audioPort
                property: "anchors.leftMargin"
                to: audioPort.anchors.leftMargin + (advancedPortWidth - basicPortWidth )
                duration: advancedToBasicTransitionTime
            }

            PropertyAction{
                target:root;
                property:"upstreamPortReadyToTransitionToBasic";
                value: "true"
            }

        }

        //give the ports time to transition their subviews
        PauseAnimation{
            duration:upstreamPort.portConnected ? advancedToBasicAnimationPauseTime: 1
        }

        //do the same for the upstream port, pulling along the audioPort
        ParallelAnimation{
            id: adjustUpstreamPortWidth
            running: false

            PropertyAnimation{
                target:upstreamPort
                property: "width"
                to: basicPortWidth
                duration: advancedToBasicTransitionTime
            }

            PropertyAnimation{
                target:audioPort
                property: "width"
                to: basicPortWidth
                duration: advancedToBasicTransitionTime
            }


            PropertyAnimation{
                target:audioPort
                property: "anchors.leftMargin"
                to: audioPort.anchors.leftMargin + 2*(advancedPortWidth - basicPortWidth + (1.2*portLeftRightMargin))
                duration: advancedToBasicTransitionTime
            }

        }

        //now adjust the heights of the right three ports by adjusting the top and bottom margins
        ParallelAnimation{
            id: adjustRightPortHeights
            running: false

            PropertyAnimation{
                target:port4
                property: "anchors.bottomMargin"
                to: 5
                duration: advancedToBasicTransitionTime
            }

            PropertyAnimation{
                target:displayPort
                property: "anchors.topMargin"
                to: 10
                duration: advancedToBasicTransitionTime
            }

            PropertyAnimation{
                target:audioPort
                property: "anchors.topMargin"
                to: 10
                duration: advancedToBasicTransitionTime
            }

            PropertyAnimation{
                target:audioPort
                property: "anchors.bottomMargin"
                to: 5
                duration: advancedToBasicTransitionTime
            }



        }


        ParallelAnimation{
            id: backgroundToBasic
            running: false

            PropertyAnimation{
                target:deviceBackground
                property: "anchors.topMargin"
                to:(3*root.height)/32
                duration: advancedToBasicTransitionTime
            }

            PropertyAnimation{
                target:deviceBackground
                property: "height"
                to: (7*parent.height)/16
                duration: advancedToBasicTransitionTime
            }

        }



        //--------------------------------------------------------------------
        //  Device Animations
        //--------------------------------------------------------------------
        ParallelAnimation{
            id: devicesToBasic
            PropertyAnimation{
                target: upstreamDevice
                property: "width"
                to: basicDeviceWidth
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: port1Device
                property: "width"
                to: basicDeviceWidth
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: port2Device
                property: "width"
                to: basicDeviceWidth
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: port3Device
                property: "width"
                to: basicDeviceWidth
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: upstreamDevice
                property: "anchors.topMargin"
                to: basicTopMargin
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: port1Device
                property: "anchors.topMargin"
                to: basicTopMargin
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: port2Device
                property: "anchors.topMargin"
                to: basicTopMargin
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: port3Device
                property: "anchors.topMargin"
                to: basicTopMargin
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: port4Device
                property: "anchors.topMargin"
                to: basicTopMargin
                duration: advancedToBasicTransitionTime
            }

            PropertyAnimation{
                target: port4Device
                property: "opacity"
                to: 1
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: videoIcon
                property: "opacity"
                to: 1
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: audioIcon
                property: "opacity"
                to: 1
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: upstreamAnimation
                property: "opacity"
                to: 1
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: port1Animation
                property: "opacity"
                to: 1
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: port2Animation
                property: "opacity"
                to: 1
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: port3Animation
                property: "opacity"
                to: 1
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: port4Animation
                property: "opacity"
                to: 1
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: displayPortAnimation
                property: "opacity"
                to: 1
                duration: advancedToBasicTransitionTime
            }
            PropertyAnimation{
                target: audioAnimation
                property: "opacity"
                to: 1
                duration: advancedToBasicTransitionTime
            }

        }
        onStopped:{
            toBasicAnimationFinished();

            //reset the variables used to trigger animations
            port2ReadyToTransitionToBasic = false;
            port1ReadyToTransitionToBasic = false
            upstreamPortReadyToTransitionToBasic = false
        }
    }

    function port2TransitionToBasicProc(){
        if (port2ReadyToTransitionToBasic == true)
            port2.prepareToTransitionToBasicView();
    }
    function port1TransitionToBasicProc(){
        if (port1ReadyToTransitionToBasic == true)
            port1.prepareToTransitionToBasicView();
    }
    function upstreamPortTransitionToBasicProc(){
        if (upstreamPortReadyToTransitionToBasic == true)
            upstreamPort.prepareToTransitionToBasicView();
    }

    Rectangle{
        id:background
        anchors.fill:parent
        color:"#145A74"
    }

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
            implicitHeight: 800
            implicitWidth: 1200
            color:"transparent"


            PlugAnimation {
                id: upstreamAnimation
                anchors.horizontalCenter: upstreamDevice.horizontalCenter
                anchors.horizontalCenterOffset: 10
                anchors.bottom: upstreamDevice.verticalCenter
                anchors.bottomMargin: -20
            }

            PlugAnimation {
                id: port1Animation
                anchors.horizontalCenter: port1Device.horizontalCenter
                anchors.horizontalCenterOffset: 10
                anchors.bottom: port1Device.verticalCenter
                anchors.bottomMargin: -20
            }

            PlugAnimation {
                id: port2Animation
                anchors.horizontalCenter: port2Device.horizontalCenter
                anchors.horizontalCenterOffset: 10
                anchors.bottom: port2Device.verticalCenter
                anchors.bottomMargin: -20
            }

            PlugAnimation {
                id: port3Animation
                anchors.horizontalCenter: port3Device.horizontalCenter
                anchors.horizontalCenterOffset: 10
                anchors.bottom: port3Device.verticalCenter
                anchors.bottomMargin: -20
            }

            PlugAnimation {
                id: port4Animation
                anchors.horizontalCenter: port4Device.horizontalCenter
                anchors.horizontalCenterOffset: 10
                anchors.bottom: port4Device.verticalCenter
                anchors.bottomMargin: -10
            }

            PlugAnimation {
                id: displayPortAnimation
                anchors.horizontalCenter: videoIcon.horizontalCenter
                anchors.horizontalCenterOffset: 10
                anchors.bottom: videoIcon.verticalCenter
                anchors.bottomMargin: -20
            }

            PlugAnimation {
                id: audioAnimation
                anchors.horizontalCenter: audioIcon.horizontalCenter
                anchors.horizontalCenterOffset: 10
                anchors.bottom: audioIcon.verticalCenter
                anchors.bottomMargin: -20
            }


            //----------------------------------------------------------------------------------------
            //                      Views
            //----------------------------------------------------------------------------------------


            Rectangle{
                id:deviceBackground
                color:"darkgrey"
                radius:5
                height:(7*scrollViewContentRect.height)/16
                anchors.left:scrollViewContentRect.left
                anchors.leftMargin: 12
                anchors.right: scrollViewContentRect.right
                anchors.rightMargin: 12
                anchors.top:scrollViewContentRect.top
                anchors.topMargin: (3*scrollViewContentRect.height)/32

                PortInfo{
                    id:upstreamPort
                    portName:"Upstream"
                    portNumber:1
                    portConnected: false
                    anchors.left: deviceBackground.left
                    anchors.leftMargin: 7
                    anchors.top:deviceBackground.top
                    anchors.topMargin: 10
                    anchors.bottom: deviceBackground.bottom
                    anchors.bottomMargin: 5
                    width:basicPortWidth

                    property int theRunningTotal: 0
                    property int theEfficiencyCount: 0
                    property int theEfficiencyAverage: 0

                    property var periodicValues: platformInterface.request_usb_power_notification

                    onPeriodicValuesChanged: {
                        var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current +2;//PTJ-1321 2 Watt compensation
                        var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current;

                        if (platformInterface.request_usb_power_notification.port === 1){
                            //sum eight values of the efficency and average before displaying
                            var theEfficiency = Math.round((theOutputPower/theInputPower) *100)
                            upstreamPort.theRunningTotal += theEfficiency;
                            //console.log("new efficiency value=",theEfficiency,"new total is",miniInfo1.theRunningTotal,miniInfo1.theEfficiencyCount);
                            upstreamPort.theEfficiencyCount++;

                            if (upstreamPort.theEfficiencyCount == 8){
                                upstreamPort.theEfficiencyAverage = portInfo1.theRunningTotal/8;
                                upstreamPort.theEfficiencyCount = 0;
                                upstreamPort.theRunningTotal = 0
                            }
                        }

                    }

                    outputVoltage:{
                        if (platformInterface.request_usb_power_notification.port === 1){
                            return (platformInterface.request_usb_power_notification.output_voltage).toFixed(1)
                        }
                        else{
                            return upstreamPort.outputVoltage;
                        }
                    }

                    maxPower:{
                        if (platformInterface.request_usb_power_notification.port === 1){
                            var voltage = platformInterface.request_usb_power_notification.negotiated_voltage;
                            var current = platformInterface.request_usb_power_notification.negotiated_current;
                            return Math.round(voltage*current *100)/100;
                        }
                        else if (!upstreamPort.portConnected){
                            return "—"  //show a dash on disconnect, so cached value won't show on connect
                        }
                        else{
                            return upstreamPort.maxPower;
                        }
                    }
                    inputPower:{
                        if (platformInterface.request_usb_power_notification.port === 1){
                            return ((platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current)+2).toFixed(1); //PTJ-1321 adding 2 watts compensation
                        }
                        else{
                            return upstreamPort.inputPower;
                        }
                    }
                    outputPower:{
                        if (platformInterface.request_usb_power_notification.port === 1){
                            return (platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current).toFixed(1);
                        }
                        else{
                            return upstreamPort.outputPower;
                        }
                    }

                    portTemperature:{
                        if (platformInterface.request_usb_power_notification.port === 1){
                            return (platformInterface.request_usb_power_notification.temperature).toFixed(1)
                        }
                        else{
                            return upstreamPort.portTemperature;
                        }
                    }
                    efficency: theEfficiencyAverage

                    property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                    property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

                    onDeviceConnectedChanged: {
                        //debug code
                        // console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port_id,
                        //             "state=",platformInterface.usb_pd_port_connect.connection_state);

                        if (platformInterface.usb_pd_port_connect.port_id === "upstream"){
                            if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                                upstreamPort.portConnected = true;
                            }
                        }
                    }

                    onDeviceDisconnectedChanged:{

                        if (platformInterface.usb_pd_port_disconnect.port_id === "upstream"){
                            if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                                upstreamPort.portConnected = false;
                            }
                        }
                    }
                }

                PortInfo{
                    id:port1
                    portName:"Port 1"
                    portNumber:2
                    portConnected: false
                    isDisplayportCapable: true
                    anchors.left: upstreamPort.right
                    anchors.leftMargin: 7
                    anchors.top:deviceBackground.top
                    anchors.topMargin: 10
                    anchors.bottom: deviceBackground.bottom
                    anchors.bottomMargin: 5
                    width:basicPortWidth

                    property int theRunningTotal: 0
                    property int theEfficiencyCount: 0
                    property int theEfficiencyAverage: 0

                    property var periodicValues: platformInterface.request_usb_power_notification

                    onPeriodicValuesChanged: {
                        var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current +2;//PTJ-1321 2 Watt compensation
                        var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current;

                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            //sum eight values of the efficency and average before displaying
                            var theEfficiency = Math.round((theOutputPower/theInputPower) *100)
                            port1.theRunningTotal += theEfficiency;
                            //debug code
                            //console.log("new efficiency value=",theEfficiency,"new total is",miniInfo1.theRunningTotal,miniInfo1.theEfficiencyCount);
                            port1.theEfficiencyCount++;

                            if (port1.theEfficiencyCount == 8){
                                port1.theEfficiencyAverage = portInfo1.theRunningTotal/8;
                                port1.theEfficiencyCount = 0;
                                port1.theRunningTotal = 0
                            }
                        }

                    }

                    outputVoltage:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return (platformInterface.request_usb_power_notification.output_voltage).toFixed(2)
                        }
                        else{
                            return port1.outputVoltage;
                        }
                    }

                    maxPower:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            var voltage = platformInterface.request_usb_power_notification.negotiated_voltage;
                            var current = platformInterface.request_usb_power_notification.negotiated_current;
                            return Math.round(voltage*current *100)/100;
                        }
                        else if (!port1.portConnected){
                            return "—"  //show a dash on disconnect, so cached value won't show on connect
                        }
                        else{
                            return port1.maxPower;
                        }
                    }
                    inputPower:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return ((platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current)+2).toFixed(2); //PTJ-1321 adding 2 watts compensation
                        }
                        else{
                            return port1.inputPower;
                        }
                    }
                    outputPower:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return (platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current).toFixed(2);
                        }
                        else{
                            return port1.outputPower;
                        }
                    }

                    portTemperature:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return (platformInterface.request_usb_power_notification.temperature).toFixed(1)
                        }
                        else{
                            return port1.portTemperature;
                        }
                    }
                    efficency: theEfficiencyAverage

                    property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                    property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

                    onDeviceConnectedChanged: {
                        //debug code
                        //console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port_id,
                        //              "state=",platformInterface.usb_pd_port_connect.connection_state);

                        if (platformInterface.usb_pd_port_connect.port_id === portName){
                            if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                                port1.portConnected = true;
                            }
                        }
                    }

                    onDeviceDisconnectedChanged:{

                        if (platformInterface.usb_pd_port_disconnect.port_id === portName){
                            if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                                port1.portConnected = false;
                            }
                        }
                    }

                }

                PortInfo{
                    id:port2
                    portName:"Port 2"
                    portNumber:3
                    portConnected: false
                    anchors.left: port1.right
                    anchors.leftMargin: 7
                    anchors.top:deviceBackground.top
                    anchors.topMargin: 10
                    anchors.bottom: deviceBackground.bottom
                    anchors.bottomMargin: 5
                    width:basicPortWidth

                    property int theRunningTotal: 0
                    property int theEfficiencyCount: 0
                    property int theEfficiencyAverage: 0

                    property var periodicValues: platformInterface.request_usb_power_notification

                    onPeriodicValuesChanged: {
                        var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current +2;//PTJ-1321 2 Watt compensation
                        var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current;

                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            //sum eight values of the efficency and average before displaying
                            var theEfficiency = Math.round((theOutputPower/theInputPower) *100)
                            port2.theRunningTotal += theEfficiency;
                            //debug code
                            //console.log("new efficiency value=",theEfficiency,"new total is",miniInfo1.theRunningTotal,miniInfo1.theEfficiencyCount);
                            port2.theEfficiencyCount++;

                            if (port2.theEfficiencyCount == 8){
                                port2.theEfficiencyAverage = portInfo1.theRunningTotal/8;
                                port2.theEfficiencyCount = 0;
                                port2.theRunningTotal = 0
                            }
                        }

                    }

                    outputVoltage:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return (platformInterface.request_usb_power_notification.output_voltage).toFixed(2)
                        }
                        else{
                            return port2.outputVoltage;
                        }
                    }

                    maxPower:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            var voltage = platformInterface.request_usb_power_notification.negotiated_voltage;
                            var current = platformInterface.request_usb_power_notification.negotiated_current;
                            return Math.round(voltage*current *100)/100;
                        }
                        else if (!port2.portConnected){
                            return "—"  //show a dash on disconnect, so cached value won't show on connect
                        }
                        else{
                            return port2.maxPower;
                        }
                    }
                    inputPower:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return ((platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current)+2).toFixed(2); //PTJ-1321 adding 2 watts compensation
                        }
                        else{
                            return port2.inputPower;
                        }
                    }
                    outputPower:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return (platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current).toFixed(2);
                        }
                        else{
                            return port2.outputPower;
                        }
                    }

                    portTemperature:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return (platformInterface.request_usb_power_notification.temperature).toFixed(1)
                        }
                        else{
                            return port2.portTemperature;
                        }
                    }
                    efficency: theEfficiencyAverage

                    property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                    property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

                    onDeviceConnectedChanged: {
                        //debug code
                        //console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port_id,
                        //            "state=",platformInterface.usb_pd_port_connect.connection_state);

                        if (platformInterface.usb_pd_port_connect.port_id === portName){
                            if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                                port2.portConnected = true;
                            }
                        }
                    }

                    onDeviceDisconnectedChanged:{

                        if (platformInterface.usb_pd_port_disconnect.port_id === portName){
                            if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                                port2.portConnected = false;
                            }
                        }
                    }

                }

                PortInfo{
                    id:port3
                    portName:"Port 3"
                    portNumber:4
                    portConnected: false
                    anchors.left: port2.right
                    anchors.leftMargin: 7
                    anchors.top:deviceBackground.top
                    anchors.topMargin: 10
                    anchors.bottom: deviceBackground.bottom
                    anchors.bottomMargin: 5
                    width:basicPortWidth

                    property int theRunningTotal: 0
                    property int theEfficiencyCount: 0
                    property int theEfficiencyAverage: 0

                    property var periodicValues: platformInterface.request_usb_power_notification

                    onPeriodicValuesChanged: {
                        var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current +2;//PTJ-1321 2 Watt compensation
                        var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current;

                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            //sum eight values of the efficency and average before displaying
                            var theEfficiency = Math.round((theOutputPower/theInputPower) *100)
                            port3.theRunningTotal += theEfficiency;
                            //debug code
                            //console.log("new efficiency value=",theEfficiency,"new total is",miniInfo1.theRunningTotal,miniInfo1.theEfficiencyCount);
                            port3.theEfficiencyCount++;

                            if (port3.theEfficiencyCount == 8){
                                port3.theEfficiencyAverage = portInfo1.theRunningTotal/8;
                                port3.theEfficiencyCount = 0;
                                port3.theRunningTotal = 0
                            }
                        }

                    }

                    outputVoltage:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return (platformInterface.request_usb_power_notification.output_voltage).toFixed(2)
                        }
                        else{
                            return port3.outputVoltage;
                        }
                    }

                    maxPower:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            var voltage = platformInterface.request_usb_power_notification.negotiated_voltage;
                            var current = platformInterface.request_usb_power_notification.negotiated_current;
                            return Math.round(voltage*current *100)/100;
                        }
                        else if (!port3.portConnected){
                            return "—"  //show a dash on disconnect, so cached value won't show on connect
                        }
                        else{
                            return port3.maxPower;
                        }
                    }
                    inputPower:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return ((platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current)+2).toFixed(2); //PTJ-1321 adding 2 watts compensation
                        }
                        else{
                            return port3.inputPower;
                        }
                    }
                    outputPower:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return (platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current).toFixed(2);
                        }
                        else{
                            return port3.outputPower;
                        }
                    }

                    portTemperature:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return (platformInterface.request_usb_power_notification.temperature).toFixed(1)
                        }
                        else{
                            return port3.portTemperature;
                        }
                    }
                    efficency: theEfficiencyAverage

                    property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                    property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

                    onDeviceConnectedChanged: {
                        //debug code
                        // console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port_id,
                        //              "state=",platformInterface.usb_pd_port_connect.connection_state);

                        if (platformInterface.usb_pd_port_connect.port_id === portName){
                            if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                                port3.portConnected = true;
                            }
                        }
                    }

                    onDeviceDisconnectedChanged:{

                        if (platformInterface.usb_pd_port_disconnect.port_id === portName){
                            if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                                port3.portConnected = false;
                            }
                        }
                    }

                }

                USBAPortInfo{
                    id:port4
                    portName:"Port 4"
                    portSubtitle: "USB-A"
                    portNumber:5
                    portConnected: false
                    anchors.left: port3.right
                    anchors.leftMargin: 7
                    anchors.top:deviceBackground.top
                    anchors.topMargin: 10
                    anchors.bottom: deviceBackground.bottom
                    anchors.bottomMargin: 5
                    width:basicPortWidth

                    outputVoltage:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return (platformInterface.request_usb_power_notification.output_voltage).toFixed(2)
                        }
                        else{
                            return port4.outputVoltage;
                        }
                    }


                    outputPower:{
                        if (platformInterface.request_usb_power_notification.port === portNumber){
                            return (platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current).toFixed(2);
                        }
                        else{
                            return port4.outputPower;
                        }
                    }
                }

                VideoPortInfo{
                    id:displayPort
                    portName:"DisplayPort"
                    portConnected: false
                    anchors.left: port4.right
                    anchors.leftMargin: 7
                    anchors.top:deviceBackground.top
                    anchors.topMargin: 10
                    anchors.bottom: deviceBackground.bottom
                    anchors.bottomMargin: 5
                    width:basicPortWidth
                }

                AudioPortInfo{
                    id:audioPort
                    portName:"Audio"
                    portConnected: false
                    anchors.left: displayPort.right
                    anchors.leftMargin: 7
                    anchors.top:deviceBackground.top
                    anchors.topMargin: 10
                    anchors.bottom: deviceBackground.bottom
                    anchors.bottomMargin: 5
                    width:basicPortWidth
                }
            }

            DeviceInfo{
                id:upstreamDevice
                anchors.top:deviceBackground.bottom
                anchors.topMargin: 95
                anchors.left:deviceBackground.left
                anchors.leftMargin: 7
                height:145
                width:160
                portNumber:1

                MouseArea{
                    anchors.fill: parent

                    onClicked: {
                        if (!upstreamAnimation.pluggedIn) {
                            upstreamAnimation.source = "images/cord.gif"
                            upstreamAnimation.currentFrame = 0
                            upstreamAnimation.playing = true
                            upstreamAnimation.pluggedIn = !upstreamAnimation.pluggedIn
                            upstreamPort.portConnected = true
                            upstreamDevice.connected = true
                        } else {
                            upstreamAnimation.source = "images/cordReverse.gif"
                            upstreamAnimation.currentFrame = 0
                            upstreamAnimation.playing = true
                            upstreamAnimation.pluggedIn = !upstreamAnimation.pluggedIn
                            upstreamPort.portConnected = false
                            upstreamDevice.connected = false
                        }
                    }
                }

            }

            DeviceInfo{
                id:port1Device
                anchors.top:deviceBackground.bottom
                anchors.topMargin: 95
                anchors.left:upstreamDevice.right
                anchors.leftMargin: 7
                height:145
                width:160
                portNumber:2

                MouseArea{
                    anchors.fill: parent

                    onClicked: {
                        if (!port1Animation.pluggedIn) {
                            port1Animation.source = "images/cord.gif"
                            port1Animation.currentFrame = 0
                            port1Animation.playing = true
                            port1Animation.pluggedIn = !port1Animation.pluggedIn
                            port1.portConnected = true
                            port1Device.connected = true
                        } else {
                            port1Animation.source = "images/cordReverse.gif"
                            port1Animation.currentFrame = 0
                            port1Animation.playing = true
                            port1Animation.pluggedIn = !port1Animation.pluggedIn
                            port1.portConnected = false
                            port1Device.connected = false
                        }
                    }
                }


            }

            DeviceInfo{
                id:port2Device
                anchors.top:deviceBackground.bottom
                anchors.topMargin: 95
                anchors.left:port1Device.right
                anchors.leftMargin: 7
                height:145
                width:160
                portNumber:3

                MouseArea{
                    anchors.fill: parent

                    onClicked: {
                        if (!port2Animation.pluggedIn) {
                            port2Animation.source = "images/cord.gif"
                            port2Animation.currentFrame = 0
                            port2Animation.playing = true
                            port2Animation.pluggedIn = !port2Animation.pluggedIn
                            port2.portConnected = true
                            port2Device.connected = true
                        } else {
                            port2Animation.source = "images/cordReverse.gif"
                            port2Animation.currentFrame = 0
                            port2Animation.playing = true
                            port2Animation.pluggedIn = !port2Animation.pluggedIn
                            port2.portConnected = false
                            port2Device.connected = false
                        }
                    }
                }
            }

            DeviceInfo{
                id:port3Device
                anchors.top:deviceBackground.bottom
                anchors.topMargin: 95
                anchors.left:port2Device.right
                anchors.leftMargin: 7
                height:145
                width:160
                portNumber:4

                MouseArea{
                    anchors.fill: parent

                    onClicked: {
                        if (!port3Animation.pluggedIn) {
                            port3Animation.source = "images/cord.gif"
                            port3Animation.currentFrame = 0
                            port3Animation.playing = true
                            port3Animation.pluggedIn = !port3Animation.pluggedIn
                            port3.portConnected = true
                            port3Device.connected = true
                        } else {
                            port3Animation.source = "images/cordReverse.gif"
                            port3Animation.currentFrame = 0
                            port3Animation.playing = true
                            port3Animation.pluggedIn = !port3Animation.pluggedIn
                            port3.portConnected = false
                            port3Device.connected = false
                        }
                    }
                }
            }

            DeviceInfo{
                id:port4Device
                anchors.top:deviceBackground.bottom
                anchors.topMargin: 95
                anchors.left:port3Device.right
                anchors.leftMargin: 7
                height:145
                width:160
                portNumber:5

                sinkVisible:false
                fastRoleSwapVisible:false
                superspeedVisible:true
                extendedSinkVisible:false

                MouseArea{
                    anchors.fill: parent

                    onClicked: {
                        if (!port4Animation.pluggedIn) {
                            port4Animation.source = "images/usbACord.gif"
                            port4Animation.currentFrame = 0
                            port4Animation.playing = true
                            port4Animation.pluggedIn = !port4Animation.pluggedIn
                            port4.portConnected = true
                            port4Device.connected = true
                        } else {
                            port4Animation.source = "images/usbACordReverse.gif"
                            port4Animation.currentFrame = 0
                            port4Animation.playing = true
                            port4Animation.pluggedIn = !port4Animation.pluggedIn
                            port4.portConnected = false
                            port4Device.connected = false
                        }
                    }
                }
            }

            Image{
                id:videoIcon
                source:"./images/videoIcon.png"
                anchors.verticalCenter: port4Device.verticalCenter
                anchors.left:port4Device.right
                anchors.leftMargin: 40
                fillMode:Image.PreserveAspectFit
                opacity: displayPort.portConnected ? 1 : .5

                MouseArea{
                    anchors.fill: parent

                    onClicked: {
                        if (!displayPortAnimation.pluggedIn) {
                            displayPortAnimation.source = "images/DisplayPortAnim.gif"
                            displayPortAnimation.currentFrame = 0
                            displayPortAnimation.playing = true
                            displayPortAnimation.pluggedIn = !displayPortAnimation.pluggedIn
                            displayPort.portConnected = true
                        } else {
                            displayPortAnimation.source = "images/DisplayPortAnimReverse.gif"
                            displayPortAnimation.currentFrame = 0
                            displayPortAnimation.playing = true
                            displayPortAnimation.pluggedIn = !displayPortAnimation.pluggedIn
                            displayPort.portConnected = false
                        }
                    }
                }
            }

            Image{
                id:audioIcon
                source:"./images/headphonesIcon.png"
                anchors.verticalCenter: port4Device.verticalCenter
                anchors.left:videoIcon.right
                anchors.leftMargin: 80
                fillMode:Image.PreserveAspectFit
                opacity: audioPort.portConnected ? 1 : .5

                MouseArea{
                    anchors.fill: parent

                    onClicked: {
                        if (!audioAnimation.pluggedIn) {
                            audioAnimation.source = "images/AudioAnim.gif"
                            audioAnimation.currentFrame = 0
                            audioAnimation.playing = true
                            audioAnimation.pluggedIn = !audioAnimation.pluggedIn
                            audioPort.portConnected = true
                        } else {
                            audioAnimation.source = "images/AudioAnimReverse.gif"
                            audioAnimation.currentFrame = 0
                            audioAnimation.playing = true
                            audioAnimation.pluggedIn = !audioAnimation.pluggedIn
                            audioPort.portConnected = false
                        }
                    }
                }
            }

        }
    }
}
