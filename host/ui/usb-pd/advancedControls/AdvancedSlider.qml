import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

Slider{
    id:control
    height:10

    property color enabledThumbBorder: "#0078D7"
    property color disabledThumbBorder: "#404040"
    property color enabledTrackFill: "#0078D7"
    property color disabledTrackFill: "#404040"

    //the trail of the slider
    background: Rectangle {
            x: control.leftPadding
            y: control.topPadding + control.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 2
            width: control.availableWidth
            height: implicitHeight
            radius: 2
            //color: enabled? "#bdbebf": disabledTextColor
            color: enabled? enabledTextColor : disabledTextColor

            //the portion of the trail to the left of the thumb
            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                color: parent.enabled ? enabledTrackFill : disabledTrackFill
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
            border.color: parent.enabled ? enabledThumbBorder : disabledThumbBorder
            border.width: 2
        }

//        onMoved: {
//            faultTempLabel.text = Math.round(control.value *10)/10

//        }


}
