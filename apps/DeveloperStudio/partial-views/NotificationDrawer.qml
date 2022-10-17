/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.sgwidgets 2.0 as SGWidgets2

import tech.strata.notification 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

Drawer {
    edge: Qt.RightEdge
    interactive: true
    dragMargin: 0
    width: 400
    modal: true

    background: Rectangle {
        color: Theme.palette.lightGray
    }

    SGSortFilterProxyModel {
        id: sortedModel
        sourceModel: sdsModel.notificationModel
        invokeCustomFilter: true
        invokeCustomLessThan: true

        function filterAcceptsRow(index) {
            const item = sourceModel.get(index)
            const currentText = filterBox.model[filterBox.currentIndex]

            if (currentText === "Show All") {
                return true
            } else if (currentText === "Show Info") {
                return item.level === Notification.Info
            } else if (currentText === "Show Warning") {
                return item.level === Notification.Warning
            } else if (currentText === "Show Error") {
                return item.level === Notification.Error
            }

            return true
        }

        function lessThan(leftIndex, rightIndex) {
            const leftItem = sourceModel.get(leftIndex)
            const rightItem = sourceModel.get(rightIndex)

            return leftItem.dateTime > rightItem.dateTime
        }
    }

    SGWidgets.SGText {
        id: titleText
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 5
        }

        text: sortedModel.count + " Notification" + (sortedModel.count === 1 ? "" : "s")
        font.bold: true
        font.capitalization: Font.AllUppercase
    }

    RowLayout {
        id: filterRow
        anchors {
            top: titleText.bottom
            left: parent.left
            right: parent.right
            margins: 5
        }

        SGWidgets2.SGButton {
            text: "Clear all"
            onClicked: {
                sdsModel.notificationModel.removeAll();
            }
        }

        SGWidgets.SGComboBox {
            id: filterBox

            Layout.fillHeight: true
            Layout.fillWidth: true
            model: ["Show All", "Show Info", "Show Warning", "Show Error"]

            onCurrentIndexChanged: {
                sortedModel.invalidate()
            }
        }
    }

    ListView {
        anchors {
            top: filterRow.bottom
            topMargin: 5
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        clip: true
        model: sortedModel
        spacing: 1
        boundsBehavior: ListView.StopAtBounds

        delegate: NotificationDelegate {
            showShadow: false
        }

        SGWidgets.SGText {
            anchors {
                centerIn: parent
            }

            text: "No Notifications"
            visible: sortedModel.count === 0
            color: Theme.palette.darkGray
            opacity: 0.5
            fontSizeMultiplier: 2
        }
    }
}
