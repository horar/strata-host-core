import QtQuick 2.9
import QtQuick.Controls 2.2
import tech.strata.sgwidgets 0.9

Flipable{
    id:root
    width:200
    height:200

    property bool flipped:false

    transform: Rotation{
        id:rotation
        origin.x:front.width/2
        origin.y:front.width/2
        axis.x:0; axis.y:1; axis.z:0
        angle: 0
    }

    states: State{
        name:"back"
        PropertyChanges { target: rotation; angle: 180 }
        when: root.flipped
    }

    transitions: Transition {
        NumberAnimation { target: rotation; property: "angle"; duration: 700 }
    }


    MouseArea{
        id:flipper
        anchors.fill:parent
        enabled: !flipped       //this enables us to use other actions to flip back

        onClicked: {
            root.flipped = !root.flipped
            console.log("flipper clicked. flipped=",flipped);
        }
    }

    front:WirelessFrontView{
        id:frontView
    }

    back:WirelessBackView {
        id:backView

        onActivated: {
            root.flipped = !root.flipped
            console.log("flipper clicked. flipped=",flipped);
        }

    }

}
