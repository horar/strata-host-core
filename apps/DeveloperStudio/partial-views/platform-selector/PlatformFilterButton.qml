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


Button {
    id: filterButtonRoot

    onYChanged: {
        if (parent === flow) {
            model.row = Math.ceil(y/(segmentCategoryList.delegateHeight + flow.spacing))
        }
    }

    background: Rectangle {
        radius: 20
        border.width: 1
        border.color: Theme.palette.onsemiDark
        color: mouse.containsMouse ? Theme.palette.lightGray : "transparent"

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                filterButtonRoot.clicked()
            }

            ToolTip {
                delay: 1000
                visible: mouse.containsMouse
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

    onClicked: {
        PlatformFilters.setFilterActive(model.filterName, true)
    }

    contentItem: ColumnLayout {
        Item {
            id: wrapper
            Layout.preferredWidth: textMetrics.boundingRect.width > 150 ? 150 : textMetrics.boundingRect.width
            Layout.preferredHeight: textMetrics.boundingRect.height

            SGText {
                text: model.text
                fontSizeMultiplier: 0.9
                color: Theme.palette.onsemiDark
                elide: textMetrics.boundingRect.width > 150 ? Text.ElideRight : Text.ElideNone
                anchors.fill: wrapper
            }
        }
    }

    TextMetrics {
        id: textMetrics

        text: model.text
        font.pixelSize: 12
    }
}
