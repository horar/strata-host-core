/*
 * Copyright (c) 2018-2021 onsemi.
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

import "qrc:/js/platform_filters.js" as PlatformFilters


AbstractButton {
    id: filterButtonRoot

    onClicked: {
        PlatformFilters.setFilterActive(model.filterName, true)
    }

    background: Rectangle {
        radius: 20

        border {
            width: 1
            color: Theme.palette.onsemiDark
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onClicked: {
                filterButtonRoot.clicked()
            }

            ToolTip {
                delay: 1000
                visible: parent.containsMouse
                text: {
                    if (model.type === "category") {
                        return "Filter platforms in this category"
                    } else {
                        return "Filter platforms in this Segment"
                    }
                }
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 5
        width: textMetrics.width + 20

        SGText {
            text: model.text
            fontSizeMultiplier: 0.9
            Layout.fillWidth: true
            color: Theme.palette.onsemiDark
            elide: Text.ElideRight
            Layout.alignment: Qt.AlignHCenter
        }

        SGText {
            text: model.type
            fontSizeMultiplier: 0.5
            color: Theme.palette.onsemiDark
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            font.bold: true
        }
    }

    TextMetrics {
        id: textMetrics

        text: model.text
        font.pixelSize: 13 * 0.9
    }
}
