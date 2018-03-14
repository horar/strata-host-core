import QtQuick 2.0
import "qrc:/js/navigation_control.js" as NavigationControl

Rectangle {
    id:control
    property string user_id
    property string platform_name
    anchors.fill: parent
    color: "white"
    Text {
        anchors { centerIn: parent }
        text: {
            var catString = "User: " + user_id + "\n" + "Platform: " + platform_name
            return catString
        }
    }
    Rectangle{
        height: 40;width:40
        anchors { bottom: control.bottom; right: control.right }
        Image {
            id: flipButton
            source:"qrc:/views/motor-vortex/images/icons/infoIcon.svg"
            anchors { fill: parent }
            height: 40;width:40
        }
    }
    MouseArea {
        width: flipButton.width; height: flipButton.height
        anchors { bottom: parent.bottom; right: parent.right }
        visible: true
        onClicked: {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }

}
