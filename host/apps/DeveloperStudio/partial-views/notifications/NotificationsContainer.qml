import QtQuick 2.12
import QtQml 2.12

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/login_utilities.js" as Authenticator
import "qrc:/js/constants.js" as Constants

import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0
import tech.strata.notifications 1.0

Item {
    width: 350

    clip: true

    property string currentUser: Constants.GUEST_USER_ID

    onCurrentUserChanged: {
        filteredNotifications.invalidate()
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
        height: parent.height
        anchors.bottom: parent.bottom
        visible: !notificationsInbox.isOpen
        model: filteredNotifications
        spacing: 10
        clip: true
        delegate: NotificationDelegate { modelIndex: index }
        verticalLayoutDirection: ListView.BottomToTop
        interactive: contentHeight > height
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 400 }
        }

        removeDisplaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: 400
                easing.type: Easing.InOutQuad
            }

            // This verifies that the opacity is set to 1.0 when the add transition is interrupted
            NumberAnimation { property: "opacity"; to: 1.0 }
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
            if (result === "Current token is valid") {
                currentUser = Authenticator.settings.user
            } else {
                currentUser = ""
            }
        }
    }
}
