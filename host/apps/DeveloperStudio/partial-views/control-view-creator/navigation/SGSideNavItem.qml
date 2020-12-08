import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

Rectangle {
    id: buttonContainer

    color: toolBarListView.currentIndex === modelIndex ? "#33b13b" : "transparent"
    enabled: {
        if (modelIndex === toolBarListView.editTab
                || modelIndex === toolBarListView.viewTab) {
            if (editor.fileTreeModel.url.toString() === "") {
                return false;
            } else if (toolBarListView.currentIndex === toolBarListView.viewTab && modelIndex === toolBarListView.viewTab && viewStack.currentIndex !== 2) {
                return false;
            }
        }
        return true;
    }

    property alias iconText: imageText.text
    property alias iconSource: tabIcon.source
    property color iconColor: "white"
    property int iconLeftMargin: 0
    property int modelIndex
    property string tooltipDescription

    ToolTip.text: tooltipDescription
    ToolTip.delay: 300
    ToolTip.visible: tooltipDescription.length > 0 ? mouseArea.containsMouse : false


    function onClicked() {
        toolBarListView.currentIndex = modelIndex
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

            iconColor: {
                if (iconTextGroup.enabled) {
                    if (toolBarListView.currentIndex !== modelIndex && mouseArea.containsMouse) {
                        return Qt.darker(buttonContainer.iconColor, 1.4)
                    } else {
                        return buttonContainer.iconColor
                    }
                } else {
                    // This color adds .40 alpha to white
                    return Qt.rgba(255, 255, 255, 0.4)
                }
            }
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

        cursorShape: Qt.PointingHandCursor
        onClicked: {
            parent.onClicked()
        }
    }
}
