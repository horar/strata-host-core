/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.sgwidgets 2.0 as SGWidgets2
import tech.strata.theme 1.0
import tech.strata.notification 1.0

Item {
    id: delegate

    width: ListView.view.width
    height: content.height + 2*shadowRadius
    opacity: 0

    property var actionModel: model.notification.actionModel
    property var notification: model.notification
    property int shadowVerticalOffset: 3
    property int shadowHorizontalOffset: 1
    property int shadowRadius: showShadow ? 8 : 0
    property int contentOutterSpacing: 12
    property int contentInnerSpacing: 4
    property bool showShadow: true

    Component.onCompleted: {
        opacity = 1
    }

    Behavior on opacity { OpacityAnimator {} }

    Rectangle {
        id: bg
        anchors {
            fill: content
        }

        radius: showShadow ? 4 : 0
        clip: true
        border.color:  Theme.palette.lightGray
        border.width: showShadow ? 1 : 0
        layer.enabled: showShadow
        layer.effect: DropShadow {
            color: Qt.rgba(0, 0, 0, 0.5)
            horizontalOffset: shadowHorizontalOffset
            verticalOffset: shadowVerticalOffset
            radius: shadowRadius
            samples: (1 + (shadowRadius * 2))
        }
    }

    MouseArea {
        //do not propagate clicks etc underneath
        anchors.fill: content
        hoverEnabled: true
    }

    Item {
        id: content
        width: parent.width - 2*shadowRadius
        height: actionFlow.y + actionFlow.height + contentOutterSpacing
        anchors {
            centerIn: parent
        }

        SGWidgets.SGIcon {
            id: levelIcon
            height: 20
            width: 20
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: contentOutterSpacing
            }

            iconColor: {
                if (model.notification.level === Notification.Warning) {
                    return Theme.palette.warning;
                } else if (model.notification.level === Notification.Error) {
                    return Theme.palette.error;
                }

                return Theme.palette.onsemiBlue;
            }

            source: {
                if (model.notification.level === Notification.Warning) {
                    return "qrc:/sgimages/exclamation-triangle.svg";
                } else if (model.notification.level === Notification.Error) {
                    return "qrc:/sgimages/exclamation-circle.svg";
                }

                return "qrc:/sgimages/info-circle.svg";
            }
        }

        SGWidgets.SGText {
            id: title
            anchors {
                left: levelIcon.right
                leftMargin: 3*contentInnerSpacing
                right: timestamp.left
                rightMargin: contentInnerSpacing
                baseline: timestamp.baseline
            }

            text: model.notification.title
            font.bold: true
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }

        SGWidgets.SGText {
            id: timestamp
            anchors {
                right: closeIcon.left
                rightMargin: 3*contentInnerSpacing
                verticalCenter: closeIcon.verticalCenter
            }

            text: model.notification.dateTime.toLocaleString(Qt.locale(), "hh:mm")
            color: Theme.palette.gray
        }

        SGWidgets.SGIcon {
            id: closeIcon
            height: 20
            width: 20
            anchors {
                right: parent.right
                rightMargin: contentOutterSpacing
                top: parent.top
                topMargin: contentOutterSpacing
            }

            source: "qrc:/sgimages/times-circle.svg"
            iconColor: closeMouseArea.containsMouse ? Theme.palette.darkGray : Theme.palette.lightGray

            Accessible.name: "Close notification"
            Accessible.role: Accessible.Button
            Accessible.onPressAction: {
                closeMouseArea.clicked()
            }

            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    sdsModel.notificationModel.remove(notification.uuid)
                }
            }
        }

        SGWidgets.SGText {
            id: description
            anchors {
                top: title.bottom
                topMargin: 2*contentInnerSpacing
                left: title.left
                right: closeIcon.right
            }

            text: model.notification.description
            wrapMode: Text.WordWrap
        }

        Flow {
            id: actionFlow
            anchors {
                top: description.bottom
                topMargin: 2*contentInnerSpacing
                left: description.left
                right: description.right
            }

            spacing: 6
            Repeater {
                model: actionModel

                delegate: SGWidgets2.SGButton {
                    isSecondary: true
                    text: model.text
                    onClicked: {
                        notification.actionTriggered(model.id)
                        sdsModel.notificationModel.remove(notification.uuid)
                    }
                }
            }
        }
    }
}
