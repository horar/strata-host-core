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
    implicitWidth: ListView.view.width
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
        border.color:  Theme.palette.lightGray
        border.width: 1

        Timer {
            id: closeTimer
            interval: model.timeout
            running: model.timeout > 0
            repeat: false

            onTriggered: {
                if (model.saveToDisk) {
                    model.hidden = true
                } else {
                    Notifications.model.remove(visibleNotifications.mapIndex(modelIndex))
                }
            }
        }

        NotificationContent {
            id: content

            onActionClicked: {
                closeTimer.stop()
                Notifications.model.remove(visibleNotifications.mapIndex(modelIndex))
            }

            onCloseClicked: {
                closeTimer.stop()
                Qt.callLater(Notifications.model.remove, visibleNotifications.mapIndex(modelIndex))
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
