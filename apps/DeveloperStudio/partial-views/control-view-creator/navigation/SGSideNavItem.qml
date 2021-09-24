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
import tech.strata.theme 1.0

Rectangle {
    id: buttonContainer
    Layout.fillWidth: true
    Layout.preferredHeight: iconTextGroup.implicitHeight + 10
    color: selected ? Theme.palette.onsemiOrange : "transparent"
    enabled: editor.fileTreeModel.url.toString() !== ""

    property alias iconText: imageText.text
    property alias iconSource: tabIcon.source
    property alias iconColor: tabIcon.iconColor
    property string tooltipDescription
    property bool selected: false

    signal clicked()

    ToolTip.text: tooltipDescription
    ToolTip.delay: 300
    ToolTip.visible: tooltipDescription.length > 0 && mouseArea.containsMouse

    ColumnLayout {
        id: iconTextGroup
        width: parent.width - 10
        anchors.centerIn: parent
        spacing: 2
        opacity: (iconTextGroup.enabled && mouseArea.containsMouse === false) ? 1 : .5

        SGIcon {
            id: tabIcon
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 35
            Layout.preferredWidth: 35
            iconColor: "white"
            source: modelData.imageSource
        }

        SGText {
            id: imageText
            Layout.preferredHeight: paintedHeight
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            fontSizeMultiplier: .8
            text: modelData.imageText
            color: tabIcon.iconColor
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            parent.clicked()
        }
    }
}
