import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as Filters
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Item {
    id: root
    implicitHeight: filterContainer.height + 160*2.5
    Layout.preferredWidth: listviewBackground.width
    Layout.fillWidth: false
    Layout.fillHeight: true

    Component.onCompleted: {
        // Restore previously set filters
        if (Filters.segmentFilter !== "") {
            let temp = Filters.segmentFilter
            Filters.segmentFilter = ""
            segmentFilterRow.selected(temp)
        }
        if (Filters.keywordFilter !== "") {
            filter.text = Filters.keywordFilter
        }
        if (Filters.categoryFilters.length > 0) {
            Filters.utility.categoryFiltersChanged()
        }

        Help.registerTarget(textFilterContainer, "Type here to filter platforms by keyword.", 0, "selectorHelp")
        Help.registerTarget(segmentFilterContainer, "Use this drop-down to filter platforms by segment.", 1, "selectorHelp")
    }

    SGSortFilterProxyModel {
        id: filteredPlatformListModel
        sourceModel: PlatformSelection.platformListModel
        sortEnabled: true
        invokeCustomFilter: true
        sortRole: "connection"

        property bool filteringCategory: false
        property bool filteringText: false
        property bool filteringSegment: false

        // Custom filtering functions
        function filterAcceptsRow(row) {
            var item = sourceModel.get(row)
            return in_category(item) && contains_text(item) && in_segment(item)
        }

        function in_category(item) {
            if (filteringCategory){
                for (let i = 0; i < Filters.categoryFilters.length; i++){
                    for (let j = 0; j < item.filters.count; j++){
                        if (Filters.categoryFilters[i] === item.filters.get(j).filterName) {
                            return true
                        }
                    }
                }
                return false
            } else {
                return true
            }
        }

        function contains_text(item) {
            if (filteringText){
                var keywords = item.description + " " + item.opn + " " + item.verbose_name
                if(keywords.toLowerCase().includes(filter.lowerCaseText)) {
                    return true
                } else {
                    return false
                }
            } else {
                return true
            }
        }

        function in_segment(item) {
            if (filteringSegment){
                for (let j = 0; j < item.filters.count; j++){
                    if (Filters.segmentFilter === item.filters.get(j).filterName) {
                        return true
                    }
                }
                return false
            } else {
                return true
            }
        }
    }

    Connections {
        target: Filters.utility
        onCategoryFiltersChanged: {
            if (Filters.categoryFilters.length === 0) {
                filteredPlatformListModel.filteringCategory = false
            } else {
                filteredPlatformListModel.filteringCategory = true
            }
            filteredPlatformListModel.invalidate() //re-triggers filterAcceptsRow check
        }

        onSegmentFilterChanged: {
            if (Filters.segmentFilter === "") {
                filteredPlatformListModel.filteringSegment = false
            } else {
                filteredPlatformListModel.filteringSegment = true
            }
            filteredPlatformListModel.invalidate() //re-triggers filterAcceptsRow check
        }
    }

    Rectangle {
        id: filterContainer
        anchors {
            bottom: listviewContainer.top
            horizontalCenter: listviewBackground.horizontalCenter
        }
        height: 30
        width: listviewBackground.width
        border {
            width: 1
            color: "#DDD"
        }

        Row {
            id: filterRow
            anchors {
                fill: filterContainer
            }

            Item {
                id: textFilterContainer
                height: filterContainer.height
                width: 577
                clip: true

                TextInput {
                    id: filter
                    text: ""
                    anchors {
                        verticalCenter: textFilterContainer.verticalCenter
                        left: textFilterContainer.left
                        leftMargin: 10
                        right: textFilterContainer.right
                        rightMargin: 10
                    }
                    color: "#33b13b"
                    font.bold: true
                    selectByMouse: true
                    enabled: PlatformSelection.platformListModel.platformListStatus === "loaded"

                    property string lowerCaseText: text.toLowerCase()

                    onLowerCaseTextChanged: {
                        Filters.keywordFilter = lowerCaseText
                        if (lowerCaseText === "") {
                            filteredPlatformListModel.filteringText = false
                        } else {
                            filteredPlatformListModel.filteringText = true
                        }
                        filteredPlatformListModel.invalidate() //re-triggers filterAcceptsRow check
                    }

                    Text {
                        id: placeholderText
                        text: "Filter By Keyword..."
                        color: filter.enabled? "#666" : "#ddd"
                        visible: filter.text === ""
                        anchors {
                            left: filter.left
                            verticalCenter: filter.verticalCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onPressed: mouse.accepted = false
                        cursorShape: Qt.IBeamCursor
                    }
                }

                SGIcon {
                    source: "qrc:/images/icons/times-circle-solid.svg"
                    height: parent.height * .75
                    width: height
                    anchors {
                        verticalCenter: textFilterContainer.verticalCenter
                        right: textFilterContainer.right
                        rightMargin: (textFilterContainer.height - height) / 2
                    }
                    iconColor: textFilterClearMouse.containsMouse ?  "#bbb" : "#999"
                    visible: !placeholderText.visible

                    MouseArea {
                        id: textFilterClearMouse
                        anchors.fill: parent
                        onClicked: {
                            filter.text = ""
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            Rectangle {
                id: segmentFilterContainer
                height: filterContainer.height
                width: filterRow.width - textFilterContainer.width
                border {
                    width: 1
                    color: "#DDD"
                }
                color: (segmentFilterMouse.containsMouse || segmentFilters.visible) ? "#f2f2f2" : "white"

                Text {
                    id: defaultSegmentFilterText
                    text: "Filter By Segment"
                    color: segmentFilterMouse.enabled? "#666" : "#ddd"
                    anchors {
                        left: segmentFilterContainer.left
                        leftMargin: 10
                        verticalCenter: segmentFilterContainer.verticalCenter
                    }
                }

                Text {
                    id: activeSegmentFilterText
                    color: "#33b13b"
                    font.bold: true
                    anchors {
                        left: segmentFilterContainer.left
                        leftMargin: 10
                        verticalCenter: segmentFilterContainer.verticalCenter
                        right: angleIcon.left
                    }
                    visible: !defaultSegmentFilterText.visible
                    elide: Text.ElideRight

                    Connections {
                        target: Filters.utility
                        onSegmentFilterChanged: {
                            switch (Filters.segmentFilter) {
                            case "segment-automotive":
                                activeSegmentFilterText.text = "Showing Automotive Platforms"
                                break
                            case "segment-industrial-cloud-power":
                                activeSegmentFilterText.text =  "Showing Industrial & Cloud Power Platforms"
                                break
                            default: // case "wirelessiot":
                                activeSegmentFilterText.text =  "Showing Internet of Things Platforms"
                            }
                        }
                    }
                }

                SGIcon {
                    id: angleIcon
                    source: "qrc:/images/icons/angle-down.svg"
                    iconColor: segmentFilterMouse.enabled? "#666" : "#ddd"
                    anchors {
                        verticalCenter: segmentFilterContainer.verticalCenter
                        right: segmentFilterContainer.right
                        rightMargin: 10
                    }
                    height: 20
                    width: height
                }

                MouseArea {
                    id: segmentFilterMouse
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    anchors {
                        fill: segmentFilterContainer
                    }
                    onPressed: {
                        segmentFilters.open()
                    }
                    enabled: Filters.segmentFilterModel.count > 0
                }

                Popup {
                    id: segmentFilters
                    y: segmentFilterContainer.height-1
                    width: segmentFilterContainer.width
                    height: 130
                    visible: false
                    padding: 0

                    Rectangle {
                        anchors {
                            fill: parent
                        }
                        border {
                            width: 1
                            color: "#DDD"
                        }

                        Row {
                            id: segmentFilterRow
                            anchors {
                                centerIn: parent
                            }
                            spacing: 10

                            signal selected(string filter)

                            onSelected: {
                                if (Filters.segmentFilter === filter) {
                                    Filters.segmentFilter = ""
                                    defaultSegmentFilterText.visible = true
                                } else {
                                    Filters.segmentFilter = filter
                                    defaultSegmentFilterText.visible = false
                                }
                                Filters.utility.segmentFilterChanged()
                                segmentFilters.close()
                            }

                            Repeater {
                                delegate: SegmentFilterDelegate {
                                    Component.onCompleted: {
                                        selected.connect(segmentFilterRow.selected)
                                    }
                                }

                                model: Filters.segmentFilterModel
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: listviewBackground
        color: "white"
        border {
            width: 1
            color: "#DDD"
        }
        anchors {
            centerIn: listviewContainer
        }
        width: listviewContainer.width+2
        height: listviewContainer.height+2
    }

    Item {
        id: listviewContainer
        height: root.height - filterContainer.height
        width: 950
        clip: true
        anchors {
            top: filterContainer.bottom
        }

        Image {
            id: maskTop
            height: 30
            source: "images/whiteFadeMask.svg"
            anchors {
                top: listviewContainer.top
                left: listviewContainer.left
                leftMargin: 1
                right: listviewContainer.right
                rightMargin: 1
            }
            z: 1
        }

        Image {
            id: maskBottom
            height: 30
            anchors {
                bottom: listviewContainer.bottom
                left: listviewContainer.left
                leftMargin: 1
                right: listviewContainer.right
                rightMargin: 1
            }
            source: maskTop.source
            z: 1

            transform: Rotation {
                origin.y: maskBottom.height/2
                origin.x: maskBottom.width/2
                axis { x: 1; y: 0; z: 0 }
                angle: 180
            }
        }

        ListView {
            id: listview
            anchors {
                bottom: listviewContainer.bottom
                left: listviewContainer.left
                right: listviewContainer.right
                top: listviewContainer.top
            }
            model: filteredPlatformListModel
            maximumFlickVelocity: 1200 // Limit scroll speed on Windows trackpads: https://bugreports.qt.io/browse/QTBUG-56075

            property real delegateHeight: 160
            property real delegateWidth: 950

            Component.onCompleted: {
                currentIndex = Qt.binding( function() { return PlatformSelection.platformListModel.currentIndex })
            }

            delegate: SGPlatformSelectorDelegate {
                height: listview.delegateHeight
                width: listview.delegateWidth
                isCurrentItem: ListView.isCurrentItem
            }

            highlight: highlightBar
            highlightFollowsCurrentItem: false
            ScrollBar.vertical: ScrollBar {
                width: 12
                anchors {
                    top: listview.top
                    bottom: listview.bottom
                    right: listview.right
                }
                policy: ScrollBar.AlwaysOn
                minimumSize: 0.1
                visible: listview.height < listview.contentHeight
            }

            Component {
                id: highlightBar
                Rectangle {
                    width: listview.delegateWidth
                    height: listview.delegateHeight
                    color: "#eee"
                    y: listview.currentItem ? listview.currentItem.y : 0
                }
            }

            Connections {
                target: filteredPlatformListModel
                onCountChanged: {
                    if (filteredPlatformListModel.count > 0) {
                        PlatformSelection.platformListModel.currentIndex = 0
                    }
                }
            }
        }
    }

    SGPlatformSelectorStatus {
        anchors {
            fill: root
        }
        status: PlatformSelection.platformListModel.platformListStatus
    }
}
