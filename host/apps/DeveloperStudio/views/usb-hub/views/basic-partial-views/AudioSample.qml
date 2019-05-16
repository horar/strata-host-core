import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

import tech.strata.sgwidgets 1.1

Item {
    id: root
    property var value

    Rectangle{
        id:valueRectangle
        anchors.left:parent.left
        anchors.leftMargin:2
        anchors.verticalCenter: parent.verticalCenter
        anchors.right:parent.right
        anchors.rightMargin: 2
        height: root.height * root.value
        radius:width/2
        color:"black"

    }

//    ParallelAnimation{
//        id:updateValueRectSize
//        PropertyAnimation{
//            target:valueRectangle
//            property:"height"
//            to:root.height * root.value
//            duration: audioSampleTransitionSpeed
//        }
//        PropertyAnimation{
//            target:valueRectangle
//            property:"x"
//            to:root.height - (root.height * root.value)/2
//            duration: audioSampleTransitionSpeed
//        }
//    }

//    onValueChanged: {
//        updateValueRectSize.start()
//    }

//    onHeightChanged: {
//        //so static value will resize when transitioning basic->advanced screen
//        updateValueRectSize.start()
//    }
}
