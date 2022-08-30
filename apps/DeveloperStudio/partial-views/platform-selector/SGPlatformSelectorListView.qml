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
import QtQuick.Layouts 1.12
import QtQml 2.12

import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as PlatformFilters
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
        if (PlatformFilters.activeFilters.length > 0) {
            PlatformFilters.utility.activeFiltersChanged()
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
        readonly property string timeFormat: "yyyy-MM-ddThh:mm:ss.zzzZ"

        // Custom filtering functions
        function filterAcceptsRow(index) {
            var listing = sourceModel.get(index)
            return in_filter(listing) && contains_text(listing) && is_visible(listing)
        }

        /*
          sort order:
          1. connected
          2. recently released
          3. coming soon
          4. alphabetically by OPN
         */
        function lessThan(indexLeft, indexRight) {
            var listingLeft = sourceModel.get(indexLeft)
            var listingRight = sourceModel.get(indexRight)

            //note: true(1) > false(0)

            if (listingLeft.connected !== listingRight.connected) {
                return listingLeft.connected > listingRight.connected
            }

            if (listingLeft.recently_released !== listingRight.recently_released) {
                return listingLeft.recently_released > listingRight.recently_released
            }

            if (listingLeft.coming_soon !== listingRight.coming_soon) {
                return listingLeft.coming_soon > listingRight.coming_soon
            }

            return listingLeft.opn < listingRight.opn
        }

        function in_filter(item) {
            if (activeFilters){
                // ensure item fulfills all active filters
                mainLoop: // label for continuing from nested loop
                for (let i = 0; i < PlatformFilters.activeFilters.length; i++){
                    if (PlatformFilters.activeFilters[i].startsWith("status-")) {
                        switch (PlatformFilters.activeFilters[i]) {
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
                        if (PlatformFilters.activeFilters[i] === item.filters.get(j).filterId) {
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
            if (filter.lowerCaseText.length && (searchCategoryText.checked || searchCategoryPartsList.checked)) {
                if (searchCategoryText.checked) {
                    if (item.description.toLowerCase().indexOf(filter.lowerCaseText) >= 0
                            || item.opn.toLowerCase().indexOf(filter.lowerCaseText) >= 0
                            || item.verbose_name.toLowerCase().indexOf(filter.lowerCaseText) >= 0) {
                        return true
                    }
                }

                if (searchCategoryPartsList.checked) {
                    for (let i = 0; i < item.parts_list.count; i++) {
                        if (item.parts_list.get(i).opn.toLowerCase().indexOf(filter.lowerCaseText) >= 0) {
                            return true
                        }
                    }
                }

                return false
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

    ListModel {
        id: statusListModel

        ListElement {
            filterId: "status-recently-released"
            name: "Show Recently Released"
        }

        ListElement {
            filterId: "status-coming-soon"
            name: "Show Coming Soon"
        }

        ListElement {
            filterId: "status-connected"
            name: "Show Connected"
        }
    }

    Connections {
        target: PlatformFilters.utility
        onActiveFiltersChanged: {
            if (PlatformFilters.activeFilters.length === 0) {
                filteredPlatformSelectorModel.activeFilters = false
            } else {
                filteredPlatformSelectorModel.activeFilters = true
            }
            filteredPlatformSelectorModel.invalidateFilter()
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
            visible: platformLoaded || Help.utility.runningTourName === "selectorHelp"

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
                    color: "white"

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
                            color: "#666"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        SGIcon {
                            id: angleIcon1
                            source: "qrc:/sgimages/chevron-down.svg"
                            iconColor: stateMouse.containsMouse || statePopup.opened ? "#444" : "#666"
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
                        y: stateFilter.height - 1

                        padding: 1
                        closePolicy: Popup.CloseOnReleaseOutsideParent
                        background: Rectangle {
                            border {
                                width: 1
                                color: "#DDD"
                            }
                        }

                        contentItem: Column {
                            id: stateColumn

                            Repeater {
                                model: statusListModel

                                delegate: Item {
                                    width: stateFilter.width - 2
                                    implicitHeight: Math.max(25, statusDelegateText.height)

                                    Rectangle {
                                        anchors.fill: parent
                                        color: statusDelegateMouseArea.containsMouse ? "#f2f2f2" : "white"
                                    }

                                    SGText {
                                        id: statusDelegateText
                                        anchors {
                                            left: parent.left
                                            leftMargin: 10
                                            right: parent.right
                                            rightMargin: 10
                                            verticalCenter: parent.verticalCenter
                                        }

                                        text: model.name
                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        id: statusDelegateMouseArea
                                        anchors {
                                            fill: parent
                                        }
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PlatformFilters.setFilterActive(model.filterId, true)
                                            statePopup.close()
                                        }
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
                            searchCategoriesDropdown.close()
                            filteredPlatformSelectorModel.invalidateFilter()
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
                        height: parent.height * .75
                        width: height
                        anchors {
                            verticalCenter: textFilterContainer.verticalCenter
                            right: settingsIcon.left
                            rightMargin: (textFilterContainer.height - height) / 2
                        }

                        source: "qrc:/sgimages/times-circle.svg"
                        iconColor: textFilterClearMouse.containsMouse ?  Theme.palette.lightGray : Theme.palette.gray
                        visible: !placeholderText.visible

                        MouseArea {
                            id: textFilterClearMouse
                            anchors.fill: parent

                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                filter.text = ""
                            }
                        }
                    }

                    SGIcon {
                        id: settingsIcon
                        height: 20
                        width: height
                        anchors {
                            verticalCenter: textFilterContainer.verticalCenter
                            right: textFilterContainer.right
                            rightMargin: (textFilterContainer.height - height) / 2
                        }

                        source: "qrc:/sgimages/chevron-down.svg"
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
                        x: -1
                        width: textFilterContainer.width+2
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
                                        filteredPlatformSelectorModel.invalidateFilter()
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
                                        filteredPlatformSelectorModel.invalidateFilter()
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

                Item {
                    id: segmentFilterContainer
                    Layout.fillHeight: true
                    // Layout width settings must match categoryControlsRow in SGPlatformSelectorDelegate
                    Layout.fillWidth: true
                    Layout.preferredWidth: 300
                    Layout.minimumWidth: 200

                    Rectangle {
                        anchors.fill: parent
                        color: "white"
                        border {
                            width: 1
                            color: "#DDD"
                        }
                    }

                    TextInput {
                        id: segmentFilterInput
                        anchors {
                            verticalCenter: segmentFilterContainer.verticalCenter
                            left: parent.left
                            leftMargin: 10
                            right: segmentClearIcon.left
                            rightMargin: 10
                        }

                        text: ""
                        color: Theme.palette.onsemiOrange
                        font.bold: true
                        selectByMouse: true
                        clip: true
                        enabled: platformLoaded
                        persistentSelection: true   // must deselect manually
                        Keys.forwardTo: segmentFilterDropdown.opened ? segmentFilterDropdown.contentItem : []
                        Keys.priority: Keys.BeforeItem

                        Keys.onDownPressed: segmentFilterDropdown.open()

                        onTextChanged: {
                            if (segmentFilterDropdown.opened === false) {
                                segmentFilterDropdown.open()
                            }
                        }

                        onActiveFocusChanged: {
                            if ((activeFocus === false) && (segmentContextMenuPopup.visible === false)) {
                                segmentFilterInput.deselect()
                            }
                        }

                        Text {
                            id: segmentPlaceholderText
                            text: "Filter by Segment or Category"
                            color: segmentFilterInput.enabled? "#666" : "#ddd"
                            visible: segmentFilterInput.text === ""
                            anchors {
                                left: segmentFilterInput.left
                                verticalCenter: segmentFilterInput.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            cursorShape: Qt.IBeamCursor

                            onClicked: {
                                segmentFilterInput.forceActiveFocus()
                            }
                            onReleased: {
                                if (containsMouse) {
                                    segmentContextMenuPopup.popup(null)
                                }
                            }
                        }

                        SGContextMenuEditActions {
                            id: segmentContextMenuPopup
                            textEditor: segmentFilterInput
                        }
                    }

                    SGIcon {
                        id: segmentClearIcon
                        height: parent.height * .75
                        width: height
                        anchors {
                            verticalCenter: segmentFilterContainer.verticalCenter
                            right: segmentDropdownIcon.left
                            rightMargin: (segmentFilterContainer.height - height) / 2
                        }

                        source: "qrc:/sgimages/times-circle.svg"
                        iconColor: segmentFilterClearMouse.containsMouse ?  Theme.palette.lightGray : Theme.palette.gray
                        visible: segmentPlaceholderText.visible === false

                        MouseArea {
                            id: segmentFilterClearMouse
                            anchors.fill: parent
                            onClicked: {
                                segmentFilterInput.text = ""
                            }
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    SGIcon {
                        id: segmentDropdownIcon
                        source: "qrc:/sgimages/chevron-down.svg"
                        height: 20
                        width: height
                        anchors {
                            verticalCenter: segmentFilterContainer.verticalCenter
                            right: segmentFilterContainer.right
                            rightMargin: (segmentFilterContainer.height - height) / 2
                        }
                        iconColor: segmentDropDownMouseArea.containsMouse || segmentFilterDropdown.opened ? "#444" : "#666"

                        MouseArea {
                            id: segmentDropDownMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                segmentFilterDropdown.opened ? segmentFilterDropdown.close() : segmentFilterDropdown.open()
                                segmentFilterInput.forceActiveFocus()
                            }
                        }
                    }

                    Popup {
                        id: segmentFilterDropdown
                        y: segmentFilterContainer.height-1
                        padding: 1
                        closePolicy: Popup.CloseOnReleaseOutsideParent | Popup.CloseOnEscape

                        background: Rectangle {
                            border {
                                width: 1
                                color: "#DDD"
                            }
                        }

                        onAboutToShow: {
                            contentItem.resetCurrentIndex();
                        }

                        contentItem: Item {
                            implicitHeight: categoryListView.height
                            implicitWidth: segmentFilterContainer.width - 2

                            Keys.onDownPressed: categoryListView.incrementCurrentIndex()
                            Keys.onUpPressed: categoryListView.decrementCurrentIndex()
                            Keys.onEnterPressed: categoryListView.addFilterId(categoryListView.currentIndex)
                            Keys.onReturnPressed: categoryListView.addFilterId(categoryListView.currentIndex)

                            function resetCurrentIndex() {
                                categoryListView.currentIndex = 0
                            }

                            SGSortFilterProxyModel {
                                id: categoryFilterModel
                                sourceModel: PlatformFilters.filterModel
                                invokeCustomLessThan: true
                                invokeCustomFilter: true

                                property string lowerCaseFilterPattern: segmentFilterInput.text.toLowerCase()
                                onLowerCaseFilterPatternChanged: {
                                    categoryFilterModel.invalidateFilter()
                                    segmentFilterDropdown.contentItem.resetCurrentIndex()
                                }

                                /*
                                  sort order:
                                  1. segment < category
                                  2. name
                                  3. filterId
                                 */
                                function lessThan(indexLeft, indexRight) {
                                    var itemLeft = sourceModel.get(indexLeft)
                                    var itemRight = sourceModel.get(indexRight)

                                    if (itemLeft.type !== itemRight.type) {
                                        return itemLeft.type === "segment"
                                    }

                                    if (itemLeft.name !== itemRight.name) {
                                        return itemLeft.name.toLowerCase() < itemRight.name.toLowerCase()
                                    }

                                    return itemLeft.filterId < itemRight.filterId
                                }

                                function filterAcceptsRow(rowIndex) {
                                    var item = PlatformFilters.filterModel.get(rowIndex)

                                    if (item.type !== "segment" && item.type !== "category") {
                                        return false
                                    }

                                    if (lowerCaseFilterPattern.length > 0 && item.name.toLowerCase().indexOf(lowerCaseFilterPattern) < 0) {
                                        return false
                                    }

                                    return true
                                }
                            }

                            ListView {
                                id: categoryListView
                                width: parent.width
                                height: Math.min(contentHeight, listview.height)

                                model: categoryFilterModel
                                clip: true
                                highlightMoveDuration: -1
                                highlightMoveVelocity: -1
                                boundsBehavior: ListView.StopAtBounds
                                section.property: "type"
                                section.criteria: ViewSection.FullString

                                ScrollBar.vertical: ScrollBar {
                                    id: verticalScrollbar

                                    policy: ScrollBar.AlwaysOn
                                    minimumSize: 0.1
                                    visible: categoryListView.height < categoryListView.contentHeight
                                }

                                header: count > 0 ? null : emptyModelComponent

                                section.delegate: Item {
                                    width: ListView.view.width
                                    height: categoryGroupText.height + 10

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Theme.palette.gray
                                    }

                                    SGText {
                                        id: categoryGroupText
                                        text: section
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

                                delegate: Item {
                                    width: ListView.view.width
                                    height: Math.max(categoryDelegateIcon.height, categoryDelegateText.height)

                                    function click() {
                                        categoryDelegateMouseArea.clicked()
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: categoryListView.currentIndex === index || categoryDelegateMouseArea.containsMouse ? "#f2f2f2" : "white"
                                    }

                                    SGIcon {
                                        id: categoryDelegateIcon
                                        width: 25
                                        height: 25
                                        anchors {
                                            left: parent.left
                                            leftMargin: 10
                                            verticalCenter: parent.verticalCenter
                                        }

                                        source: model.iconSource
                                        mipmap: true
                                        iconColor: "black"
                                        visible: model.iconSource !== ""
                                    }

                                    SGText {
                                        id: categoryDelegateText
                                        anchors {
                                            left: categoryDelegateIcon.right
                                            leftMargin: 5
                                            right: parent.right
                                            rightMargin: 10
                                            verticalCenter: parent.verticalCenter
                                        }

                                        text: highlightPatternInText(model.name, categoryFilterModel.lowerCaseFilterPattern)
                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        id: categoryDelegateMouseArea
                                        anchors {
                                            fill: parent
                                        }
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            categoryListView.currentIndex = index
                                            categoryListView.addFilterId(categoryListView.currentIndex)
                                        }
                                    }
                                }

                                Component {
                                    id: emptyModelComponent
                                    Item {
                                        width: ListView.view ? ListView.view.width : 0
                                        height: text.paintedHeight + 6

                                        SGText {
                                            id: text
                                            anchors {
                                                verticalCenter: parent.verticalCenter
                                                left: parent.left
                                                leftMargin: 5
                                                right: parent.right
                                                rightMargin: 5
                                            }

                                            text: "No segments or categories"
                                            font.italic: true
                                        }
                                    }
                                }

                                function addFilterId(index) {
                                    var sourceIndex = categoryListView.model.mapIndexToSource(index)
                                    if (sourceIndex < 0) {
                                        return
                                    }

                                    var item = categoryListView.model.sourceModel.get(sourceIndex)
                                    PlatformFilters.setFilterActive(item.filterId, true)
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
                        sourceModel: PlatformFilters.filterModel
                        filterRole: "activelyFiltering"
                        filterPattern: "true"
                        sortEnabled: false
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
                                text: model.name
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
                                        PlatformFilters.setFilterActive(model.filterId, false)
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
                boundsBehavior: Flickable.StopAtBounds
                model: filteredPlatformSelectorModel

                property real delegateHeight: 160

                delegate: SGPlatformSelectorDelegate {
                    implicitHeight: listview.delegateHeight
                    implicitWidth: listview.width - (listview.ScrollBar.vertical.width + 2)
                    isCurrentItem: ListView.isCurrentItem
                    highlightPattern: filter.lowerCaseText
                    matchName: highlightPattern.length && searchCategoryText.checked
                    matchDescription: matchName
                    matchOpn: matchName
                    matchPartList: highlightPattern.length && searchCategoryPartsList.checked
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


    function highlightPatternInText(text, pattern) {
        if (!text) {
            return ""
        }

        var pos = text.toLowerCase().indexOf(pattern)
        if (pos >= 0) {
            var txt = text
            return txt.substring(0, pos)
                    + `<font color="${Theme.palette.onsemiOrange}">`
                    + txt.substring(pos, pos + pattern.length)
                    + "</font>"
                    + txt.substring(pos + pattern.length);
        }

        return text
    }
}
