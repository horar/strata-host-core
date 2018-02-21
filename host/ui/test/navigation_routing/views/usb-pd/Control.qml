import QtQuick 2.0

Rectangle {
    property string user_id
    property string platform_name
    anchors.fill: parent
    color: "Red"
    Text {
        anchors { centerIn: parent }
        text: {
            var catString = "User: " + user_id + "\n" + "Platform: " + platform_name
            return catString
        }
    }
}
