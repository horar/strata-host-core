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
import QtQml 2.12

import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as Filters
import "qrc:/js/help_layout_manager.js" as Help
import "qrc:/js/constants.js" as Constants
import "qrc:/js/navigation_control.js" as NavigationControl

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0
import tech.strata.sgwidgets 0.9 as SGWidgets09

Item {
    id: platformSelectorListView
    Layout.fillWidth: true
    Layout.fillHeight: true

    property alias listview: listview
    property alias model: filteredPlatformSelectorModel
    property alias filterText: filter.text
    property bool platformLoaded: PlatformSelection.platformSelectorModel.platformListStatus === "loaded"

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
        // QTBUG-46487: calling invalidate() on this model can cause warning in logs, i.e. "DelegateModel::cancel: index out range 5 4"
        // TODO: verify if problem persists once the QTBUG is fixed and close the related ticket (CS-1920)
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

            // sort listings according to following priority:
            if (listing1.connected === true && listing2.connected === false) {
                return true     // connected platforms on top
            } else if (listing1.connected === false && listing2.connected === true) {
                return false    // not connected platforms on bottom
            } else if (listing1.device_id !== Constants.NULL_DEVICE_ID &&
                       listing2.device_id === Constants.NULL_DEVICE_ID) {
                return true     // listings with a device id attached (from a previously connected board) on top
            } else if (listing1.device_id === Constants.NULL_DEVICE_ID &&
                       listing2.device_id !== Constants.NULL_DEVICE_ID) {
                return false    // listings without a device id attached on bottom
            } else if (listing1.available.documents === true && listing1.available.order === true &&
                       listing2.available.documents === false && listing2.available.order === false) {
                return true     // already available boards on top
            } else if (listing1.available.documents === false && listing1.available.order === false &&
                       listing2.available.documents === true && listing2.available.order === true) {
                return false    // "coming soon" on bottom
            } else if (timestamp1.getTime() !== timestamp2.getTime()) {
                return timestamp1 > timestamp2 // newer listings on top, older on bottom
            } else {
                return listing1.opn < listing2.opn // sort alphabetically by opn if everything else fails
            }
        }

        function in_filter(item) {
            if (activeFilters){
                // ensure item fulfills all active filters
                mainLoop: // label for continuing from nested loop
                for (let i = 0; i < Filters.activeFilters.length; i++){

                    if (Filters.activeFilters[i].startsWith("status-")) {
                        switch (Filters.activeFilters[i]) {
                        case "status-connected":
                            if (item.connected) {
                                continue mainLoop
                            } else {
                                return false
                            }
                        case "status-coming-soon":
                            if (item.coming_soon) {
                                continue mainLoop
                            } else {
                                return false
                            }
                        case "status-recently-released":
                            if (item.recently_released) {
                                continue mainLoop
                            } else {
                                return false
                            }
                        }
                    }

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

    Connections {
        id: helpConnection
        target: Help.utility
        property bool tourRunning: false

        onTour_runningChanged: {
            tourRunning = tour_running
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
            visible: platformLoaded || helpConnection.tourRunning

            RowLayout {
                id: filterRow
                anchors {
                    fill: filterContainer
                }
                spacing: 0

                Rectangle {
                    id: stateFilter // coming soon, recently released, connected
                    Layout.fillHeight: true
                    Layout.preferredWidth: 168 + 20 // matches PlatformImage + left margin
                    border {
                        width: 1
                        color: "#DDD"
                    }
                    color: (stateMouse.containsMouse || statePopup.visible) ? "#f2f2f2" : "white"

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 8
                            rightMargin: 8
                        }
                        spacing: 8

                        Text {
                            id: stateFilterText
                            text: "Filter by Status"
                            color: segmentFilterMouse.enabled? "#666" : "#ddd"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        SGIcon {
                            id: angleIcon1
                            source: "qrc:/sgimages/chevron-down.svg"
                            iconColor: stateMouse.enabled? "#666" : "#ddd"
                            height: 20
                            width: height
                        }
                    }

                    MouseArea {
                        id: stateMouse
                        anchors {
                            fill: parent
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked:  {
                            statePopup.opened ? statePopup.close() : statePopup.open()
                        }
                    }

                    Popup {
                        id: statePopup
                        width: parent.width
                        y: stateFilter.height -1
                        height: stateColumn.height + 20
                        padding: 0
                        closePolicy: Popup.CloseOnReleaseOutsideParent
                        background: Rectangle {
                            border {
                                width: 1
                                color: "#DDD"
                            }
                        }

                        ColumnLayout {
                            id: stateColumn
                            width: parent.width - 20
                            anchors {
                                centerIn: parent
                            }

                            Repeater {
                                model: ListModel {

                                    ListElement {
                                        filterName: "status-recently-released"
                                        text: "Show Recently Released"
                                        iconSource: ""
                                    }

                                    ListElement {
                                        filterName: "status-coming-soon"
                                        text: "Show Coming Soon"
                                        iconSource: ""
                                    }

                                    ListElement {
                                        filterName: "status-connected"
                                        text: "Show Connected"
                                        iconSource: ""
                                    }
                                }

                                delegate: SegmentFilterDelegate {
                                    Component.onCompleted: {
                                        selected.connect(statePopup.close)
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    id: textFilterContainer
                    Layout.fillHeight: true
                    // Layout width settings must match infoColumn in SGPlatformSelectorDelegate
                    Layout.preferredWidth: 300
                    Layout.fillWidth: true
                    clip: true

                    TextInput {
                        id: filter
                        text: ""
                        anchors {
                            verticalCenter: textFilterContainer.verticalCenter
                            left: parent.left
                            leftMargin: 10
                            right: clearIcon.left
                            rightMargin: 10
                        }
                        color: Theme.palette.onsemiOrange
                        font.bold: true
                        selectByMouse: true
                        clip: true
                        enabled: platformLoaded
                        persistentSelection: true   // must deselect manually

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

                        onActiveFocusChanged: {
                            if ((activeFocus === false) && (contextMenuPopup.visible === false)) {
                                filter.deselect()
                            }
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
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            cursorShape: Qt.IBeamCursor

                            onClicked: {
                                filter.forceActiveFocus()
                            }
                            onReleased: {
                                if (containsMouse) {
                                    contextMenuPopup.popup(null)
                                }
                            }
                        }

                        SGContextMenuEditActions {
                            id: contextMenuPopup
                            textEditor: filter
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
                    // Layout width settings must match categoryControlsRow in SGPlatformSelectorDelegate
                    Layout.fillWidth: true
                    Layout.preferredWidth: 200
                    Layout.minimumWidth: 300

                    border {
                        width: 1
                        color: "#DDD"
                    }
                    color: (segmentFilterMouse.containsMouse || segmentFilters.visible) ? "#f2f2f2" : "white"

                    Text {
                        id: defaultSegmentFilterText
                        text: "Filter by Segment or Category"
                        color: segmentFilterMouse.enabled? "#666" : "#ddd"
                        anchors {
                            left: parent.left
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
                        enabled: Filters.filterModel.count > 0
                        anchors {
                            fill: segmentFilterContainer
                        }

                        onPressed: {
                            segmentFilters.opened ? segmentFilters.close() : segmentFilters.open()
                            categoryHighlightPopup.showOn = false
                        }
                    }

                    // popup occurs once; on every user's first login
                    // intended to demonstrate that we have many categories
                    SGWidgets09.SGToolTipPopup {
                        id: categoryHighlightPopup
                        color: Qt.lighter(Theme.palette.onsemiOrange, 1.15)
                        anchors {
                            bottom: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }
                        content: Text {
                            text: "Click here to view all of our platform categories!"
                            color: "white"
                        }

                        MouseArea {
                            anchors {
                                fill: parent
                            }

                            onClicked:  {
                                parent.showOn = false
                            }
                        }

                        Component.onCompleted: {
                            if (NavigationControl.userSettings.firstLogin) {
                                categoryHighlightPopup.showOn = Qt.binding(() => (listview.count > 0))
                                NavigationControl.userSettings.firstLogin = false
                            }
                        }
                    }

                    Popup {
                        id: segmentFilters
                        y: segmentFilterContainer.height-1
                        width: segmentFilterContainer.width
                        height: Math.min(listview.height, filterColumn.height)
                        visible: false
                        padding: 0
                        closePolicy: Popup.CloseOnReleaseOutsideParent

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
