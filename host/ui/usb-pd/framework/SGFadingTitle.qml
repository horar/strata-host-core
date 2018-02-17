import QtQuick 2.0

Item {

    property int position : 10
    property int offset: 10
    property int letterHolder: -1
    property int animationHolder:0
    property int fadeInTime: 0
    property int fadeOutTime: 0
    property string titleName: " "
    property int timerInterval: 0


    Component.onCompleted: {
        timerAnimation.start();
    }

    function getElement(element) {
        return element.itemAt(letterHolder);

    }
    function createObject() {
        var dynamicObject = Qt.createQmlObject(
                    'import QtQuick 2.7; SequentialAnimation{ id: animation
               NumberAnimation { target: getElement(repeater) ; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: fadeInTime;}
                NumberAnimation { target: getElement(repeater); property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: fadeOutTime;}
            }',
                    parent,'firstObject');
        dynamicObject.start();
        return dynamicObject;
    }

    function substring(str,start,end) {
        return str.substring(start, end);
    }
    function changePosition(){

        return position = position + offset;
    }

    function changeInterval(index) {
        return index * 500;
    }

    Item {
        z: 2
        anchors { top: onLogo.bottom;
            horizontalCenter: parent.horizontalCenter;
            horizontalCenterOffset: -170
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
                text: substring(titleName,index,index+1)
                Component.onCompleted: {x = changePosition();console.log("change position", changePosition())}
            }
        }
    }

    Timer {
        id: timerAnimation
        interval: timerInterval;running: true; repeat: true
        onTriggered: {

            if(letterHolder != titleName.length - 1)
            { letterHolder++; }
            else  { letterHolder = 0; }
            createObject();
        }

    }

}
