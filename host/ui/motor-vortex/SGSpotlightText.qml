import QtQuick 2.7

Item {

    property int indexIncrementer: -1
    property int animationHolder:0
    property int fadeInTime: 1000
    property int fadeOutTime: 4000
    property string titleName: "Scrolling Title Name"
    property int timerInterval: 400
    property int endOfStringDelay: 500
    property real currentXPosition: 0
    property var letterObject: [ ]

    Component.onCompleted: {
        timerAnimation.start();
        createObject(titleName.length);
    }

    function getElement(element) {
        return element.itemAt(indexIncrementer);

    }

    function createObject(count) {
        for(var i = 0 ; i < count ; ++i) {
            letterObject.push(getObject());
        }
    }

    // TODO[Taniya] : create an component for the animation
    function getObject() {
        var dynamicObject = Qt.createQmlObject('import QtQuick 2.7; SequentialAnimation{ id: animation
                        NumberAnimation { target: getElement(repeater) ; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: fadeInTime;}
                        NumberAnimation { target: getElement(repeater); property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: fadeOutTime;}
                }',

                                               parent,'firstObject');
        return dynamicObject;
    }


    TextMetrics {
        //this is used to calculate the width of the title
        //so it will be centered horizontally on the screen
        id: titleMetrics
        font.family: "helvetica"
        font.pixelSize: 24
        text: titleName
    }

    Item {
        anchors {
            horizontalCenter: parent.horizontalCenter;
            horizontalCenterOffset: -(titleMetrics.width/2)
        }
        Repeater {
            id: repeater
            model: titleName.length

            Text{
                id: modelText
                color: "#aeaeae"
                opacity: 0
                width: 0; height: 31

                font.family: "helvetica"
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                text: titleName.substring(index,index+1)
                Component.onCompleted:{
                    //increment the current x position by the width of this character
                    x = currentXPosition;
                    currentXPosition += modelText.advance.width;
                    width = modelText.advance.width;
                    //console.log("character=",modelText.text,"x=",x," width=",width)
                }
            }
        }
    }

    //this timer is used to pause the animation of individual letters at the end of the string
    Timer{
        id:endOfStringDelayTimer
        interval: timerInterval
        running: false
        repeat: true

        onTriggered:
            timerAnimation.start()
    }

    Timer {
        id: timerAnimation
        interval: timerInterval; running: true; repeat: true
        onTriggered: {
            if(indexIncrementer!= titleName.length - 1) {
                indexIncrementer++;
                letterObject[indexIncrementer].start();
            }
            else {
                indexIncrementer = -1;
                //at the end of the string, stop the animation of letters, and let the
                //string fade out briefly
                timerAnimation.stop()
                endOfStringDelayTimer.start()
            }
        }

    }

}
