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
import tech.strata.sgwidgets 2.0 as SGWidgets
import tech.strata.theme 1.0

AbstractButton {
    id: control

    property var buttonSize: SGButton.Small
    property bool isSecondary: false
    property alias hintText: tooltip.text

    enum Size {
        Large,
        Medium,
        Small,
        Tiny
    }

    property real fontSizeMultiplier: {
        if (buttonSize === SGButton.Large) {
            return 1.5
        } else if (buttonSize === SGButton.Medium) {
            return 1.2
        }

        return 1.0
    }

    font.pixelSize: SGWidgets.SGSettings.fontPixelSize * fontSizeMultiplier

    font.bold: {
        if (buttonSize === SGButton.Tiny) {
            return false
        }

        return true
    }

    focusPolicy: Qt.NoFocus

    verticalPadding: {
        if (buttonSize === SGButton.Large) {
            return 12
        } else if (buttonSize === SGButton.Medium) {
            return 8
        } else if (buttonSize === SGButton.Small) {
            return 6
        }

        return 2
    }

    horizontalPadding: {
        if (buttonSize === SGButton.Tiny) {
            return 6
        }

        return 2*verticalPadding
    }

    contentItem: Item {
        implicitHeight: textItem.paintedHeight
        implicitWidth: textItem.implicitWidth

        SGWidgets.SGText {
            id: textItem
            anchors.centerIn: parent

            text: control.text
            opacity: enabled ? 1 : 0.5
            font: control.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            color: {
                if (isSecondary &&
                        (buttonSize === SGButton.Medium
                         || buttonSize === SGButton.Small
                         || buttonSize === SGButton.Tiny)) {

                    if (control.hovered) {
                        return Theme.palette.white
                    }

                    return Theme.palette.onsemiSecondaryDarkBlue
                }

                return Theme.palette.white
            }
        }
    }

    background: Item {
        implicitHeight: 20
        implicitWidth: 60

        Rectangle {
            id: fill
            anchors {
                fill: parent
            }

            radius: Math.floor(height/2)
            opacity: enabled ? 1 : 0.4

            color: {
                if (isSecondary) {

                    if (buttonSize === SGButton.Large) {
                        if (control.pressed) {
                            return Qt.darker(Theme.palette.onsemiSecondaryDarkBlue, 1.2)
                        }

                        if (control.hovered) {
                            return Qt.darker(Theme.palette.onsemiSecondaryDarkBlue, 1.1)
                        }

                        return Theme.palette.onsemiSecondaryDarkBlue
                    }

                    if (control.pressed) {
                        return Qt.darker(Theme.palette.onsemiSecondaryDarkBlue, 1.2)
                    }

                    if (control.hovered) {
                        return Theme.palette.onsemiSecondaryDarkBlue
                    }

                    return Theme.palette.white
                }

                if (control.pressed) {
                    return Qt.darker(Theme.palette.onsemiOrange, 1.2)
                }

                if (control.hovered) {
                    return Qt.darker(Theme.palette.onsemiOrange, 1.1)
                }

                return Theme.palette.onsemiOrange
            }

            border.width: {
                if (isSecondary) {
                    if (buttonSize === SGButton.Tiny) {
                        return 1
                    }

                    return 2
                }

                return 0
            }
            border.color: {
                if (control.pressed) {
                    return fill.color
                }

                if (control.hovered) {
                    return fill.color
                }

                return Theme.palette.onsemiSecondaryDarkBlue
            }
        }
    }

    ToolTip {
        id: tooltip
        visible: text.length && mouseArea.containsMouse
        delay: 500
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: {
            mouse.accepted = false
        }
        hoverEnabled: true
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
