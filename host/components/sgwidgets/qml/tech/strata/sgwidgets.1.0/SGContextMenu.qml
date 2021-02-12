import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Menu {
    topPadding: 8
    bottomPadding: 8

    delegate: MenuItem {
            id: menuItem
            implicitHeight: 20
            highlighted: hovered
            leftPadding: 16
            background: Rectangle {
                id: menuItemBackground
                opacity: enabled ? 1 : 0.3
                color: menuItem.highlighted ? Qt.lighter(TangoTheme.palette.selectedText, 1.5) : "transparent"
                border.color: menuItem.highlighted ? Theme.palette.gray : "transparent"
                border.width: 1
            }
    }

    background: Rectangle {
        id: contextMenuBackground
        implicitWidth: 150
        color: Theme.palette.white
        border.color: Theme.palette.gray
        border.width: 1
        radius: 4
    }
}
