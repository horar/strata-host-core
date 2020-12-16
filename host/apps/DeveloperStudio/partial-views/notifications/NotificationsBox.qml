import QtQuick 2.12
import QtQml 2.12

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/login_utilities.js" as Authenticator

import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0

Item {
    height: listView.height
    width: 350

    property string currentUser

    onCurrentUserChanged: {
        filteredNotifications.invalidate()
    }

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
        sourceModel: Notifications.model
        invokeCustomFilter: true
        sortEnabled: false

        function filterAcceptsRow(index) {
            const notification = Notifications.model.get(index);
            if (notification.hidden || (notification.to !== "all" && notification.to !== currentUser)) {
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

    Connections {
        target: Signals

        onLoginResult: {
            const resultObject = JSON.parse(result)
            //console.log(Logger.devStudioCategory, "Login result received")
            if (resultObject.response === "Connected") {
                currentUser = resultObject.user_id
            }
        }

        onLogout: {
            for (let i = 0; i < Notifications.model.count; i++) {
                // Clear any actions when the user logs out
                Notifications.model.get(i).actions.clear()
            }

            currentUser = ""
        }

        onValidationResult: {
            currentUser = Authenticator.settings.user
        }
    }
}
