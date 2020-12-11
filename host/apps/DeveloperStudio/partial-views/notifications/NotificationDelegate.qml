import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
import tech.strata.fonts 1.0

Item {
    width: parent.width
    height: notificationContainer.height + 2

    property int modelIndex

    MouseArea {
        // This is needed to prevent any cursor hover effects from items below this item
        anchors.fill: parent
    }

    Rectangle {
        id: notificationContainer
        width: parent.width - 2
        height: columnLayout.implicitHeight + 20
        radius: 4
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
            interval: model.timeout
            running: false //model.timeout > 0
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
                Layout.preferredHeight: 25
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
                    source: model.level === Notifications.info ? "qrc:/sgimages/exclamation-circle.svg" : "qrc:/sgimages/exclamation-triangle.svg"
                }

                Text {
                    text: model.title
                    font {
                        bold: true
                        family: Fonts.franklinGothicBook
                        pixelSize: 14
                    }
                    verticalAlignment: Text.AlignVCenter
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 2
                }

                Text {
                    text: model.date.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                    font {
                        family: Fonts.franklinGothicBook
                        pixelSize: 12
                    }
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.preferredWidth: 50
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                color: Theme.palette.lightGray
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.preferredHeight: 1
            }

            Text {
                id: description
                text: model.description
                Layout.fillWidth: true
                Layout.leftMargin: 10
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.preferredHeight: 35
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
                            }
                        }
                    }
                }
            }
        }
    }

    DropShadow {
        anchors.fill: parent
        source: notificationContainer
        color: Theme.palette.lightGray
        horizontalOffset: 2
        verticalOffset: 2
        cached: true
        radius: 8.0
    }
}
