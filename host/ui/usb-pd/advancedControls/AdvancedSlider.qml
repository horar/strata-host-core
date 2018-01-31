import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

Slider{
    id:control
//    anchors.left:faultTempUnitText.right
//    anchors.leftMargin: 5
//    anchors.right:parent.right
//    anchors.rightMargin: 10
//    anchors.verticalCenter: faultTempText.verticalCenter
    height:10
//    from: 25
//    to:100
//    value:5
//    stepSize: 0.0
    //the trail of the slider
    background: Rectangle {
            x: control.leftPadding
            y: control.topPadding + control.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 2
            width: control.availableWidth
            height: implicitHeight
            radius: 2
            color: enabled? "#bdbebf": disabledTextColor

            //the portion of the trail to the left of the thumb
            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                color: "#0078D7"
                radius: 2
            }
        }

    //the thumb of the slider
        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: control.topPadding + control.availableHeight / 2 - height / 2
            implicitWidth: 10
            implicitHeight: 10
            radius: 5
            color: "black"
            border.color: "#0078D7"
            border.width: 2
        }

//        onMoved: {
//            faultTempLabel.text = Math.round(control.value *10)/10

//        }


}
