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
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

AbstractButton {
    id: control

    property var buttonSize: StrataButton.Small
    property bool isSecondary: false

    enum Size {
        Large,
        Medium,
        Small
    }

    property int basePadding: {
        if (buttonSize === StrataButton.Large) {
            return 12
        } else if (buttonSize === StrataButton.Medium) {
            return 8
        }

        return 6
    }

    topPadding: basePadding
    bottomPadding: basePadding
    leftPadding: 2*basePadding
    rightPadding: 2*basePadding

    focusPolicy: Qt.NoFocus

    contentItem: Item {
        implicitHeight: textItem.paintedHeight
        implicitWidth: textItem.implicitWidth

        SGWidgets.SGText {
            id: textItem
            anchors.centerIn: parent

            text: control.text
            opacity: enabled ? 1 : 0.5
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            color: {
                if (isSecondary &&
                        (buttonSize === StrataButton.Medium
                         || buttonSize === StrataButton.Small)) {

                    if (control.hovered) {
                        return Theme.palette.white
                    }

                    return Theme.palette.onsemiSecondaryDarkBlue
                }

                return Theme.palette.white
            }

            fontSizeMultiplier: {
                if (buttonSize === StrataButton.Large) {
                    return 1.5
                } else if (buttonSize === StrataButton.Medium) {
                    return 1.2
                }

                return 1.0
            }
        }
    }

    background: Item {
        implicitHeight: 40
        implicitWidth: 100

        Rectangle {
            id: fill
            anchors {
                fill: parent
            }

            radius: Math.floor(height/2)
            opacity: enabled ? 1 : 0.4

            color: {
                if (isSecondary) {

                    if (buttonSize === StrataButton.Large) {
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

            border.width: isSecondary ? 2 : 0
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
