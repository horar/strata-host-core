import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

Rectangle {
    id: buttonContainer
    width: parent.width
    height: 70
    color: ListView.isCurrentItem ? "#33b13b" : "transparent"
    enabled: {
        if (index === toolBarListView.editTab
                || index === toolBarListView.viewTab) {
            if (editor.treeModel.url.toString() === "") {
                return false;
            } else if (toolBarListView.currentIndex === toolBarListView.viewTab && index === toolBarListView.viewTab && viewStack.currentIndex !== 4) {
                return false;
            }
        }
        return true;
    }

    property alias iconText: imageText.text
    property alias iconSource: tabIcon.source
    property int iconLeftMargin: 0

    function onClicked() {
        toolBarListView.currentIndex = index
    }

    ColumnLayout {
        id: iconTextGroup
        anchors.margins: 5
        anchors.fill: parent
        spacing: 2

        SGIcon {
            id: tabIcon
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredHeight: 30
            Layout.minimumHeight: 30
            // Setting left margin is to handle centering for the edit image
            Layout.leftMargin: buttonContainer.iconLeftMargin
            Layout.fillWidth: true

            // This color adds .40 alpha to white
            iconColor: parent.enabled ? "white" : Qt.rgba(255, 255, 255, 0.4)
            source: modelData.imageSource
        }

        SGText {
            id: imageText
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: paintedHeight
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter

            text: modelData.imageText
            color: tabIcon.iconColor
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: parent.enabled

        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

        onContainsMouseChanged: {
            if (containsMouse && iconTextGroup.enabled && !buttonContainer.ListView.isCurrentItem) {
                tabIcon.iconColor = Qt.darker(tabIcon.iconColor, 1.4)
            } else if (iconTextGroup.enabled) {
                tabIcon.iconColor = "white"
            }
        }

        onClicked: {
            parent.onClicked()
            tabIcon.iconColor = "white"
        }
    }
}
