import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle {
    property string user_id
    property string platform_name

    anchors.fill: parent
    color: "purple"

    BusyIndicator{
        id: busyIcon
        anchors.centerIn: parent
        running: true
    }

    Text {
        anchors {   top: busyIcon.bottom
                    centerIn: parent
        }
        text:   qsTr("Waiting for platform connection")
    }
}

