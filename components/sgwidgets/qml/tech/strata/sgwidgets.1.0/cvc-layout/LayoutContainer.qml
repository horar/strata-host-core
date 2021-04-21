import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.12

// container for rows/columns api - functions as LayoutOverlay as well as base container for widgets
// contentItem is the control that fills this container

Item {
    id: layoutContainerRoot
    x: layoutInfo.xColumns * columnSize
    y: layoutInfo.yRows * rowSize
    width: layoutInfo.columnsWide * columnSize
    height: layoutInfo.rowsTall * rowSize

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

