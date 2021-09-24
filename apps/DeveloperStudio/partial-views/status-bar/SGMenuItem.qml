/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.9
import QtQuick.Controls 2.3

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
import QtQuick.Layouts 1.12

Button {
    id: root
    text: qsTr("Button Text")
    hoverEnabled: true

    property alias buttonColor: backRect.color
    property alias textColor: buttonText.color
    property alias iconSource: icon.source

    contentItem: RowLayout {
        Text {
            id: buttonText
            text: root.text
            opacity: enabled ? 1.0 : 0.3
            color: "white"
            font {
                family: Fonts.franklinGothicBook
            }
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        SGIcon {
            id: icon
            Layout.preferredHeight: 20
            Layout.preferredWidth: Layout.preferredHeight
            iconColor : "white"
            visible: source !== ""
        }
    }

    background: Rectangle {
        id: backRect
        implicitWidth: 100
        implicitHeight: 40
        opacity: enabled ? 1 : 0.3
        radius: 2
        color: !root.hovered ? Theme.palette.onsemiOrange : root.pressed ? Qt.darker(Theme.palette.onsemiOrange, 1.25) : Qt.darker(Theme.palette.onsemiOrange, 1.15)
    }

    Accessible.onPressAction: function() {
        clicked()
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: mouse.accepted = false
        cursorShape: Qt.PointingHandCursor
    }
}
