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
    implicitWidth: parent.width
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
        height: row.implicitHeight + (row.anchors.margins * 2)
        radius: 4
        clip: true
        border.color: {
            if (model.level === Notifications.Level.Info) {
                return Theme.palette.gray;
            } else if (model.level === Notifications.Level.Warning) {
                return Theme.palette.warning;
            } else if (model.level === Notifications.Level.Critical) {
                return Theme.palette.error;
            }
        }
        border.width: 1
        color: "white"

        Timer {
            id: closeTimer
            interval: model.timeout
            running: model.timeout > 0
            repeat: false

            onTriggered: {
                if (model.saveToDisk) {
                    model.hidden = true
                } else {
                    Notifications.model.remove(filteredNotifications.mapIndexToSource(modelIndex))
                }
            }
        }

        RowLayout {
            id: row
            anchors {
                left: parent.left
                right: parent.right
                margins: 15
                verticalCenter: parent.verticalCenter
            }
            spacing: 10

            SGIcon {
                Layout.preferredWidth: 15
                Layout.preferredHeight: 15
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Image.AlignVCenter
                visible: model.iconSource !== ""

                iconColor: {
                    if (model.level === Notifications.Level.Info) {
                        return Theme.palette.gray;
                    } else if (model.level === Notifications.Level.Warning) {
                        return Theme.palette.warning;
                    } else if (model.level === Notifications.Level.Critical) {
                        return Theme.palette.error;
                    }
                }
                source: model.iconSource
            }

            ColumnLayout {
                id: columnLayout
                Layout.fillWidth: true
                spacing: 5

                RowLayout {
                    Layout.fillHeight: model.description.length === 0
                    Layout.fillWidth: true
                    spacing: 5
                    clip: true

                    Text {
                        id: title
                        text: model.title
                        font {
                            bold: true
                            pixelSize: 13
                        }
                        verticalAlignment: Text.AlignVCenter
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                    }

                    Text {
                        text: model.date.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                        font {
                            pixelSize: 11
                        }
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        Layout.preferredWidth: 50
                        Layout.fillHeight: true
                        Layout.rightMargin: 5
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    SGIcon {
                        Layout.preferredHeight: 17
                        Layout.preferredWidth: 17
                        Layout.alignment: Qt.AlignVCenter
                        source: "qrc:/sgimages/times-circle.svg"
                        iconColor: closeNotificationButton.containsMouse ? Theme.palette.darkGray : Theme.palette.lightGray

                        Accessible.name: "Close notification"
                        Accessible.role: Accessible.Button
                        Accessible.onPressAction: {
                            closeNotificationButton.clicked()
                        }

                        MouseArea {
                            id: closeNotificationButton
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                closeTimer.stop()
                                Notifications.model.remove(filteredNotifications.mapIndexToSource(modelIndex))
                            }
                        }
                    }
                }

                Rectangle {
                    color: Theme.palette.lightGray
                    visible: description.visible
                    Layout.fillWidth: true
                    Layout.rightMargin: 10
                    Layout.preferredHeight: 1
                }

                Text {
                    id: description
                    text: model.description
                    visible: model.description.length > 0
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    color: Theme.palette.lightGray
                    visible: buttonFlow.visible
                    Layout.fillWidth: true
                    Layout.rightMargin: 10
                    Layout.preferredHeight: 1
                }

                Flow {
                    id: buttonFlow
                    Layout.fillWidth: true
                    visible: model.actions.count > 0
                    spacing: 3

                    Repeater {
                        model: actions

                        delegate: Rectangle {
                            id: button
                            implicitWidth: metrics.tightBoundingRect.width + 20
                            implicitHeight: metrics.tightBoundingRect.height + 20
                            color: "transparent"
                            border.color: actionMouseArea.containsMouse ? Qt.darker(Theme.palette.highlight) : Theme.palette.highlight
                            border.width: 1
                            radius: 4

                            Text {
                                id: actionText
                                height: parent.height
                                anchors.centerIn: parent
                                text: model.action.text
                                color: Theme.palette.highlight
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            TextMetrics {
                                id: metrics
                                font: actionText.font
                                text: actionText.text
                            }

                            MouseArea {
                                id: actionMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    model.action.trigger()
                                    closeTimer.stop()
                                    Notifications.model.remove(filteredNotifications.mapIndexToSource(modelIndex))
                                }
                            }
                        }
                    }
                }
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
