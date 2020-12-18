import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

ColumnLayout {
    spacing: 0
    Layout.maximumHeight: Math.max(list.contentHeight + 25, 25)

    property string level
    property alias dataModel: list.model

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 25
        color: Theme.palette.lightGray

        Text {
            id: levelText
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                right: notificationCountIcon.left
                leftMargin: 10
            }
            verticalAlignment: Text.AlignVCenter
            color: {
                switch (level) {
                case "critical":
                    return Theme.palette.error
                case "warning":
                    return Theme.palette.warning
                default:
                    return Theme.palette.black
                }
            }

            text: level.toUpperCase()
        }

        Rectangle {
            id: notificationCountIcon
            anchors {
                top: parent.top
                topMargin: 2
                right: parent.right
                rightMargin: 10
                bottom: parent.bottom
                bottomMargin: 2
            }

            visible: list.model.count > 0
            width: 30
            height: 15
            radius: width / 2
            border.width: 1
            border.color: levelText.color
            color: Theme.palette.lightGray

            Text {
                id: notificationCountText
                anchors.centerIn: parent
                color: levelText.color
                text: list.model.count
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        delegate: NotificationsInboxDelegate {
            modelIndex: index
        }
    }
}
