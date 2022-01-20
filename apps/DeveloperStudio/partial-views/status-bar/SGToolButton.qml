/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12
import "qrc:/partial-views"

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

Rectangle {
    id: buttonRoot
    height: 30
    implicitWidth: parent.width
    color: {
        if (delegateMouse.containsMouse) {
            return Qt.lighter(Theme.palette.onsemiOrange, 1.15)
        } else if (model.selected) {
            return Qt.darker(Theme.palette.onsemiOrange, 1.15)
        } else {
            return Theme.palette.onsemiOrange
        }
    }
    clip: true
    property alias toolItem: toolItem

    Item {
        id: toolItem
        implicitWidth: parent.width
        height: 14
    }

    Accessible.name: model.text
    Accessible.role: Accessible.Button
    Accessible.selected: model.selected
    Accessible.onPressAction: {
        delegateMouse.clicked(mouse)
    }

    Rectangle {
        id: selectedSideHighlight
        color: "black"
        opacity: .15
        height: parent.height
        width: 5
        visible: model.selected
        anchors {
            right: parent.right
        }
    }

    RowLayout {
        id: row
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 0
            right: parent.right
            rightMargin: 10
        }
        spacing: 10
        height: 25

        Text {
            color: "white"
            text: model.text
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            font.family: model.selected ? Fonts.franklinGothicBold : Fonts.franklinGothicBook
            Layout.preferredHeight: font.family === Fonts.franklinGothicBold ? contentHeight : contentHeight + 2  // hack to force franklinGothicBook to vertical center
            verticalAlignment: Text.AlignBottom
        }

        SGIcon {
            id: delegateIcon
            iconColor: "white"
            height: 20
            width: 20
            source:  model.icon
        }
    }

    MouseArea {
        id: delegateMouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            platformTabRoot.menuClicked(index)
        }
    }
}
