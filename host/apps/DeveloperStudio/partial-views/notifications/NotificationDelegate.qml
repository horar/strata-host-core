import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
import tech.strata.fonts 1.0

Item {
    id: root
    width: parent.width
    height: notificationContainer.height + (2 * notificationShadow.radius)

    property int modelIndex

    MouseArea {
        // This is needed to prevent any cursor hover effects from items below this item
        anchors.fill: parent
    }

    ListView.onRemove: SequentialAnimation {

        PropertyAction {
            target: root; property: "ListView.delayRemove"; value: true
        }
        NumberAnimation { target: notificationContainer; property: "height"; to: 0; duration: 250; easing.type: Easing.InOutQuad; onFinished: root.height = 0 }
        PropertyAction { target: root; property: "ListView.delayRemove"; value: false }
    }

    Rectangle {
        id: notificationContainer
        width: parent.width - (2 * notificationShadow.radius)
        height: columnLayout.implicitHeight + 20
        radius: 4
        clip: true
        border.color: {
            if (model.level === Notifications.info) {
                return Theme.palette.gray;
            } else if (model.level === Notifications.warning) {
                return Theme.palette.warning;
            } else if (model.level === Notifications.critical) {
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
                Notifications.remove(modelIndex)
            }
        }

        ColumnLayout {
            id: columnLayout
            anchors {
                left: parent.left
                leftMargin: 10
                right: parent.right
                rightMargin: 10
                top: parent.top
                topMargin: 10
            }
            spacing: 5

            RowLayout {
                Layout.minimumHeight: 30
                Layout.fillHeight: model.description.length === 0
                Layout.fillWidth: true
                spacing: 5
                clip: true

                SGIcon {
                    Layout.preferredWidth: 15
                    Layout.preferredHeight: 15
                    Layout.alignment: Qt.AlignVCenter
                    verticalAlignment: Image.AlignVCenter

                    iconColor: {
                        if (model.level === Notifications.info) {
                            return Theme.palette.gray;
                        } else if (model.level === Notifications.warning) {
                            return Theme.palette.warning;
                        } else if (model.level === Notifications.critical) {
                            return Theme.palette.error;
                        }
                    }
                    source: model.iconSource
                }

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

                RoundButton {
                    Layout.preferredHeight: 17
                    Layout.preferredWidth: 17
                    Layout.alignment: Qt.AlignVCenter
                    padding: 0
                    hoverEnabled: true

                    icon {
                        source: "qrc:/sgimages/times.svg"
                        color: closeNotificationButton.containsMouse ? Theme.palette.darkGray : "black"
                        height: 10
                        width: 10
                        name: "Close"
                    }

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
                            Notifications.remove(modelIndex)
                        }
                    }
                }
            }

            Rectangle {
                color: Theme.palette.lightGray
                visible: model.description.length > 0
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.preferredHeight: 1
            }

            Text {
                id: description
                text: model.description
                visible: model.description.length > 0
                Layout.fillWidth: true
                Layout.leftMargin: 10
                wrapMode: Text.WordWrap
            }

            Rectangle {
                color: Theme.palette.lightGray
                visible: model.actions.count > 0
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.preferredHeight: 1
            }

            RowLayout {
                visible: model.actions.count > 0
                Layout.preferredHeight: 35
                Layout.leftMargin: 5
                spacing: 3

                Repeater {
                    model: actions

                    delegate: Rectangle {
                        id: button

                        Layout.preferredWidth: metrics.tightBoundingRect.width + 20
                        Layout.preferredHeight: 25
                        color: "transparent"
                        border.color: actionMouseArea.containsMouse ? Theme.palette.highlight : "transparent"
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
                                Notifications.remove(modelIndex)
                            }
                        }
                    }
                }
            }
        }
    }

    DropShadow {
        id: notificationShadow
        anchors.fill: root
        source: notificationContainer
        color: Theme.palette.gray
        horizontalOffset: 1
        verticalOffset: 3
        cached: true
        radius: 8
        smooth: true
        samples: radius*2
    }
}
