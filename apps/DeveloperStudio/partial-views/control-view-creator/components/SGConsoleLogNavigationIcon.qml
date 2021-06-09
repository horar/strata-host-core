import QtQuick 2.0

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

Rectangle {
     id: errorAndWarningCountDisplay
     anchors.top:parent.top
     anchors.left: parent.left
     width: parent.width
     height: width
     radius: 25
     z: 100

    property int count: 0
    property string type: ""

    color: type === "error" ? Theme.palette.error : Theme.palette.warning
    visible:!isConsoleLogOpen && count > 0

    SGText {
        anchors.fill: errorAndWarningCountDisplay
        color: "white"
        text: count > 99 ? "99+" : count
        font.bold: true
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
