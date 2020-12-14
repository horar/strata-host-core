import QtQuick 2.12
import QtQml 2.12

import "qrc:/js/navigation_control.js" as NavigationControl

import tech.strata.commoncpp 1.0

Item {
    height: listView.height
    width: 350

    // This removes any cursor changes to elements that are underneath listView
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: {
            mouse.accepted = false
        }
    }

    SGSortFilterProxyModel {
        id: filteredNotifications
        sourceModel: Notifications

        function filterAcceptsRow(index) {
            if (mainWindow.state === NavigationControl.states.CONTROL_STATE) {
                return true
            }

            if (!Notifications.get(index).notifyAllUsers) {
                return false
            } else {
                return true
            }
        }

    }

    ListView {
        id: listView
        width: parent.width
        height: Math.min(contentHeight, mainWindow.height - statusBarContainer.height - parent.anchors.bottomMargin) // This sets the height to be a max of the window height - status bar height - the bottom margin - 20 for top margin padding
        model: filteredNotifications
        spacing: 10
        clip: true
        delegate: NotificationDelegate { modelIndex: index }
        verticalLayoutDirection: ListView.BottomToTop

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 400 }
        }
    }
}
