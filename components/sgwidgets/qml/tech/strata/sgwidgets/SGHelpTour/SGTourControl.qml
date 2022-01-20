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
import "qrc:/help_layout_manager.js" as Help

import tech.strata.fonts 1.0

Item {
    id: root
    height: root.childrenRect.height
    width: 360

    property int index: 0
    property alias description: description.text

    signal close()
    onClose: Help.closeTour()

    Item {
        id: closer
        width: iconImage.width
        height: iconImage.height
        anchors {
            top: root.top
            right: root.right
            rightMargin: 2
        }

        Image {
            id: iconImage
            visible: false
            fillMode: Image.PreserveAspectFit
            source: "icons/times.svg"
            sourceSize.height: 18
        }

        ColorOverlay {
            id: overlay
            anchors.fill: iconImage
            source: iconImage
            visible: true
            color: closerMouse.containsMouse ? "lightgrey" : "grey"
        }

        MouseArea {
            id: closerMouse
            anchors {
                fill: closer
            }
            onClicked: root.close()
            hoverEnabled: true
        }
    }

    Column {
        id: column
        width: root.width

        Text {
            id: helpText
            color:"grey"
            font {
                pixelSize: 20
            }
            text: " "
            anchors {
                horizontalCenter: column.horizontalCenter
            }
            onVisibleChanged: {
                if (visible) {
                    text = (root.index + 1) + "/" + Help.tour_count
                }
            }
        }

        Item {
            height: 15
            width: 15
        }

        Rectangle {
            width: root.width - 40
            height: 1
            color: "darkgrey"
            anchors {
                horizontalCenter: column.horizontalCenter
            }
        }

        Item {
            height: 15
            width: 15
        }

        TextEdit {
            id: description
            text: "Placeholder Text"
            width: root.width - 20
            color: "grey"
            anchors {
                horizontalCenter: column.horizontalCenter
            }
            wrapMode: TextEdit.Wrap
        }

        Item {
            height: 15
            width: 15
        }

        Row {
            anchors {
                horizontalCenter: column.horizontalCenter
            }

            Button {
                text: "Prev"
                onClicked: {
                    Help.prev(root.index)
                }
                enabled: root.index !== 0
            }

            Item {
                height: 15
                width: 15
            }

            Button {
                text: "Next"
                onClicked: {
                    Help.next(root.index)
                }
                onVisibleChanged: {
                    if (visible) {
                        text = (root.index + 1) === Help.tour_count ? "End Tour" : "Next"
                    }
                }
            }
        }
    }
}
