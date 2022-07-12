/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0

import "qrc:/js/platform_filters.js" as PlatformFilters

Rectangle {
    id: root
    implicitHeight: row.implicitHeight
    Layout.fillWidth: true
    color: mouseArea.containsMouse ? "#f2f2f2" : "white"

    property bool checked: false

    signal selected()

    function onClicked() {
        PlatformFilters.setFilterActive(model.filterId, true)
        selected()
    }

    MouseArea {
        id: mouseArea
        anchors {
            fill: parent
        }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.onClicked()
        }
    }

    RowLayout {
        id: row
        spacing: 0
        anchors {
            fill: parent
        }

        SGIcon {
            id: icon
            implicitWidth: 25
            implicitHeight: 25
            source: model.iconSource
            mipmap: true
            iconColor: "black"
            Layout.leftMargin: 20
            visible: model.iconSource !== ""
        }

        SGText {
            text: model.name
            Layout.fillWidth: true
            Layout.margins: 5
            elide: Text.ElideRight
        }
    }
}
