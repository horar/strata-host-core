import QtQuick 2.12

Item {
    height: listView.height
    width: 450

    ListView {
        id: listView
        width: parent.width
        height: Math.min(contentHeight, mainWindow.height - statusBarContainer.height - anchors.bottomMargin - 20) // This sets the height to be a max of the window height - status bar height - the bottom margin - 20 for top margin padding
        model: Notifications
        delegate: NotificationDelegate { modelIndex: index }
        verticalLayoutDirection: ListView.BottomToTop
    }
}
