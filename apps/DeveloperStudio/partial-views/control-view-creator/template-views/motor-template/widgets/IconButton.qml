/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

MouseArea {
    id: iconButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    Layout.preferredHeight: iconColumn.implicitHeight
    Layout.fillWidth: true

    property alias toolTipText: toolTip.text
    property alias unit: unit.text
    property alias value: value.text
    property alias source: icon.source
    property alias iconColor: icon.iconColor
    property alias iconOpacity: icon.opacity
    property alias animationRunning: animator.running
    property alias animationDirection: animator.direction
    property bool clickEnabled: true

    ColumnLayout {
        id: iconColumn
        width: parent.width
        spacing: 0

        SGIcon {
            id: icon
            iconColor: "white"
            Layout.preferredWidth: iconButton.width - 10
            Layout.preferredHeight: Layout.preferredWidth
            Layout.alignment: Qt.AlignHCenter

            RotationAnimator {
                id: animator
                target: icon
                from: direction === RotationAnimator.Clockwise ? 0 : 360
                to: direction === RotationAnimator.Clockwise ? 360 : 0
                loops: Animation.Infinite
                running: false
                duration: 3000

                onRunningChanged: {
                    if (running === false) {
                        icon.rotation = 0
                    }
                }
            }
        }

        Text {
            id: value
            color: "white"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            visible: text !== ""
        }

        Text {
            id: unit
            color: "white"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            visible: text !== ""

        }
    }

    ToolTip {
        id: toolTip
        visible: parent.containsMouse && text !== ""
        delay: 200
    }
}
