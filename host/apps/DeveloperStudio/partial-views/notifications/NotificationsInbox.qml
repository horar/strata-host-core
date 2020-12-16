import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import "qrc:/js/login_utilities.js" as Authenticator

import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0

Rectangle {

    property string currentUser: Constants.GUEST_USER_ID

    onCurrentUserChanged: {
        criticalNotificationsModel.invalidate()
        warningNotificationsModel.invalidate()
        infoNotificationsModel.invalidate()
    }

    SGSortFilterProxyModel {
        id: criticalNotificationsModel
        sourceModel: Notifications.model
        sortEnabled: true
        invokeCustomLessThan: true
        invokeCustomFilter: true

        function lessThan(index1, index2) {
            const item1 = sourceModel.get(index1);
            const item2 = sourceModel.get(index2);

            return item1.date < item2.date
        }

        function filterAcceptsRow(index) {
            const item = sourceModel.get(index);

            return item.level === Notifications.critical && item.hidden && (item.to === "all" || item.to === currentUser)
        }
    }

    SGSortFilterProxyModel {
        id: warningNotificationsModel
        sourceModel: Notifications.model

        sortEnabled: true
        invokeCustomLessThan: true
        invokeCustomFilter: true

        function lessThan(index1, index2) {
            const item1 = sourceModel.get(index1);
            const item2 = sourceModel.get(index2);

            return item1.date < item2.date
        }

        function filterAcceptsRow(index) {
            const item = sourceModel.get(index);

            return item.level === Notifications.warning && item.hidden && (item.to === "all" || item.to === currentUser)
        }
    }

    SGSortFilterProxyModel {
        id: infoNotificationsModel
        sourceModel: Notifications.model

        sortEnabled: true
        invokeCustomLessThan: true
        invokeCustomFilter: true

        function lessThan(index1, index2) {
            const item1 = sourceModel.get(index1);
            const item2 = sourceModel.get(index2);

            return item1.date < item2.date
        }

        function filterAcceptsRow(index) {
            const item = sourceModel.get(index);

            return item.level === Notifications.info && item.hidden && (item.to === "all" || item.to === currentUser)
        }
    }

    ColumnLayout {
        NotificationsInboxList {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 3
            level: "critical"
            dataModel: criticalNotificationsModel.sourceModel
        }

        NotificationsInboxList {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 3
            level: "warning"
            dataModel: warningNotificationsModel.sourceModel
        }

        NotificationsInboxList {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 3
            level: "info"
            dataModel: infoNotificationsModel.sourceModel
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
