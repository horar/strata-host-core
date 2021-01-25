import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
import tech.strata.fonts 1.0
import tech.strata.notifications 1.0

Item {
    id: root
    implicitWidth: parent.width
    implicitHeight: notificationContainer.height + (2 * notificationShadow.radius)
    opacity: 0

    property int modelIndex

    Component.onCompleted: {
        opacity = 1
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 400
        }
    }

    MouseArea {
        // This is needed to prevent any cursor hover effects from items below this item
        anchors.fill: parent
    }

    Rectangle {
        id: notificationContainer
        y: notificationShadow.radius - notificationShadow.verticalOffset
        x: notificationShadow.radius - notificationShadow.horizontalOffset
        width: parent.width - (2 * notificationShadow.radius)
        height: content.implicitHeight + (content.anchors.margins * 2)
        radius: 4
        clip: true
        border.color: {
            if (model.level === Notifications.Level.Info) {
                return Theme.palette.gray;
            } else if (model.level === Notifications.Level.Warning) {
                return Theme.palette.warning;
            } else if (model.level === Notifications.Level.Critical) {
                return Theme.palette.error;
            }
        }
        border.width: 1
        color: "white"

        Timer {
            id: closeTimer
            interval: model.timeout
            running: model.timeout > 0
            repeat: false

            onTriggered: {
                if (model.saveToDisk) {
                    model.hidden = true
                } else {
                    Notifications.model.remove(filteredNotifications.mapIndexToSource(modelIndex))
                }
            }
        }

        NotificationContent {
            id: content

            onActionClicked: {
                closeTimer.stop()
                Notifications.model.remove(filteredNotifications.mapIndexToSource(modelIndex))
            }

            onCloseClicked: {
                closeTimer.stop()
                Qt.callLater(Notifications.model.remove, filteredNotifications.mapIndexToSource(modelIndex))
            }
        }
    }

    DropShadow {
        id: notificationShadow
        anchors.fill: notificationContainer
        source: notificationContainer
        color: Qt.rgba(0, 0, 0, .5)
        horizontalOffset: 1
        verticalOffset: 3
        cached: true
        radius: 8
        smooth: true
        samples: radius*2
    }
}
