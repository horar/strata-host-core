import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as Filters
import "qrc:/js/help_layout_manager.js" as Help
import "qrc:/js/constants.js" as Constants

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

Item {
    id: platformSelectorListView
    Layout.fillWidth: true
    Layout.fillHeight: true

    property alias listview: listview
    property alias model: filteredPlatformSelectorModel
    property alias filterText: filter.text

    function setSegmentCategoryWidth(width) {
        segmentFilterContainer.Layout.preferredWidth = width
    }

    Component.onCompleted: {
        // Restore previously set filters
        if (Filters.keywordFilter !== "") {
            filter.text = Filters.keywordFilter
        }
        if (Filters.activeFilters.length > 0) {
            Filters.utility.activeFiltersChanged()
        }

        Help.registerTarget(textFilterContainer, "Type here to filter platforms by keyword.", 0, "selectorHelp")
        Help.registerTarget(segmentFilterContainer, "Use this drop-down to filter platforms by segment.", 1, "selectorHelp")
    }

    SGSortFilterProxyModel {
        id: filteredPlatformSelectorModel
        sourceModel: PlatformSelection.platformSelectorModel
        sortEnabled: true
        invokeCustomFilter: true
        invokeCustomLessThan: true

        property bool activeFilters: false
        property bool filteringText: false
        readonly property string timeFormat: "yyyy-MM-ddThh:mm:ss.zzzZ"

        // Custom filtering functions
        function filterAcceptsRow(index) {
            var listing = sourceModel.get(index)
            return in_filter(listing) && contains_text(listing) && is_visible(listing)
        }

        function lessThan(index1, index2) {
            var listing1 = sourceModel.get(index1)
            var listing2 = sourceModel.get(index2)

            let timestamp1 = Date.fromLocaleString(Qt.locale(), listing1.timestamp, timeFormat);
            let timestamp2 = Date.fromLocaleString(Qt.locale(), listing2.timestamp, timeFormat);

            // sort listings according to following comment priority:
            return listing1.connected ||  // connected platforms on top
                    (listing1.device_id !== Constants.NULL_DEVICE_ID && !listing2.connected) || // listings with a device id attached (from a previously connected board) on top
                    (!listing2.available.documents && !listing2.available.order) || // "coming soon" on bottom
                    timestamp1 > timestamp2 // newer listings on top
        }

        function in_filter(item) {
            if (activeFilters){
                // ensure item fulfills all active filters
                mainLoop: // label for continuing from nested loop
                for (let i = 0; i < Filters.activeFilters.length; i++){
                    for (let j = 0; j < item.filters.count; j++){
                        if (Filters.activeFilters[i] === item.filters.get(j).filterName) {
                            continue mainLoop
                        }

                        if (j === item.filters.count - 1) {
                            return false
                        }
                    }
                }
            }
            return true
        }

        function contains_text(item) {
            if (filteringText && (searchCategoryText.checked || searchCategoryPartsList.checked)){
                let found = false

                if (searchCategoryText.checked === true) {
                    let replaceIdx = item.description.toLowerCase().indexOf(filter.lowerCaseText)
                    if (replaceIdx > -1) {
                        found = true;
                    }

                    item.desc_matching_index = replaceIdx

                    replaceIdx = item.opn.toLowerCase().indexOf(filter.lowerCaseText)
                    if (replaceIdx > -1) {
                        found = true
                    }
                    item.opn_matching_index = replaceIdx

                    replaceIdx = item.verbose_name.toLowerCase().indexOf(filter.lowerCaseText)
                    if (replaceIdx > -1) {
                        found = true
                    }
                    item.name_matching_index = replaceIdx
                }

                if (searchCategoryPartsList.checked === true) {
                    for (let i = 0; i < item.parts_list.count; i++) {
                        let idxMatched = item.parts_list.get(i).opn.toLowerCase().indexOf(filter.lowerCaseText);
                        if (idxMatched !== -1) {
                            found = true
                        }
                        item.parts_list.set(i, {
                            opn: item.parts_list.get(i).opn,
                            matchingIndex: idxMatched
                        });
                    }
                }
                return found
            } else {
                return true
            }
        }

        function is_visible(item) {
            if (item.visible) {
                if (item.available.unlisted){
                    return false
                } else {
                    return true
                }
            } else {
                return false
            }
        }
    }

    Connections {
        target: Filters.utility
        onActiveFiltersChanged: {
            if (Filters.activeFilters.length === 0) {
                filteredPlatformSelectorModel.activeFilters = false
            } else {
                filteredPlatformSelectorModel.activeFilters = true
            }
            filteredPlatformSelectorModel.invalidate() //re-triggers filterAcceptsRow check
        }

        onKeywordFilterChanged: {
            platformSelectorListView.filterText = ""
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
        }

        Rectangle {
            id: filterContainer
            Layout.fillWidth: true
            implicitHeight: 30
            border {
                width: 1
                color: "#DDD"
            }

            RowLayout {
                id: filterRow
                anchors {
                    fill: filterContainer
                }
                spacing: 0

                Item {
                    id: textFilterContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true

                    SGIcon {
                        id: searchIcon
                        source: "qrc:/sgimages/zoom.svg"
                        height: filter.height * .75
                        width: height
                        iconColor: "#666"
                        anchors {
                            left: textFilterContainer.left
                            leftMargin: 10
                            verticalCenter: textFilterContainer.verticalCenter
                        }
                    }

                    TextInput {
                        id: filter
                        text: ""
                        anchors {
                            verticalCenter: textFilterContainer.verticalCenter
                            left: searchIcon.right
                            leftMargin: 5
                            right: clearIcon.left
                            rightMargin: 10
                        }
                        color: Theme.palette.green
                        font.bold: true
                        selectByMouse: true
                        clip: true
                        enabled: PlatformSelection.platformSelectorModel.platformListStatus === "loaded"

                        property string lowerCaseText: text.toLowerCase()

                        onLowerCaseTextChanged: {
                            Filters.keywordFilter = lowerCaseText
                            searchCategoriesDropdown.close()
                            if (lowerCaseText === "") {
                                filteredPlatformSelectorModel.filteringText = false
                            } else {
                                filteredPlatformSelectorModel.filteringText = true
                            }
                            filteredPlatformSelectorModel.invalidate() //re-triggers filterAcceptsRow check
                        }


                        Text {
                            id: placeholderText
                            text: {
                                if (searchCategoryText.checked) {
                                    if (searchCategoryPartsList.checked) {
                                        return "Filter by Titles, Descriptions, and Part Numbers..."
                                    }
                                    return "Filter by Titles and Descriptions..."
                                } else if (searchCategoryPartsList.checked) {
                                    return "Filter by Part Numbers in Bill of Materials..."
                                } else {
                                    return "Please Select Search Options Below..."
                                }
                            }
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
                            acceptedButtons: Qt.NoButton
                            cursorShape: Qt.IBeamCursor
                        }
                    }

                    SGIcon {
                        id: clearIcon
                        source: "qrc:/sgimages/times-circle.svg"
                        height: parent.height * .75
                        width: height
                        anchors {
                            verticalCenter: textFilterContainer.verticalCenter
                            right: settingsIcon.left
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

                    SGIcon {
                        id: settingsIcon
                        source: "qrc:/sgimages/chevron-down.svg"
                        height: 20
                        width: height
                        anchors {
                            verticalCenter: textFilterContainer.verticalCenter
                            right: textFilterContainer.right
                            rightMargin: (textFilterContainer.height - height) / 2
                        }
                        iconColor: cogMouse.containsMouse || searchCategoriesDropdown.opened ? "#444" : "#666"

                        MouseArea {
                            id: cogMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                searchCategoriesDropdown.opened ? searchCategoriesDropdown.close() : searchCategoriesDropdown.open()
                            }
                        }
                    }

                    Popup {
                        id: searchCategoriesDropdown

                        y: textFilterContainer.height-1
                        width: textFilterContainer.width+1
                        topPadding: 0
                        bottomPadding: 0
                        leftPadding: 5

                        closePolicy: Popup.CloseOnReleaseOutsideParent

                        background: Rectangle {
                            border {
                                width: 1
                                color: "#DDD"
                            }
                        }

                        contentItem: Column {
                            id: checkboxCol
                            anchors.fill: parent

                            RowLayout {
                                CheckBox {
                                    id: searchCategoryText
                                    checked: true
                                    enabled: searchCategoryPartsList.checked

                                    onCheckedChanged: {
                                        filteredPlatformSelectorModel.invalidate() //re-triggers filterAcceptsRow check
                                    }
                                }

                                SGText {
                                    id: titlesDescriptions
                                    text: qsTr("Titles and Descriptions")
                                }
                            }

                            RowLayout {
                                CheckBox {
                                    id: searchCategoryPartsList
                                    checked: true
                                    enabled: searchCategoryText.checked

                                    onCheckedChanged: {
                                        filteredPlatformSelectorModel.invalidate() //re-triggers filterAcceptsRow check
                                    }
                                }

                                SGText {
                                    id: partNumbers
                                    text: qsTr("Part Numbers in Bill of Materials")
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: segmentFilterContainer
                    Layout.fillHeight: true
                    Layout.preferredWidth: 0 // set by setSegmentCategoryWidth()
                    border {
                        width: 1
                        color: "#DDD"
                    }
                    color: (segmentFilterMouse.containsMouse || segmentFilters.visible) ? "#f2f2f2" : "white"

                    SGIcon {
                        id: filterIcon
                        source: "qrc:/sgimages/funnel.svg"
                        height: filter.height * .75
                        width: height
                        iconColor: "#666"
                        anchors {
                            left: segmentFilterContainer.left
                            leftMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        id: defaultSegmentFilterText
                        text: "Filter by Segment or Category"
                        color: segmentFilterMouse.enabled? "#666" : "#ddd"
                        anchors {
                            left: filterIcon.right
                            leftMargin: 10
                            verticalCenter: segmentFilterContainer.verticalCenter
                        }
                    }

                    SGIcon {
                        id: angleIcon
                        source: "qrc:/sgimages/chevron-down.svg"
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
                        enabled: Filters.filterModel.count > 0
                    }

                    Popup {
                        id: segmentFilters
                        y: segmentFilterContainer.height-1
                        width: segmentFilterContainer.width
                        height: Math.min(listview.height, filterColumn.height)
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

                            ScrollView {
                                id: filterScroll
                                anchors {
                                    fill: parent
                                    margins: 1
                                }
                                clip: true

                                ColumnLayout {
                                    id: filterColumn
                                    width: filterScroll.width
                                    spacing: 0

                                    signal selected()

                                    onSelected: {
                                        segmentFilters.close()
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: segmentTitle.implicitHeight + 10
                                        Layout.bottomMargin: 3
                                        color: Theme.palette.gray

                                        SGText {
                                            id: segmentTitle
                                            text: "Segments:"
                                            color: "white"
                                            anchors {
                                                verticalCenter: parent.verticalCenter
                                                left: parent.left
                                                leftMargin: 5
                                            }
                                            font.capitalization: Font.AllUppercase
                                            fontSizeMultiplier: .8
                                        }
                                    }

                                    Repeater {
                                        id: segmentFilterRepeater
                                        model: SGSortFilterProxyModel {
                                            sourceModel: Filters.filterModel
                                            invokeCustomFilter: true

                                            function filterAcceptsRow(index) {
                                                let item = sourceModel.get(index)
                                                return item.type === "segment"
                                            }
                                        }

                                        delegate: SegmentFilterDelegate {
                                            Component.onCompleted: {
                                                selected.connect(filterColumn.selected)
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: categoryTitle.implicitHeight + 10
                                        Layout.topMargin: 8
                                        Layout.bottomMargin: 3
                                        color: Theme.palette.gray

                                        SGText {
                                            id: categoryTitle
                                            text: "Categories:"
                                            color: "white"
                                            anchors {
                                                verticalCenter: parent.verticalCenter
                                                left: parent.left
                                                leftMargin: 5
                                            }
                                            font.capitalization: Font.AllUppercase
                                            fontSizeMultiplier: .8
                                        }
                                    }

                                    Repeater {
                                        id: categoryFilterRepeater
                                        model: SGSortFilterProxyModel {
                                            sourceModel: Filters.filterModel
                                            invokeCustomFilter: true

                                            function filterAcceptsRow(index) {
                                                let item = sourceModel.get(index)
                                                return item.type === "category"
                                            }
                                        }

                                        delegate: SegmentFilterDelegate {
                                            Component.onCompleted: {
                                                selected.connect(filterColumn.selected)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            visible: implicitHeight > 0
            implicitHeight: filterFlow.implicitHeight

            Behavior on implicitHeight {
                NumberAnimation { duration: 100 }
            }

            Flow {
                id: filterFlow
                spacing: 5
                width: parent.width

                SGText {
                    text: "Active Filters:"
                    height: 22 // activeFilterRepeater delegate height
                    verticalAlignment: Text.AlignVCenter
                    visible: activeFilterRepeater.model.count > 0
                }

                Repeater {
                    id: activeFilterRepeater
                    model: SGSortFilterProxyModel {
                        sourceModel: Filters.filterModel
                        invokeCustomFilter: true

                        function filterAcceptsRow (index) {
                            let item = sourceModel.get(index)
                            return item.activelyFiltering
                        }
                    }

                    delegate: Rectangle {
                        radius: height/2
                        implicitHeight: filterNameRow.implicitHeight + 4
                        implicitWidth: filterNameRow.implicitWidth + 4
                        color: Theme.palette.darkGray

                        RowLayout {
                            id: filterNameRow
                            anchors {
                                centerIn: parent
                            }

                            SGText {
                                text: model.text
                                color: "white"
                                Layout.leftMargin: 5
                            }

                            SGIcon {
                                id: filterDeleter
                                source: "qrc:/sgimages/times-circle.svg"
                                implicitHeight: 18
                                implicitWidth: 18
                                iconColor: "white"

                                MouseArea {
                                    id: mouse
                                    anchors {
                                        fill: parent
                                    }
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked:  {
                                        Filters.setFilterActive(model.filterName, false)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true

            ListView {
                id: listview
                anchors {
                    fill: parent
                }
                maximumFlickVelocity: 1200 // Limit scroll speed on Windows trackpads: https://bugreports.qt.io/browse/QTBUG-56075
                clip: true
                highlightFollowsCurrentItem: false
                model: filteredPlatformSelectorModel

                property real delegateHeight: 160

                delegate: SGPlatformSelectorDelegate {
                    implicitHeight: listview.delegateHeight
                    implicitWidth: listview.width - (listview.ScrollBar.vertical.width + 2)
                    isCurrentItem: ListView.isCurrentItem
                }

                highlight: Rectangle {
                    width: listview.width - (listview.ScrollBar.vertical.width + 2)
                    height: listview.delegateHeight
                    color: "#eee"
                    y: listview.currentItem ? listview.currentItem.y : 0
                }

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

                Component.onCompleted: {
                    currentIndex = Qt.binding( function() { return PlatformSelection.platformSelectorModel.currentIndex })
                }

                Connections {
                    target: filteredPlatformSelectorModel
                    onCountChanged: {
                        if (filteredPlatformSelectorModel.count > 0) {
                            PlatformSelection.platformSelectorModel.currentIndex = 0
                        }
                    }
                }
            }
        }
    }

    SGPlatformSelectorStatus {
        anchors {
            fill: platformSelectorListView
        }
        status: PlatformSelection.platformSelectorModel.platformListStatus
    }
}
