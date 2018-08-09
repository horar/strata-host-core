import QtQuick 2.0

Rectangle {
    id: badgeCircle

    // Number to show on the badge.
    property int revisionCount: 0

    width: parent.width < parent.height ? parent.width/1.9 : parent.height/1.8
    height: width
    color: "red"
    radius: width*0.5
    //anchors.bottom: parent.top
    //anchors.right: parent.right
    anchors.bottomMargin: -20

    // Only show badge if rev is > 0
    visible: badgeCircle.revisionCount ? true : false

    Text {
        id: badgeText
        color: "white"
        z:2
        wrapMode: Text.WordWrap
        anchors { fill: parent }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        }


    NumberAnimation on width {
        running: badgeCircle.revisionCount ? true: false
        from: 0; to: parent.width < parent.height ? parent.width/1.9 : parent.height/1.8
        duration: 500
        onStarted: {
            badgeText.text = ""
        }

        onStopped: {
            badgeText.text = badgeCircle.revisionCount
        }
    }
 }
