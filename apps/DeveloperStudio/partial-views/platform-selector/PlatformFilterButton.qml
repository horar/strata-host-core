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
import QtQuick.Layouts 1.12
import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Button {
    id: control

    horizontalPadding: 6
    verticalPadding: 5
    hoverEnabled: true

    property string type
    property int maxWidth

    contentItem: SGText {
        id: textItem
        fontSizeMultiplier: 0.9
        horizontalAlignment: Text.AlignHCenter
        text: textMetrics.elidedText
        color: control.hovered ? Theme.palette.white : Theme.palette.onsemiDark
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitHeight: 10
        implicitWidth: 20
        radius: 20
        border.width: 1
        border.color: Theme.palette.onsemiDark
        color: control.hovered ? Theme.palette.onsemiDark : "transparent"
    }

    ToolTip {
        delay: 1000
        visible: control.hovered
        text: {
            if (control.type === "category") {
                return "Filter platforms in this category"
            } else {
                return "Filter platforms in this Segment"
            }
        }
    }

    TextMetrics {
        id: textMetrics
        text: control.text
        font: textItem.font
        elide: Qt.ElideRight
        elideWidth: control.maxWidth - control.leftPadding - control.rightPadding
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
