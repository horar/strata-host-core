import QtQuick 2.0

Item {

    property int position : 9
    property int indexIncrementer: -1
    property int animationHolder:0
    property int fadeInTime: 1000
    property int fadeOutTime: 4000
    property string titleName: "Scrolling Title Name"
    property int timerInterval: 400


    Component.onCompleted: {
        timerAnimation.start();
    }

    function getElement(element) {
        return element.itemAt(indexIncrementer);

    }
    // TODO[Taniya] : create an component for the animation
    function createObject() {
        var dynamicObject = Qt.createQmlObject('import QtQuick 2.7; SequentialAnimation{ id: animation
                    NumberAnimation { target: getElement(repeater) ; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: fadeInTime;}
                    NumberAnimation { target: getElement(repeater); property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: fadeOutTime;}
            }',
                                               parent,'firstObject');
        dynamicObject.start();
        return dynamicObject;
    }
        function changePosition(TextWidth){

            return position = position + TextWidth;
        }


    Item {
        z: 2
        anchors { /*top: onLogo.bottom;*/
            horizontalCenter: parent.horizontalCenter;
            horizontalCenterOffset: -150
        }
        Repeater {
            id: repeater
            model: titleName.length

            Text{
                id: modelText
                color: "#aeaeae"
                opacity: 0
                width: 18; height: 31
                font.pixelSize: 24
                horizontalAlignment: Text.AlignLeft
                text: titleName.substring(index,index+1)
                Component.onCompleted:{
                   x = changePosition(modelText.width);
                }
            }
        }
    }

    Timer {
        id: timerAnimation
        interval: timerInterval; running: true; repeat: true
        onTriggered: {
            if(indexIncrementer!= titleName.length - 1) {
                indexIncrementer++;
            }
            else {
                indexIncrementer = 0;
            }
            createObject();
        }

    }

}
