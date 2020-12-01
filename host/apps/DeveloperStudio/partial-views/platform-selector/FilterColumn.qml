import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import "qrc:/js/platform_filters.js" as Filters
import "qrc:/js/platform_selection.js" as PlatformSelection

import tech.strata.fonts 1.0

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true

    property string side: ""
    property alias model: repeater.model
    property alias repeater: repeater
    property alias responsiveVisible: topTextContainer.visible

    Item {
        id: topTextContainer
        anchors {
            right: root.right
            left: root.left
        }
        height: topText.height + 20
        visible: model.count > 0 && leftColumn.width >= 75 // width of filter icons

        Text {
            id: topText
            text: "Filter by Category:"
            width: topTextContainer.width
            wrapMode: Text.Wrap
            anchors {
                centerIn: parent
            }
            horizontalAlignment: Text.AlignHCenter
            font.family: Fonts.franklinGothicBold
            color: "#555"
        }
    }

    ScrollView {
        anchors {
            top: topTextContainer.bottom
            right: root.right
            bottom: root.bottom
            left: root.left
        }
        width: root.width
        contentHeight: leftColumn.height
        clip: true

        Column {
            id: leftColumn
            spacing: 0
            width: root.width

            Repeater {
                id: repeater

                delegate: CategoryFilterDelegate {
                    iconSource: model.iconSource
                    text: model.text
                    visible: {
                        if (root.side === "left") {
                            return index < Filters.categoryFilterModel.count/2
                        } else {
                            return index >= Filters.categoryFilterModel.count/2
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: Filters.utility
        onCategoryFiltersChanged: {
            if (Filters.categoryFilters.length === 0) {
                for (let i = 0; i < repeater.model.count; i++){
                    repeater.itemAt(i).pressed = false
                }
            }
        }
    }
}
