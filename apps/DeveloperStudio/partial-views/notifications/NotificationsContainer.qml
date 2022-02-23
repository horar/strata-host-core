/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQml 2.12

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/login_utilities.js" as Authenticator

import tech.strata.commoncpp 1.0
import tech.strata.notifications 1.0

Item {
    width: 350

    SGSortFilterProxyModel {
        id: visibleNotifications
        sourceModel: Notifications.model
        invokeCustomFilter: true
        sortEnabled: false

        function filterAcceptsRow(index) {
            const notification = sourceModel.get(index);
            return notification.hidden !== true
        }

        function mapIndex(index) {
            return Notifications.model.mapIndexToSource(mapIndexToSource(index))
        }
    }

    ListView {
        id: listView
        width: parent.width
        height: parent.height
        visible: !notificationsInbox.isOpen
        model: visibleNotifications
        spacing: 10
        clip: true
        delegate: NotificationDelegate { modelIndex: index }
        verticalLayoutDirection: ListView.BottomToTop
        interactive: contentHeight > height

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
}
