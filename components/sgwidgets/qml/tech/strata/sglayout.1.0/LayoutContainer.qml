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
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.12

// container for rows/columns api - functions as LayoutOverlay as well as base container for widgets
// contentItem is the control that fills this container

Item {
    id: layoutContainerRoot
    x: Math.round(layoutInfo.xColumns * columnSize)
    y: Math.round(layoutInfo.yRows * rowSize)
    width: Math.round(layoutInfo.columnsWide * columnSize)
    height: Math.round(layoutInfo.rowsTall * rowSize)

    property LayoutInfo layoutInfo: LayoutInfo { }
    property var contentItem: null

    onContentItemChanged: {
        if (contentItem) {
            contentItem.anchors.fill = layoutContainerRoot
            contentItem.parent = layoutContainerRoot
        } else {
            console.warn("ContentItem not set, LayoutContainer will not function properly:", layoutInfo.uuid)
        }
    }
}

