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
import QtQml 2.12
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.12

import "qrc:/js/navigation_control.js" as NavigationControl

import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0
import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.notifications 1.0

Drawer {
    id: notificationsDrawer
    edge: Qt.RightEdge
    interactive: true
    dragMargin: 0 // prevent swipes to open
    width: 400
    modal: true

    background: Rectangle {
        color: Theme.palette.lightGray
    }

    Loader {
        width: parent.width
        height: parent.height
        active: parent.visible

        sourceComponent: ColumnLayout {
            spacing: 5

            SGSortFilterProxyModel {
                id: sortedModel
                sourceModel: Notifications.model
                sortEnabled: true
                invokeCustomFilter: true
                sortRole: "date"
                sortAscending: false

                function filterAcceptsRow(index) {
                    const item = sourceModel.get(index);
                    const filterLevel = filterBox.currentIndex - 1;

                    if (filterLevel < 0) {
                        return true
                    } else {
                        return item.level === filterLevel
                    }
                }
            }

            SGText {
                text: sortedModel.count + " Notification" + (sortedModel.count === 1 ? "" : "s")
                font.bold: true
                font.capitalization: Font.AllUppercase
                Layout.fillWidth: true
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                Layout.topMargin: 5
            }

            RowLayout {
                Layout.preferredHeight: 30
                Layout.fillHeight: false
                Layout.leftMargin: 5
                Layout.rightMargin: 5

                Rectangle {
                    id: button
                    implicitWidth: actionText.implicitWidth + 12
                    Layout.fillHeight: true
                    color: actionMouseArea.containsMouse ? Theme.palette.darkGray : Theme.palette.gray
                    radius: 4

                    Text {
                        id: actionText
                        anchors.centerIn: parent
                        text: "Clear all"
                        color: "white"
                    }

                    MouseArea {
                        id: actionMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Notifications.model.clear()
                        }
                    }
                }

                SGComboBox {
                    id: filterBox
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    model: ["Show All", "Show Info", "Show Warning", "Show Critical"]

                    onCurrentIndexChanged: {
                        sortedModel.invalidate()
                    }
                }
            }

            ListView {
                clip: true
                model: sortedModel
                spacing: 1
                Layout.fillHeight: true
                Layout.fillWidth: true

                delegate: NotificationsInboxDelegate {
                    modelIndex: index
                }

                SGText {
                    visible: sortedModel.count === 0
                    anchors {
                        centerIn: parent
                    }
                    text: "No Notifications"
                    color: Theme.palette.darkGray
                    opacity: .5
                    fontSizeMultiplier: 2
                }
            }
        }
    }
}
