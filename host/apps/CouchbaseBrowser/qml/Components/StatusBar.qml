import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

RowLayout {
    property alias message: messageBar.text
    property alias messageBackgroundColor: messageBackground.color
    property alias activityLevel: activityLevelBar.text
    property alias activityLevelColor: activityLevelBackground.color
    property bool displayActivityLevel: false

    spacing: 0

    TextField {
        id: messageBar
        Layout.fillHeight: true
        Layout.fillWidth: true
        color: "#eee"
        text: ""
        readOnly: true
        horizontalAlignment: TextInput.AlignHCenter
        background: Rectangle {
            id: messageBackground
            anchors.fill: parent
            color: "#b55400"
        }
    }
    Rectangle {
        Layout.fillHeight: true
        Layout.preferredWidth: 1
        color: "black"
    }

    TextField {
        id: activityLevelBar
        visible: displayActivityLevel
        Layout.fillHeight: true
        Layout.preferredWidth: 100
        color: "#eee"
        text: ""
        readOnly: true
        horizontalAlignment: TextInput.AlignHCenter
        background: Rectangle {
            id: activityLevelBackground
            anchors.fill: parent
            color: "green"
        }
    }
}
