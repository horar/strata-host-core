import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import "qrc:/js/login_utilities.js" as Authenticator
import "qrc:/js/constants.js" as Constants

import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0
import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0

Rectangle {
    id: root

    property string currentUser: Constants.GUEST_USER_ID
    property int expandWidth: 300
    readonly property bool isOpen: width > 0

    color: Theme.palette.white

    onCurrentUserChanged: {
        criticalNotificationsModel.invalidate()
        warningNotificationsModel.invalidate()
        infoNotificationsModel.invalidate()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: false
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

    SGSplitView {
        anchors.fill: parent
        orientation: Qt.Vertical

        NotificationsInboxList {
            id: criticalNotificationsList
            Layout.fillWidth: true
            Layout.minimumHeight: 25
            level: "critical"
            dataModel: criticalNotificationsModel.sourceModel
        }

        NotificationsInboxList {
            id: warningNotificationsList
            Layout.fillWidth: true
            Layout.minimumHeight: 25
            level: "warning"
            dataModel: warningNotificationsModel.sourceModel
        }

        NotificationsInboxList {
            id: infoNotificationsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 25
            level: "info"
            dataModel: infoNotificationsModel.sourceModel
        }
    }


    NumberAnimation {
        id: showAnimation
        target: root
        property: "width"
        duration: 250
        to: expandWidth
        easing.type: Easing.InOutQuad
    }


    NumberAnimation {
        id: hideAnimation
        target: root
        property: "width"
        duration: 250
        to: 0
        easing.type: Easing.InOutQuad
    }

    function toggle() {
        if (isOpen) {
            hideAnimation.restart()
        } else {
            showAnimation.restart()
        }
    }

    function open() {
        if (!showAnimation.running) {
            showAnimation.start()
        }
    }

    function close() {
        if (!hideAnimation.running) {
            hideAnimation.start()
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
