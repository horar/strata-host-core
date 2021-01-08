import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import tech.strata.theme 1.0
import tech.strata.notifications 1.0
import tech.strata.sgwidgets 1.0

Rectangle {
    id: root

    width: parent.width
    implicitHeight: mainColumnLayout.implicitHeight + 20
    color: "transparent"
    property int modelIndex

    MouseArea {
        anchors.fill: parent
    }

    RowLayout {
        id: mainRowLayout
        anchors {
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: 10
            top: parent.top
            topMargin: 10
        }

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
            id: mainColumnLayout

            Layout.fillWidth: true
            spacing: 5

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: model.description.length === 0
                Layout.leftMargin: 10

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
                    text: {
                        if (!datesAreOnSameDay(new Date(), model.date)) {
                            return model.date.toLocaleString(Qt.locale(), "MM/dd")
                        } else {
                            return model.date.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                        }
                    }
                    font {
                        pixelSize: 11
                    }
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.preferredWidth: 50
                    Layout.fillHeight: true
                    Layout.rightMargin: 5
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    function datesAreOnSameDay(d1, d2) {
                        return d1.getFullYear() === d2.getFullYear() &&
                                d1.getMonth() === d2.getMonth() &&
                                d1.getDate() === d2.getDate();
                    }
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
                            Qt.callLater(Notifications.model.remove, sortedModel.mapIndexToSource(modelIndex))
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
                                Notifications.model.remove(sortedModel.mapIndexToSource(modelIndex))
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: mainRowLayout.bottom
            topMargin: 10
        }
        color: Theme.palette.gray
        height: 1
    }
}
