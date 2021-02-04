import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
import tech.strata.fonts 1.0
import tech.strata.notifications 1.0

RowLayout {
    id: row
    anchors {
        left: parent.left
        right: parent.right
        margins: 15
        verticalCenter: parent.verticalCenter
    }
    spacing: 10

    signal actionClicked()
    signal closeClicked()

    SGIcon {
        Layout.preferredWidth: 15
        Layout.preferredHeight: 15
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
        spacing: 10

        RowLayout {
            Layout.fillHeight: false
            Layout.fillWidth: true
            spacing: 10
            clip: true

            SGText {
                id: title
                text: model.title
                font {
                    bold: true
                }
                Layout.fillHeight: true
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                clip: true
            }

            SGText {
                text: {
                    if (!datesAreOnSameDay(new Date(), model.date)) {
                        return model.date.toLocaleString(Qt.locale(), "MM/dd")
                    } else {
                        return model.date.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                    }
                }
                fontSizeMultiplier: .9
                Layout.preferredWidth: 50
                color: Theme.palette.gray

                function datesAreOnSameDay(d1, d2) {
                    return d1.getFullYear() === d2.getFullYear() &&
                            d1.getMonth() === d2.getMonth() &&
                            d1.getDate() === d2.getDate();
                }
            }

            SGIcon {
                Layout.preferredHeight: 17
                Layout.preferredWidth: 17
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
                        row.closeClicked()
                    }
                }
            }
        }

        Text {
            id: description
            text: model.description
            visible: model.description.length > 0
            Layout.fillWidth: true
            clip: true
            wrapMode: Text.Wrap
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
                    implicitWidth: actionText.implicitWidth + 12
                    implicitHeight: actionText.implicitHeight + 12
                    color: actionMouseArea.containsMouse ? Theme.palette.darkGray : Theme.palette.gray
                    radius: 4

                    Text {
                        id: actionText
                        anchors.centerIn: parent
                        text: model.action.text
                        color: "white"
                    }

                    MouseArea {
                        id: actionMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            model.action.trigger()
                            row.actionClicked()
                        }
                    }
                }
            }
        }
    }
}

