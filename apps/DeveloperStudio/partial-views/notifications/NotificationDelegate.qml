import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
import tech.strata.fonts 1.0
import tech.strata.notifications 1.0

MouseArea { // MouseArea is needed to prevent any cursor hover effects from items underneath this
    id: root
    implicitWidth: ListView.view.width
    implicitHeight: notificationContainer.height + (2 * shadowRadius)
    opacity: 0

    property int modelIndex
    property int shadowVerticalOffset: 3
    property int shadowHorizontalOffset: 1
    property int shadowRadius: 9

    Component.onCompleted: {
        opacity = 1
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 400
        }
    }
    
    Rectangle {
        id: notificationContainer
        y: shadowRadius - shadowVerticalOffset
        x: shadowRadius - shadowHorizontalOffset
        width: parent.width - (2 * shadowRadius)
        height: content.implicitHeight + (content.anchors.margins * 2)
        radius: 4
        clip: true
        border.color:  Theme.palette.lightGray
        border.width: 1
        layer.enabled: true
        layer.effect: DropShadow {
            color: Qt.rgba(0, 0, 0, .5)
            horizontalOffset: shadowHorizontalOffset
            verticalOffset: shadowVerticalOffset
        }

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
}